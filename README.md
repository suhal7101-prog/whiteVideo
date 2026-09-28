# 白熊动漫平台

> 一个面向二次元用户的全栈动漫社区平台，集成番剧检索、视频解析、社区、AI 助手与创作者投稿等多场景能力。

---

## 一、项目简介

白熊动漫（White Bear Anime）由三端组成，前端 Vue 3、后端 Spring Boot、数据/向量服务 Python FastAPI，配合 MySQL、MinIO、Redis（可选）与 DeepSeek 大模型，提供：

- 番剧目录检索、详情、播放、视频源代理（HLS 分片）
- 社区动态（帖子、评论、点赞、关注、弹幕）
- 用户与创作者中心（注册、登录、密码重置、邮箱验证、创作者申请、投稿）
- AI 智能体（**追番助手 Agent**、AI 对话 / 推荐 / 角色查询 / RAG 知识库检索）
- 管理后台（用户、视频、广告、公告、排行榜、Banner 特效、统计、创作者审核）

---

## 二、技术栈

| 层 | 技术 |
| --- | --- |
| 前端 | Vue 3.5 · Vite 8 · Pinia · Vue Router 4 · Element Plus · Tailwind CSS · ECharts · HLS.js · Video.js |
| 后端 | Spring Boot 3.2.5 · Java 17 · MyBatis-Plus · Spring Security · JWT · WebSocket · MinIO · OkHttp · Knife4j · Hutool · Fastjson2 |
| 数据 API | FastAPI 0.115 · Uvicorn 0.34 · Requests · ChromaDB (RAG 向量库) |
| 数据库 | MySQL 8（生产）/ H2（开发备选） |
| 对象存储 | MinIO（头像 / 视频 / 封面 / 社区图片） |
| AI 大模型 | DeepSeek（OkHttp 直连，已移除 Spring AI） |
| 构建工具 | Maven · npm · pip |

---

## 三、系统架构与数据流

```
┌──────────────────────────────────────────────────────┐
│  Vue 3 前端  (Vite dev server, 5174)                │
│                                                      │
│   /api/user  /community  /ai  /admin  /video         │
│   /ranking  /announcements  /bilibili  /banner...    │
│          │                                           │
│          └──────────────►  Spring Boot  (Java 8088)  │
│                                                      │
│   /api/catalog  /anime  /proxy  /vector              │
│          │                                           │
│          └────────────►  Python FastAPI  (8082)       │
│                            │                         │
│                            └─►  资源站 / ChromaDB    │
└──────────────────────────────────────────────────────┘
```

WebSocket `/ws` → Java 8088（弹幕 / 实时通知）。

---

## 四、端口总览

| 端口 | 服务 | 启动命令（项目根目录） |
| --- | --- | --- |
| **5174** | Vue 3 前端（Vite dev） | `cd white-bear-anime && npm run dev` |
| **8088** | Spring Boot 后端 | `cd white-bear-anime-spring-boot && start-boot.bat`<br>或：`java -jar target\white-bear-anime-1.0.0.jar --server.port=8088` |
| **8082** | Python FastAPI 数据/向量服务 | `cd white-bear-anime\server && python -m uvicorn main:app --host 0.0.0.0 --port 8082` |
| 3306 | MySQL（外部依赖） | — |
| 9000 | MinIO（外部依赖，可选） | — |
| `/ws` | WebSocket（绑定 8088） | — |

启动后访问入口：

- 前台首页：**http://localhost:5174**
- API 文档（Knife4j）：**http://localhost:8088/doc.html**
- 健康检查：**http://localhost:8082/health**

---

## 五、目录结构

```
white/
├── README.md                         # 本文档
├── install.bat                       # 一键安装脚本（Windows）
├── .gitignore                        # Git 忽略规则
│
├── ad/                               # 广告位素材（被 Java 后端引用 ../ad）
│
├── white-bear-anime/                 # ★ 前端 + 数据 API（Vue + Python）
│   ├── src/                          #    Vue 3 源码（views/components/api/...）
│   ├── public/                       #    静态资源（含 329 张 banner webp）
│   ├── scripts/                      #    工具脚本
│   ├── server/                       #    Python FastAPI 主数据服务
│   │   ├── main.py                   #      ~1400 行：资源代理 + 向量检索
│   │   ├── requirements.txt          #      Python 依赖清单
│   │   ├── chroma_data*/             #      向量库（运行时生成，gitignore）
│   │   └── api_cache.json 等          #    缓存（gitignore）
│   ├── backend/                      #    辅助实验项目（gitignore 排除，不随仓库发布）
│   ├── bilibili-banner/              #    第三方参考（gitignore 排除）
│   ├── VodHub/                       #    第三方参考（gitignore 排除）
│   ├── package.json                  #    前端依赖声明
│   └── vite.config.js                #    Vite + 代理规则
│
└── white-bear-anime-spring-boot/     # ★ Spring Boot 后端（Java 17）
    ├── pom.xml                       #    Maven 配置
    ├── start-boot.bat                #    一键启动（依赖已构建产物）
    ├── 启动后端.bat                  #    Maven spring-boot:run 方式启动
    ├── src/main/java/com/whitebear/anime/
    │   ├── controller/               #    11 个 Controller
    │   ├── service/  service/impl/   #    业务逻辑
    │   ├── mapper/                   #    MyBatis-Plus Mapper（20+）
    │   ├── model/entity/             #    实体类（19 个，wb_ 前缀表）
    │   ├── model/dto/                #    DTO（25+）
    │   ├── security/                 #    JWT / Security 配置
    │   ├── config/                   #    MinIO / WebSocket / DataInitializer
    │   └── aspect/                   #    AOP 日志切面
    └── src/main/resources/
        ├── application.yml           #    Spring Boot 主配置
        └── sql/                      #    数据表与种子脚本
```

---

## 六、环境要求

| 工具 | 版本 | 说明 |
| --- | --- | --- |
| JDK | 17+ | Spring Boot 3 / Maven 编译 |
| Maven | 3.8+ | 用户级安装，目录 `C:\Users\ASUS\maven\bin\mvn.cmd` |
| Node.js | 18+ | 前端构建（推荐 20+） |
| Python | 3.10+ | FastAPI 服务（已验证 3.11.9） |
| MySQL | 8.0+ | 主数据库（字符集 utf8mb4） |
| MinIO | 最新 | 对象存储（头像 / 视频 / 封面 / 社区图片） |
| Git | 2.30+ | 拉取/推送仓库 |

> 注：本机默认 Python 3.13 所在 E 盘已失效，已改用 Python 3.11.9 (`C:\Users\ASUS\AppData\Local\Programs\Python\Python311\python.exe`)。`install.bat` 优先查找 `python`，找不到再回退 `py` launcher。

---

## 七、快速开始

### 1. 一键安装依赖

```bat
install.bat
```

脚本会依次执行：
1. `npm install` 安装前端依赖
2. `pip install -r white-bear-anime/server/requirements.txt` 安装 Python 依赖
3. `mvn dependency:resolve` 预解析 Spring Boot 依赖

### 2. 初始化 MySQL

```sql
CREATE DATABASE white_bear_anime
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;
```

> 数据表由 `DataInitializer`（37KB）在 Spring Boot 首次启动时通过 `JdbcTemplate` 自动创建，无需手动执行 SQL。

### 3. （可选）配置环境变量

| 变量 | 说明 | 默认 |
| --- | --- | --- |
| `DB_USERNAME` | MySQL 用户名 | `root` |
| `DB_PASSWORD` | MySQL 密码 | `root` |
| `JWT_SECRET` | JWT 签名密钥（≥32 字符） | 本地开发密钥 |
| `DEEPSEEK_API_KEY` | DeepSeek API Key（启用 AI 功能） | 空 |
| `MAIL_HOST` / `MAIL_USERNAME` / `MAIL_PASSWORD` | 邮件服务（找回密码） | 空 |
| `MINIO_ACCESS_KEY` / `MINIO_SECRET_KEY` | MinIO 访问凭据 | 占位符 |
| `FRONTEND_URL` | 前端地址（邮件回调） | `http://localhost:5174` |
| `PYTHON_API_URL` | Python 服务地址 | `http://localhost:8082` |

### 4. 配置 DeepSeek API Key（启用 AI 功能）

AI 对话 / 追番助手 Agent / 个性化推荐等功能依赖 DeepSeek 大模型，**不配置也能正常使用平台其他功能**，仅 AI 模块会返回「AI 模型尚未配置」提示。

#### 第一步：申请 API Key

1. 访问 DeepSeek 开放平台：**https://platform.deepseek.com**
2. 注册 / 登录账号
3. 进入「API Keys」页面 → 点击「创建 API Key」
4. 复制生成的密钥（形如 `sk-xxxxxxxxxxxxxxxx`，**只显示一次，请立即保存**）
5. 确保账户有余额（DeepSeek 按调用量计费，充值少量即可测试）

#### 第二步：配置 Key（三选一）

**方式 ①：环境变量（推荐，安全）**

`application.yml` 中的 `${DEEPSEEK_API_KEY:sk-placeholder-key}` 会优先读取同名环境变量：

```powershell
# PowerShell 临时设置（仅当前窗口有效）
$env:DEEPSEEK_API_KEY="sk-你的真实key"
java -jar target\white-bear-anime-1.0.0.jar --server.port=8088
```

或设置系统环境变量（永久生效）：
`此电脑 → 属性 → 高级系统设置 → 环境变量 → 用户变量 → 新建`
变量名 `DEEPSEEK_API_KEY`，变量值 `sk-你的真实key`，**设置后需重启终端/IDE 才能生效**。

**方式 ②：直接修改配置文件（本地调试方便）**

编辑 `white-bear-anime-spring-boot/src/main/resources/application.yml`：

```yaml
deepseek:
  api-key: sk-你的真实key        # ← 改这里
  base-url: https://api.deepseek.com
  chat-model: deepseek-chat
```

> ⚠️ 此方式 key 会明文存入仓库，**推送 GitHub 前务必改回占位符**，否则密钥泄露。

**方式 ③：启动参数覆盖（一次性）**

```powershell
java -jar white-bear-anime-1.0.0.jar --server.port=8088 --deepseek.api-key=sk-你的真实key
```

#### 第三步：重启 Java 服务并验证

1. 重启 Spring Boot（8088）——配置只在启动时读取
2. 打开前端 http://localhost:5174 → 「AI 助手」页面
3. 发送一条提问（如「推荐几部热血动漫」），收到正常回答即配置成功
4. 若仍提示「AI 模型尚未配置」，检查 key 是否包含 `placeholder` / `your-deepseek` 字样（代码防呆校验），以及环境变量是否在**启动服务的同一终端**中设置

#### 相关文件说明

| 文件 | 作用 |
| --- | --- |
| `white-bear-anime-spring-boot/src/main/resources/application.yml` | DeepSeek 配置入口（`deepseek.*`） |
| `.../service/impl/AIServiceImpl.java` | 实际调用 DeepSeek 的代码（OkHttp 直连 `POST /chat/completions`） |
| `.../controller/AIController.java` | AI 接口路由 `/api/ai/*`（含每分钟 20 次限流） |

### 5. 启动三个服务（任选其一）

**方式 A：分别启动（推荐开发调试）**

```bat
:: 终端 1 - Spring Boot
cd white-bear-anime-spring-boot
start-boot.bat

:: 终端 2 - Python FastAPI
cd white-bear-anime\server
python -m uvicorn main:app --host 0.0.0.0 --port 8082

:: 终端 3 - Vue 前端
cd white-bear-anime
npm run dev
```

**方式 B：构建后启动（生产/演示）**

```bat
:: 构建后端
cd white-bear-anime-spring-boot
mvn -DskipTests package
java -jar target\white-bear-anime-1.0.0.jar --server.port=8088

:: 构建前端
cd ..\white-bear-anime
npm run build
npm run preview
```

### 6. 验证

- 前端：**http://localhost:5174**
- API 文档：**http://localhost:8088/doc.html**
- Python 健康检查：`curl http://localhost:8082/health` → `{"status":"ok","version":"2.0"}`

---

## 八、关键模块说明

### 1. AI 智能体（Agent）

AI 能力由 **DeepSeek** 大模型 + **ChromaDB** 向量库驱动，端到端链路：

| 入口 | 调用方 | 后端 |
| --- | --- | --- |
| `/api/ai/chat` | AiChat.vue | RAG + DeepSeek 对话 |
| `/api/ai/agent` | AiAssistant.vue | **追番助手 Agent**（自然语言指令 → 结构化操作） |
| `/api/ai/recommend` | AiRecommend.vue | 个性化推荐 |
| `/api/ai/character` | AiAssistant.vue | 角色信息查询 |
| `/api/ai/search` | AiAssistant.vue | RAG 知识库检索 |

实现位置：
- `white-bear-anime-spring-boot/src/main/java/com/whitebear/anime/controller/AIController.java`
- `white-bear-anime-spring-boot/src/main/java/com/whitebear/anime/service/impl/AIServiceImpl.java`（30KB，含 OkHttp 直连 DeepSeek）
- `white-bear-anime/server/main.py` 中 `/api/vector/index|search|status` 提供 RAG 检索后端
- `white-bear-anime/server/chroma_data*/` 向量库本地持久化

### 2. 数据 API（Python）

`white-bear-anime/server/main.py`（FastAPI，约 1400 行）聚合外部资源站与本地服务：

- `/api/catalog/**` — 番剧目录/详情/播放/发现
- `/api/anime/**` — 列表/搜索/相关/B 站搜索
- `/api/proxy/**` — 图片与 HLS 分片代理（视频源防盗链）
- `/api/vector/**` — ChromaDB 索引/检索（RAG 知识库）
- `/api/community/danmaku/{anime_id}` — 弹幕
- `/health` — 健康检查

### 3. 后端核心包结构（Spring Boot）

```
com.whitebear.anime
├── controller    11 个：Admin / User / Anime / VideoComment / Community
│                 Ranking / Advertisement / BannerEffect / Announcement / AI
├── service       含 AdvertisementImage / File / VideoUpload / RankingSync
├── mapper        20+ MyBatis-Plus Mapper
├── model.entity  19 个实体类，表名前缀 wb_
├── model.dto     25+ DTO（含 AIAgentDTO / AIChatDTO）
├── security      JwtAuthenticationFilter / JwtUtils / SecurityConfig
├── config        DataInitializer（建表+种子）/ WebSocketConfig / MinIOConfig
└── aspect        LogAspect（AOP 操作日志）
```

---

## 九、常用命令速查

| 操作 | 命令 |
| --- | --- |
| 安装依赖 | `install.bat` |
| 启动前端 | `cd white-bear-anime && npm run dev` |
| 启动后端（jar） | `start-boot.bat` |
| 启动后端（mvn） | `启动后端.bat` |
| 构建后端 | `cd white-bear-anime-spring-boot && mvn -DskipTests package` |
| 启动 Python | `cd white-bear-anime\server && python -m uvicorn main:app --port 8082` |
| 构建前端 | `cd white-bear-anime && npm run build` |
| 后端日志 | `white-bear-anime-spring-boot\boot-out.log` |
| API 文档 | http://localhost:8088/doc.html |

---

## 十、注意事项

1. **Redis 已默认关闭**：开发环境排除 Redis 自动装配；启用需在 `application.yml` 取消注释并补充连接信息。
2. **Spring AI 已移除**：项目采用 OkHttp 直连 DeepSeek，不依赖 Spring AI starter；如需切换模型，改 `application.yml` 的 `deepseek.*` 配置即可。
3. **ChromaDB 首次启动慢**：向量库为空时 `/api/vector/search` 会返回提示；首次部署后建议调用 `/api/vector/index` 构建本地知识库。
4. **MinIO 桶自动创建**：上传时若桶不存在，由 `MinioConfig` 自动创建；需保证 9000 端口可达。
5. **敏感配置**：仓库内 `application.yml` 使用开发期占位符，生产部署请通过环境变量覆盖 `JWT_SECRET` / `DB_PASSWORD` / `DEEPSEEK_API_KEY` / `MINIO_*`，**切勿将真实密钥提交到公开仓库**。
6. **第三方参考库不包含**：仓库排除了 VodHub、bilibili-banner、Anime-API × 4 副本、animepahe-api、anime-scraper、anime-site、anime-api.zip 等第三方参考资料与本地实验项目，仅保留白熊动漫自研的三端核心代码。

---

## 十一、推送至 GitHub

仓库已完成本地 Git 初始化与首次提交，可按以下步骤推送：

```bat
:: 1. 在 GitHub 上创建空仓库（建议 README 留空，避免冲突）
:: 2. 添加远程并推送
cd d:\桌面\white
git remote add origin https://github.com/<your-account>/<repo-name>.git
git branch -M main
git push -u origin main
```

如使用 SSH：

```bat
git remote add origin git@github.com:<your-account>/<repo-name>.git
git push -u origin main
```

---

## 十二、许可证

本仓库内白熊动漫自研代码采用 MIT License（建议在推送 GitHub 后追加 `LICENSE` 文件）。

仓库中曾引用的第三方参考项目遵循其各自开源协议（参考 `VodHub/LICENSE` 等），这些项目已通过 `.gitignore` 从本仓库排除，不随本项目一并发布。