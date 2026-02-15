@echo off
setlocal enabledelayedexpansion

:: Set exiftool path (same folder as script)
set "EXIFTOOL=%~dp0exiftool.exe"

:: Check if exiftool exists
if not exist "%EXIFTOOL%" (
    echo Error: exiftool.exe not found in script directory
    echo Expected location: %EXIFTOOL%
    pause
    exit /b 1
)

:: Parse arguments
set "source="
set "dest="
set "nextIsSource=0"
set "nextIsDest=0"

for %%a in (%*) do (
    if "%%a"=="-s" (
        set "nextIsSource=1"
    ) else if "%%a"=="-d" (
        set "nextIsDest=1"
    ) else if "!nextIsSource!"=="1" (
        set "source=%%~a"
        set "nextIsSource=0"
    ) else if "!nextIsDest!"=="1" (
        set "dest=%%~a"
        set "nextIsDest=0"
    )
)

:: Validate inputs
if not defined source (
    echo Usage: %~nx0 -s ^<source_photo^> -d ^<destination_photo^>
    echo.
    echo Example: %~nx0 -s "C:\Photos\source.jpg" -d "C:\Photos\dest.jpg"
    echo Or drag and drop: %~nx0 -s [drag source] -d [drag dest]
    pause
    exit /b 1
)

if not defined dest (
    echo Error: Destination photo not specified
    echo Usage: %~nx0 -s ^<source_photo^> -d ^<destination_photo^>
    pause
    exit /b 1
)

if not exist "%source%" (
    echo Error: Source file not found: %source%
    pause
    exit /b 1
)

if not exist "%dest%" (
    echo Error: Destination file not found: %dest%
    pause
    exit /b 1
)

:: Copy EXIF data
echo Copying camera settings from:
echo   Source: %source%
echo   Dest:   %dest%
echo.

"%EXIFTOOL%" -TagsFromFile "%source%" -FocalLength -ISO -ShutterSpeed -Aperture -FNumber -ExposureTime -LensModel -Lens -LensInfo -Make -Model -ExposureCompensation -ExposureMode -ExposureProgram -MeteringMode -FocusMode -Flash -WhiteBalance -ColorSpace -Saturation -Contrast -Sharpness -DateTimeOriginal -Orientation -Copyright -Artist -overwrite_original "%dest%"

if %errorlevel% equ 0 (
    echo.
    echo Success! Camera settings copied.
) else (
    echo.
    echo Error: Failed to copy EXIF data
)

echo.
echo Press any key to close...
pause >nul

endlocal