@echo off
chcp 65001 >nul

REM ============================================================
REM   水果商城系统 - 一键启动（Windows）
REM
REM   前置条件：
REM     1. 已安装 JDK 17 与 Maven，并加入 PATH
REM     2. MySQL 已启动，且已导入 db_mall.sql
REM     3. 已按 README 配置好 application-local.properties
REM ============================================================

set "ROOT=%~dp0"

echo ============================================================
echo   水果商城系统 - 一键启动
echo ============================================================
echo.

where java >nul 2>nul
if errorlevel 1 goto :no_java

where mvn >nul 2>nul
if errorlevel 1 goto :no_mvn

where npm >nul 2>nul
if errorlevel 1 goto :no_npm

if not exist "%ROOT%springboot\src\main\resources\application-local.properties" goto :no_conf

if exist "%ROOT%vue\node_modules" goto :deps_ok
echo [1/2] 安装前端依赖（首次较慢）...
pushd "%ROOT%vue"
call npm install
if errorlevel 1 goto :npm_fail
popd

:deps_ok
echo [2/2] 启动服务...
start "商城后端 1234" cmd /k "cd /d "%ROOT%springboot" && mvn spring-boot:run"
echo     后端启动中，等待 25 秒...
timeout /t 25 /nobreak >nul
start "商城前端 8080" cmd /k "cd /d "%ROOT%vue" && npm run serve"

echo.
echo ============================================================
echo   启动完成
echo ============================================================
echo   后端接口 : http://localhost:1234
echo   前端页面 : http://localhost:8080
echo.
echo   演示账号（口令均为 123456）：
echo     超级管理员  Sadmin
echo     管理员      admin
echo     普通用户    user
echo.
echo   关闭本窗口不会停止服务，
echo   请到「商城后端 / 商城前端」两个窗口按 Ctrl+C 停止。
echo ============================================================
echo.
pause
exit /b 0

:no_java
echo [错误] 未找到 java，请安装 JDK 17 并加入 PATH
pause
exit /b 1

:no_mvn
echo [错误] 未找到 mvn，请安装 Maven 并加入 PATH
pause
exit /b 1

:no_npm
echo [错误] 未找到 npm，请安装 Node.js 并加入 PATH
pause
exit /b 1

:no_conf
echo ============================================================
echo   [需要配置] 未找到 application-local.properties
echo ============================================================
echo   请先执行：
echo       cd springboot\src\main\resources
echo       copy application-local.properties.example application-local.properties
echo   然后填入数据库口令、邮箱授权码与大模型 API Key。
echo ============================================================
echo.
pause
exit /b 1

:npm_fail
popd
echo [错误] 前端依赖安装失败，请检查网络后重试
pause
exit /b 1
