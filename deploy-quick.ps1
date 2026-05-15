# QuantDinger-Vue 快速部署脚本
# 使用方法: .\deploy-quick.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "QuantDinger-Vue 部署到线上服务器" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$SERVER = "39.105.150.99"
$USER = "root"
$DEPLOY_DIR = "/www/wwwroot/quantdinger-vue"

Write-Host "[步骤 1] 检查 dist 目录..." -ForegroundColor Yellow
if (-not (Test-Path "dist\index.html")) {
    Write-Host "✗ dist/index.html 不存在，请先运行 npm run build" -ForegroundColor Red
    exit 1
}
Write-Host "✓ dist 目录检查通过" -ForegroundColor Green
Write-Host ""

Write-Host "[步骤 2] 在服务器上创建部署目录..." -ForegroundColor Yellow
ssh ${USER}@${SERVER} "mkdir -p ${DEPLOY_DIR}"
Write-Host "✓ 目录创建完成" -ForegroundColor Green
Write-Host ""

Write-Host "[步骤 3] 清空旧文件..." -ForegroundColor Yellow
ssh ${USER}@${SERVER} "rm -rf ${DEPLOY_DIR}/*"
Write-Host "✓ 旧文件已清空" -ForegroundColor Green
Write-Host ""

Write-Host "[步骤 4] 上传新文件（这可能需要几分钟）..." -ForegroundColor Yellow
scp -r dist\* ${USER}@${SERVER}:${DEPLOY_DIR}/
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ 上传失败！" -ForegroundColor Red
    Write-Host "请检查：" -ForegroundColor Yellow
    Write-Host "  1. SSH 连接是否正常" -ForegroundColor Yellow
    Write-Host "  2. 是否有写入权限" -ForegroundColor Yellow
    Write-Host "  3. 服务器磁盘空间是否充足" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ 文件上传完成" -ForegroundColor Green
Write-Host ""

Write-Host "[步骤 5] 设置文件权限..." -ForegroundColor Yellow
ssh ${USER}@${SERVER} "chown -R nginx:nginx ${DEPLOY_DIR} 2>/dev/null; chown -R www-data:www-data ${DEPLOY_DIR} 2>/dev/null; echo '权限设置完成'"
ssh ${USER}@${SERVER} "chmod -R 755 ${DEPLOY_DIR}"
Write-Host "✓ 权限设置完成" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "部署完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "访问地址: http://${SERVER}" -ForegroundColor White
Write-Host "API 代理: http://${SERVER}:8888" -ForegroundColor White
Write-Host ""
Write-Host "下一步操作：" -ForegroundColor Yellow
Write-Host "1. 配置 nginx（如果还未配置）" -ForegroundColor White
Write-Host "   将 deploy/nginx-server.conf 上传到服务器并安装" -ForegroundColor White
Write-Host ""
Write-Host "2. 测试 nginx 配置：" -ForegroundColor White
Write-Host "   ssh ${USER}@${SERVER} 'nginx -t'" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 重载 nginx：" -ForegroundColor White
Write-Host "   ssh ${USER}@${SERVER} 'systemctl reload nginx'" -ForegroundColor Gray
Write-Host ""
Write-Host "4. 查看日志：" -ForegroundColor White
Write-Host "   ssh ${USER}@${SERVER} 'tail -f /var/log/nginx/access.log'" -ForegroundColor Gray
Write-Host ""
