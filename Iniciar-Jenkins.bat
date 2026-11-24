@echo off
title Servidor Jenkins (http://localhost:8080)
echo ========================================================
echo               INICIANDO SERVIDOR JENKINS
echo ========================================================
echo.
echo Servidor: http://localhost:8080
echo Nota: Mantener esta ventana abierta mientras uses Jenkins.
echo Para detenerlo, simplemente cierra esta ventana.
echo.
cd /d "C:\Jenkins"
java -jar jenkins.war --httpPort=8080
pause
