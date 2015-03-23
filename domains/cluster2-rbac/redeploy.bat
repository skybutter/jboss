@echo off
setlocal

IF "%1"=="" (
   echo Usage:
   echo   %0 app-name
   echo Example:
   echo   %0 framework.ear
   echo   %0 muni.ear -new
   goto :theend
)
call setenv.bat

set APP=%1
set finalname=%APP%
set RELEASE_DIR=./releases
set NOPAUSE=true

set UNDEPLOY=%2

echo *********************************************
echo JAVA_HOME=%JAVA_HOME%
echo JBOSS_MGMT=%JBOSS_MGMT%
echo DOMAIN_DIR=%DOMAIN_DIR%
echo RELEASE_DIR=%RELEASE_DIR%
echo finalname=%finalname%
echo *********************************************
@REM ##############
@REM ## Undeploy
@REM ##############
echo UNDEPLOY=%UNDELPOY%
IF NOT "%UNDEPLOY%"=="-new" (
	echo Undeploying %APP%
   call %JBOSS_HOME%\bin\jboss-cli.bat -c --controller=%JBOSS_MGMT% --command="undeploy %finalname% --server-groups=%SERVER_GROUP%"
) else (
    echo "Skipping undeploy."
)
@REM ##############
@REM ## Deploy
@REM ##############
echo Deploying %APP%
%JBOSS_HOME%\bin\jboss-cli.bat -c --controller=%JBOSS_MGMT% --command="deploy %RELEASE_DIR%/%finalname% --unmanaged --server-groups=%SERVER_GROUP%"

:theend

endlocal
@echo off
