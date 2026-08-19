#!/usr/bin/python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 11-07-2026 18.07.32
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

XCLIP_ROOT_DIR_FILE=os.environ.get("XCLIP_ROOT_DIR_FILE", "/tmp/xclip.rootdir")   # ✅ Definita qui


# -------------------------
# Logging setup
# -------------------------
def setLogger(filename: str, file_Log_level: int = logging.INFO, console_Log_level: int = logging.WARNING):
    logger = logging.getLogger("LnLogger")
    logger.setLevel(logging.DEBUG)

    formatter = logging.Formatter(
        fmt="%(asctime)s [%(module)-20s:%(lineno)4s] [%(levelname)4s] : %(message)s",
        datefmt="%H:%M:%S",
        style="%",
    )

    file_handler = logging.FileHandler(filename)
    file_handler.setLevel(file_Log_level)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)

    console_handler = logging.StreamHandler()
    console_handler.setLevel(console_Log_level)
    console_handler.setFormatter(formatter)
    logger.addHandler(console_handler)

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
    logger.info("findFileInPath: root=%s, filename=%s", root, filename)
    if not Path(filename).suffix:
        filenames_to_be_searched = [f"{filename}{ext}" for ext in DEFAULT_EXTENSIONS]
        filenames_to_be_searched.insert(0, filename)
    else:
        filenames_to_be_searched = [filename]

    for dirpath, _, files in os.walk(root):
        for filename in filenames_to_be_searched:
            full_path = os.path.join(dirpath, filename)
            if ".build_stage" in full_path:
                continue
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
    ret_value = None

    # ✅ Controllo che riga non sia None
    if riga is None:
        return ret_value

    riga = os.path.expandvars(riga)
    riga = riga.replace(":", " ").replace(",", " ").replace("(", " ").replace(")", " ")
    token = riga.split()

    logger.info("tokens: %s", token)
    if not token:
        return ret_value

    filepath = token.pop(0)
    line_no = 1

    for inx, word in enumerate(token):
        if word in ["line", "line:"]:
            line_no = token[inx + 1]
            break
        elif word.isdigit():  # ✅ Corretto
            line_no = int(word)
            break
    logger.info("filepath: %s, line_no: %s", filepath, line_no)

    filepath = filepath.strip(""" "' """)
    if not os.path.isabs(filepath):
        # ✅ Controllo rootDir
        if rootDir is None:
            logger.error("rootDir is None")
            return None
        filepath = findFileInPath(root=rootDir, filename=Path(filepath).name)

    logger.info("filepath: %s, line_no: %s", filepath, line_no)
    if filepath and os.path.exists(filepath):
        ret_value = f"{filepath}:{int(line_no)}"
    # else:
    #     logger.error("filepath %s NOT FOUND", filepath)

    logger.info("ret_value: %s", ret_value)
    return ret_value


##############################################################
# - Parse Input
##############################################################
def parserInput() -> argparse.Namespace:
    default_value: str = "[%(default)s]\n\n"  # ✅ indentato correttamente
    parser = argparse.ArgumentParser(description="xClip")
    _ = parser.add_argument("--file", required=False, metavar="", default=XCLIP_ROOT_DIR_FILE, help=f"file containing root dir {default_value}", )
    _ = parser.add_argument("--console",  action='store_true',  help=f"console log {default_value}", )
    _ = parser.add_argument("--zed",  action='store_true',  help=f"usa ZED editor {default_value}", )

    args = parser.parse_args()
    return args


#########################################################
#
#########################################################
if __name__ == "__main__":
    global logger
    args = parserInput()
    LOG_CONSOLE=logging.INFO if args.console else logging.WARNING

    xclip_logg_filename = "/tmp/xclip.log"
    logger = setLogger(filename=xclip_logg_filename, file_Log_level=logging.INFO, console_Log_level=LOG_CONSOLE)
    logger.info("starting....")
    file_path: str = cast(str, args.file)  # ✅ Forza il tipo
    ffile = Path(file_path)
    rootDirs: list[str]|list[Path]  = [Path(os.path.curdir).resolve()]

    ### --- read RootDirectory for searching files
    try:
        with ffile.open(mode="r") as f:
            content = f.read()
        if content:
            rootDirs = content.split()

    except FileNotFoundError:
        logger.error(f"File {ffile} not found")
        sys.exit(1)

    except PermissionError:
        logger.error(f"Permission denied reading {ffile}")
        sys.exit(1)

    except Exception as e:  # ✅ Cattura tutto il resto ma è esplicito
        logger.error(f"Unexpected error: {e}", exc_info=True)
        sys.exit(1)

    if rootDirs:
        testo_copiato: str | None = leggi_clipboard("clipboard")
        testo_selezionato: str | None = leggi_clipboard("primary")
        logger.info("-")
        logger.info("-")
        logger.info("-")
        # logger.info("default editor:                          %s", editor_command)
        logger.info("Clipboard (Ctrl+C).....................: %s", testo_copiato)
        logger.info("Primary Selection (selezione col mouse): %s", testo_selezionato)
        logger.info("rootDirs:                                 %s", rootDirs)

        if not testo_selezionato.strip():
            logger.error("test non selezionato")
            sys.exit(1)

        # ✅ Chiamata corretta
        for root_dir in rootDirs:
            file_to_be_edited = analizza_riga(riga=testo_selezionato, rootDir=root_dir)
            if file_to_be_edited:
                logger.warning("[%s]\n\tfound in %s", testo_selezionato, root_dir)
                break
            else:
                logger.warning(testo_selezionato)
                logger.warning("\tNOT found in %s", root_dir)
        else:
            file_to_be_edited = xclip_logg_filename
            file_to_be_edited = None

    else:
        logger.warning("may be you should run .cd command to set current directory")
        sys.exit(1)


    fDEBUG = True
    # logger.info(f"{editor_command    = }")
    # logger.info(f"{file_to_be_edited = }")

    if file_to_be_edited:
        if args.zed:
            zed_config_dir=os.path.expandvars("${ln_ZED_CONFIG_DIR}")
            editor_command = [
                "/home/loreto/.local/bin/zed", ## già include --user-data-dir
                # f"--user-data-dir={zed_config_dir}",
                file_to_be_edited,
            ]

        else:
            editor_command = [
                "/home/loreto/filu/Applications/linuxPortable/SublimeText4/sublime_text",
                file_to_be_edited,
            ]


        if fDEBUG:
            print(' '.join(editor_command))
        process = subprocess.Popen(editor_command)
        # _ = process.wait()
