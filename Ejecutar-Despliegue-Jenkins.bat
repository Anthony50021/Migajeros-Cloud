@echo off
chcp 65001 >nul
title Ejecutar y Verificar Despliegue - Migajeros-Cloud

set JENKINS_URL=http://localhost:8080
set JENKINS_USER=admin
set JENKINS_PASS=abc123$
set JOB_NAME=pipeline-contingencia-azure
set AZURE_RG=rg-migajeros-cloud

echo ========================================================
echo     DISPARANDO PIPELINE EN JENKINS (Migajeros-Cloud)
echo ========================================================
echo.
echo 1. Conectando con Jenkins...

curl -s -c cookies.txt -u "%JENKINS_USER%:%JENKINS_PASS%" "%JENKINS_URL%/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)" > crumb.txt
set /p CRUMB=<crumb.txt

if "%CRUMB%"=="" (
    echo.
    echo [ERROR] No se pudo conectar a Jenkins.
    echo Verifica que Iniciar-Jenkins.bat este abierto.
    del cookies.txt crumb.txt 2>nul
    pause
    exit /b 1
)

echo 2. Iniciando despliegue del Job: %JOB_NAME%...
curl -s -o nul -w "Codigo HTTP: %%{http_code}\n" -X POST -b cookies.txt -u "%JENKINS_USER%:%JENKINS_PASS%" -H "%CRUMB%" "%JENKINS_URL%/job/%JOB_NAME%/build"

echo.
echo 3. Esperando a que Jenkins termine de crear los recursos en Azure...
echo    (Esto suele demorar entre 1 y 3 minutos, por favor espera...)
timeout /t 8 /nobreak >nul

:esperar
curl -s -u "%JENKINS_USER%:%JENKINS_PASS%" "%JENKINS_URL%/job/%JOB_NAME%/lastBuild/api/json?tree=building,result" > status.txt
findstr /C:"\"building\":true" status.txt >nul
if %errorlevel% equ 0 (
    echo    ... desplegando en Azure, verificando en 5 segundos...
    timeout /t 5 /nobreak >nul
    goto esperar
)

echo.
findstr /C:"\"result\":\"SUCCESS\"" status.txt >nul
if %errorlevel% equ 0 (
    echo ========================================================
    echo   [EXITO] DESPLIEGUE COMPLETADO EN AZURE!
    echo ========================================================
    echo.
    echo Listando recursos creados en %AZURE_RG%:
    echo.
    call az resource list --resource-group %AZURE_RG% --output table
) else (
    echo ========================================================
    echo   [ERROR] El pipeline fallo o fue cancelado.
    echo   Revisa el detalle en: %JENKINS_URL%/job/%JOB_NAME%/
    echo ========================================================
)

:: Limpiar archivos temporales
del cookies.txt crumb.txt status.txt 2>nul

echo.
pause