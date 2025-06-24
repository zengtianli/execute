#!/bin/bash
# 文件路径
ESSENTIAL_APPS="$HOME/Desktop/essential_apps.txt"
RUNNING_APPS="$HOME/Desktop/running_apps.txt"

# 先执行 list_app.sh 获取当前运行的应用程序列表
echo "正在获取当前运行的应用程序列表..."
# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
# 执行 list_applications.sh 脚本
"$SCRIPT_DIR/list_applications.sh"

# 检查文件是否存在
if [ ! -f "$ESSENTIAL_APPS" ]; then
    echo "错误: 文件 $ESSENTIAL_APPS 不存在"
    exit 1
fi

if [ ! -f "$RUNNING_APPS" ]; then
    echo "错误: 文件 $RUNNING_APPS 不存在"
    exit 1
fi

# 创建临时文件以存储清理后的应用列表
TEMP_ESSENTIAL=$(mktemp)
TEMP_RUNNING=$(mktemp)

# 清理文件内容（移除标题、空行和其他非应用行）
# 使用 grep "\.app$" 只匹配以 .app 结尾的行
grep "\.app$" "$ESSENTIAL_APPS" | grep -v "^==" | sed 's/^[0-9]* //g' | sort > "$TEMP_ESSENTIAL"
grep "\.app$" "$RUNNING_APPS" | grep -v "^==" | sed 's/^[0-9]* //g' | sort > "$TEMP_RUNNING"

# 查找需要打开的应用程序
echo "以下应用程序将被启动:"
while IFS= read -r app; do
    # 检查应用程序是否已经在运行
    if ! grep -q "^${app}$" "$TEMP_RUNNING"; then
        echo "启动: $app"
        
        # 构建完整的应用程序路径并尝试打开
        if [ -d "/Applications/$app" ]; then
            # 如果应用在主应用程序文件夹中
            open "/Applications/$app"
        elif [ -d "$HOME/Applications/$app" ]; then
            # 如果应用在用户的应用程序文件夹中
            open "$HOME/Applications/$app"
        elif [ -d "/System/Applications/$app" ]; then
            # 如果应用在系统应用程序文件夹中
            open "/System/Applications/$app"
        else
            # 尝试使用open命令直接打开应用的名称（不带.app）
            APP_NAME=$(echo "$app" | sed 's/\.app$//')
            open -a "$APP_NAME" || echo "无法找到应用: $app"
        fi
        
        # 等待一小段时间，以避免同时打开太多应用程序
        sleep 1
    fi
done < "$TEMP_ESSENTIAL"

# 清理临时文件
rm "$TEMP_ESSENTIAL" "$TEMP_RUNNING"

echo "完成!"