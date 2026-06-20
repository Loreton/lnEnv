#!/usr/bin/bash



mySublimeDesktop_Filename="${HOME}/.local/share/applications/sublime-text_subl.desktop"
mySublimeDesktop_Filename="/tmp/sublime-text_subl.desktop__"
sublimePath="/home/loreto/lnFreex/SublimeText4/sublime_text"



function mySublimeDesktop() {
    mydata="
           [Desktop Entry]
            Version=1.0
            Type=Application
            Name=Sublime Text
            GenericName=Text Editor
            Comment=Sophisticated text editor for code, markup and prose
            # ASSICURATI CHE IL PERCORSO SIA CORRETTO!
            Exec=${sublimePath} %F
            Terminal=false
            # ASSICURATI CHE IL PERCORSO DELL'ICONA SIA CORRETTO!
            Icon=${sublimePath}/Icon/16x16/sublime-text.png
            Categories=Development;TextEditor;
            MimeType=text/plain;text/x-python;application/x-yaml;text/csv;application/json;
            StartupWMClass=Sublime_text
    "
}


# #############################################
# # ---- M A I N -----
# #############################################
    mySublimeDesktop
    if [[ -f $mySublimeDesktop_Filename ]]; then
        echo "      ERROR - file $mySublimeDesktop_Filename already exists!"
        exit 1
    fi
    touch ${mySublimeDesktop_Filename}
    # echo >${outFilename}

    while IFS= read -r line; do
        line=$(echo $line) # trim BLANKs
        [[ -z $line ]] && continue
        firstChar="${line:0:1}"
        [[ $firstChar == '#' ]] && continue
        echo $line >>${mySublimeDesktop_Filename}
    done < <(printf '%s\n' "$mydata")

    echo "-----------------------------------"
    cat $mySublimeDesktop_Filename
    echo "-----------------------------------"
    echo

    echo "modificare il file: /home/loreto/.config/mimeapps.list"
    echo "  [Default Applications]"
    echo "  # ... altre righe ..."
    echo "  text/plain=sublime-text_subl.desktop  <-- Usa Sublime per i file generici"
    echo "  text/x-python=sublime-text_subl.desktop"
    echo "  application/x-yaml=sublime-text_subl.desktop"
    echo "  text/csv=sublime-text_subl.desktop"
    echo "  application/json=sublime-text_subl.desktop"
    echo
    echo "in modo che l'associazione sia quella voluta"
    echo "una volta completato eseguire l'update  del database MIME di sistema"
    echo
    echo "      update-desktop-database ~/.local/share/applications/"