property helperName : "微信双开助手"
property originalApp : "/Applications/WeChat.app"
property cloneApp : "/Applications/WeChat2.app"
property cloneBundleId : "com.tencent.xinWeChat2"

on run
	set noticeText to "使用前请注意：" & return & return & "1. 这台电脑必须先安装官方微信到“应用程序”文件夹。" & return & return & "2. 第一次打开本助手时，macOS 可能会提示无法验证开发者。请在访达里右键点击本助手，再选择“打开”。" & return & return & "3. 微信大版本更新后，如果第二个微信失效，请再次运行本助手进行修复。" & return & return & "点击继续后，本助手会检查或创建 WeChat2.app，并尝试打开两个微信。"
	try
		display dialog noticeText buttons {"取消", "我知道了，继续"} default button "我知道了，继续" cancel button "取消" with title helperName with icon note
	on error number -128
		return
	end try
	
	try
		do shell script "test -d " & quoted form of originalApp
	on error
		display dialog "没有找到 /Applications/WeChat.app。请先把官方微信安装到“应用程序”文件夹。" buttons {"好"} default button "好" with icon stop
		return
	end try
	
	set repairNeeded to my needsRepair()
	if repairNeeded is "1" then
		try
			my repairClone()
		on error errMsg number errNo
			display dialog "创建或修复 WeChat2.app 失败：" & return & return & errMsg buttons {"好"} default button "好" with icon stop
			return
		end try
	end if
	
	try
		my launchBoth()
	on error errMsg number errNo
		display dialog "启动微信失败：" & return & return & errMsg buttons {"好"} default button "好" with icon stop
		return
	end try
	
	display notification "已尝试打开两个微信。" with title helperName
end run

on needsRepair()
	set checkScript to "set -e
CLONE=/Applications/WeChat2.app
if [ ! -d \"$CLONE\" ]; then
  echo 1
  exit 0
fi
if [ ! -x \"$CLONE/Contents/MacOS/WeChat\" ]; then
  echo 1
  exit 0
fi
ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' \"$CLONE/Contents/Info.plist\" 2>/dev/null || true)
if [ \"$ID\" != \"com.tencent.xinWeChat2\" ]; then
  echo 1
  exit 0
fi
if ! /usr/bin/codesign -dv \"$CLONE\" 2>&1 | /usr/bin/grep -q 'Identifier=com.tencent.xinWeChat2'; then
  echo 1
  exit 0
fi
echo 0"
	return do shell script checkScript
end needsRepair

on repairClone()
	set repairScript to "set -e
ORIGINAL=/Applications/WeChat.app
CLONE=/Applications/WeChat2.app
if [ ! -d \"$CLONE\" ]; then
  /bin/cp -R \"$ORIGINAL\" \"$CLONE\"
fi
/usr/libexec/PlistBuddy -c 'Set :CFBundleIdentifier com.tencent.xinWeChat2' \"$CLONE/Contents/Info.plist\"
/usr/libexec/PlistBuddy -c 'Set :CFBundleName WeChat2' \"$CLONE/Contents/Info.plist\" 2>/dev/null || true
/usr/libexec/PlistBuddy -c 'Set :CFBundleDisplayName WeChat2' \"$CLONE/Contents/Info.plist\" 2>/dev/null || true
/usr/bin/codesign --force --deep --sign - \"$CLONE\"
/usr/bin/xattr -dr com.apple.quarantine \"$CLONE\" 2>/dev/null || true"
	do shell script repairScript with administrator privileges
end repairClone

on launchBoth()
	set launchScript to "set -e
/usr/bin/open /Applications/WeChat.app
/bin/sleep 2
/usr/bin/open /Applications/WeChat2.app
/bin/sleep 2
if ! /usr/bin/pgrep -f '/Applications/WeChat2.app/Contents/MacOS/WeChat' >/dev/null; then
  /usr/bin/nohup /Applications/WeChat2.app/Contents/MacOS/WeChat >/tmp/wechat2-launcher.log 2>&1 &
fi"
	do shell script launchScript
end launchBoth
