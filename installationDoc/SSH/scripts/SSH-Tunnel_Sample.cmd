SET MyECHO=OFF
@ECHO %MyECHO%
    SET DestLabel=%1

        REM ----------- Controlli -----------
    IF '%DestLabel%'  == '' GOTO :ERROR
    SET BKG=-N
    SET BKG=
        REM ----------- Set defaults -----------
    SET BridgeAddr=172.20.131.3
    SET BridgeAddr=172.20.131.4
    SET BridgeAddr=10.1.12.49
    SET BridgeUser=root

    SET SSH_CMD1=ssh -o ControlMaster=no -o ServerAliveInterval=30 user@remote_address
    SET SSH_CMD=ssh -o ControlMaster=no -o ServerAliveInterval=30 %BridgeUser%@%BridgeAddr%

    IF '%DestLabel:~0,1%' == ':' GOTO %1
    GOTO :%1



:appo
 ssh -o ControlMaster=no root@server -L 10.1.12.49:443:remote_address:443 -L 10.1.12.49:40443:tremote_address:40443



:SSH_PROXY
    SHIFT
    SET localPort=9999
    SET Comando=ssh -o ControlMaster=no -D 9949 root@10.1.12.49
    SET Comando=ssh -o ControlMaster=no -o ServerAliveInterval=30 -D 9943 user@remote_address
    SET Comando=ssh -o ControlMaster=no -o ServerAliveInterval=30 -D 9944 user@remote_address
    GOTO :Esegui



:SSH
    SHIFT
    SET localPort=%1
    SET destAddr=%2
    IF '%destAddr%'  == '' GOTO :ERROR
    IF '%localPort%' == '' GOTO :ERROR
    SET BKG=
    SET Comando=%SSH_CMD%  ^
        -L %localPort%:%destAddr%:22 ^
        %BKG%
    GOTO :Esegui

:BASE
    SHIFT
    SET localPort=%1
    SET destAddrAndPort=%2
    IF '%localPort%'        == '' GOTO :ERROR
    IF '%destAddrAndPort%'  == '' GOTO :ERROR
    SET Comando=%SSH_CMD%  ^
        -L %localPort%:%destAddrAndPort% ^
        %BKG%
    GOTO :Esegui


:Giulio
    SET BKG=
    SET SatelliteDOM=10.120.230.230
    SET TargetMachine=10.1.12.98
    SET TargetMachine=10.1.12.45
    REM SET SSH_CMD=ssh -o ControlMaster=no -o ServerAliveInterval=30 root@%T2ZIPL05%
    REM SET Comando=%SSH_CMD% -R 127.0.0.1:20000:%repoRHEL5%:80 %BKG%
    REM SET Comando=ssh -o ControlMaster=no -o ServerAliveInterval=30 root@%TargetMachine% ^
            REM -R 127.0.0.1:80:%SatelliteDOM%:80 ^
            REM -R 127.0.0.1:443:%SatelliteDOM%:443 ^
            REM -R 127.0.0.1:4545:%SatelliteDOM%:4545 ^
            REM -R 127.0.0.1:5269:%SatelliteDOM%:5269 ^
            REM %BKG%
    SET TargetMachine=10.1.12.49
    SET Comando=ssh -o ControlMaster=no -o ServerAliveInterval=30 root@%TargetMachine% ^
            -R %TargetMachine%:80:%SatelliteDOM%:80 ^
            -R %TargetMachine%:443:%SatelliteDOM%:443 ^
            -R %TargetMachine%:4545:%SatelliteDOM%:4545 ^
            -R %TargetMachine%:5269:%SatelliteDOM%:5269 ^
            %BKG%

    GOTO :Esegui

:_REVERSE
    SET BKG=
    SET TargetMachine=10.1.12.98
    SET TargetMachine=10.1.12.45
    REM SET SSH_CMD=ssh -o ControlMaster=no -o ServerAliveInterval=30 root@%T2ZIPL05%
    REM SET Comando=%SSH_CMD% -R 127.0.0.1:20000:%repoRHEL5%:80 %BKG%
    REM SET Comando=ssh -o ControlMaster=no -o ServerAliveInterval=30 root@%TargetMachine% ^
            REM -R 127.0.0.1:80:%SatelliteDOM%:80 ^
            REM -R 127.0.0.1:443:%SatelliteDOM%:443 ^
            REM -R 127.0.0.1:4545:%SatelliteDOM%:4545 ^
            REM -R 127.0.0.1:5269:%SatelliteDOM%:5269 ^
            REM %BKG%
    SET TargetMachine=10.1.12.49
    SET Comando=ssh -o ControlMaster=no -o ServerAliveInterval=30 root@%TargetMachine% ^
            -R %TargetMachine%:80:%SatelliteDOM%:80 ^
            -R %TargetMachine%:443:%SatelliteDOM%:443 ^
            -R %TargetMachine%:4545:%SatelliteDOM%:4545 ^
            -R %TargetMachine%:5269:%SatelliteDOM%:5269 ^
            %BKG%

    GOTO :Esegui

:Reverse
    SET BKG=
    SET TargetMachine=machine_address
    SET sourceMachine=from_machine
    SET Comando=ssh -o ControlMaster=no -o ServerAliveInterval=30 root@remote_address ^
            -R %sourceMachine%:61019:%TargetMachine%:61019 ^
            -R %sourceMachine%:60022:%TargetMachine%:22 ^
            %BKG%

    GOTO :Esegui



