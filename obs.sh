#!/bin/bash
CURRENT_DIR=$(pwd)
OBSIDIAN_CONFIG="$HOME/Library/Application Support/obsidian/obsidian.json"

# 检查是否已经是保管库
if [ -d "$CURRENT_DIR/.obsidian" ]; then
    # 检查是否已在 obsidian.json 中注册
    if grep -q "\"path\":\"$CURRENT_DIR\"" "$OBSIDIAN_CONFIG"; then
        # 如果已注册，直接打开
        echo "保管库已注册，直接打开..."
        open "obsidian://open?path=$(echo $CURRENT_DIR | sed 's/ /%20/g')"
    else
        # 如果是保管库但未注册，直接修改配置文件注册
        echo "保管库未注册，正在注册..."
        
        # 生成唯一ID (16位十六进制字符)
        VAULT_ID=$(openssl rand -hex 8)
        
        # 读取现有配置
        CONFIG_CONTENT=$(cat "$OBSIDIAN_CONFIG")
        
        # 检查是否已有保管库
        if [[ "$CONFIG_CONTENT" == *"\"vaults\":"* ]]; then
            # 已有保管库，添加新保管库
            NEW_CONFIG=$(echo "$CONFIG_CONTENT" | sed -E "s/(\"vaults\":[[:space:]]*\{)/\1\"$VAULT_ID\":{\"path\":\"$CURRENT_DIR\",\"ts\":$(date +%s)000},/")
        else
            # 没有保管库，创建新的保管库部分
            NEW_CONFIG="{\"vaults\":{\"$VAULT_ID\":{\"path\":\"$CURRENT_DIR\",\"ts\":$(date +%s)000}}}"
        fi
        
        # 写入新配置
        echo "$NEW_CONFIG" > "$OBSIDIAN_CONFIG"
        
        # 打开保管库
        echo "保管库已注册，正在打开..."
        open "obsidian://open?path=$(echo $CURRENT_DIR | sed 's/ /%20/g')"
    fi
else
    # 如果不是保管库，先创建基本结构
    echo "目录不是 Obsidian 保管库，正在创建基本结构..."
    mkdir -p "$CURRENT_DIR/.obsidian/plugins"
    mkdir -p "$CURRENT_DIR/.obsidian/themes"
    touch "$CURRENT_DIR/.obsidian/app.json"
    touch "$CURRENT_DIR/.obsidian/appearance.json"
    touch "$CURRENT_DIR/.obsidian/core-plugins.json"
    touch "$CURRENT_DIR/.obsidian/hotkeys.json"
    
    # 添加基本配置
    echo '{}' > "$CURRENT_DIR/.obsidian/app.json"
    echo '{"accentColor":"","cssTheme":""}' > "$CURRENT_DIR/.obsidian/appearance.json"
    echo '["backlink","command-palette","file-explorer","search","page-preview","daily-notes","templates","outline","workspaces"]' > "$CURRENT_DIR/.obsidian/core-plugins.json"
    echo '{}' > "$CURRENT_DIR/.obsidian/hotkeys.json"
    
    # 生成唯一ID (16位十六进制字符)
    VAULT_ID=$(openssl rand -hex 8)
    
    # 读取现有配置
    CONFIG_CONTENT=$(cat "$OBSIDIAN_CONFIG")
    
    # 检查是否已有保管库
    if [[ "$CONFIG_CONTENT" == *"\"vaults\":"* ]]; then
        # 已有保管库，添加新保管库
        NEW_CONFIG=$(echo "$CONFIG_CONTENT" | sed -E "s/(\"vaults\":[[:space:]]*\{)/\1\"$VAULT_ID\":{\"path\":\"$CURRENT_DIR\",\"ts\":$(date +%s)000},/")
    else
        # 没有保管库，创建新的保管库部分
        NEW_CONFIG="{\"vaults\":{\"$VAULT_ID\":{\"path\":\"$CURRENT_DIR\",\"ts\":$(date +%s)000}}}"
    fi
    
    # 写入新配置
    echo "$NEW_CONFIG" > "$OBSIDIAN_CONFIG"
    
    # 打开保管库
    echo "保管库已创建并注册，正在打开..."
    open "obsidian://open?path=$(echo $CURRENT_DIR | sed 's/ /%20/g')"
fi

