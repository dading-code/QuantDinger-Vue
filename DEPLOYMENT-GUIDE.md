# QuantDinger-Vue 线上部署完成指南

## ✅ 已完成步骤

1. ✓ 本地构建生产版本（npm run build）
2. ✓ 创建服务器目录 `/www/wwwroot/quantdinger-vue`
3. ✓ 上传所有静态文件到服务器
4. ✓ 设置文件权限（chmod 755）
5. ✓ 上传 nginx 配置文件到 `/tmp/quantdinger-nginx.conf`

## 📋 下一步操作（在服务器上执行）

### 1. 安装 nginx 配置文件

```bash
# 复制配置文件到 nginx 配置目录
cp /tmp/quantdinger-nginx.conf /etc/nginx/conf.d/quantdinger-vue.conf

# 测试 nginx 配置
nginx -t

# 如果测试通过，重载 nginx
systemctl reload nginx
```

### 2. 验证部署

访问以下地址检查部署是否成功：
- **前端页面**: http://39.105.150.99
- **健康检查**: http://39.105.150.99/health
- **API 代理**: http://39.105.150.99/api/health → 应该转发到 http://39.105.150.99:8888/api/health

### 3. 查看日志（如有问题）

```bash
# 查看 nginx 访问日志
tail -f /var/log/nginx/access.log

# 查看 nginx 错误日志
tail -f /var/log/nginx/error.log
```

## 🔧 常用管理命令

```bash
# 重载 nginx（修改配置后）
systemctl reload nginx

# 重启 nginx
systemctl restart nginx

# 查看 nginx 状态
systemctl status nginx

# 重新部署（更新文件后）
cd /www/wwwroot/quantdinger-vue
# 从本地上传新文件后，只需重载 nginx
systemctl reload nginx
```

## 📝 配置文件说明

### Nginx 配置要点

- **根目录**: `/www/wwwroot/quantdinger-vue`
- **API 代理**: `/api/` → `http://39.105.150.99:8888/api/`
- **静态资源缓存**: 7天
- **Gzip 压缩**: 已启用
- **SPA 路由支持**: 已配置（try_files）

### 后端 API

- **地址**: http://39.105.150.99:8888
- **健康检查**: http://39.105.150.99:8888/api/health

## ⚠️ 注意事项

1. 确保后端服务（端口 8888）正在运行
2. 确保防火墙允许 80 端口访问
3. 如需 HTTPS，需要额外配置 SSL 证书
4. 每次更新前端代码后，需要重新构建并上传 dist 目录

## 🚀 快速重新部署流程

```bash
# 在本地执行
npm run build
scp -r dist/* root@39.105.150.99:/www/wwwroot/quantdinger-vue/

# 在服务器上执行（可选，如果需要更新 nginx 配置）
systemctl reload nginx
```

---

**部署时间**: 2026-05-14
**服务器**: 39.105.150.99
**项目**: QuantDinger-Vue
