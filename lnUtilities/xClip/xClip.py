#!/usr/bin/python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 20-06-2026 14.59.31
#
# Funzione per eseguire editor (nano in questo esempio) sulla stringa selezionata
# Assicurati che 'xclip' sia installato (sudo apt install xclip)

import argparse
import logging
import os
import subprocess
import sys
from pathlib import Path
from typing import cast

# from typing import Optional

sys.dont_write_bytecode = True

fDEBUG = False
XCLIP_ROOT_DIR_FILE = "/tmp/xclip_rootdir"  # ✅ Definita qui


# -------------------------
# Logging setup
# -------------------------
def setLogger(filename: str, level: int = logging.INFO):
    logger = logging.getLogger("LnLogger")
    logger.setLevel(logging.DEBUG)

    file_handler = logging.FileHandler(filename)
    file_handler.setLevel(level)

    formatter = logging.Formatter(
        fmt="%(asctime)s [%(module)s.:%(lineno)4s] [%(levelname)4s] : %(message)s",
        datefmt="%H:%M:%S",
        style="%",
    )

    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    return logger


def findFileInDir(_path: str, _filename: str) -> None:
    """Cerca un file in una directory specifica."""
    # TODO: Implementare questa funzione
    pass


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
    if not Path(filename).suffix:
        filenames = [f"{filename}{ext}" for ext in DEFAULT_EXTENSIONS]
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
        comando = ["xclip", "-o", "-selection", tipo_appunti]
        risultato = subprocess.run(comando, capture_output=True, text=True, check=True)
        return risultato.stdout.strip()
    except subprocess.CalledProcessError as e:
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

    # ✅ Controllo che riga non sia None
    if riga is None:
        return None

    riga = os.path.expandvars(riga)
    riga = riga.replace(":", " ").replace(",", " ").replace("(", " ").replace(")", " ")
    token = riga.split()
    ret_value = None

    logger.info("tokens: %s", token)
    if not token:
        return None

    filepath = token.pop(0)
    line_no = 1

    for inx, word in enumerate(token):
        if word in ["line", "line:"]:
            line_no = token[inx + 1]
            break
        elif word.isdigit():  # ✅ Corretto
            line_no = int(word)
            break

    filepath = filepath.strip(""" "' """)
    if not os.path.isabs(filepath):
        # ✅ Controllo rootDir
        if rootDir is None:
            logger.error("rootDir is None")
            return None
        filepath = findFileInPath(root=rootDir, filename=Path(filepath).name)
    # else: filepath = filepath (non serve)

    if filepath and os.path.exists(filepath):
        ret_value = f"{filepath}:{int(line_no)}"
    else:
        logger.error("filepath %s NOT FOUND", filepath)

    return ret_value


##############################################################
# - Parse Input
##############################################################
def parserInput() -> argparse.Namespace:
    default_value: str = "[%(default)s]\n\n"  # ✅ indentato correttamente
    parser = argparse.ArgumentParser(description="xClip")
    _ = parser.add_argument(
        "--file",
        required=False,
        metavar="",
        default=XCLIP_ROOT_DIR_FILE,  # ✅ ora definita
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
    logger = setLogger(filename=xclip_logg_filename, level=logging.INFO)
    sublime_editor = [
        "/home/loreto/filu/Applications/linuxPortable/SublimeText4/sublime_text"
    ]
    zed_editor = [
        "/usr/bin/flatpak",
        "run",
        "dev.zed.Zed",
        "--user-data-dir",
        "/home/loreto/filu/lnEnv/config/appls/zed",
    ]
    editor_command: list[str] = sublime_editor
    args = parserInput()
    file_path: str = cast(str, args.file)  # ✅ Forza il tipo
    ffile = Path(file_path)
    rootDir: str | None = None
    try:
        with ffile.open(mode="r") as f:
            content = f.read()
        if content:
            rootDir = content.split()[0]
            if not Path(rootDir).is_dir():
                rootDir = os.curdir
        else:
            rootDir = None

    except FileNotFoundError:
        logger.error(f"File {ffile} not found")
        sys.exit(1)

    except PermissionError:
        logger.error(f"Permission denied reading {ffile}")
        sys.exit(1)

    except Exception as e:  # ✅ Cattura tutto il resto ma è esplicito
        logger.error(f"Unexpected error: {e}", exc_info=True)
        sys.exit(1)

    if rootDir:
        testo_copiato: str | None = leggi_clipboard("clipboard")
        testo_selezionato: str | None = leggi_clipboard("primary")
        logger.info("-")
        logger.info("-")
        logger.info("-")
        logger.info("defaul editor:                           %s", editor_command)
        logger.info("Clipboard (Ctrl+C).....................: %s", testo_copiato)
        logger.info("Primary Selection (selezione col mouse): %s", testo_selezionato)
        logger.info("rootDir:                                 %s", rootDir)

        # ✅ Chiamata corretta
        file_to_be_edited = analizza_riga(riga=testo_selezionato, rootDir=rootDir)

        if not file_to_be_edited:
            file_to_be_edited = analizza_riga(riga=testo_copiato, rootDir=rootDir)
            if not file_to_be_edited:
                file_to_be_edited = xclip_logg_filename
    else:
        logger.info("may be you should run .cdd command to set current directory")
        file_to_be_edited = xclip_logg_filename

    if file_to_be_edited:
        # editor_command: list[str] = [editor_command, file_to_be_edited]
        # editor_command: list[str] = editor_command + list(file_to_be_edited)
        editor_command.append(file_to_be_edited)
        if fDEBUG:
            print(editor_command)
        process = subprocess.Popen(editor_command)
        _ = process.wait()
