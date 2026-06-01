# 微信双开助手

一个用于 macOS 的微信双开小工具。双击后会检查官方微信和 `WeChat2.app`，必要时自动复制、修改 Bundle ID、重新签名，然后打开两个微信。

## 下载使用

1. 先安装官方微信到 `/Applications/WeChat.app`。
2. 下载 `微信双开助手.zip`，解压后双击 `微信双开助手.app`。
3. 第一次打开如果 macOS 提示无法验证开发者，请在访达中右键点击应用，选择“打开”。
4. 首次创建或修复 `WeChat2.app` 时，系统会要求输入管理员密码。

## 工作原理

助手会在 `/Applications` 下创建或修复一个微信副本：

- 原版：`/Applications/WeChat.app`
- 副本：`/Applications/WeChat2.app`
- 副本 Bundle ID：`com.tencent.xinWeChat2`

修复时主要执行：

```bash
cp -R /Applications/WeChat.app /Applications/WeChat2.app
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier com.tencent.xinWeChat2' /Applications/WeChat2.app/Contents/Info.plist
codesign --force --deep --sign - /Applications/WeChat2.app
```

之后用 macOS 的 `open` 命令打开两个应用。

## 从源码构建

```bash
./build.sh
```

构建完成后会生成：

- `微信双开助手.app`
- `微信双开助手.zip`

## 注意事项

- 这个工具只处理 macOS 版微信。
- 微信大版本更新后，如果第二个微信无法打开，重新运行本助手即可修复。
- 本项目没有绕过微信账号限制，只是让 macOS 同时启动两个独立 Bundle ID 的微信应用副本。

## 许可证

MIT
