# 宝莉和它的小宝宝 · 安卓1.5 家庭同步

[下载新版 APK](https://github.com/zqy952287863-svg/MY-Codex-project/raw/refs/heads/paw-app-download-v1.5/app-download/baoli-babies-v1.5.apk)

新增夫妻两台手机共用家庭记录：保存后上传、打开时拉取、前台约10秒检查、离线保留待传、不同记录合并和同一条记录冲突确认。APP关闭时不后台运行，下次打开更新。

**需要先开通自己的 Supabase 云项目，安装包本身不会自动开通。** [一次性设置说明](cloud/README.md) · [建库SQL](cloud/supabase.sql)。一台建立家庭，另一台粘贴家庭码加入，此后不用重复录入。APK不包含家庭访问凭据。

同签名覆盖更新，原本机数据保留。升级和加入家庭前先备份。客户端、两份独立浏览器模拟及 PostgreSQL 权限和版本写入检查通过；实际云项目与安卓真机同步尚待开通后验证。
