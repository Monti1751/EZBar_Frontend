@echo off
REM ====================================
REM   Ejecutando Tests con Cobertura
REM   Frontend Flutter - LCOV
REM ====================================

echo.
echo ====================================
echo   Ejecutando Tests con Cobertura
echo ====================================
echo.

cd /d "%~dp0"

REM Ejecutar tests con cobertura
echo Ejecutando: flutter test --coverage
echo.
call flutter test --coverage

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ========================================
    echo   ❌ Tests fallaron
    echo ========================================
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   ✅ Tests completados exitosamente
echo ========================================
echo.
echo 📊 Reporte de cobertura generado en:
echo    coverage\lcov.info
echo.

REM Verificar si existe el reporte
if exist "coverage\lcov.info" (
    echo ✅ Archivo de cobertura generado correctamente
    echo.
    echo 📄 Para generar reporte HTML, instala genhtml y ejecuta:
    echo    genhtml coverage\lcov.info -o coverage\html
    echo.
    echo 💡 O usa una extensión de VS Code como "Coverage Gutters"
    echo    para visualizar la cobertura directamente en el editor
) else (
    echo ⚠️  No se encontró el archivo de cobertura
    echo    Verifica que los tests se hayan ejecutado correctamente
)

echo.
pause
