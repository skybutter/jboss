@echo off
setlocal
call setenv.bat

set JBOSS_HOST=host1
set JBOSS_PIDFILE=%DOMAIN_DIR%\%JBOSS_HOST%.pid

@REM #################################
@REM ## Stop JBoss
@REM #################################
echo JBOSS_HOME=%JBOSS_HOME%
echo DOMAIN_DIR=%DOMAIN_DIR%
echo JBOSS_MGMT=%JBOSS_MGMT%
echo Stopping JBoss %JBOSS_HOST% ...
call %JBOSS_HOME%\bin\jboss-cli.bat --connect controller=%JBOSS_MGMT% /host=%JBOSS_HOST%:shutdown
endlocal
