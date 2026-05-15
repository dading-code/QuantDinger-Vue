@echo off
chcp 65001 >nul
echo ========================================
echo QuantDinger-Vue 部署到线上服务器
echo ========================================
echo.

echo [步骤 1] 清理旧的构建文件...
if exist dist rmdir /s /q dist
echo ✓ 清理完成
echo.

echo [步骤 2] 开始构建生产版本...
call npm run build
if errorlevel 1 (
    echo ✗ 构建失败！
    pause
    exit /b 1
)
echo ✓ 构建完成
echo.

echo [步骤 3] 检查 dist 目录...
if not exist dist\index.html (
    echo ✗ dist/index.html 不存在，构建可能失败
    pause
    exit /b 1
)
echo ✓ dist 目录检查通过
echo.

echo [步骤 4] 准备上传到服务器...
echo 服务器地址: 39.105.150.99
echo 目标目录: /www/wwwroot/quantdinger-vue
echo.
echo 请确认以下信息：
echo - 您已经有服务器的 SSH 访问权限
echo - nginx 配置文件已准备好: deploy\nginx-server.conf
echo.
pause

echo.
echo [步骤 5] 上传文件到服务器...
echo 使用 scp 上传 dist 目录...
scp -r dist\* root@39.105.150.99:/www/wwwroot/quantdinger-vue/
if errorlevel 1 (
    echo ✗ 上传失败！
    echo 请检查：
    echo 1. SSH 连接是否正常
    echo 2. 目标目录是否存在
    echo 3. 是否有写入权限
    pause
    exit /b 1
)
echo ✓ 文件上传完成
echo.

echo [步骤 6] 上传 nginx 配置文件...
scp deploy\nginx-server.conf root@39.105.150.99:/tmp/quantdinger-nginx.conf
if errorlevel 1 (
    echo ⚠ nginx 配置文件上传失败（可选步骤）
) else (
    echo ✓ nginx 配置文件已上传到 /tmp/quantdinger-nginx.conf
    echo 请在服务器上执行以下命令：
    echo   cp /tmp/quantdinger-nginx.conf /etc/nginx/conf.d/quantdinger-vue.conf
    echo   nginx -t
    echo   systemctl reload nginx
)
echo.

echo ========================================
echo 部署完成！
echo ========================================
echo.
echo 下一步操作：
echo 1. 在服务器上配置 nginx（如果还未配置）
echo 2. 重启或重载 nginx: systemctl reload nginx
echo 3. 访问 http://39.105.150.99 查看效果
echo.
pause
