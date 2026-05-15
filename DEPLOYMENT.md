# QuantDinger 前端部署指南

## 前置条件

1. 已完成前端构建（`npm run build`）
2. 拥有服务器 SSH 访问权限
3. 服务器已安装 Nginx

## 部署步骤

### 方法一：使用自动化脚本（推荐）

1. 编辑 `deploy-to-server.ps1` 文件，修改以下变量：
   ```powershell
   $SERVER_USER = "your_username"  # 您的服务器用户名
   $DEPLOY_PATH = "/usr/share/nginx/html"  # 部署路径
   ```

2. 运行部署脚本：
   ```powershell
   .\deploy-to-server.ps1
   ```

### 方法二：手动部署

#### 1. 上传文件到服务器

使用 SCP 或 SFTP 工具上传 `dist` 目录中的所有文件到服务器：

```bash
# 使用 scp 命令
scp -r dist/* root@39.105.150.99:/usr/share/nginx/html/

# 或使用 rsync（更高效）
rsync -avz --delete dist/ root@39.105.150.99:/usr/share/nginx/html/
```

#### 2. 配置 Nginx

将 `deploy/nginx-production.conf` 文件复制到服务器的 `/etc/nginx/conf.d/` 目录：

```bash
# 在本地执行
scp deploy/nginx-production.conf root@39.105.150.99:/etc/nginx/conf.d/quantdinger.conf

# 或在服务器上创建文件
ssh root@39.105.150.99
nano /etc/nginx/conf.d/quantdinger.conf
# 粘贴 nginx-production.conf 的内容
```

#### 3. 重启 Nginx

```bash
ssh root@39.105.150.99

# 测试配置文件
nginx -t

# 重启 Nginx
systemctl restart nginx
# 或
service nginx restart
```

#### 4. 设置文件权限

```bash
ssh root@39.105.150.99

# 设置正确的所有者（根据系统调整）
chown -R www-data:www-data /usr/share/nginx/html
# 或
chown -R nginx:nginx /usr/share/nginx/html

# 设置权限
chmod -R 755 /usr/share/nginx/html
```

## 验证部署

1. 访问 http://39.105.150.99:8888
2. 检查页面是否正常加载
3. 打开浏览器开发者工具，检查是否有错误
4. 测试 API 请求是否正常（登录、获取数据等）

## 常见问题

### 1. 页面空白或 404 错误

- 检查 Nginx 配置中的 `root` 路径是否正确
- 确认 `index.html` 文件存在
- 检查 Nginx 错误日志：`tail -f /var/log/nginx/error.log`

### 2. API 请求失败

- 确认后端服务正在运行（默认端口 5000）
- 检查 Nginx 配置中的 `proxy_pass` 地址
- 查看 Nginx 错误日志

### 3. 静态资源加载失败

- 检查文件权限是否正确
- 确认所有文件都已上传
- 清除浏览器缓存后重试

### 4. WebSocket 连接失败

- 确认 Nginx 配置中包含 WebSocket 支持
- 检查后端 WebSocket 服务是否运行
- 查看浏览器控制台的网络标签

## 更新部署

当需要更新前端代码时：

1. 在本地重新构建：
   ```bash
   npm run build
   ```

2. 运行部署脚本或手动上传新文件

3. 刷新浏览器（可能需要强制刷新 Ctrl+F5）

## 备份建议

在部署前，建议备份当前版本：

```bash
ssh root@39.105.150.99
cp -r /usr/share/nginx/html /usr/share/nginx/html.backup.$(date +%Y%m%d)
```

## 监控和维护

- 定期检查 Nginx 日志
- 监控服务器资源使用情况
- 定期备份重要数据
- 保持系统和软件更新
