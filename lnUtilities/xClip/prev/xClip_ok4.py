#!/usr/bin/python3
#
# xClip.py
#
# updated by ...: Loreto Notarantonio
# Date .........: 28-07-2026 16.48.16
#
# Edit del testo selezionato tramite shortcut.
# Cerca riferimenti a file/linea e apre il file nell'editor.
#
# Richiede:
#   sudo apt install xclip
#

import argparse
import logging
import os
import re
import subprocess
import sys
from pathlib import Path


sys.dont_write_bytecode = True


XCLIP_ROOT_DIR_FILE = os.environ.get(
    "XCLIP_ROOT_DIR_FILE",
    "/tmp/xclip.rootdir",
)


# =========================================================
# Logging
# =========================================================

def setLogger(
    filename: str,
    file_Log_level: int = logging.INFO,
    console_Log_level: int = logging.WARNING,
) -> logging.Logger:

    logger = logging.getLogger("LnLogger")
    logger.setLevel(logging.DEBUG)

    # Evita di aggiungere handler multipli se la funzione
    # viene eventualmente richiamata più volte.
    logger.handlers.clear()

    formatter = logging.Formatter(
        fmt="%(asctime)s [%(module)-20s:%(lineno)4s] "
            "[%(levelname)4s] : %(message)s",
        datefmt="%H:%M:%S",
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


# =========================================================
# File search
# =========================================================

def findFileInDir(
    path: str,
    filename: str,
) -> str | None:
    """Cerca un file direttamente nella directory indicata."""

    path_obj = Path(path)
    candidate = path_obj / filename

    if candidate.is_file():
        return str(candidate)

    return None


def findFileInPath(
    root: str,
    filename: str,
) -> str | None:
    """
    Cerca ricorsivamente filename sotto root.

    Se filename non ha estensione, prova anche una serie
    di estensioni predefinite.
    """

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

    logger.info(
        "findFileInPath: root=%s, filename=%s",
        root,
        filename,
    )

    filename = Path(filename).name

    if Path(filename).suffix:
        filenames_to_be_searched = [filename]
    else:
        filenames_to_be_searched = [
            f"{filename}{ext}"
            for ext in DEFAULT_EXTENSIONS
        ]

        # Prima prova anche il nome senza estensione.
        filenames_to_be_searched.insert(0, filename)

    logger.debug(
        "filenames_to_be_searched: %s",
        filenames_to_be_searched,
    )

    for dirpath, dirnames, files in os.walk(root):

        # Evita di entrare nei .build_stage
        dirnames[:] = [
            d for d in dirnames
            if d != ".build_stage"
        ]

        for candidate_name in filenames_to_be_searched:

            logger.debug(
                "checking for: %s",
                os.path.join(dirpath, candidate_name),
            )

            if candidate_name in files:
                full_path = os.path.join(
                    dirpath,
                    candidate_name,
                )

                logger.info(
                    "Trovato: %s",
                    full_path,
                )

                return full_path

    return None


# =========================================================
# Clipboard
# =========================================================

def leggi_clipboard(
    tipo_appunti: str = "clipboard",
) -> str | None:
    """
    Legge il contenuto degli appunti usando xclip.

    tipo_appunti:
        clipboard
        primary
    """

    try:
        comando = [
            "xclip",
            "-o",
            "-selection",
            tipo_appunti,
        ]

        risultato = subprocess.run(
            comando,
            capture_output=True,
            text=True,
            check=True,
        )

        return risultato.stdout.strip()

    except subprocess.CalledProcessError as exc:
        logger.error(
            "Errore durante la lettura degli appunti: %s",
            exc,
        )
        return None

    except FileNotFoundError:
        logger.error(
            "Il comando 'xclip' non è installato "
            "o non è nel PATH.",
        )
        return None


# =========================================================
# Source location parser
# =========================================================

def parse_source_location(
    riga: str,
) -> tuple[str, int] | None:
    """
    Cerca nella riga un riferimento del tipo:

        [file_name.func_name : 112]

    oppure:

        [file_name : 112]

    oppure un traceback Python:

        File "/path/file.py", line 232, in function

    Restituisce:

        (filepath, line_no)

    oppure None se non trova nulla.
    """

    patterns = [

        # -------------------------------------------------
        # Logger
        #
        # [file_name.func_name : 112]
        # [file_name              : 112]
        #
        # func_name viene ignorato.
        # -------------------------------------------------
        (
            "logger",
            re.compile(
                r"\[([^.]+)(?:\.[^:]+)?\s*:\s*(\d+)\]"
            ),
        ),

        # -------------------------------------------------
        # Python traceback
        #
        # File "/path/file.py", line 232
        # -------------------------------------------------
        (
            "traceback",
            re.compile(
                r'File "([^"]+)",\s+line\s+(\d+)'
            ),
        ),
    ]

    for name, pattern in patterns:

        match = pattern.search(riga)

        if match:
            filepath = match.group(1)
            line_no = int(match.group(2))

            logger.info(
                "source location [%s]: filepath=%s, line_no=%s",
                name,
                filepath,
                line_no,
            )

            return filepath, line_no

    return None


# =========================================================
# Fallback parser
# =========================================================

def parse_generic_location(
    riga: str,
) -> tuple[str, int] | None:
    """
    Fallback per forme non ancora gestite dalle regex.

    Esempi possibili:

        file.py 123
        file.py line 123
        file.py:123
        module.func 123
    """

    riga = os.path.expandvars(riga)

    # Normalizza alcuni separatori.
    normalized = (
        riga
        .replace(":", " ")
        .replace(",", " ")
        .replace("(", " ")
        .replace(")", " ")
    )

    tokens = normalized.split()

    logger.info("generic tokens: %s", tokens)

    if not tokens:
        return None

    filepath = tokens[0]
    line_no = 1

    for index, word in enumerate(tokens):

        if word in ("line", "line:"):

            if index + 1 < len(tokens):
                candidate = tokens[index + 1]

                if candidate.isdigit():
                    line_no = int(candidate)
                    break

        elif word.isdigit():

            line_no = int(word)
            break

    return filepath, line_no


# =========================================================
# Analisi riga
# =========================================================

def analizza_riga(
    riga: str | None,
    rootDir: str | None,
) -> str | None:
    """
    Analizza una riga e cerca di ottenere:

        filepath
        line_no

    Poi risolve eventualmente il filepath sotto rootDir.

    Restituisce:

        "/path/file.py:123"

    oppure None.
    """

    logger.info("processing riga: %s", riga)

    if not riga:
        return None

    riga = riga.strip()

    if not riga:
        return None

    # -----------------------------------------------------
    # 1. La selezione è già un filename completo?
    #
    # Esempio:
    #   "/home/loreto/test.py"
    # -----------------------------------------------------

    filepath_candidate = riga.strip('"').strip("'")

    if os.path.isfile(filepath_candidate):

        filepath = filepath_candidate
        line_no = 1

        logger.info(
            "riga contiene direttamente un file: %s",
            filepath,
        )

        return f"{filepath}:{line_no}"

    # -----------------------------------------------------
    # 2. Prova i formati conosciuti
    # -----------------------------------------------------

    location = parse_source_location(riga)

    # -----------------------------------------------------
    # 3. Fallback
    # -----------------------------------------------------

    if location is None:
        location = parse_generic_location(riga)

    if location is None:
        logger.warning(
            "Nessun riferimento sorgente trovato: %s",
            riga,
        )
        return None

    filepath, line_no = location

    logger.info(
        "parsed filepath=%s, line_no=%s",
        filepath,
        line_no,
    )

    # -----------------------------------------------------
    # 4. Pulizia filepath
    # -----------------------------------------------------

    filepath = filepath.strip()
    filepath = filepath.strip('"')
    filepath = filepath.strip("'")

    # -----------------------------------------------------
    # 5. Se è assoluto non serve cercarlo
    # -----------------------------------------------------

    if not os.path.isabs(filepath):

        if rootDir is None:
            logger.error("rootDir is None")
            return None

        found_filepath = findFileInPath(
            root=rootDir,
            filename=Path(filepath).name,
        )

        if found_filepath is None:
            logger.warning(
                "File non trovato: %s sotto %s",
                filepath,
                rootDir,
            )
            return None

        filepath = found_filepath

    # -----------------------------------------------------
    # 6. Controlli finali
    # -----------------------------------------------------

    if not os.path.exists(filepath):
        logger.warning(
            "filepath does not exist: %s",
            filepath,
        )
        return None

    if os.path.isdir(filepath):
        logger.error(
            "filepath is a directory: %s",
            filepath,
        )
        return None

    ret_value = f"{filepath}:{int(line_no)}"

    logger.info(
        "ret_value: %s",
        ret_value,
    )

    return ret_value


# =========================================================
# Argument parser
# =========================================================

def parserInput() -> argparse.Namespace:

    parser = argparse.ArgumentParser(
        description="xClip",
    )

    parser.add_argument(
        "--file",
        required=False,
        metavar="",
        default=XCLIP_ROOT_DIR_FILE,
        help=(
            "file containing root directories "
            "[%(default)s]"
        ),
    )

    parser.add_argument(
        "--console",
        action="store_true",
        help="console log",
    )

    parser.add_argument(
        "--zed",
        action="store_true",
        help="usa ZED editor",
    )

    return parser.parse_args()


# =========================================================
# Main
# =========================================================

if __name__ == "__main__":

    args = parserInput()

    LOG_CONSOLE = (
        logging.INFO
        if args.console
        else logging.WARNING
    )

    xclip_logg_filename = "/tmp/xclip.log"

    logger = setLogger(
        filename=xclip_logg_filename,
        file_Log_level=logging.INFO,
        console_Log_level=LOG_CONSOLE,
    )

    logger.info("starting....")

    # -----------------------------------------------------
    # Root directory file
    # -----------------------------------------------------

    ffile = Path(args.file)

    rootDirs: list[str] = []

    try:

        with ffile.open(mode="r") as f:
            content = f.read()

        if content:
            rootDirs = content.split()

    except FileNotFoundError:

        logger.error(
            "File %s not found",
            ffile,
        )
        sys.exit(1)

    except PermissionError:

        logger.error(
            "Permission denied reading %s",
            ffile,
        )
        sys.exit(1)

    except Exception as exc:

        logger.error(
            "Unexpected error: %s",
            exc,
            exc_info=True,
        )
        sys.exit(1)

    if not rootDirs:

        logger.warning(
            "May be you should run .cd command "
            "to set current directory",
        )
        sys.exit(1)

    # -----------------------------------------------------
    # Clipboard
    # -----------------------------------------------------

    testo_copiato = leggi_clipboard("clipboard")
    testo_selezionato = leggi_clipboard("primary")

    logger.info("-")
    logger.info("-")
    logger.info("-")

    logger.info(
        "Clipboard (Ctrl+C).....................: %s",
        testo_copiato,
    )

    logger.info(
        "Primary Selection (mouse).............: %s",
        testo_selezionato,
    )

    logger.info(
        "rootDirs: %s",
        rootDirs,
    )

    if not testo_selezionato:

        logger.error(
            "testo non selezionato",
        )
        sys.exit(1)

    # -----------------------------------------------------
    # Cerca il file in tutti i rootDirs
    # -----------------------------------------------------

    file_to_be_edited: str | None = None

    for root_dir in rootDirs:

        file_to_be_edited = analizza_riga(
            riga=testo_selezionato,
            rootDir=root_dir,
        )

        if file_to_be_edited:

            logger.warning(
                "text: [%s]\nfound in:\n%s",
                testo_selezionato,
                root_dir,
            )

            break

        logger.warning(
            "%s",
            testo_selezionato,
        )

        logger.warning(
            "\tNOT found in %s",
            root_dir,
        )

    # -----------------------------------------------------
    # Nessun file trovato
    # -----------------------------------------------------

    if not file_to_be_edited:

        logger.warning(
            "Nessun file trovato.",
        )

        # Se vuoi, qui potresti eventualmente aprire
        # il log di xClip.
        #
        # file_to_be_edited = xclip_logg_filename

        sys.exit(1)

    # -----------------------------------------------------
    # Editor
    # -----------------------------------------------------

    fDEBUG = True

    if args.zed:

        editor_command = [
            "/home/loreto/filu/lnEnv/start_proc/zed_start.sh",
            file_to_be_edited,
        ]

    else:

        editor_command = [
            "/home/loreto/filu/Applications/linuxPortable/SublimeText4/sublime_text",
            file_to_be_edited,
        ]

    logger.info(
        "editor command: %s",
        editor_command,
    )

    if fDEBUG:
        print(" ".join(editor_command))

    subprocess.Popen(editor_command)
