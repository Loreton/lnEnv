@echo off
if NOT DEFINED SOCKS5_PASSWORD set /P SOCKS5_PASSWORD="Please insert f602250 Itaca Password:=> "

@setlocal
    set "DestLabel=%1"
    echo %DestLabel%
    @if "%DestLabel%" == "" goto :SYNTAX
    set "scriptPATH=%~dp0"
    set "DRIVE=%scriptPATH:~0,1%"                       &:: prendi il carattere da 0 per 1
    set "scriptPATH=e:\LnDisk\Loreto\GIT-REPO"

    @if not defined Ln.LoretoDir (
        @echo Ln.LoretoDir NON definito
        goto :EOF
    )


        :: converte \ in /%Action:~1,1%
    set "cyScriptPATH=%scriptPATH:\=/%"
    set "cyScriptPATH=/cygdrive/%DRIVE%/%cyScriptPATH:~3%"    &:: prendi dal terzo carattere in poi
    echo "%cyScriptPATH%"


    set "HOME=%scriptPATH%\homeLoreto"
    set "USERPROFILE=%scriptPATH%\homeLoreto"

    set "PATH=%scriptPATH%\SSH_Tools;%PATH%"

    :: ssh -i /cygdrive/c/Users/f602250/.ssh/id_rsa -Fe:\LnDisk\Loreto\GIT-REPO\homeLoreto\.ssh\config_via_Itaca pi@loreton.n
    :: ssh -F%cyScriptPATH%\homeLoreto\.ssh\config_via_Itaca pi@loreton.no-ip.info
    :: ssh -F/cygdrive/e/LnDisk/Loreto/GIT-REPO/homeLoreto/.ssh/config_via_Itaca %1
    :: ssh -FhomeLoreto/.ssh/config_via_Itaca %1

    set "sshCONFIG=-F%cyScriptPATH%/homeLoreto/.ssh/config_via_Itaca"
    IF "%DestLabel:~0,1%" == ":" GOTO %DestLabel%
    GOTO :SYNTAX


:LORETO
    rem ---- crea un socks
    rem ---- loreto è risolto nel ssh config file
    start "LORETO" ssh %sshCONFIG% loreto -D localhost:9946 -L 192.168.58.22:60022:localhost:22
    GOTO :EOF

:SYNTAX
    echo.
    echo.
    echo "Immettere il nome della connessione"
    echo.


:EOF
:Esci
