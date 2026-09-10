#!/usr/bin/python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 28-11-2025 08.57.25
#
# Funzione per eseguire editor (nano in questo esempio) sulla stringa selezionata
# Assicurati che 'xclip' sia installato

import sys; sys.dont_write_bytecode=True
import os
import subprocess
from pathlib import Path

fDEBUG=False


#########################################################
#
#########################################################
def leggi_clipboard(tipo_appunti='clipboard'):
    """Legge il contenuto degli appunti (clipboard o primary selection) usando xclip."""
    try:
        # -o: output
        # -selection: specifica quale registro usare (clipboard o primary)
        comando = ['xclip', '-o', '-selection', tipo_appunti]

        risultato = subprocess.run(
            comando,
            capture_output=True,
            text=True,
            check=True
        )
        return risultato.stdout.strip()

    except subprocess.CalledProcessError as e:
        # Questo si attiva se xclip fallisce, ad esempio se non c'Ã¨ testo negli appunti.
        print(f"ERROR: durante la lettura degli appunti: {e}")
        return None
    except FileNotFoundError:
        print("ERROR: il comando 'xclip' non Ã¨ installato o non Ã¨ nel PATH.")
        return None


#########################################################
#
#########################################################
def analizza_riga(riga: str):
    riga = os.path.expandvars(riga) ### resolve env vars
    riga = riga.replace(':', ' ').replace(',', " ").replace('(', ' ').replace(')', ' ') ### rimuovi ':' con BLANKs
    token = riga.split()
    ret_value=None

    if not token:
        return None

    filepath=token.pop(0)
    filepath=filepath.strip(''' "' ''')
    filepath=os.path.abspath(filepath)

    # import pdb; pdb.set_trace() # by Loreto
    if os.path.exists(filepath):
        ret_value = f"{filepath}:1"
        for inx, word in enumerate(token):
            if word in ['line', 'line:']: ### ex.: "/path/filename line: 90"
                line_no = token[inx+1]
                ret_value = f"{filepath}:{line_no}"
                break
            elif isinstance(int(word), int):
                '''
                    ex.: "/path/filename:90"
                    ex.: ### ex.: /home/loreto/filu/Programming/gitREPO/lnDevices/deviceManager/__main__.py(90)<module>()
                '''
                line_no = word
                ret_value = f"{filepath}:{line_no}"
                break

    else:
        print(f"ERROR: filepath '{filepath}' NOT FOUND")

    return ret_value


#########################################################
#
#########################################################
if __name__ == '__main__':
    testo_copiato = leggi_clipboard('clipboard')
    testo_selezionato = leggi_clipboard('primary')
    DEFAULT_EDITOR='/home/loreto/filu/Applications/linuxPortable/SublimeText4/sublime_text'

    file_to_be_edited = analizza_riga(testo_selezionato)
    if file_to_be_edited:
        editor_command = [DEFAULT_EDITOR, file_to_be_edited]
        if fDEBUG: print(editor_command)
        subprocess.Popen(editor_command)

    if fDEBUG:
        print(f"Clipboard (Ctrl+C).....................: '{testo_copiato}'")
        print(f"Primary Selection (selezione col mouse): '{testo_selezionato}'")