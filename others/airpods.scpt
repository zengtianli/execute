-- 文件路径，用于存储上次运行的快捷方式名称
set stateFile to (path to home folder as text) & "Desktop:noise_state.txt"

-- 读取上次运行的快捷方式名称
try
    set lastRun to read file stateFile
on error
    -- 如果文件不存在，默认为 "SetNoise2"
    set lastRun to "SetNoise2"
end try

-- 切换快捷方式
tell application "Shortcuts"
    if lastRun contains "SetNoise2" then
        run shortcut "SetNoise1"
        set newState to "SetNoise1"
    else
        run shortcut "SetNoise2"
        set newState to "SetNoise2"
    end if
end tell

-- 保存新的状态到文件
try
    set fileRef to open for access stateFile with write permission
    set eof fileRef to 0
    write newState to fileRef
    close access fileRef
on error
    try
        close access stateFile
    end try
end try

-- 输出运行的快捷方式名称（可选）
return newState

