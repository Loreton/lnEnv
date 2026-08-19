#!/usr/bin/python3
#
# /home/loreto/filu/lnEnv/lnUtilities/xClip/xClip.py
# /home/loreto/filu/lnEnv/lnUtilities/xClip/xclip.yaml
#
# updated by ...: Loreto Notarantonio
# ruff: noqa: I001 Import block is un-sorted or un-formatted help: Organize imports (Ruff I001)
#
# xClip:
#   - legge la Primary Selection
#   - riconosce riferimenti a file/linea
#   - cerca il file nei root directories configurati
#   - determina il programma da utilizzare tramite YAML
#   - apre il file
#
# Richiede:
#   sudo apt install xclip zenity
#
# Python:
#   PyYAML
#

from dataclasses import dataclass
from pathlib import Path
import argparse
import logging
import os
import re
import subprocess
import sys
import yaml


sys.dont_write_bytecode = True


# ============================================================
# Configuration
# ============================================================

XCLIP_ROOT_DIR_FILE = os.environ.get( "XCLIP_ROOT_DIR_FILE", "/tmp/xclip.rootdir" )
XCLIP_CONFIG_FILE = os.environ.get( "XCLIP_CONFIG_FILE", str(Path(__file__).with_name("xclip.yaml")) )
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


# ============================================================
# Data classes
# ============================================================

@dataclass(slots=True)
class SourceLocation:
    """
    Posizione sorgente riconosciuta nel testo.

    filename:
        Nome del file oppure path completo.

    line_no:
        Numero della linea.

    format:
        Formato con cui è stato riconosciuto il riferimento.

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


@dataclass(slots=True)
class FileHandler:
    """
    Programma utilizzato per aprire un determinato tipo
    di file.
    """

    name: str
    extensions: list[str]
    command: list[str]
    line_number: bool = False

    def handles(self, filename: str) -> bool:
        """
        Verifica se questo handler gestisce il file.
        """

        suffix = Path(filename).suffix.lower()

        return suffix in self.extensions


# ============================================================
# Logging
# ============================================================

def setLogger( filename: str, file_Log_level: int = logging.INFO, console_Log_level: int = logging.WARNING, ) -> logging.Logger:

    logger = logging.getLogger("LnLogger")
    logger.setLevel(logging.DEBUG)

    # Evita duplicazioni degli handler.
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


# ============================================================
# GUI messages
# ============================================================

def show_error(message: str) -> None:
    """
    Mostra un errore tramite zenity.

    Se zenity non è disponibile, registra solamente
    il messaggio nel log.
    """

    try:
        subprocess.run(
            [ "zenity", "--error", "--title=xClip", f"--text={message}" ],
            check=False,
        )

    except FileNotFoundError:
        logger.error( "zenity non installato: %s", message, )



def show_info(message: str) -> None:
    """
    Mostra un messaggio informativo tramite zenity.
    """

    try:

        subprocess.run(
            [ "zenity", "--info", "--title=xClip", f"--text={message}", ],
            check=False,
        )

    except FileNotFoundError:
        logger.info( "zenity non installato: %s", message, )



# ============================================================
# YAML configuration
# ============================================================

def load_config(filename: str) -> dict:
    """
    Carica la configurazione YAML.
    """

    logger.info(
        "Loading configuration: %s",
        filename,
    )

    try:
        with open( filename, "r", encoding="utf-8", ) as f:
            config = yaml.safe_load(f)

    except FileNotFoundError:
        logger.error( "Configuration file not found: %s", filename, )
        raise

    except yaml.YAMLError as exc:
        logger.error( "Invalid YAML configuration: %s", exc, )
        raise

    if not isinstance(config, dict):
        raise TypeError( "Invalid configuration: root must be a dictionary" )

    return config



# ============================================================
# load_handlers
# ============================================================
def load_handlers( config: dict, ) -> list[FileHandler]:
    """
    Converte la sezione 'handlers' del YAML in FileHandler.
    """

    handlers_config = config.get( "handlers", {}, )

    if not isinstance(handlers_config, dict):
        raise TypeError( "'handlers' must be a dictionary" )

    handlers: list[FileHandler] = []

    for name, data in handlers_config.items():

        if name == "default":
            continue

        if not isinstance(data, dict):
            logger.warning( "Ignoring invalid handler: %s", name, )
            continue

        extensions = data.get( "extensions", [], )
        command = data.get( "command", [], )
        line_number = data.get( "line_number", False, )


        if not isinstance(extensions, list):
            raise TypeError( f"Handler '{name}': " "'extensions' must be a list" )

        if not isinstance(command, list):
            raise TypeError( f"Handler '{name}': " "'command' must be a list" )

        extensions = [ str(ext).lower() for ext in extensions ]
        command = [ str(item) for item in command ]
        handler = FileHandler( name=name, extensions=extensions, command=command, line_number=bool(line_number), )
        handlers.append(handler)
        logger.info( "Loaded handler: %s -> %s", name, handler, )

    return handlers


def load_default_handler( config: dict, ) -> FileHandler | None:
    """
    Carica l'handler 'default'.
    """

    data = config.get( "handlers", {}, ).get( "default", )

    if not data:
        return None

    command = data.get( "command", [], )

    line_number = data.get( "line_number", False, )

    if not isinstance(command, list):
        raise TypeError( "Default handler: command must be a list" )

    return FileHandler(
        name="default",
        extensions=[],
        command=[
            str(item)
            for item in command
        ],
        line_number=bool(line_number),
    )


# ============================================================
# get_file_handler
# ============================================================

def get_file_handler( filepath: str, handlers: list[FileHandler], default_handler: FileHandler | None, ) -> FileHandler | None:
    """
    Determina quale handler utilizzare per filepath.
    """

    suffix = Path(filepath).suffix.lower()

    logger.info( "Looking for handler for extension: %s", suffix, )


    for handler in handlers:
        if handler.handles(filepath):
            logger.info( "Handler selected: %s", handler.name, )
            return handler

    logger.info( "No specific handler found for: %s", suffix, )

    return default_handler


# ============================================================
# Command builder
# ============================================================

def build_editor_command(
    filepath: str,
    line_no: int,
    handler: FileHandler,
) -> list[str]:
    """
    Costruisce il comando da passare a subprocess.

    Se line_number è True:

        /path/file.py:123

    altrimenti:

        /path/file.epub
    """

    command = list(handler.command)
    # command = shlex.split( " ".join(command) )
    # breakpoint()

    if handler.line_number:
        command.append( f"{filepath}:{line_no}" )
    else:
        command.append(filepath)

    logger.info( "Command built: %s", command, )

    return command


# ============================================================
# File search
# ============================================================

def findFileInDir(path: str, filename: str, ) -> str | None:
    """
    Cerca filename direttamente nella directory.
    """

    candidate = Path(path) / filename

    if candidate.is_file():
        return str(candidate)

    return None


def findFileInPath( root: str, filename: str, ) -> str | None:
    """
    Cerca ricorsivamente filename sotto root.
    """

    logger.info( "findFileInPath: root=%s, filename=%s", root, filename, )

    filename = Path(filename).name

    if Path(filename).suffix:
        filenames_to_be_searched = [ filename, ]

    else:
        filenames_to_be_searched = [ f"{filename}{ext}" for ext in DEFAULT_EXTENSIONS ]
        filenames_to_be_searched.insert( 0, filename, )


    logger.debug( "filenames_to_be_searched: %s", filenames_to_be_searched, )

    # exclude_paths = [".build_stage", ".build", "__pycache__", "logs"]
    # exclude_paths = ["__pycache__", "logs", "dist", ".git", ".vscode", ".venv", ".saved", ".desktop"]
    # exclude_paths = exclude_dirnames

    for dirpath, dirnames, files in os.walk(root):
        # Non scendere nei .build_stage.
        dirnames[:] = [
            dirname
            for dirname in dirnames
            if dirname not in exclude_dirnames
        ]
        # if dirname not in exclude_paths and not dirname.startswith(".")



        for candidate_name in filenames_to_be_searched:
            full_path = os.path.join( dirpath, candidate_name, )
            logger.debug( "checking for: %s", full_path, )

            if candidate_name in files:
                logger.info( "Trovato: %s", full_path, )
                return full_path


    return None


# ============================================================
# Clipboard
# ============================================================

def leggi_clipboard(
    tipo_appunti: str = "clipboard",
) -> str | None:
    """
    Legge il contenuto del clipboard o della Primary Selection.
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


# ============================================================
# Source location parser
# ============================================================

def parse_source_location( riga: str, ) -> SourceLocation | None:
    """
    Cerca nella riga un riferimento sorgente.

    Formati riconosciuti:

        [file_name.func_name : 112]

        [file_name : 112]

        File "/path/file.py", line 232, in function
    """

    patterns = [

        # ----------------------------------------------------
        # Logger
        # ----------------------------------------------------

        (
            "logger",
            re.compile(
                r"\[([^.]+)(?:\.[^:]+)?\s*:\s*(\d+)\]"
            ),
        ),

        # ----------------------------------------------------
        # Python traceback
        # ----------------------------------------------------

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

        location = SourceLocation(
            filename=match.group(1),
            line_no=int(match.group(2)),
            format=format_name,
        )

        logger.info( "SourceLocation found: %s", location, )

        return location

    return None


# ============================================================
# Generic parser
# ============================================================

def parse_generic_location( riga: str, ) -> SourceLocation | None:
    """
    Fallback per formati generici.

    Esempi:

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

    logger.info( "generic tokens: %s", tokens, )

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

    return SourceLocation( filename=filepath, line_no=line_no, format="generic", )


# ============================================================
# Analizza riga
# ============================================================

def analizza_riga( riga: str | None, rootDir: str | None, ) -> tuple[SourceLocation, str] | None:
    """
    Analizza la riga e risolve il riferimento al file.

    Restituisce:

        (SourceLocation, filepath)

    oppure None.
    """

    logger.info( "processing riga: %s", riga, )

    if not riga:
        return None

    riga = riga.strip()

    if not riga:
        return None

    # --------------------------------------------------------
    # 1. La selezione è direttamente un file?
    # --------------------------------------------------------
    filepath_candidate = ( riga.strip('"') .strip("'") )

    if os.path.isfile(filepath_candidate):
        location = SourceLocation( filename=filepath_candidate, line_no=1, format="direct_file", )
        logger.info( "Direct file found: %s", location, )
        return location, filepath_candidate



    # --------------------------------------------------------
    # 2. Parser specifici
    # --------------------------------------------------------
    location = parse_source_location(riga)

    # --------------------------------------------------------
    # 3. Parser generico
    # --------------------------------------------------------
    if location is None:
        location = parse_generic_location(riga)

    if location is None:
        logger.warning( "Nessun riferimento sorgente trovato: %s", riga, )
        return None

    # --------------------------------------------------------
    # 4. Pulizia filename
    # --------------------------------------------------------

    filepath = location.filename.strip()
    filepath = filepath.strip('"')
    filepath = filepath.strip("'")
    filepath = filepath.strip("[")
    filepath = filepath.strip("]")

    # --------------------------------------------------------
    # 5. Path assoluto
    # --------------------------------------------------------

    if os.path.isabs(filepath):
        logger.info( "Absolute filepath: %s", filepath, )

    # --------------------------------------------------------
    # 6. Path relativo
    # --------------------------------------------------------
    else:

        if rootDir is None:
            logger.error( "rootDir is None", )
            return None

        found_filepath = findFileInPath( root=rootDir, filename=Path(filepath).name, )

        if found_filepath is None:
            logger.warning( "File non trovato: %s", filepath, )
            return None

        filepath = found_filepath

    # --------------------------------------------------------
    # 7. Controlli
    # --------------------------------------------------------

    if not os.path.exists(filepath):
        logger.warning( "filepath does not exist: %s", filepath, )
        return None

    if os.path.isdir(filepath):
        logger.error( "filepath is a directory: %s", filepath, )
        return None

    logger.info( "Resolved location: %s -> %s", location, filepath, )

    return location, filepath


# ============================================================
# Argument parser
# ============================================================

def parserInput() -> argparse.Namespace:

    parser = argparse.ArgumentParser( description="xClip", )

    parser.add_argument( "--file", required=False, metavar="", default=XCLIP_ROOT_DIR_FILE, help=( "file containing root directories " "[%(default)s]" ) )
    parser.add_argument( "--config", required=False, metavar="", default=XCLIP_CONFIG_FILE, help=( "xClip YAML configuration " "[%(default)s]" ) )
    parser.add_argument( "--console", action="store_true", help="console log", )
    parser.add_argument( "--zed", action="store_true", help="compatibility option: usa ZED", )

    return parser.parse_args()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":

    args = parserInput()

    LOG_CONSOLE = ( logging.INFO if args.console else logging.WARNING )

    # --------------------------------------------------------
    # Logger
    # --------------------------------------------------------
    logger = setLogger( filename=XCLIP_LOG_FILENAME, file_Log_level=logging.INFO, console_Log_level=LOG_CONSOLE, )
    logger.info("starting....")



    # --------------------------------------------------------
    # Load YAML configuration file
    # --------------------------------------------------------
    try:
        config = load_config( args.config, )
        handlers = load_handlers( config, )
        default_handler = load_default_handler( config, )
        primary_root_dir_file = config["primary_root_dirs_file"] # get filename
        secondary_root_dirs = config["secondary_root_dirs"] # get list of root_top_dirs
        exclude_dirnames = config.get("exclude_dirnames", [])

    except Exception as exc:
        logger.error( "Unable to load configuration: %s", exc, exc_info=True, )
        show_error( "Errore caricando la configurazione " f"di xClip:\n\n{exc}\n\n" f"{args.config}" )
        sys.exit(1)



    # --------------------------------------------------------
    # Root directories
    # --------------------------------------------------------

    # ffile = Path(args.file)
    ffile = Path(primary_root_dir_file)

    rootDirs: list[str] = []

    # read root directories from file createde by .cd alias command
    try:
        with ffile.open( mode="r", encoding="utf-8", ) as f:
            content = f.read()
        if content:
            rootDirs = content.split()

    except FileNotFoundError:
        logger.error( "File %s not found", ffile, )
        # show_error( "File delle root directory non trovato:\n\n" f"{ffile}" )
        # sys.exit(1)

    # except PermissionError:
    #     logger.error( "Permission denied reading %s", ffile, )
    #     show_error( "Permesso negato:\n\n" f"{ffile}" )
    #     sys.exit(1)

    # except Exception as exc:
    #     logger.error( "Unexpected error: %s", exc, exc_info=True, )
    #     show_error( f"Errore durante la lettura:\n\n{exc}" )
    #     sys.exit(1)


    # aggiungiamo quelle configurate nel file di configurazione
    rootDirs.extend(secondary_root_dirs)

    if not rootDirs:
        logger.warning( "No root directories configured.", )
        show_error( "Nessuna root directory configurata." )
        sys.exit(1)


    # --------------------------------------------------------
    # Clipboard
    # --------------------------------------------------------

    testo_copiato = leggi_clipboard( "clipboard", )
    testo_selezionato = leggi_clipboard( "primary", )

    logger.info("-")
    logger.info("-")
    logger.info("-")

    logger.info( "Clipboard (Ctrl+C).....................: %s", testo_copiato, )
    logger.info( "Primary Selection......................: %s", testo_selezionato, )
    logger.info( "rootDirs: %s", rootDirs, )

    if not testo_selezionato:
        logger.error( "testo non selezionato", )
        show_error( "Nessun testo selezionato." )
        sys.exit(1)



    # --------------------------------------------------------
    # Cerca il file in tutti i rootDirs
    # --------------------------------------------------------

    location: SourceLocation | None = None
    filepath: str | None = None

    for root_dir in rootDirs:

        logger.info( "Trying rootDir: %s", root_dir, )

        result = analizza_riga( riga=testo_selezionato, rootDir=root_dir, )

        if result:

            location, filepath = result

            logger.info(
                "Found file in: %s",
                root_dir,
            )

            break

        logger.info(
            "NOT found in: %s",
            root_dir,
        )

    # --------------------------------------------------------
    # File non trovato
    # --------------------------------------------------------

    if location is None or filepath is None:

        roots = "\n".join(
            f"  {root}"
            for root in rootDirs
        )

        logger.warning(
            "Nessun file trovato per:\n%s",
            testo_selezionato,
        )

        show_error(
            "File non trovato.\n\n"
            f"Selezione:\n"
            f"{testo_selezionato}\n\n"
            f"Root directories cercate:\n"
            f"{roots}\n\n"
            f"Log:\n"
            f"{XCLIP_LOG_FILENAME}"
        )

        sys.exit(1)

    # --------------------------------------------------------
    # Determina handler
    # --------------------------------------------------------

    handler = get_file_handler(
        filepath=filepath,
        handlers=handlers,
        default_handler=default_handler,
    )

    if handler is None:

        logger.error(
            "No handler available for: %s",
            filepath,
        )

        show_error(
            "Nessun programma configurato per:\n\n"
            f"{filepath}"
        )

        sys.exit(1)

    # --------------------------------------------------------
    # Costruisce comando
    # --------------------------------------------------------

    editor_command = build_editor_command(
        filepath=filepath,
        line_no=location.line_no,
        handler=handler,
    )
    logger.info( "Source location : %s", location, )
    logger.info( "Resolved file   : %s", filepath, )
    logger.info( "Handler         : %s", handler.name, )
    logger.info( "Command          : %s", editor_command, )


    # --------------------------------------------------------
    # Avvio programma
    # --------------------------------------------------------

    try:
        subprocess.Popen( editor_command, )

    except FileNotFoundError as exc:
        logger.error( "Program not found: %s", exc, )
        show_error(
            "Programma non trovato:\n\n"
            f"{editor_command[0]}\n\n"
            f"File:\n{filepath}"
        )

        sys.exit(1)

    except Exception as exc:

        logger.error(
            "Error starting program: %s",
            exc,
            exc_info=True,
        )

        show_error(
            "Errore avviando il programma:\n\n"
            f"{exc}"
        )

        sys.exit(1)
