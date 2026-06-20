#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 19-10-2025 17.38.31
# Updates:
#
# #########################################################


####################Ã 
# Colors:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37
redH='\033[1;31m'
cyanH='\033[1;36m'
yellowH='\033[1;33m'
purpleH='\033[1;35m'
colorReset='\033[0m' # No Color



# cd /percorso/del/tuo/progetto
git init

# Rinominare il branch principale (master) in "main" (se necessario)
git branch -M main

git config --global user.name "Loreto Notarantonio"
git config --global user.email "loreto.n@gmail.com"

git config user.name "Loreto Notarantonio"
git config user.email "loreto.n@gmail.com"


: << __comment__
    5. Collegare a GitHub e fare l'upload
    Passaggio 1:
    Creare un repository su GitHub
        Vai su github.com
        Accedi con il tuo account
        Clicca su "+" in alto a destra → "New repository"
        Dai un nome al repository (es: mio-progetto)
        Non inizializzare il repository con README, .gitignore o licenza (poiché hai già file locali)
        Clicca "Create repository"
    Passaggio 2:
    Collegare il repository remoto e fare il push
        Dopo aver creato il repository su GitHub, esegui questi comandi:
__comment__

# Aggiungere il repository remoto
git remote add origin https://github.com/tuousername/mio-progetto.git

