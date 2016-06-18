@echo off
mode con cols=80 lines=25
color fd
cls
title ��Ϊ�ն� OTA ģ�������

REM ========================================
REM     GETTING LOCAL NETWORK IP ADDRESS
REM ========================================
FOR /F "tokens=4 delims= " %%i in ('route print ^| find " 0.0.0.0"') do set localIp=%%i

REM ========================================
REM         PRINT HELP INFORMATION
REM ========================================
:HwOUC_Main_Menu
cls
echo ������������������������������������������������������������������������������
echo ������������������������������������������������������������������������������
echo ������������������������������������������������������������������������������
echo �������������� ���� ��ӭʹ�ã���Ϊ�ն� OTA ����ģ������������� ��������������
echo ������������������������������������������������������������������������������
echo ������������������������������������������������������������������������������
echo �ĩ���������������������������������������������������������������������������
echo ������������������������������������������������������������������������������
echo ����������������������ڻ�Ϊ OTA ����ģ�⣬ʹ���г����κ����������н����   ��
echo ������Ȩ��������������ɵ������Ϊ��Դ��������������ݰ�Ȩ���ڻ�Ϊ���С�  ��
echo ������������������������������������������������������������������������������
echo �ĩ���������������������������������������������������������������������������
echo ������������������������������������������������������������������������������
echo ��������ʹ�÷������������������������������������������������������     �� ��
echo ������1. ���Ƚ��ֻ���������ӵ�ͬһ�����磨·�������С���������         ������
echo ������2. ������ĵ����а�װ�з���ǽ���������رջ����������������       ��
echo ������3. ��й¶�����������Ƶ��������Ŀ¼���У�������Ϊ update.zip���ļ���  ��
echo ������4. �ڽ������Ľ������밴����ʾ���в�����                               ��
echo ������������������������������������������������������������������������������
echo �ĩ���������������������������������������������������������������������������
echo ����������������������������   ����������Ӧ���ֲ����س�: [1] ����  [2] �˳� ��
echo ������������������������������������������������������������������������������
echo.
set /p keydown="��������Ӧ���ֲ����س�:> "
if "%keydown%"=="1" goto :HwOUC_Server_Startup
if "%keydown%"=="2" goto :HwOUC_Server_Stop_and_Exit
echo ������ ���Ĳ������󣬽��� 3 ��󷵻����ԡ�
ping 127.1 -n 2 >NUL
goto HwOUC_Main_Menu

:HwOUC_Server_Startup
cls
echo ================================================================================
echo                          ��Ϊ�ն� OTA ����ģ�������
echo.
echo ================================================================================
echo �����������ʾ�𲽲�����ÿ������밴�س�������
echo -----------------------------------------------
echo.
set /p wait=[1] �뽫 precheck-script �� update.zip ���ڱ�Ŀ¼ 
set /p wait=[2] �뽫���ֻ��� DNS ��������ַ����Ϊ��%localIp% 
set /p currentVer=[3] �����������������İ汾���� CHM-TL00C00B551����
set /p ruok=[4] ��ȷ������������Ϣ��ȷ�������� emui �س�ȷ�ϣ���
echo.
echo.
if "%ruok%"=="emui" goto :Hw_Server_IAmOk
echo.
echo ������ �������ȷ����Ϣ���� emui�����ѷ���������3 ��󷵻������档
ping 127.1 -n 3 >NUL
goto :HwOUC_Main_Menu
exit

:Hw_Server_IAmOk
echo �������ڿ�ʼ�����������ĵȴ��������
echo -----------------------------------------------
echo.
echo [1] ������ճ�����ǰ��ʷ��¼ ...
call %~dp0\usr\clean.bat
ping 127.1 -n 2 >NUL

echo [2] ��ģ������ OTA ������Ϣ�ļ� ...
%~dp0\usr\iconvsed\iconv -f utf-8 -t gb2312 %~dp0\full\template\HwOUC_Response.json > %~dp0\full\HwOUC_Response.json.gb2312
%~dp0\usr\iconvsed\iconv -f utf-8 -t gb2312 %~dp0\full\template\changelog.xml > %~dp0\full\changelog.xml.gb2312
%~dp0\usr\iconvsed\sed -i "s/hwouc_dest_version/%currentVer%/g" %~dp0\full\HwOUC_Response.json.gb2312
%~dp0\usr\iconvsed\sed -i "s/hwouc_dest_version/%currentVer%/g" %~dp0\full\changelog.xml.gb2312
%~dp0\usr\iconvsed\iconv -t utf-8 -f gb2312 %~dp0\full\HwOUC_Response.json.gb2312 > %~dp0\full\HwOUC_Response.json
%~dp0\usr\iconvsed\iconv -t utf-8 -f gb2312 %~dp0\full\changelog.xml.gb2312 > %~dp0\full\changelog.xml
ping 127.1 -n 2 >NUL

echo [3] �����ƶ�����ļ� ...
move /y %~dp0\precheck-script %~dp0\full\ >nul 2>nul
move /y %~dp0\update.zip %~dp0\full\ >nul 2>nul

echo [4] ���ڼ����ļ� MD5 У���벢���� ...
for /f "delims=" %%t in ('%~dp0\usr\md5 -n %~dp0\full\changelog.xml') do set changelog_md5=%%t
for /f "delims=" %%a in ('dir /b /s %~dp0\full\changelog.xml') do set /a "changelog_size+=%%~za"
for /f "delims=" %%t in ('%~dp0\usr\md5 -n %~dp0\full\precheck-script') do set precheck_md5=%%t
for /f "delims=" %%a in ('dir /b /s %~dp0\full\precheck-script') do set /a "precheck_size+=%%~za"
for /f "delims=" %%t in ('%~dp0\usr\md5 -n %~dp0\full\update.zip') do set update_md5=%%t
for /f "delims=" %%a in ('dir /b /s %~dp0\full\update.zip') do set /a "update_size+=%%~za"
%~dp0\usr\iconvsed\iconv -f utf-8 -t gb2312 %~dp0\full\template\filelist.xml > %~dp0\full\filelist.xml.gb2312
%~dp0\usr\iconvsed\sed -i "s/hwouc_changelog_md5/%changelog_md5%/g" %~dp0\full\filelist.xml.gb2312
%~dp0\usr\iconvsed\sed -i "s/hwouc_changelog_size/%changelog_size%/g" %~dp0\full\filelist.xml.gb2312
%~dp0\usr\iconvsed\sed -i "s/hwouc_precheck_md5/%precheck_md5%/g" %~dp0\full\filelist.xml.gb2312
%~dp0\usr\iconvsed\sed -i "s/hwouc_precheck_size/%precheck_size%/g" %~dp0\full\filelist.xml.gb2312
%~dp0\usr\iconvsed\sed -i "s/hwouc_update_md5/%update_md5%/g" %~dp0\full\filelist.xml.gb2312
%~dp0\usr\iconvsed\sed -i "s/hwouc_update_size/%update_size%/g" %~dp0\full\filelist.xml.gb2312
%~dp0\usr\iconvsed\iconv -t utf-8 -f gb2312 %~dp0\full\filelist.xml.gb2312 > %~dp0\full\filelist.xml

echo [5] ���������������ʱ�ļ� ...
del %~dp0\full\*.gb2312 /f /q >nul 2>nul
del %~dp0\????????? /f /q >nul 2>nul
ping 127.1 -n 2 >NUL

echo [6] ����������ط��� ...
REM ========================================
REM      STARTING UP HTTP SERVER ENGINE
REM ========================================
set webroot=%~dp0
cd %~dp0\usr\httpd\conf
echo server {                                 >  localhost.vhost
echo     listen 80;                           >> localhost.vhost
echo     server_name  query.hicloud.com;      >> localhost.vhost
echo     charset utf-8;                       >> localhost.vhost
echo     location / {                         >> localhost.vhost
echo         root   %webroot:\=\\%;           >> localhost.vhost
echo         error_page 405 = $uri;           >> localhost.vhost
echo         rewrite "^/sp_ard_common\/v2\/Check.action(.*)"  /full/HwOUC_Response.json last; >> localhost.vhost
echo     }                                    >> localhost.vhost
echo }                                        >> localhost.vhost
cd %~dp0\usr\httpd
%~dp0\usr\hide nginx-hwouc

REM ========================================
REM        STARTING UP DNS SERVICE
REM ========================================
cd %~dp0\usr\named
echo [{                                       >  rules.cfg
echo    "Pattern": "^query\\.hicloud\\.com$", >> rules.cfg
echo    "Address": "%localIp%"                >> rules.cfg
echo }]                                       >> rules.cfg
%~dp0\usr\hide DNSAgent.exe

ping 127.1 -n 5 >NUL
echo [7] OTA �������������!
ping 127.1 -n 2 >NUL
goto :HwOUC_Server_Waiting
exit

:HwOUC_Server_Waiting
cls
echo ================================================================================
echo                          ��Ϊ�ն� OTA ����ģ�������
echo.
echo ================================================================================
echo ��Ҫ��Ϣ����ǰ OTA �����������������У�����رմ��ڣ������������ϵͳ����ʧ�ܣ�
echo --------------------------------------------------------------------------------
set /p ruok=��Ҫ�˳������� exit ���س���
if "%ruok%"=="exit" goto :HwOUC_Server_Stop_and_Exit
goto :HwOUC_Server_Waiting

:HwOUC_Server_Stop_and_Exit
echo.
echo.
echo.
echo ��������׼���˳���������;�رձ����ڣ�
echo -----------------------------------------------
echo.
echo [1] ���ڹرղ������ʱ�ļ� ...
call %~dp0\usr\clean.bat
del %~dp0\full\*.gb2312 /f /q >nul 2>nul
del %~dp0\full\*.xml /f /q >nul 2>nul
del %~dp0\full\*.json /f /q >nul 2>nul
del %~dp0\????????? /f /q >nul 2>nul
ping 127.1 -n 2 >NUL

echo [2] ���ڻ�ԭ ROM �ļ� ...
move /y %~dp0\full\update.zip %~dp0\ >nul 2>nul
move /y %~dp0\full\precheck-script %~dp0\ >nul 2>nul

echo [3] OTA �������Ѿ��ɹ��رգ��밴������˳�
pause >nul 2>nul