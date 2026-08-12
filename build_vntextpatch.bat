@echo off
setlocal EnableExtensions

rem Build only the managed VNTextPatch tool.
cd /d "%~dp0"
set "PROJECT=%~dp0VNTextPatch\VNTextPatch.csproj"
set "OUTPUT=%~dp0Build\VNTextPatch"
set "MSBUILD="

for /f "delims=" %%I in ('where msbuild 2^>nul') do if not defined MSBUILD set "MSBUILD=%%I"
if not defined MSBUILD if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
    for /f "usebackq delims=" %%I in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do if not defined MSBUILD set "MSBUILD=%%I"
)
if not defined MSBUILD if exist "%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe" (
    for /f "usebackq delims=" %%I in (`"%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do if not defined MSBUILD set "MSBUILD=%%I"
)

if not defined MSBUILD (
    echo MSBuild was not found. Install Visual Studio with the .NET desktop build tools.
    exit /b 1
)

if exist "%OUTPUT%" rmdir /s /q "%OUTPUT%"
mkdir "%OUTPUT%"

"%MSBUILD%" "%PROJECT%" /restore /m /nologo /p:LangVersion=9 /p:AllowUnsafeBlocks=true /p:Platform=AnyCPU /p:Configuration=Release /p:OutputPath="%OUTPUT%"
if errorlevel 1 exit /b %errorlevel%

rem Remove development-only files from the distributable output.
del /q "%OUTPUT%\*.pdb" 2>nul
del /q "%OUTPUT%\FreeMote*.xml" 2>nul
del /q "%OUTPUT%\*.txt" 2>nul

echo.
echo Build succeeded: %OUTPUT%\VNTextPatch.exe
exit /b 0
