-- Run once in your own Supabase project's SQL Editor.
create extension if not exists pgcrypto with schema extensions;
create table if not exists public.baoli_families (
 token_hash text primary key,
 data jsonb not null,
 version integer not null default 1,
 updated_at timestamptz not null default now()
);
alter table public.baoli_families enable row level security;
revoke all on public.baoli_families from anon, authenticated;

create or replace function public.baoli_check(p_token text, p_data jsonb default null) returns void
language plpgsql set search_path = '' as $$
begin
 if p_token is null or p_token !~ '^[a-f0-9]{64}$' then raise exception 'Invalid family code'; end if;
 if p_data is not null and (pg_column_size(p_data)>1000000 or coalesce(jsonb_typeof(p_data->'dogs'),'') <> 'array' or coalesce(jsonb_array_length(p_data->'dogs'),0) not between 1 and 100) then raise exception 'Invalid records'; end if;
end; $$;

create or replace function public.baoli_create(p_token text,p_data jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare row public.baoli_families;
begin
 perform public.baoli_check(p_token,p_data);
 insert into public.baoli_families(token_hash,data) values(encode(extensions.digest(p_token,'sha256'),'hex'),p_data) returning * into row;
 return jsonb_build_object('data',row.data,'version',row.version,'accepted',true);
end; $$;
create or replace function public.baoli_read(p_token text) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare row public.baoli_families;
begin
 perform public.baoli_check(p_token);
 select * into row from public.baoli_families where token_hash=encode(extensions.digest(p_token,'sha256'),'hex');
 if not found then raise exception 'Family not found'; end if;
 return jsonb_build_object('data',row.data,'version',row.version);
end; $$;
create or replace function public.baoli_write(p_token text,p_version integer,p_data jsonb) returns jsonb
language plpgsql security definer set search_path = '' as $$
declare row public.baoli_families;
begin
 perform public.baoli_check(p_token,p_data);
 update public.baoli_families set data=p_data,version=version+1,updated_at=now() where token_hash=encode(extensions.digest(p_token,'sha256'),'hex') and version=p_version returning * into row;
 if not found then
  return public.baoli_read(p_token)||jsonb_build_object('accepted',false);
 end if;
 return jsonb_build_object('data',row.data,'version',row.version,'accepted',true);
end; $$;
revoke all on function public.baoli_check(text,jsonb) from public;
revoke all on function public.baoli_create(text,jsonb) from public;
revoke all on function public.baoli_read(text) from public;
revoke all on function public.baoli_write(text,integer,jsonb) from public;
grant execute on function public.baoli_create(text,jsonb) to anon;
grant execute on function public.baoli_read(text) to anon;
grant execute on function public.baoli_write(text,integer,jsonb) to anon;
