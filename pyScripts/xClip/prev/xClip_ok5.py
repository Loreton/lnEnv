#!/usr/bin/python3
#
# xClip.py
#
# updated by ...: Loreto Notarantonio
# Date .........: 28-07-2026 16.48.16
#
# Funzione per eseguire editor sulla stringa selezionata.
#
# xClip:
#   - legge la Primary Selection
#   - riconosce riferimenti a file/linea
#   - cerca il file nei root directories configurati
#   - apre il file nell'editor
#
# Richiede:
#   sudo apt install xclip
#   sudo apt install zenity
#

import argparse
import logging
import os
import re
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path


sys.dont_write_bytecode = True


# =========================================================
# Configuration
# =========================================================

XCLIP_ROOT_DIR_FILE = os.environ.get(
    "XCLIP_ROOT_DIR_FILE",
    "/tmp/xclip.rootdir",
)

XCLIP_LOG_FILENAME = "/tmp/xclip.log"


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


# =========================================================
# Source location
# =========================================================

@dataclass(slots=True)
class SourceLocation:
    """
    Rappresenta una posizione all'interno di un sorgente.

    filename:
        Nome del file oppure path completo.

    line_no:
        Numero di riga.

    format:
        Formato con cui è stata riconosciuta la posizione.
        Esempi:
            logger
            traceback
            generic
            direct_file
    """

    filename: str
    line_no: int
    format: str

    def __str__(self) -> str:
        return f"{self.filename}:{self.line_no}"


# =========================================================
# Logging
# =========================================================

def setLogger(
    filename: str,
    file_Log_level: int = logging.INFO,
    console_Log_level: int = logging.WARNING,
) -> logging.Logger:
    """
    Configura il logger principale.
    """

    logger = logging.getLogger("LnLogger")
    logger.setLevel(logging.DEBUG)

    # Evita duplicazioni nel caso setLogger()
    # venga chiamato più volte.
    logger.handlers.clear()

    formatter = logging.Formatter(
        fmt=(
            "%(asctime)s "
            "[%(module)-20s:%(lineno)4s] "
            "[%(levelname)4s] : %(message)s"
        ),
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
# GUI
# =========================================================

def show_error(message: str) -> None:
    """
    Mostra un messaggio di errore grafico tramite zenity.

    Se zenity non è disponibile, l'errore viene registrato
    solamente nel log.
    """

    try:

        subprocess.run(
            [
                "zenity",
                "--error",
                "--title=xClip",
                f"--text={message}",
            ],
            check=False,
        )

    except FileNotFoundError:

        logger.error(
            "zenity non installato. Messaggio: %s",
            message,
        )


def show_info(message: str) -> None:
    """
    Mostra un messaggio informativo tramite zenity.
    """

    try:

        subprocess.run(
            [
                "zenity",
                "--info",
                "--title=xClip",
                f"--text={message}",
            ],
            check=False,
        )

    except FileNotFoundError:

        logger.info(
            "zenity non installato. Messaggio: %s",
            message,
        )


# =========================================================
# File search
# =========================================================

def findFileInDir(
    path: str,
    filename: str,
) -> str | None:
    """
    Cerca filename direttamente nella directory path.
    """

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

    Se filename non ha estensione, vengono provate
    anche le estensioni definite in DEFAULT_EXTENSIONS.
    """

    logger.info(
        "findFileInPath: root=%s, filename=%s",
        root,
        filename,
    )

    # Se arriva un path, per la ricerca ci interessa
    # solamente il nome del file.
    filename = Path(filename).name

    # -----------------------------------------------------
    # Costruzione lista nomi da cercare
    # -----------------------------------------------------

    if Path(filename).suffix:

        filenames_to_be_searched = [
            filename,
        ]

    else:

        filenames_to_be_searched = [
            f"{filename}{ext}"
            for ext in DEFAULT_EXTENSIONS
        ]

        # Prima prova comunque il nome senza estensione.
        filenames_to_be_searched.insert(
            0,
            filename,
        )

    logger.debug(
        "filenames_to_be_searched: %s",
        filenames_to_be_searched,
    )

    # -----------------------------------------------------
    # Ricerca
    # -----------------------------------------------------

    for dirpath, dirnames, files in os.walk(root):

        # Evita di scendere nei .build_stage.
        dirnames[:] = [
            dirname
            for dirname in dirnames
            if dirname != ".build_stage"
        ]

        for candidate_name in filenames_to_be_searched:

            full_path = os.path.join(
                dirpath,
                candidate_name,
            )

            logger.debug(
                "checking for: %s",
                full_path,
            )

            if candidate_name in files:

                logger.info(
                    "Trovato: %s",
                    full_path,
                )

                return full_path

    logger.info(
        "File non trovato: %s",
        filename,
    )

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
) -> SourceLocation | None:
    """
    Cerca nella riga un riferimento sorgente.

    Formati riconosciuti:

    1) Logger:

       [file_name.func_name : 112]

       [file_name : 112]

    2) Python traceback:

       File "/path/file.py", line 232, in function

    Restituisce SourceLocation oppure None.
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

    for format_name, pattern in patterns:

        match = pattern.search(riga)

        if not match:
            continue

        filepath = match.group(1)
        line_no = int(match.group(2))

        location = SourceLocation(
            filename=filepath,
            line_no=line_no,
            format=format_name,
        )

        logger.info(
            "source location found: %s",
            location,
        )

        logger.info(
            "source location format: %s",
            format_name,
        )

        return location

    return None


# =========================================================
# Generic parser
# =========================================================

def parse_generic_location(
    riga: str,
) -> SourceLocation | None:
    """
    Fallback per formati non ancora gestiti dalle regex.

    Alcuni esempi che può gestire:

        file.py 123
        file.py line 123
        file.py:123
        module.func 123
    """

    riga = os.path.expandvars(riga)

    normalized = (
        riga
        .replace(":", " ")
        .replace(",", " ")
        .replace("(", " ")
        .replace(")", " ")
    )

    tokens = normalized.split()

    logger.info(
        "generic tokens: %s",
        tokens,
    )

    if not tokens:
        return None

    filepath = tokens[0]
    line_no = 1

    # -----------------------------------------------------
    # Cerca numero di linea
    # -----------------------------------------------------

    for index, word in enumerate(tokens):

        # Esempio:
        #
        # file.py line 123
        #

        if word in ("line", "line:"):

            if index + 1 < len(tokens):

                candidate = tokens[index + 1]

                if candidate.isdigit():

                    line_no = int(candidate)
                    break

        # -------------------------------------------------
        # Qualunque numero trovato
        # -------------------------------------------------

        elif word.isdigit():

            line_no = int(word)
            break

    location = SourceLocation(
        filename=filepath,
        line_no=line_no,
        format="generic",
    )

    logger.info(
        "generic source location: %s",
        location,
    )

    return location


# =========================================================
# Analizza riga
# =========================================================

def analizza_riga(
    riga: str | None,
    rootDir: str | None,
) -> str | None:
    """
    Analizza la riga selezionata.

    Restituisce:

        /path/file.py:123

    oppure:

        None
    """

    logger.info(
        "processing riga: %s",
        riga,
    )

    # -----------------------------------------------------
    # Validazione input
    # -----------------------------------------------------

    if not riga:
        return None

    riga = riga.strip()

    if not riga:
        return None

    # -----------------------------------------------------
    # 1. La selezione è direttamente un file?
    #
    # Esempio:
    #
    # /home/loreto/test.py
    # "/home/loreto/test.py"
    #
    # In questo caso usiamo linea 1.
    # -----------------------------------------------------

    filepath_candidate = (
        riga.strip('"')
            .strip("'")
    )

    if os.path.isfile(filepath_candidate):

        location = SourceLocation(
            filename=filepath_candidate,
            line_no=1,
            format="direct_file",
        )

        logger.info(
            "direct file found: %s",
            location,
        )

        return str(location)

    # -----------------------------------------------------
    # 2. Prova i formati conosciuti
    # -----------------------------------------------------

    location = parse_source_location(riga)

    # -----------------------------------------------------
    # 3. Fallback generico
    # -----------------------------------------------------

    if location is None:
        location = parse_generic_location(riga)

    if location is None:

        logger.warning(
            "Nessun riferimento sorgente trovato: %s",
            riga,
        )

        return None

    # -----------------------------------------------------
    # 4. Estrai filepath
    # -----------------------------------------------------

    filepath = location.filename
    line_no = location.line_no

    logger.info(
        "parsed location: %s",
        location,
    )

    # -----------------------------------------------------
    # 5. Normalizzazione filepath
    # -----------------------------------------------------

    filepath = filepath.strip()
    filepath = filepath.strip('"')
    filepath = filepath.strip("'")

    # -----------------------------------------------------
    # 6. Path assoluto
    # -----------------------------------------------------

    if os.path.isabs(filepath):

        logger.info(
            "absolute filepath: %s",
            filepath,
        )

    # -----------------------------------------------------
    # 7. Path relativo
    # -----------------------------------------------------

    else:

        if rootDir is None:

            logger.error(
                "rootDir is None",
            )

            return None

        logger.info(
            "searching relative filepath '%s' "
            "under '%s'",
            filepath,
            rootDir,
        )

        found_filepath = findFileInPath(
            root=rootDir,
            filename=Path(filepath).name,
        )

        if found_filepath is None:

            logger.warning(
                "File non trovato: %s",
                filepath,
            )

            return None

        filepath = found_filepath

    # -----------------------------------------------------
    # 8. Controlli finali
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

    # -----------------------------------------------------
    # 9. Risultato standardizzato
    # -----------------------------------------------------

    ret_value = f"{filepath}:{line_no}"

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

    # -----------------------------------------------------
    # Logger
    # -----------------------------------------------------

    logger = setLogger(
        filename=XCLIP_LOG_FILENAME,
        file_Log_level=logging.INFO,
        console_Log_level=LOG_CONSOLE,
    )

    logger.info("starting....")

    # -----------------------------------------------------
    # Root directories
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

        show_error(
            f"File delle root directory non trovato:\n\n"
            f"{ffile}"
        )

        sys.exit(1)

    except PermissionError:

        logger.error(
            "Permission denied reading %s",
            ffile,
        )

        show_error(
            f"Permesso negato:\n\n"
            f"{ffile}"
        )

        sys.exit(1)

    except Exception as exc:

        logger.error(
            "Unexpected error: %s",
            exc,
            exc_info=True,
        )

        show_error(
            f"Errore durante la lettura:\n\n"
            f"{exc}"
        )

        sys.exit(1)

    if not rootDirs:

        logger.warning(
            "May be you should run .cd command "
            "to set current directory",
        )

        show_error(
            "Nessuna root directory configurata."
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

        show_error(
            "Nessun testo selezionato."
        )

        sys.exit(1)

    # -----------------------------------------------------
    # Cerca il file in tutti i rootDirs
    # -----------------------------------------------------

    file_to_be_edited: str | None = None

    for root_dir in rootDirs:

        logger.info(
            "Trying rootDir: %s",
            root_dir,
        )

        file_to_be_edited = analizza_riga(
            riga=testo_selezionato,
            rootDir=root_dir,
        )

        if file_to_be_edited:

            logger.info(
                "Text found in rootDir: %s",
                root_dir,
            )

            logger.info(
                "file_to_be_edited: %s",
                file_to_be_edited,
            )

            break

        logger.info(
            "NOT found in rootDir: %s",
            root_dir,
        )

    # -----------------------------------------------------
    # Nessun file trovato
    # -----------------------------------------------------

    if not file_to_be_edited:

        logger.warning(
            "Nessun file trovato per la selezione:\n%s",
            testo_selezionato,
        )

        roots = "\n".join(
            f"  {root}"
            for root in rootDirs
        )

        show_error(
            "File non trovato.\n\n"
            f"Selezione:\n"
            f"{testo_selezionato}\n\n"
            f"Root directories cercate:\n"
            f"{roots}\n\n"
            f"Dettagli nel log:\n"
            f"{XCLIP_LOG_FILENAME}"
        )

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
            "/home/loreto/filu/Applications/linuxPortable/"
            "SublimeText4/sublime_text",
            file_to_be_edited,
        ]

    logger.info(
        "editor command: %s",
        editor_command,
    )

    if fDEBUG:
        print(" ".join(editor_command))

    try:

        subprocess.Popen(editor_command)

    except FileNotFoundError as exc:

        logger.error(
            "Editor non trovato: %s",
            exc,
        )

        show_error(
            f"Editor non trovato:\n\n"
            f"{editor_command[0]}"
        )

        sys.exit(1)

    except Exception as exc:

        logger.error(
            "Errore avviando editor: %s",
            exc,
            exc_info=True,
        )

        show_error(
            f"Errore avviando editor:\n\n"
            f"{exc}"
        )

        sys.exit(1)
