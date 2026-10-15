# 水果商城系统

> **开发周期：2025.02 – 2025.06** ｜ 2026.10 整理开源
>
> 本项目核心开发于 2025 年上半年完成。2026 年 10 月做了一轮集中排查与加固：修复 JWT 拦截器
> 被路径排除规则抵消导致的**后端零鉴权**、口令哈希随接口返回，并接入 Caffeine(L1) + Redis(L2) 两级缓存。
> 仓库中的提交时间集中在 10 月，它们是**加固记录**，不是开发记录。

基于 **Spring Boot 3 + Vue 2** 的前后端分离商城系统，包含前台商城、管理后台与 AI 智能导购。

## 功能模块

### 前台商城
商品浏览、分类筛选、关键词搜索、商品详情、购物车、下单与订单查询、收藏、
商品评论、收货地址管理、个人中心、与商家在线客服。

### 管理后台
商品与分类管理、轮播图管理、订单管理与退款干预、库存入库/出库、物流管理、
用户管理、菜单与数据字典、文章与公告管理、评论管理。

### AI 智能导购
用户在商城中用自然语言描述需求（例如「想要酸甜的、便宜一点的当季水果」），
后端调用大模型从候选商品中挑选匹配项并返回。候选集按上架状态、库存与销量预先
筛选，模型返回的商品 id 会再经一次校验，只接受候选集中真实存在的项。

### 个性化推荐

除大模型导购外，另有一套**不依赖大模型**的协同过滤推荐：

- **用户-商品矩阵**：把每个用户买过、收藏过的商品聚成集合
- **余弦相似度**：两两计算用户之间的相似度，找出"口味相近的人"
- **推荐生成**：取相似用户买过、但当前用户没买过的商品，按相似度加权排序
- **离线重算**：定时任务（`0 0 2 * * ?`）每天重建一次相似度矩阵，
  查询时直接读内存结果，不把计算压在请求路径上

接口：

- `GET /recommend/user/{userId}`
- `POST /recommend/update`

> 说明：相似度矩阵在应用内存中维护，多实例部署时应改为落库或放 Redis 共享。

## 技术栈

| 层次 | 技术 |
| --- | --- |
| 后端框架 | Spring Boot 3 |
| 数据访问 | MyBatis-Plus |
| 数据库 | MySQL 8 |
| 缓存 | Caffeine(L1) + Redis(L2) 两级缓存（Spring Cache 注解） |
| 认证鉴权 | Spring Security + JWT |
| 邮件 | Spring Mail（注册验证码） |
| 大模型 | Spring AI（OpenAI 兼容接口） |
| 前端 | Vue 2.6、Element UI、Vue Router、Axios |

## 项目结构

```
fruit-mall/
├── springboot/                          # 后端（Maven 工程）
│   └── src/main/
│       ├── java/org/example/springboot/
│       │   ├── controller/              # 接口层
│       │   ├── service/                 # 业务层
│       │   ├── mapper/                  # 数据访问层
│       │   ├── entity/                  # 实体
│       │   ├── config/                  # 配置（缓存、安全、拦截器、定时任务等）
│       │   ├── util/                    # 工具类
│       │   └── enumClass/               # 枚举
│       └── resources/
│           ├── application.properties   # 主配置（不含任何密钥）
│           ├── application-local.properties.example   # 本地私密配置模板
│           └── mapper/                  # MyBatis XML
├── vue/                                 # 前端（Vue CLI 工程）
│   └── src/
│       ├── views/front/                 # 前台商城页面
│       ├── views/                       # 管理后台页面
│       ├── components/                  # 公共组件
│       └── router/                      # 路由
├── db_mall.sql                          # 数据库结构与演示数据
└── 启动全部.bat                          # 一键启动脚本（Windows）
```

## 快速开始

### 1. 导入数据库

```bash
mysql -u root -p < db_mall.sql
```

### 2. 配置本地私密参数

数据库口令、邮箱 SMTP 授权码、大模型 API Key 都不写进主配置，
而是放在单独的本地文件里：

```bash
cd springboot/src/main/resources
cp application-local.properties.example application-local.properties
```

然后编辑 `application-local.properties` 填入真实值。
该文件已加入 `.gitignore`，不会被提交。

### 3. 启动 Redis

两级缓存需要本地 Redis（**不起也能跑** —— Redis 不可用时会自动降级为仅用 L1，
但日志会持续输出 WARN）：

```bash
redis-server
```

默认连 `127.0.0.1:6379`，可用环境变量 `REDIS_HOST` / `REDIS_PORT` 覆盖。

### 4. 启动后端

```bash
cd springboot
mvn spring-boot:run
```

后端端口 `1234`。

### 5. 启动前端

```bash
cd vue
npm install
npm run serve
```

前端端口 `8080`，浏览器打开 <http://localhost:8080>。

### 一键启动（Windows）

在已安装 JDK 17、Maven、Node.js 且 MySQL 已启动的前提下，
直接双击根目录的 `启动全部.bat`。

## 说明

- 商品图片等上传文件存放于 `springboot/files/`，该目录内容不纳入版本控制，
  克隆后首次上传时会自动创建
- 前端构建产物位于 `vue/dist/`，同样不纳入版本控制
