@echo off
setlocal
call setenv.bat

set JBOSS_HOST=host1
set JBOSS_PIDFILE=%DOMAIN_DIR%\%JBOSS_HOST%.pid
set JBOSS_CONSOLE_LOG=%DOMAIN_DIR%\logs\%JBOSS_HOST%.log
@REM #################################
@REM ## Clean up JBoss
@REM #################################
echo "Clean up servers\server*\tmp directory"
rd /s /q servers\server1\tmp
rd /s /q servers\server2\tmp

@REM #################################
@REM ## Start JBoss
@REM #################################
echo JBOSS_HOME=%JBOSS_HOME%
echo DOMAIN_DIR=%DOMAIN_DIR%

IF "%~1"=="" (
	echo Default: Not sending output to file.
	echo If want to sent output to file, run %0 -file or %0 -both
	echo You must have tee to send output to both display and file.
	call %JBOSS_HOME%\bin\domain.bat --domain-config=domain.xml --host-config=%JBOSS_HOST%.xml -P %DOMAIN_DIR%/configuration/%JBOSS_HOST%.properties
) ELSE (
   IF "%~1"=="-file" (
    echo "Press any key to continue after stopping server."
	call %JBOSS_HOME%\bin\domain.bat --domain-config=domain.xml --host-config=%JBOSS_HOST%.xml -P %DOMAIN_DIR%/configuration/%JBOSS_HOST%.properties > %JBOSS_CONSOLE_LOG%
   ) ELSE (
	  call %JBOSS_HOME%\bin\domain.bat --domain-config=domain.xml --host-config=%JBOSS_HOST%.xml -P %DOMAIN_DIR%/configuration/%JBOSS_HOST%.properties | tee %JBOSS_CONSOLE_LOG%
   )
)
endlocal
