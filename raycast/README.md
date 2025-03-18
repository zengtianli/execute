# Raycast 脚本使用说明

本说明文档介绍了位于此目录下所有 Raycast 脚本的用法、功能和参数说明。所有脚本均可通过 Raycast 快捷启动，并使用 Finder 当前目录作为工作目录。

## 脚本列表及说明

1. **ray_comp_data.sh**
   - 用途：比较数据。该脚本调用 Python 脚本 `compare_data.py` 对两个 Excel 文件进行数据比较。
   - 参数：需要提供两个文本参数，分别作为要比较的两个文件的前缀（自动追加 `.xlsx`）。
   - 功能：将 Finder 当前目录作为工作目录，执行数据比较，并在完成后通过 Raycast 通知用户。

2. **ray_d2m.sh**
   - 用途：创建新文件。调用 Python 脚本 `docxmark_1.py` 生成一个新的 DOCX 文件。
   - 参数：需要提供一个文件名（不含扩展名），脚本会自动追加 `.docx`。
   - 功能：在 Finder 当前目录下生成指定名称的 DOCX 文件，并使用 Raycast 的通知反馈操作结果。

3. **ray_comp_item.sh**
   - 用途：比较项目。调用 Python 脚本 `compare_items.py` 对两个 Excel 文件中的项目进行比较。
   - 参数：需要提供两个文本参数，作为要比较的两个文件的前缀（自动追加 `.xlsx`）。
   - 功能：在 Finder 当前目录下执行操作，并完成后发送通知。

4. **ray_m2d.sh**
   - 用途：创建 Markdown 文件。调用 Python 脚本 `main.py` （来自 `docx_styler` 工具）生成一个新的 Markdown 文件。
   - 参数：需要提供一个文件名（不含扩展名），脚本会自动追加 `.md`。
   - 功能：在 Finder 当前目录下生成指定名称的 Markdown 文件，并使用通知反馈。

5. **ray_execute_fsj_gui.sh**
   - 用途：执行 FSJ 图形界面脚本。通过指定的 Python 路径运行位于 `gui.py` 的脚本，启动图形界面。
   - 参数：无固定参数，直接运行。
   - 功能：设置好必要的环境变量（如 `QT_PLUGIN_PATH`），然后启动 FSJ GUI 应用。

6. **ray_restart_raycast.sh**
   - 用途：重启 Raycast 应用。
   - 参数：无参数。
   - 功能：检查 Raycast 是否在运行，若在运行则退出后等待彻底退出，再重新启动 Raycast 应用。

7. **ray_splitsheets.sh**
   - 用途：拆分 Excel 表格。调用 Python 脚本 `splitsheets.py` 将一个 Excel 文件拆分成多个工作表。
   - 参数：需要提供 Excel 文件的前缀（自动追加 `.xlsx`）。
   - 功能：在 Finder 当前目录下执行拆分操作，并通知用户操作成功。

8. **ray_execute_mike_gui.sh**
   - 用途：启动 MIKE 图形界面脚本。调用 Python 脚本 `mike_gui.py` 启动 MIKE GUI 应用。
   - 参数：无固定参数。
   - 功能：设置好必要的环境变量（例如 `QT_PLUGIN_PATH`）以及日志文件路径，然后启动 MIKE GUI 应用。

9. **ray_terminate_mike_gui.sh**
   - 用途：终止 MIKE 图形界面脚本。
   - 参数：无参数。
   - 功能：使用 `pkill` 命令终止正在运行的 MIKE GUI 进程。

10. **ray_txt2xls.sh**
    - 用途：将 TXT 文件转换为 XLSX 文件。调用 Python 脚本 `txt2xls.py` 实现转换。
    - 参数：无须指定文件名，脚本将在 Finder 当前目录下转换所有 TXT 文件，并生成相应的 XLSX 文件。
    - 功能：转换结束后发送通知。

11. **ray_winsurf.sh**
    - 用途：打开 Windsurf 应用。
    - 参数：无参数。
    - 功能：在 Finder 当前目录下启动 Windsurf 应用，并通过通知反馈操作结果。

12. **ray_xls2txt.sh**
    - 用途：将 XLSX 文件转换为 TXT 文件。调用 Python 脚本 `xls2txt.py` 完成转换。
    - 参数：无须指定文件名，脚本将在 Finder 当前目录下转换所有 XLSX 文件，并生成对应的 TXT 文件。
    - 功能：转换结束后发送通知。

13. **terminate_py.sh**
    - 用途：终止所有正在运行的 Python 进程。
    - 参数：无参数。
    - 功能：使用 `pkill` 命令结束所有 Python 进程，可选的更严格方式已在脚本中注释。

14. **ray_execute_mike_gui copy.bark**
    - 用途：该文件看似是 `ray_execute_mike_gui.sh` 的一个备份或复制文件，其具体用途取决于用户后续是否需要。
    - 参数及功能：与 `ray_execute_mike_gui.sh` 类似，但文件扩展名不同，可能用于测试或备份目的。

## 使用方法

1. 将所需的脚本通过 Raycast 快捷方式调用，确保在 Finder 中切换到正确的目录。
2. 根据各脚本的用途，输入必要的参数，例如文件名前缀或其他文本参数。
3. 脚本执行完成后，会通过终端或 Raycast 的通知显示操作结果。

## 注意事项

- 本目录中的脚本均依赖于 Python 脚本位于特定路径下，如果路径或依赖环境发生变化，请根据实际情况修改脚本内的对应路径。
- 执行前请确保相关 Python 环境已正确配置，例如 `miniforge3` 目录下的 Python 解释器和必要的插件路径。
- 部分脚本可能会修改当前 Finder 目录下的文件，请谨慎使用并确保数据备份。

---

以上就是各个 Raycast 脚本的详细说明。如有任何疑问或需进一步调整，请联系相关人员进行修改。
