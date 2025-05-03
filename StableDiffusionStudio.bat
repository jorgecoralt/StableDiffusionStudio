@echo off
:: ==========================================
:: Stable Diffusion Studio Installer v1.0.0
:: Autor: Jorge Coral Torres - En https://www.jorgecoral.com/stable-diffusion-studio
:: ==========================================

:: ==== Elevar permisos de Administrador ====
openfiles >nul 2>&1
if %errorlevel% NEQ 0 (
    echo [+] Se requieren permisos de administrador para continuar.
	pause 
    echo [+] Solicitando permisos...
    powershell Start-Process '%0' -Verb runAs
    exit /b
)
:: ==== Fin de elevacion ====


:: ==== Definir variables globales dinamicamente ====

set "INSTALL_DIR=%~dp0stable-diffusion-webui"
set ACCESSO_DIRECTO=%USERPROFILE%\Desktop\Stable Diffusion Studio.lnk
set VERSION_LOCAL_FILE=%INSTALL_DIR%\install_log.txt

:: ==== Confirmar ruta de instalacion ====

echo.
echo Se instalara Stable Diffusion Studio en:
echo %INSTALL_DIR%
echo.
set /p CONFIRMAR_INSTALACION=Deseas continuar con esta ruta? [S/N] (Enter = Si) :

if /i "%CONFIRMAR_INSTALACION%"=="N" (
    echo Instalacion cancelada por el usuario.
    pause
    exit /b
)

:: ==== Informar espacio requerido ====

echo.
echo Se recomienda tener al menos 10 GB libres en la unidad donde se instalara Stable Diffusion Studio.
echo.
echo Verifica manualmente si tienes suficiente espacio disponible antes de continuar.
echo.
pause



:MENU
cls
color 0A
echo.
echo ==========================================================
echo         BIENVENIDO A STABLE DIFFUSION STUDIO
echo ==========================================================
echo.
echo   [1] Instalar o Actualizar Stable Diffusion Studio
echo.
echo   [2] Revisar estado de instalacion actual
echo.
echo   [3] Desinstalar Stable Diffusion Studio
echo.
echo   [4] Salir
echo.
set /p opcion=Introduce el numero de tu opcion y presiona [Enter]: 

if "%opcion%"=="1" goto INSTALAR
if "%opcion%"=="2" goto REVISAR
if "%opcion%"=="3" goto DESINSTALAR
if "%opcion%"=="4" exit

goto MENU


:INSTALAR
cls
echo.
echo ==========================================================
echo         INSTALANDO STABLE DIFFUSION STUDIO 
echo ==========================================================
echo.

call :PREPARAR_CARPETAS
call :INSTALAR_WEBUI
call :INSTALAR_DEPENDENCIAS
call :INSTALAR_MODELOS
call :INSTALAR_EXTENSIONES
call :CREAR_ACCESO_DIRECTO
call :CREAR_INSTALL_LOG
call :CERRAR_INSTALACION


goto MENU


:PREPARAR_CARPETAS
cls
echo.
echo ==========================================================
echo         PREPARANDO CARPETA PRINCIPAL
echo ==========================================================
echo.

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
)

goto :eof

:INSTALAR_WEBUI
cls
echo.
echo ==========================================================
echo         INSTALANDO / ACTUALIZANDO WEBUI
echo ==========================================================
echo.

if not exist "%INSTALL_DIR%\webui-user.bat" (
    echo [+] Clonando repositorio de AUTOMATIC1111...
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "%INSTALL_DIR%"
    if %errorlevel% neq 0 (
        echo [X] Error al clonar el repositorio. Verifica tu conexion a Internet.
        pause
        goto MENU
    )
    echo [OK] Repositorio clonado exitosamente.
) else (
    echo [OK] Repositorio ya existente. Verificando actualizaciones...
    cd /d "%INSTALL_DIR%"
    git pull
)

:: Crear subcarpetas adicionales si no existen
cd /d "%INSTALL_DIR%"

:: Crear outputs y sus subcarpetas
if not exist "outputs" (
    mkdir "outputs"
)
if not exist "outputs\txt2img-images" (
    mkdir "outputs\txt2img-images"
)
if not exist "outputs\img2img-images" (
    mkdir "outputs\img2img-images"
)
:: Crear models\Stable-diffusion si no existe
if not exist "models\Stable-diffusion" (
    mkdir "models\Stable-diffusion"
)
:: Crear tutorials para el manual
if not exist "tutorials" (
    mkdir "tutorials"
)

:: Crear acceso directo al manual como archivo .url
if not exist "tutorials\Manual de Stable Diffusion Studio.url" (
    echo [InternetShortcut] > "tutorials\Manual de Stable Diffusion Studio.url"
    echo URL=https://jorgecoral.com/stable-diffusion-studio/ >> "tutorials\Manual de Stable Diffusion Studio.url"
)

pause

goto :eof


:INSTALAR_DEPENDENCIAS
cls
echo.
echo ==========================================================
echo        VERIFICANDO Y PREPARANDO PYTHON
echo ==========================================================
echo.

cd /d "%INSTALL_DIR%"

:: Intentar detectar la version de Python directamente
for /f "tokens=2 delims= " %%I in ('python --version 2^>nul') do set PY_VER=%%I

if "%PY_VER%"=="" (
    echo [X] No se detecto una instalacion funcional de Python.
    echo [X] Instalaremos Python 3.11.6 para corregir esto.
    timeout /t 2 >nul
    goto INSTALAR_PYTHON
)

echo [+] Version de Python detectada: %PY_VER%
set PY_MAJOR=%PY_VER:~0,1%
set PY_MINOR=%PY_VER:~2,2%

:: Si no es 3.11, ofrecer desinstalar e instalar el correcto
if not "%PY_MAJOR%"=="3" (
    goto OFRECER_CORREGIR_PYTHON
) else if not "%PY_MINOR%"=="11" (
    goto OFRECER_CORREGIR_PYTHON
)

echo [OK] Version de Python compatible detectada: %PY_VER%
goto INSTALAR_REQUERIMIENTOS


:: ------------------------------
:OFRECER_CORREGIR_PYTHON
cls
echo.
echo ==========================================================
echo        VERSION INCOMPATIBLE DE PYTHON DETECTADA
echo ==========================================================
echo.
color 0C
echo [!] Se detecto que tienes una version de Python incompatible: %PY_VER%
echo.
echo Para instalar Stable Diffusion Studio correctamente se requiere Python 3.11.6.
echo.
echo Esta version especifica es necesaria porque las herramientas utilizadas
echo dentro del sistema solo han sido validadas y son compatibles plenamente
echo con Python 3.11.6.
echo.
echo Si continuas usando otra version de Python, podias experimentar errores,
echo cierres inesperados o problemas de compatibilidad.
echo.
echo Pero no te preocupes, te ayudare a solucionarlo...
echo.
pause

cls

color 0A
echo ==========================================================
echo Que debes hacer ahora:
echo.
echo 1) Presiona la tecla de Windows en tu teclado.
echo 2) Escribe "Python" en la barra de busqueda.
echo 3) Busca la aplicacion llamada, por ejemplo:
echo    "Python 3.12.2 (64-bit)" o similares.
echo 4) Verifica que debajo diga "Aplicacion".
echo 5) Haz clic derecho sobre la aplicacion y selecciona "Desinstalar".
echo 6) Sigue los pasos hasta completar la desinstalacion.
echo.
echo ==========================================================
echo Una vez que hayas terminado la desinstalacion
echo Regresa aqui y presiona cualquier tecla 
echo para continuar con la instalacion automatica
echo de Python 3.11.6...
echo.
pause >nul
goto INSTALAR_DEPENDENCIAS


:: ------------------------------
:INSTALAR_PYTHON
cls
echo.
echo ==========================================================
echo         INSTALANDO PYTHON 3.11.6
echo ==========================================================
echo.

set "PYTHON_INSTALLER=python-3.11.6-amd64.exe"

echo [+] Descargando instalador de Python 3.11.6...
powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.6/python-3.11.6-amd64.exe' -OutFile '%PYTHON_INSTALLER%'"

if not exist "%PYTHON_INSTALLER%" (
    echo [X] No se pudo descargar el instalador de Python.
    pause
    exit /b
)

echo [+] Ejecutando instalacion silenciosa de Python...
start /wait "" "%PYTHON_INSTALLER%" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0

if %errorlevel% neq 0 (
    echo [X] Error instalando Python 3.11.6.
    pause
    exit /b
)

del "%PYTHON_INSTALLER%"

echo [OK] Python 3.11.6 instalado correctamente.
echo. 
echo Se cerrara esta ventana para finalizar la instalacion. 
echo.
echo Por favor vuelva a ejecutar despues de esto la instalacion.
pause
exit 
goto :eof

:: ------------------------------
:INSTALAR_REQUERIMIENTOS
cls
echo.
echo ==========================================================
echo         INSTALANDO DEPENDENCIAS DE PYTHON
echo ==========================================================
echo.

echo [+] Actualizando pip...
python -m pip install --upgrade pip

if %errorlevel% neq 0 (
    echo [X] Error actualizando pip.
    pause
    goto MENU
)

echo.
echo [+] Instalando requerimientos principales...
python -m pip install --prefer-binary -r requirements.txt

if %errorlevel% neq 0 (
    echo [X] Error instalando dependencias principales.
    pause
    goto MENU
)

echo.
echo [OK] Todas las dependencias instaladas correctamente.
pause

:: Agregar aquí validación de GPU
call :VALIDAR_CUDA
echo [!] Pueden haberse detectado algunas versiones más recientes de numpy o pillow que podrían generar advertencias leves.
echo [!] Stable Diffusion suele funcionar correctamente, pero podemos restaurar versiones recomendadas.

pause 

call :AJUSTAR_DEPENDENCIAS
color 0A
:: Luego seguir normal
goto INSTALAR_MODELOS


:AJUSTAR_DEPENDENCIAS
echo.
echo [+] Corrigiendo posibles conflictos de versiones para numpy y pillow...
python -m pip install numpy==1.26.4 pillow==10.2.0
echo [OK] Dependencias ajustadas.
goto :eof


:VALIDAR_CUDA
cls
echo.
echo ==========================================================
echo          VERIFICANDO USO DE GPU (CUDA) EN PYTORCH
echo ==========================================================
echo.

:: Crear un pequeño script de Python para validar
set VALIDACION_CUDA=validar_cuda.py

echo import torch > %VALIDACION_CUDA%
echo if torch.cuda.is_available(): print("[OK] GPU disponible:", torch.cuda.get_device_name(0)) >> %VALIDACION_CUDA%
echo else: print("[X] GPU no disponible o Torch no tiene soporte CUDA.") >> %VALIDACION_CUDA%

:: Ejecutar el script
python "%VALIDACION_CUDA%"

:: Borrar el script temporal
del "%VALIDACION_CUDA%"

:: Preguntar al usuario si desea reinstalar Torch con soporte CUDA si no detecta GPU
echo.
set /p REINSTALAR_TORCH=¿Deseas reinstalar PyTorch con soporte CUDA 11.8? [S/N] (Enter = No): 

if /i "%REINSTALAR_TORCH%"=="S" (
    call :REINSTALAR_TORCH_CUDA
) else (
    echo [!] Continuando sin reinstalar Torch.
    timeout /t 2 >nul
)

goto :eof


:REINSTALAR_TORCH_CUDA
cls
echo.
echo ==========================================================
echo     REINSTALANDO PYTORCH CON SOPORTE CUDA 11.8
echo ==========================================================
echo.

:: Activar entorno virtual si quieres ser más preciso aquí si usas venv (opcional)

echo [+] Forzando reinstalacion de torch, torchvision y torchaudio...

python -m pip install --force-reinstall torch==2.0.1+cu118 torchvision==0.15.2+cu118 torchaudio==2.0.2 --index-url https://download.pytorch.org/whl/cu118


if %errorlevel% neq 0 (
    echo [X] Error reinstalando PyTorch.
    pause
    goto MENU
)

echo [OK] PyTorch reinstalado correctamente con soporte CUDA 11.8.
timeout /t 2 >nul

goto :eof


:INSTALAR_MODELOS
cls
echo.
echo ==========================================================
echo           INSTALAR MODELOS DISPONIBLES 
echo ==========================================================
echo.
echo IMPORTANTE:
echo - Cada modelo ocupa entre 4 GB y 6 GB de espacio en disco.
echo - Asegurate de tener suficiente espacio disponible antes de descargar.
echo.

echo Modelos disponibles:
echo.
echo [1] Stable Diffusion v1.5 (4.0 GB aprox.)
echo     - Modelo generalista rapido y versatil. Ideal para empezar.
echo [2] Realistic Vision v5.0 (5.2 GB aprox.)
echo     - Realismo fotografico de alta calidad.
echo [3] Dreamlike Diffusion 1.0 (4.1 GB aprox.)
echo     - Estilo arte fantastico y onirico.
echo [4] Anything V5 (3.9 GB aprox.)
echo     - Estilo anime/manga de alta calidad.
echo [5] No descargar modelos ahora
echo.

set /p MODELOS_ELEGIDOS=Que modelos deseas instalar? (Ej: 1,3,4) :

if "%MODELOS_ELEGIDOS%"=="" goto :eof

for %%a in (%MODELOS_ELEGIDOS%) do (
    if "%%a"=="1" call :DESCARGAR_MODELO "StableDiffusion-v1-5" "https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors" "4.0 GB"
    if "%%a"=="2" call :DESCARGAR_MODELO "RealisticVision-v5" "https://civitai.com/api/download/models/109046" "5.2 GB"
    if "%%a"=="3" call :DESCARGAR_MODELO "DreamlikeDiffusion-1.0" "https://huggingface.co/dreamlike-art/dreamlike-diffusion-1.0/resolve/main/dreamlike-diffusion-1.0.safetensors" "4.1 GB"
    if "%%a"=="4" call :DESCARGAR_MODELO "AnythingV5" "https://civitai.com/api/download/models/94057" "3.9 GB"
    if "%%a"=="5" goto :eof
)

goto :eof

:DESCARGAR_MODELO
set MODEL_NAME=%~1
set MODEL_URL=%~2
set MODEL_PESO=%~3

if exist "%INSTALL_DIR%\\models\\Stable-diffusion\\%MODEL_NAME%.safetensors" (
    echo [OK] El modelo %MODEL_NAME% ya esta instalado.
	pause
    goto :eof
)

echo [+] Descargando %MODEL_NAME% (%MODEL_PESO%)...
powershell -Command "Invoke-WebRequest -Uri '%MODEL_URL%' -OutFile '%INSTALL_DIR%\\models\\Stable-diffusion\\%MODEL_NAME%.safetensors'"
echo
echo

if exist "%INSTALL_DIR%\\models\\Stable-diffusion\\%MODEL_NAME%.safetensors" (
    echo
	echo [OK] Modelo %MODEL_NAME% instalado correctamente.
	pause
) else (
	echo
    echo [X] Error descargando %MODEL_NAME%.
	pause
)

goto :eof


:INSTALAR_EXTENSIONES
cls
echo.
echo ==========================================================
echo               INSTALAR EXTENSIONES (Plugins)
echo ==========================================================
echo.

if not exist "%INSTALL_DIR%\extensions" (
    mkdir "%INSTALL_DIR%\extensions"
)

call :PREGUNTAR_EXTENSION "ControlNet" "Permite controlar poses, bordes, profundidad y guias visuales." "https://github.com/Mikubill/sd-webui-controlnet.git" "300 MB aprox." "Recomendado"
call :PREGUNTAR_EXTENSION "Ultimate SD Upscale" "Permite aumentar resolucion de imagenes sin perder calidad." "https://github.com/Coyote-A/ultimate-upscale-for-automatic1111.git" "50 MB aprox." "Opcional"
call :PREGUNTAR_EXTENSION "Dynamic Prompts" "Genera prompts aleatorios para mayor creatividad." "https://github.com/adieyal/sd-dynamic-prompts.git" "5 MB aprox." "Opcional"
call :PREGUNTAR_EXTENSION "Tiled Diffusion" "Permite generar imagenes ultra grandes dividiendo en partes." "https://github.com/pkuliyi2015/multidiffusion-upscaler-for-automatic1111.git" "100 MB aprox." "Opcional"
call :PREGUNTAR_EXTENSION "Real-ESRGAN - Upscaler" "Mejora la nitidez de imagenes generadas." "https://github.com/xinntao/Real-ESRGAN.git" "300 MB aprox." "Recomendado"

goto :eof


:PREGUNTAR_EXTENSION
set EXT_NAME=%~1
set EXT_DESC=%~2
set EXT_REPO=%~3
set EXT_PESO=%~4
set EXT_NECESIDAD=%~5

echo.
echo ==========================================================
echo.
echo [%EXT_NAME%]
echo - %EXT_DESC%
echo - Peso estimado: %EXT_PESO%
echo - Recomendacion: %EXT_NECESIDAD%
echo.

if exist "%INSTALL_DIR%\extensions\%EXT_NAME%" (
    echo [OK] %EXT_NAME% ya esta instalada.
	echo.
	pause
    goto :eof
)

set /p INSTALAR_EXT=Deseas instalar %EXT_NAME%? [S/N] (Enter = Si) :

if /i "%INSTALAR_EXT%"=="N" (
    echo [!] Saltando %EXT_NAME%.
    goto :eof
)

cd /d "%INSTALL_DIR%\extensions"
echo [+] Instalando %EXT_NAME%...
git clone %EXT_REPO% "%EXT_NAME%"

if exist "%INSTALL_DIR%\extensions\%EXT_NAME%" (
    echo [OK] %EXT_NAME% instalado correctamente.
) else (
    echo [X] Error instalando %EXT_NAME%.
)

pause

goto :eof

:CREAR_ACCESO_DIRECTO
cls
echo.
echo ==========================================================
echo             CREANDO ACCESO DIRECTO 
echo ==========================================================
echo.

:: Definir ruta del icono
set ICONO_URL=https://raw.githubusercontent.com/jorgecoralt/stable-diffusion-studio/main/favicon.ico
set ICONO_PATH=%INSTALL_DIR%\logo.ico

:: Descargar el icono si no existe
if not exist "%ICONO_PATH%" (
    echo [+] Descargando icono personalizado...
    powershell -Command "Invoke-WebRequest -Uri '%ICONO_URL%' -OutFile '%ICONO_PATH%'"
)

:: Verificar si existe carpeta Desktop
if exist "%USERPROFILE%\Desktop" (
    set DESTINO_DIRECTO=%USERPROFILE%\Desktop\Stable Diffusion Studio.lnk
) else (
    set DESTINO_DIRECTO=%INSTALL_DIR%\tutorials\Stable Diffusion Studio.lnk
    set CREAR_MANUALMENTE=1
)

:: Crear acceso directo
powershell -Command ^
 $WshShell = New-Object -ComObject WScript.Shell; ^
 $Shortcut = $WshShell.CreateShortcut('%DESTINO_DIRECTO%'); ^
 $Shortcut.TargetPath = '%INSTALL_DIR%\webui-user.bat'; ^
 $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; ^
 if (Test-Path '%ICONO_PATH%') { $Shortcut.IconLocation = '%ICONO_PATH%' }; ^
 $Shortcut.Description = 'Lanzador de Stable Diffusion Studio'; ^
 $Shortcut.Save()

echo.

if defined CREAR_MANUALMENTE (
    echo [!] No se detecto carpeta Escritorio. 
    echo [!] El acceso directo fue creado en la carpeta 'stable-diffusion-webui\tutorials'.
    echo [!] Puedes moverlo manualmente al Escritorio si lo deseas.
) else (
    echo [OK] Acceso directo creado exitosamente en el Escritorio.
)

echo.
pause
goto :eof


:CREAR_INSTALL_LOG
cls
echo.
echo ==========================================================
echo             CREANDO REGISTRO DE INSTALACION  
echo ==========================================================
echo.

(
echo Stable Diffusion Studio - Install Log
echo Fecha de instalacion: %DATE%
echo Version instalada: 1.0.0
echo.
echo Modelos instalados:
dir /b "%INSTALL_DIR%\models\Stable-diffusion\*.safetensors"
echo.
echo Extensiones instaladas:
dir /b "%INSTALL_DIR%\extensions"
) > "%INSTALL_DIR%\install_log.txt"

echo [OK] Registro de instalacion generado correctamente en 'stable-diffusion-webui\install_log.txt'.
pause
goto :eof


:CERRAR_INSTALACION
cls
echo.
echo ==========================================================
echo             INSTALACION COMPLETADA EXITOSAMENTE 
echo ==========================================================
echo.
echo Felicidades! Stable Diffusion Studio esta listo para usarse.
echo.
echo ==========================================================
echo.
echo Hemos creado un acceso directo en tu escritorio o en la carpeta tutorials llamado: 'Stable Diffusion Studio'.
echo.
echo ==========================================================
echo.
echo Tambien puedes acceder al manual desde la carpeta 'tutorials' 
echo o cuando quieras ingresando directamente en la web https://jorgecoral.com/stable-diffusion-studio/
echo.
echo ==========================================================
echo.

:: Limpiar entorno virtual previo si existe
if exist "%INSTALL_DIR%\venv" (
	echo [+] Buscando carpeta: "%INSTALL_DIR%\venv"
    echo [OK] venv encontrado
	echo [+] Limpiando entorno virtual -venv-
	pause
	rmdir /s /q "%INSTALL_DIR%\venv"
)

echo.
echo ==========================================================
echo.

:: === CONFIGURAR WEBUI PARA MODO CPU SI NO HAY GPU ===
where nvidia-smi >nul 2>nul
if %errorlevel% neq 0 (
    echo [+] No se detecto GPU NVIDIA. Se configurara Stable Diffusion Studio para funcionar en modo CPU...
    powershell -Command "(Get-Content '%INSTALL_DIR%\webui-user.bat') -replace 'set COMMANDLINE_ARGS=.*', 'set COMMANDLINE_ARGS=--skip-torch-cuda-test --no-half --precision full' | Set-Content '%INSTALL_DIR%\webui-user.bat'"
    echo [OK] WebUI configurado para modo CPU correctamente.
    timeout /t 1 >nul
)


echo.
echo ==========================================================
echo.
echo Abrire ahora la pagina oficial para que explores tutoriales y novedades. 
echo Puede minimizar la pagina web para volver a ver el programa de Stable Difussion Studio
echo.
echo Y tambien abrire el ejecutable del programa en un segundo plano para que termine de configurar otros componentes.
echo.
echo NOTA: Recomiendo mientras se actualiza completamente SDS revisar el sitio web 
echo http://www.jorgecoral.com/stable-diffusion-studio/
echo para aprender todo lo que necesita par usar correctamente Stable Diffusion Studio
echo.
echo ==========================================================
pause

:: Abrir la pagina web oficial
start "" "https://jorgecoral.com/stable-diffusion-studio/"

:: Abrir directamente Stable Diffusion Studio
start "" "%INSTALL_DIR%\webui-user.bat"

echo.
echo [OK] Se abrio el programa y la pagina oficial. Ya puede cerrar esta ventana.
echo.
pause
exit



:REVISAR
cls
echo.
echo ==========================================================
echo             REVISANDO INSTALACION ACTUAL 
echo ==========================================================
echo.

if not exist "%INSTALL_DIR%" (
    echo [X] No se encontro la instalacion de Stable Diffusion Studio.
    pause
    goto MENU
)

if not exist "%INSTALL_DIR%\webui-user.bat" (
    echo [X] Archivos principales faltantes. Puede que la instalacion este incompleta.
    pause
    goto MENU
)

echo [OK] Instalacion principal detectada correctamente.
echo.

echo Modelos instalados:
if exist "%INSTALL_DIR%\models\Stable-diffusion" (
    dir /b "%INSTALL_DIR%\models\Stable-diffusion\*.safetensors"
) else (
    echo No se encontraron modelos instalados.
)

echo.
echo Extensiones instaladas:
if exist "%INSTALL_DIR%\extensions" (
    dir /b "%INSTALL_DIR%\extensions"
) else (
    echo No se encontraron extensiones instaladas.
)

echo.
echo [+] Verificando dependencias de Python...
python -m pip list --outdated
echo.

echo ==========================================================
echo            Revision completada.
echo ==========================================================
echo.
pause
goto MENU


:DESINSTALAR
cls
echo.
echo ==========================================================
echo            DESINSTALAR STABLE DIFFUSION STUDIO
echo ==========================================================
echo.
echo Vas a eliminar Stable Diffusion Studio del sistema.
echo Esto incluira modelos, extensiones y configuraciones locales.
echo.

if exist "%INSTALL_DIR%\models\Stable-diffusion" (
    echo Modelos detectados:
    dir /b "%INSTALL_DIR%\models\Stable-diffusion\*.safetensors"
) else (
    echo No se encontraron modelos personalizados.
)

echo.
echo Recuerda: Python y Git NO se eliminaran.
echo.
set /p CONFIRMAR_BORRAR=Seguro que deseas eliminar todo? [S/N] (Enter = No): 

if /i "%CONFIRMAR_BORRAR%" NEQ "S" (
    echo Cancelando desinstalacion.
    pause
    goto MENU
)

:: Borrar carpeta principal
rmdir /s /q "%INSTALL_DIR%"

:: Borrar acceso directo
if exist "%ACCESSO_DIRECTO%" (
    del "%ACCESSO_DIRECTO%"
)

echo.
echo [OK] Stable Diffusion Studio eliminado exitosamente.
echo.

pause
goto MENU
