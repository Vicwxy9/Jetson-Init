#!/bin/bash

log_file="script.log"  # 日志文件名

# 将标准输出和标准错误输出同时输出到终端和日志文件
exec > >(tee -a "$log_file") 2>&1

# 脚本的其他命令和操作
echo "Script started at $(date)"
# ...

echo "Script finished at $(date)"
