@echo off
chcp 65001 >nul
title Eliminar y Verificar Recursos Azure - Migajeros-Cloud

set AZURE_RG=rg-migajeros-cloud

echo ========================================================
echo      ELIMINAR RECURSOS EN AZURE (Migajeros-Cloud)
echo ========================================================
echo.
echo Se eliminara el grupo de recursos: %AZURE_RG%
echo (Borra la VNet, VM, SQL Server, BD y Private Endpoint)
echo.
set /p confirmar="Estas seguro de continuar? (S/N): "

if /I not "%confirmar%"=="S" (
    echo.
    echo Operacion cancelada. No se elimino ningun recurso.
    echo.
    pause
    exit /b 0
)

echo.
echo 1. Enviando orden de eliminacion a Azure...
call az group delete --name %AZURE_RG% --yes --no-wait

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] No se pudo enviar la orden. Verifica tu sesion con 'az login'.
    pause
    exit /b 1
)

echo.
echo 2. Esperando confirmacion de borrado en Azure...
echo    (Esto suele demorar entre 1 y 3 minutos, por favor espera...)

:esperar
call az group exists --name %AZURE_RG% > existe.txt
set /p EXISTE=<existe.txt

if /I "%EXISTE%"=="true" (
    echo    ... eliminando recursos en Azure, verificando en 10 segundos...
    timeout /t 10 /nobreak >nul
    goto esperar
)

del existe.txt 2>nul

echo.
echo ========================================================
echo   [EXITO] EL GRUPO %AZURE_RG% Y TODOS SUS RECURSOS
echo   HAN SIDO ELIMINADOS POR COMPLETO DE AZURE!
echo ========================================================
echo.
pause