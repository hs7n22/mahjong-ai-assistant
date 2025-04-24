# AI Mahjong Assistant

🔐 完成 Supabase 登录注册系统（含邮箱验证）

- 实现邮箱+密码注册与登录逻辑
- 支持 Supabase 自动发送验证邮件
- 注册成功后提示用户前往邮箱验证
- 未验证邮箱无法进入主页，提示验证引导
- 新增 AppBar 刷新按钮，供用户手动检查验证状态
- 用户完成验证后可立即跳转进入 Home 页面
- 登录状态跳转逻辑清晰，页面结构合理

### 🚀 项目封装加重构

```
frontend/
├── services/         # AuthService、UploadService、ApiService 等
├── pages/            # AuthPage、HomePage
├── widgets/          # UI 组件：AuthForm、UserInfoCard、ImageUploadBox
├── constants.dart    # 全局配置
├── main.dart         # 入口文件
backend/
├── main.py           # FastAPI 后端主服务
├── .env              # SUPABASE_JWT_SECRET、PROJECT_ID 等配置
```
