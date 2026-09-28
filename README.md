# N1 OpenWrt · OpenClash

基于 [nantayo/N1-OpenWrt](https://github.com/nantayo/N1-OpenWrt)（起始提交 `fff00309065fd8722814c8d94b5cb8d966fd83f1`）改造，适用于斐讯 N1 旁路由。

- ImmortalWrt `openwrt-25.12`，ARM64，ophub 打包，flippy 6.12 系列内核。
- daed 替换为 [OpenClash](https://github.com/vernesong/OpenClash)，预装官方 ARM64 Meta 内核。
- 去除 Docker、Podman、容器管理界面及容器运行时。
- 保留 PassWall、Samba4 和 luci-app-amlogic，不添加 PPPoE 或 Wi-Fi 功能。

## 在线编译

1. 打开本仓库的 **Actions → Build N1 OpenClash → Run workflow**。
2. 选择 `master`，点击 **Run workflow**。编译及镜像打包可能需要数小时。
3. 成功后，从 **Releases** 下载 `.img.gz` 固件和 `sha256sums`；Actions 中也保留 7 天的固件与诊断附件。

工作流仅手动触发，不会在每次提交后自动编译，也不会定期删除已有 Release。使用内置 `GITHUB_TOKEN`，无需配置个人 Token。如果组织策略禁止 Actions 写入仓库，需要管理员允许工作流的 `contents: write` 权限后才能发布 Release。

配置和产物包清单都会检查 OpenClash 是否存在、daed 和容器软件是否被意外选中；检查失败将终止构建。每次构建记录各上游源码提交以及 Meta 内核 SHA256，随固件发布。上游软件会持续变化，因此后续构建仍可能需要适配。

## 首次使用

- 管理地址：`192.168.2.2`；上级网关：`192.168.2.1`（请按自己的网络调整）。
- 使用全新配置刷写，避免恢复原版中的 daed 或容器设置。
- OpenClash 默认关闭。进入“服务 → OpenClash”，导入自己的订阅或配置，确认 Meta 内核后再启用。
- 保留的 PassWall 作为备选，不要同时开启两个透明代理服务。
- 在线更新指向当前构建仓库，匹配 `N1-OpenClash` 标签和 `.img.gz` 文件；分叉本项目后，工作流会自动替换为新仓库地址。
- 生成镜像不代表已经通过 N1 实机测试；首次使用请保留可恢复的原固件。

## 配置入口

| 文件 | 用途 |
| --- | --- |
| `.github/workflows/armsr_armv8.yml` | 编译、配置检查、打包、附件与 Release |
| `armsr/armv8/N1/.config` | 固件组件选择 |
| `armsr/armv8/diy/diy.sh` | 第三方插件及 OpenClash Meta 内核 |
| `armsr/armv8/N1/files/` | 网络与首次启动配置 |

`mk_s905d_n1.sh` 是保留的上游历史打包脚本，已去除 Docker 专属配置调用；当前 Actions 使用 ophub 打包流程，不执行此文件。

## 致谢

[nantayo](https://github.com/nantayo/N1-OpenWrt)、[ImmortalWrt](https://github.com/immortalwrt/immortalwrt)、[OpenClash](https://github.com/vernesong/OpenClash)、[OpenWrt PassWall](https://github.com/Openwrt-Passwall/openwrt-passwall)、[ophub](https://github.com/ophub/amlogic-s9xxx-openwrt) 和 flippy。各上游组件的许可归其原作者所有。
