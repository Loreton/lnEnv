#!/usr/bin/python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 20-06-2026 13.50.05
#
# Funzione per eseguire editor (nano in questo esempio) sulla stringa selezionata
# Assicurati che 'xclip' sia installato (sudo apt install xclip)

import argparse
import logging
import os
import subprocess
import sys
from pathlib import Path

# from typing import Optional

sys.dont_write_bytecode = True

fDEBUG = False


# -------------------------
# Logging setup
# -------------------------
def setLogger(filename: str, level: int = logging.INFO):
    # import logging

    # Create logger
    logger = logging.getLogger("LnLogger")
    logger.setLevel(logging.DEBUG)

    # Create file handler
    file_handler = logging.FileHandler(filename)
    file_handler.setLevel(level)

    # Define log format
    formatter = logging.Formatter(
        # fmt="%(asctime)s [%(module)s.%(funcName)s:%(lineno)4s] [%(levelname)4s] : %(message)s",
        fmt="%(asctime)s [%(module)s.:%(lineno)4s] [%(levelname)4s] : %(message)s",
        datefmt="%H:%M:%S",
        style="%",
    )

    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    return logger


def findFileInDir(path: str, filename: str): ...


def findFileInPath(root: str, filename: str):
    DEFAULT_EXTENSIONS = [
        ".py",
        ".sh",
        ".conf",
        ".yaml",
        ".json",
        ".txt",
        ".ini",
        ".cpp",
        ".c",
        ".h",
        ".tpl",
        ".alias",
    ]
    # import pdb; pdb.set_trace() # by Loreto
    if not Path(filename).suffix:
        # tentiamo possibile extensions
        filenames = [f"{filename}{ext}" for ext in DEFAULT_EXTENSIONS]
        ### inseriamo il file selezionato come primo nella lista
        filenames.insert(0, filename)
    else:
        filenames = [filename]

    for dirpath, _, files in os.walk(root):
        for filename in filenames:
            full_path = os.path.join(dirpath, filename)
            logger.debug("checking for: %s", full_path)
            if filename in files:
                logger.info("Trovato: %s", os.path.join(dirpath, filename))
                return os.path.join(dirpath, filename)
    return None


#########################################################
#
#########################################################
def leggi_clipboard(tipo_appunti: str = "clipboard") -> str | None:
    """Legge il contenuto degli appunti (clipboard o primary selection) usando xclip."""
    try:
        # -o: output
        # -selection: specifica quale registro usare (clipboard o primary)
        comando = ["xclip", "-o", "-selection", tipo_appunti]

        risultato = subprocess.run(comando, capture_output=True, text=True, check=True)
        return risultato.stdout.strip()

    except subprocess.CalledProcessError as e:
        # Questo si attiva se xclip fallisce, ad esempio se non c'è testo negli appunti.
        logger.error("ERROR: durante la lettura degli appunti: %s", e)
        return None

    except FileNotFoundError:
        logger.error("ERROR: il comando 'xclip' non è installato o non è nel PATH.")
        return None


#########################################################
#
#########################################################
def analizza_riga(riga: str | None, rootDir: str | None) -> str | None:
    logger.info("processing riga: %s", riga)
    if riga is None:  # ✅ Controllo esplicito
        return None

    if rootDir is None:  # ✅ Controllo
        logger.error("rootDir is None")
        return None

    riga: str = os.path.expandvars(riga)  ### resolve env vars
    riga = (
        riga.replace(":", " ").replace(",", " ").replace("(", " ").replace(")", " ")
    )  ### rimuovi ':' con BLANKs
    token = riga.split()
    ret_value = None

    logger.info("tokens: %s", token)
    if not token:
        return None

    filepath = token.pop(0)
    line_no = 1

    # calcolo line_no
    ### Es.: ['toYaml', '30']
    for inx, word in enumerate(token):
        if word in ["line", "line:"]:  ### example.: "/path/filename line: 90"
            line_no = token[inx + 1]
            break
        elif word.isdigit():  # ✅ controlla se è un numero
            """
                ex.: "/path/filename:90"
                ex.: ### ex.: /home/loreto/filu/Programming/gitREPO/lnDevices/deviceManager/__main__.py(90)<module>()
            """
            line_no = int(word)
            break
        # elif isinstance(int(word), int):
        #     line_no = word
        #     # ret_value = f"{filepath}:{line_no}"
        #     break

    filepath = filepath.strip(""" "' """)
    if not os.path.isabs(filepath):
        filepath = findFileInPath(root=rootDir, filename=Path(filepath).name)
    else:
        filepath = filepath

    if filepath and os.path.exists(filepath):
        ret_value = f"{filepath}:{int(line_no)}"
    else:
        logger.error("filepath %s NOT FOUND", filepath)

    return ret_value


#
##############################################################
# - Parse Input
##############################################################


def parserInput():
    default_value: str = "[%(default)s]\n\n"
    parser = argparse.ArgumentParser(description="xClip")
    _ = parser.add_argument(
        "--file",
        required=False,
        metavar="",
        default=XCLIP_ROOT_DIR_FILE,
        type=str,
        help=f"file containing root dir {default_value}",
    )

    args = parser.parse_args()

    return args


#########################################################
#
#########################################################
if __name__ == "__main__":
    global logger
    xclip_logg_filename = "/tmp/xClip.log"
    XCLIP_ROOT_DIR_FILE = "/tmp/xclip_rootdir"
    logger = setLogger(filename=xclip_logg_filename, level=logging.INFO)
    DEFAULT_EDITOR1 = (
        "/home/loreto/filu/Applications/linuxPortable/SublimeText4/sublime_text"
    )
    DEFAULT_EDITOR = "/usr/bin/flatpak run dev.zed.Zed --user-data-dir /home/loreto/filu/lnEnv/config/appls/zed"

    args = parserInput()
    rootDir: str | None = None
    try:
        ffile = Path(args.file)
        with ffile.open(mode="r") as f:
            content = f.read()  # single string
        if content:
            rootDir = content.split()[0]
            if not Path(rootDir).is_dir():
                rootDir = os.curdir
        else:
            rootDir = None

    except:
        logger.error("error loading file", exc_info=True)
        sys.exit(1)

    # if not testo_copiato and not testo_selezionato:
    #     logger.info("there is no selected data")
    #     file_to_be_edited=xclip_logg_filename

    if rootDir:
        testo_copiato: str | None = leggi_clipboard("clipboard")
        testo_selezionato: str | None = leggi_clipboard("primary")
        logger.info("-")
        logger.info("-")
        logger.info("-")
        logger.info("defaul editor:                           %s", DEFAULT_EDITOR)
        logger.info("Clipboard (Ctrl+C).....................: %s", testo_copiato)
        logger.info("Primary Selection (selezione col mouse): %s", testo_selezionato)
        logger.info("rootDir:                                 %s", rootDir)

        ### proviamo prima con il testo selezionato e poi con quello copiato
        file_to_be_edited = analizza_riga(riga=testo_selezionato, rootDir=rootDir)
        if not file_to_be_edited:
            file_to_be_edited = analizza_riga(riga=testo_copiato, rootDir=rootDir)  # type: ignore
            if not file_to_be_edited:
                file_to_be_edited = xclip_logg_filename
    else:
        logger.info("may be you should run .cdd command to set current directory")
        file_to_be_edited = xclip_logg_filename

    if file_to_be_edited:
        editor_command: list[str] = [DEFAULT_EDITOR, file_to_be_edited]
        if fDEBUG:
            print(editor_command)
        process = subprocess.Popen(editor_command)
        _ = process.wait()
