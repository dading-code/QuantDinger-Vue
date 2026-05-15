#!/bin/bash
# QuantDinger-Vue 服务器端部署脚本
# 在服务器上执行此脚本

set -e

echo "========================================"
echo "QuantDinger-Vue 服务器端配置"
echo "========================================"
echo ""

# 创建部署目录
DEPLOY_DIR="/www/wwwroot/quantdinger-vue"
echo "[1] 创建部署目录: $DEPLOY_DIR"
mkdir -p $DEPLOY_DIR
echo "✓ 目录创建完成"
echo ""

# 设置目录权限
echo "[2] 设置目录权限"
chown -R nginx:nginx $DEPLOY_DIR 2>/dev/null || chown -R www-data:www-data $DEPLOY_DIR 2>/dev/null || echo "⚠ 请手动设置目录权限"
chmod -R 755 $DEPLOY_DIR
echo "✓ 权限设置完成"
echo ""

# 检查并配置 nginx
NGINX_CONF="/etc/nginx/conf.d/quantdinger-vue.conf"
TEMP_CONF="/tmp/quantdinger-nginx.conf"

echo "[3] 配置 nginx"
if [ -f "$TEMP_CONF" ]; then
    echo "找到临时配置文件，正在安装..."
    cp $TEMP_CONF $NGINX_CONF
    echo "✓ nginx 配置文件已安装到: $NGINX_CONF"
else
    echo "⚠ 未找到临时配置文件"
    echo "请确保已将 deploy/nginx-server.conf 上传到 /tmp/quantdinger-nginx.conf"
    exit 1
fi
echo ""

# 测试 nginx 配置
echo "[4] 测试 nginx 配置"
nginx -t
if [ $? -eq 0 ]; then
    echo "✓ nginx 配置测试通过"
else
    echo "✗ nginx 配置测试失败，请检查配置文件"
    exit 1
fi
echo ""

# 重载 nginx
echo "[5] 重载 nginx"
systemctl reload nginx
if [ $? -eq 0 ]; then
    echo "✓ nginx 重载成功"
else
    echo "⚠ nginx 重载失败，尝试重启..."
    systemctl restart nginx
fi
echo ""

# 检查服务状态
echo "[6] 检查服务状态"
systemctl status nginx --no-pager -l | head -20
echo ""

echo "========================================"
echo "部署完成！"
echo "========================================"
echo ""
echo "访问地址: http://39.105.150.99"
echo "API 代理: http://39.105.150.99:8888"
echo ""
echo "常用命令："
echo "  查看日志: tail -f /var/log/nginx/access.log"
echo "  重载配置: systemctl reload nginx"
echo "  重启服务: systemctl restart nginx"
echo ""
