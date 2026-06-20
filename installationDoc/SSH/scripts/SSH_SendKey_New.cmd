@@ECHO OFF
SETLOCAL

    @SET MyKEY="/cygdrive/l/Loreto/ApplsConfig/Putty/MyKeys/LoretoBI_SSH_xx.pub_forRemoteMachine"
    @SET MyKEY="%USERPROFILE%/.ssh/id_rsa.pub"
    @SET MyKEY="/cygdrive/c/Documents and Settings/f602250/.ssh/id_rsa.pub"
    @SET REMOTE_HOST=%1
    @SET REMOTE_USER=%2
    @SET SU_USER=%3


    @if NOT DEFINED REMOTE_HOST (
        @SET /P REMOTE_HOST="Please enter remoteMachine: => "
        @SET /P REMOTE_USER="Please enter userID: => "
        @SET /P SU_USER="Please enter SU userID: => "
        )

    @if NOT DEFINED REMOTE_HOST @GOTO :ERROR
    @if NOT DEFINED REMOTE_USER @GOTO :ERROR
    @if NOT DEFINED SU_USER     @GOTO :ERROR


    @SET REMOTE_DIR=/home/%REMOTE_USER%
    @if "%REMOTE_USER%" == "root" @SET REMOTE_DIR=/root


    @CALL :EseguiCMD GO %REMOTE_HOST% %REMOTE_USER% %SU_USER% %REMOTE_DIR%
    @GOTO :Esci


:CreateRemoteScript

    @SET ShScript=SSH_SendKey_RemoteScript.sh
    @goto :EOF

    REM ----------- Qui creo lo script remoto dinamicamente (se dovesse servire)
    @SET MyKEY="l:\LnFree\Security\MyKeys\Loreto\LoretoBI_SSH_xx.pub_forRemoteMachine"
    @SET tmpFile=%TEMP%\appo_ssh.sh

     >%tmpFile% @echo #!/bin/bash
    >>%tmpFile% echo.
    >>%tmpFile% @echo baseDIR="$HOME/.ssh"
    >>%tmpFile% @echo pubKey="$baseDIR/id_rsa.pub"
    >>%tmpFile% @echo auth_Keys="$baseDIR/authorized_keys"
    >>%tmpFile% @echo @if [ ! -r "$pubKey" ]; then
    >>%tmpFile% @echo     @echo "$pubKey NOT found or NOT readable"
    >>%tmpFile% @echo     mkdir .ssh
    >>%tmpFile% @echo     chmod 700 .ssh
    >>%tmpFile% @echo     ssh-keygen -t rsa -b 1024 -N "" -f .ssh/id_rsa
    >>%tmpFile% @echo     cd $baseDIR
    >>%tmpFile% @echo fi
    >>%tmpFile% echo.
    >>%tmpFile% echo.

        REM ---------- Read First line from file  (Grande soluzione) ----------------
        REM ---------- http://stackoverflow.com/questions/130116/windows-batch-commands-to-read-first-line-from-text-file ----------------
    @set /p MyKeyValue=<%MyKEY%
        REM ---------- Write  Key ----------------
    >>%tmpFile% @echo NewKEY='%MyKeyValue%'

    >>%tmpFile% @echo @echo "$NewKEY" ^>^>$auth_Keys
    >>%tmpFile% @echo chmod 600 "$auth_Keys"

    @SET ShScript="%tmpFile%"

    type %ShScript%
    @goto :EOF


:EseguiCMD
    @SET ACTION=%1
    @SET ServerName=%2
    @SET loginUser=%3
    @SET suUser=%4
    @SET homeDir=%5
    @SET REMOTE_SERVER=%loginUser%@%ServerName%
    @SET REMOTE_DIR=%homeDir%


    @echo "-----------------------------------------------------------------"
    @echo "----------- Server:     %REMOTE_SERVER%"
    @echo "----------- homeDir:    %homeDir%"
    @echo "-----------------------------------------------------------------"


    @IF /I NOT .%ACTION%. == .GO. (
        @echo "----------- S K I P P E D"
        echo.
        @GOTO :EOF
    )
    @CALL :CreateRemoteScript


    @echo "... copia dello script sul sito remoto"
        @echo pscp -p "%ShScript%" %REMOTE_SERVER%:/tmp/ln.sh
        pscp -p "%ShScript%" %REMOTE_SERVER%:/tmp/ln.sh

    @echo "... Esecuzione dello script"
        ssh %REMOTE_SERVER% "bash /tmp/ln.sh %suUser% %homeDir%"
        ssh %REMOTE_SERVER% "rm -f /tmp/ln.sh"

    @GOTO :EOF




:EseguiSingolo
    REM @SET REMOTE_HOST=root@esil819
    REM @SET MyKEY="L:\Loreto\ApplsConfig\Putty\MyKeys\LoretoBI_SSH_xx.pub_forRemoteMachine"

    ssh %REMOTE_SERVER% "touch ~/.ssh/authorized_keys"
    cat %MyKEY%  |  ssh %REMOTE_SERVER% "cat >> ~/.ssh/authorized_keys"
    ssh %REMOTE_SERVER% "chmod 600 ~/.ssh/authorized_keys"
    @GOTO :Esci


REM # ----------------------------------------------------------------------------
REM # - Il file è così composto:
REM # - # commento
REM # - nomeMacchina userID
REM # ----------------------------------------------------------------------------
:LOOP
    @echo "lettura del file %FILE_DAT% in corso"
    FOR /F "eol=# tokens=1,2,3,4,5* delims=, " %%i IN (%FILE_DAT%) DO @CALL :EseguiCMD %%i %%j %%k %%l %%m
    @GOTO :Esci

:ERROR
    @echo "Immettere userID@remoteMachine"

:Esci
    ENDLOCAL

pause