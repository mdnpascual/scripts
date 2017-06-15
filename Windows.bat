@ECHO OFF
SetLocal EnableDelayedExpansion

::Serial number
for /f "delims== skip=1" %%A IN ('wmic bios get serialnumber') DO if not defined line set "line=%%A"
CALL :TRIM line
ECHO %line%>> logfile.txt

::Bios ver
for /F "delims== skip=1" %%B IN ('wmic bios get smbiosbiosversion') DO if not defined line2 set "line2=%%B"
CALL :TRIM line2
ECHO %line2%>> logfile.txt
::echo %line2% >> logfile.txt

::Model
for /f "delims== skip=1" %%C IN ('wmic computersystem get manufacturer') DO if not defined line3 set "line3=%%C"
for /f "delims== skip=1" %%D IN ('wmic computersystem get model') DO if not defined line4 set "line4=%%D"
CALL :TRIM line3
CALL :TRIM line4
ECHO %line3% %line4%>> logfile.txt

::Processor
for /f "delims== skip=1" %%E IN ('wmic cpu get name') DO if not defined line5 set "line5=%%E"
CALL :TRIM line5
ECHO %line5%>> logfile.txt
::echo %line5% >> logfile.txt

::RAM
for /f "delims== skip=1" %%F IN ('wmic computersystem get TotalPhysicalMemory') DO if not defined line6 set "line6=%%F"
set /a line7=%line6:~0,4% / (1049)
echo %line7%GB>> logfile.txt

::OS
for /f "delims== skip=1" %%G IN ('wmic os get Caption') DO if not defined line8 set "line8=%%G"
CALL :TRIM line8
echo %line8%>> logfile.txt

::HDD
for /f "delims== skip=1" %%H IN ('wmic logicaldisk get size') DO if not defined line9 set "line9=%%H"
set /a line12=%line9:~0,6% / (1074)
echo %line12%GB>> logfile.txt
for /f "delims== skip=1" %%I IN ('wmic diskdrive get model') DO if not defined line10 set "line10=%%I"
CALL :TRIM line10
echo %line10%>> logfile.txt
for /f "delims== skip=1" %%J IN ('wmic diskdrive get serialnumber') DO if not defined line11 set "line11=%%J"
CALL :TRIM line11
echo %line11%>> logfile.txt

::IP
for /f "tokens=1-2 delims=:" %%K in ('ipconfig^|find "IPv4"') do set ip=%%L
set ip=%ip:~1%
echo %ip%>> logfile.txt

::MAC Address
@echo off
for /f "tokens=2 delims=:" %%M in ('ipconfig /all^| find "Physical Address"') do (
  echo %%M >> 123.txt
)

set "OldString1=-"
set "NewString1=:"
for %%x in (123.txt) do call:process "%%~x"
goto:eof 
:process
(for /f "skip=2 delims=" %%a in ('find /n /v "" "%~1"') do (  
    set "ln=%%a"  
    Setlocal enableDelayedExpansion  
    set "ln=!ln:*]=!"  
    if defined ln (
        set "ln=!ln:%OldString1%=%NewString1%!"  
    )
    echo(!ln!  
    endlocal  
))>> 234.txt

set "line="
for /F "delims=" %%N in (234.txt) do set "line=!line!|%%N"
echo !line:~1!>> 345.txt

set "OldString2= "
set "NewString2="
for %%y in (345.txt) do call:process2 "%%~y"
GOTO :EOF
:process2
(for /f "skip=2 delims=" %%b in ('find /n /v "" "%~1"') do (  
    set "ln=%%b"  
    Setlocal enableDelayedExpansion  
    set "ln=!ln:*]=!"  
    if defined ln (
        set "ln=!ln:%OldString2%=%NewString2%!"  
    )
    echo(!ln!  
    endlocal  
))>> logfile.txt
del 123.txt
del 234.txt
DEL 345.txt

::Hostname
FOR /F "usebackq" %%O IN (`hostname`) DO SET MYVAR=%%O
ECHO %MYVAR%>> logfile.txt

::Monitor
cscript monitor.vbs %MYVAR% >> 456.txt
find "EDID_SerialNumber=" 456.txt >> 567.txt
find "EDID_ModelName=" 456.txt >> 678.txt
for /f "delims=€ skip=2" %%P IN (678.txt) DO ECHO %%P >> logfile.txt
for /f "delims=€ skip=2" %%Q IN (567.txt) DO ECHO %%Q >> logfile.txt
cscript monitor.vbs %MYVAR% >> logfile2.txt

del 456.txt
del 567.txt
del 678.txt

ECHO ------------------------------------------------------ >> logfile.txt
GOTO :EOF

::trim test
::@ECHO OFF

::SET /p NAME=- NAME ? 
::ECHO "%NAME%"
::CALL :TRIM %NAME% NAME
::ECHO "%NAME%"
::PAUSE

:TRIM
SetLocal EnableDelayedExpansion
Call :TRIMSUB %%%1%%
EndLocal & set %1=%tempvar%
GOTO :EOF

:TRIMSUB
set tempvar=%*
GOTO :EOF
