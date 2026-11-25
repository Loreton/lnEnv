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
# ruff: noqa: E402 Module level import not at top of file

from _typeshed import StrPath
import sys; sys.dont_write_bytecode = True

from dataclasses import dataclass, field
from pathlib import Path
import argparse
import logging
import os
import re
import subprocess
import yaml
from string import Template
from typing import TypedDict, cast




# --- import pyLnLib
pylnlib_path = Path(__file__).parent.parent / "pyLnLib_last.zip"
sys.path.insert(0,str(pylnlib_path))
from pyLnLib import get_logger, lnDict, get_yamlEngine, get_colors
logger = get_logger()
C = get_colors()


# ============================================================
# Configuration
# ============================================================





XCLIP_TEMP_DIR = Path("/tmp/xclip")
LOG_FILE_NAME = XCLIP_TEMP_DIR / "xclip.log"
BASE_TOP_DIRS_FILE = XCLIP_TEMP_DIR / "top_dirs.txt"
EXTRA_TOP_DIRS_FILE = XCLIP_TEMP_DIR / "extra_top_dirs.txt"
EXTRA_VARS_FILE = XCLIP_TEMP_DIR / "extra_vars.txt"

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



class MainConfig(TypedDict, total=False):
    system_vars_file: str
    extra_vars_file: str | Path
    base_top_dirs_file: str | Path
    extra_top_dirs_file: str | Path
    default_top_dirs: list[str]
    exclude_dirnames: list[str]


class XClipConfig(TypedDict):
    main: MainConfig
    # Puoi aggiungere qui altre sezioni del YAML, es. handlers: list[dict[str, object]]

@dataclass(slots=True)
class project_vars:
    """Mantiene tutte le variabili di progetto."""

    log_filename: Path
    system_vars_file: str = ""
    extra_vars_file: Path = EXTRA_VARS_FILE
    base_top_dirs_file: Path = BASE_TOP_DIRS_FILE
    extra_top_dirs_file: Path = EXTRA_TOP_DIRS_FILE
    default_handler: FileHandler | None = None
    top_dirs: list[str] = field(default_factory=list)
    exclude_dirnames: list[str] = field(default_factory=list)
    project_env_vars: dict[str, object] = field(default_factory=dict)
    handlers: list[FileHandler] = field(default_factory=list)
    main_config: MainConfig = field(default_factory=dict)


# ============================================================
# Logging
# ============================================================
def setLogger( filename: StrPath, file_Log_level: int = logging.INFO, console_Log_level: int = logging.WARNING, ) -> logging.Logger:

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
        subprocess.run( [ "zenity", "--error", "--title=xClip", f"--text={message}" ], check=False, )

    except FileNotFoundError:
        logger.error( "zenity non installato: %s", message, )



def show_info(message: str) -> None:
    """
    Mostra un messaggio informativo tramite zenity.
    """
    try:
        subprocess.run( [ "zenity", "--info", "--title=xClip", f"--text={message}", ], check=False, )

    except FileNotFoundError:
        logger.info( "zenity non installato: %s", message, )



# ============================================================
# YAML configuration
# ============================================================

def load_config(filename: str) -> dict[str, object]:
    """
    Carica la configurazione YAML.
    """
    logger.info( "Loading configuration: %s", filename, )
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
def load_handlers( config: dict[str, object], ) -> list[FileHandler]:
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
        logger.debug( "Loaded handler: %s -> %s", name, handler, )

    return handlers


def load_default_handler( config: dict[str, object], ) -> FileHandler:
    """
    Carica l'handler 'default'.
    """

    data = config.get( "handlers", {}, ).get( "default", )
    command=None

    if data:
        command = data.get( "command", [], )

        line_number = data.get( "line_number", False, )

        if not isinstance(command, list):
            raise TypeError( "Default handler: command must be a list" )

        command=[
            str(item)
            for item in command
        ],


    return FileHandler(
        name="default",
        extensions=[],
        command=command,
        line_number=bool(line_number),
    )


# ============================================================
# get_file_handler
# ============================================================
def get_file_handler( filepath: str,
                    handlers: list[FileHandler],
                    default_handler: FileHandler | None,
                    is_url: bool = False,
                ) -> FileHandler | None:
    """Determina quale handler utilizzare per filepath o URL."""

    if is_url:
        for handler in handlers:
            if handler.name == "browser":
                return handler
        # Se non è presente un handler 'browser' specifico nello yaml, usa il default
        return default_handler

    suffix = Path(filepath).suffix.lower()
    logger.info("Looking for handler for extension: %s", suffix)

    for handler in handlers:
        if handler.handles(filepath):
            logger.info("Handler selected: %s", handler.name)
            return handler

    logger.info("No specific handler found for: %s", suffix)
    return default_handler




# ============================================================
# Command builder
# ============================================================

def build_editor_command(filepath: str, line_no: int, handler: FileHandler, ) -> list[str]:
    """
    Costruisce il comando da passare a subprocess.

    If line_number is True:
        /path/file.py:123

    else:
        /path/file.epub
    """

    command = list(handler.command)

    if handler.line_number:
        command.append( f"{filepath}:{line_no}" )
    else:
        command.append(filepath)

    logger.info( "Command built: %s", command, )

    return command


# ============================================================
# - File search
# ============================================================
def findFileInDir(path: str, filename: str, ) -> str | None:
    """ Cerca filename direttamente nella directory. """
    candidate = Path(path) / filename
    if candidate.is_file():
        return str(candidate)
    return None


# ============================================================
def findFileInPath( root: str, filename: str, ) -> str | None:
    """ Cerca ricorsivamente filename sotto root. """

    logger.info( "findFileInPath: root=%s, filename=%s", root, filename, )
    filename = Path(filename).name

    if Path(filename).suffix:
        filenames_to_be_searched = [ filename, ]
    else:
        filenames_to_be_searched = [ f"{filename}{ext}" for ext in DEFAULT_EXTENSIONS ]
        filenames_to_be_searched.insert( 0, filename, )


    logger.debug( "filenames_to_be_searched: %s", filenames_to_be_searched, )

    for dirpath, dirnames, files in os.walk(root):
        # Non scendere nei .build_stage.
        dirnames[:] = [ dirname
                        for dirname in dirnames
                        if dirname not in pv.exclude_dirnames
                    ]


        for candidate_name in filenames_to_be_searched:
            full_path = os.path.join( dirpath, candidate_name, )
            logger.debug( "checking for: %s", full_path, )

            if candidate_name in files:
                logger.info( "Trovato: %s", full_path, )
                return full_path


    return None


# ============================================================
# - Clipboard
# ============================================================
def leggi_clipboard(tipo_appunti: str = "clipboard", ) -> str:
    """
    Legge il contenuto del clipboard o della Primary Selection.
    """


    try:
        comando = [ "xclip", "-o", "-selection", tipo_appunti, ]
        risultato = subprocess.run( comando, capture_output=True, text=True, check=True, )
        return Template(risultato.stdout.strip()).safe_substitute(pv.project_env_vars)

    except subprocess.CalledProcessError as exc:
        logger.error( "Errore durante la lettura degli appunti: %s", exc, )
        return ""


    except FileNotFoundError:
        logger.error( "Il comando 'xclip' non è installato " "o non è nel PATH.", )
        return ""




# ============================================================
# Source location parser
# ============================================================

def parse_source_location( riga: str, ) -> SourceLocation | None:
    """
    Cerca nella riga un riferimento sorgente.
    Formati riconosciuti:
        logger:
            [file_name.func_name : 112]
            [file_name : 112]
        python traceback:
            File "/path/file.py", line 232, in function
    """

    patterns = [
        # --- Logger
        ( "logger", re.compile( r"\[([^.]+)(?:\.[^:]+)?\s*:\s*(\d+)\]" ), ),

        # --- Python traceback
        ( "traceback", re.compile( r'File "([^"]+)",\s+line\s+(\d+)' ), ),
    ]

    for format_name, pattern in patterns:
        match = pattern.search(riga)
        if not match:
            continue

        location = SourceLocation( filename=match.group(1), line_no=int(match.group(2)), format=format_name, )
        logger.info( "SourceLocation found: %s", location, )
        return location

    return None



################################################################################
# Web / Browser
# Se selezioni http://localhost:8000/api
#     oppure 192.168.1.50:3000/dashboard,
#     lo script riconosce immediatamente il pattern senza interrogare il filesystem.
################################################################################
def is_url_or_ip(text: str) -> str | None:
    """Verifica se il testo è un URL o un IP (con eventuale porta/path)

    e restituisce un URL valido pronto per il browser.
    """
    # Regex per URL (http://, https://, ftp://) e IP/Hostname con porta opzionale
    URL_PATTERN = re.compile(
        r"^(https?://[^\s]+)"  # URL completi con schema http/https
        r"|^((?:[0-9]{1,3}\.){3}[0-9]{1,3}(?::\d+)?(?:/[^\s]*)?)$"  # IP tipo 192.168.1.1 o 192.168.1.1:8080
    )
    text = text.strip().strip('"').strip("'")
    match = URL_PATTERN.match(text)
    if not match:
        return None

    # Se non specifica lo schema (es: 192.168.1.1:8080), prefissiamo con http://
    if not text.startswith(("http://", "https://", "ftp://")):
        return f"http://{text}"

    return text


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
        file.yaml#xxx
    """
    # riga='/home/loreto/filu/myData/Songs/mp3_songs/Italiani/Luciano_Rossi/Loreto_selection_list.yaml__##__Albums'
    normalized = (riga
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

    yaml_keypath_sep = pv.project_env_vars.get('YAML_KEYPATH_SEP', '#')
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

        elif f".yaml{yaml_keypath_sep}" in word: # specifico per !include file yaml
            filepath = word.split(yaml_keypath_sep)[0]
            if os.path.isfile(filepath):
                break

    return SourceLocation( filename=filepath, line_no=line_no, format="generic", )


# ============================================================
# Analizza riga
# ============================================================

def analizza_riga( riga: str | None, rootDir: str | None, ) -> tuple[SourceLocation, str] | None:
    """
    Analizza la riga e risolve il riferimento al file.

    Return:
        - (SourceLocation, filepath)
        - None.
    """

    logger.info( "processing riga: %s", riga, )

    if not riga:
        return None

    riga = os.path.expandvars(riga)
    riga = Template(riga).safe_substitute(pv.project_env_vars)
    riga = riga.strip()

    if not riga:
        return None

    # --------------------------------------------------------
    # 0. La selezione è un URL o un Indirizzo IP?
    # --------------------------------------------------------
    url_found = is_url_or_ip(riga)
    if url_found:
        location = SourceLocation( filename=url_found, line_no=1, format="url" )
        logger.info("URL/IP detected: %s", location)
        return location, url_found


    # --- 0. La selezione è direttamente un file?
    filepath_candidate = ( riga.strip('"').strip("'") )
    if os.path.isfile(filepath_candidate):
        location = SourceLocation( filename=filepath_candidate, line_no=1, format="direct_file", )
        logger.info( "Direct file found: %s", location, )
        return location, filepath_candidate

    elif os.path.isdir(filepath_candidate):
        logger.error( "selected text is a direcotry: %s", filepath_candidate, )
        show_error(f"selected text is a direcotr y:\n{filepath_candidate}")
        sys.exit(1)


    # --- 1. Parser specifici (logger and python traceback))
    location = parse_source_location(riga)

    # --- 2. Parser generico
    if location is None:
        location = parse_generic_location(riga)

    if location is None:
        logger.warning( "Nessun riferimento sorgente trovato: %s", riga, )
        return None


    # --- 3. Pulizia filename
    filepath = location.filename.strip()
    filepath = filepath.strip('"')
    filepath = filepath.strip("'")
    filepath = filepath.strip("[")
    filepath = filepath.strip("]")

    # --- 5. Path assoluto
    if os.path.isabs(filepath):
        logger.info( "Absolute filepath: %s", filepath, )

    # --- 6. Path relativo
    else:
        if rootDir is None:
            logger.error( "rootDir is None", )
            # show_error( "rootDir is None", )
            return None

        found_filepath = findFileInPath( root=rootDir, filename=Path(filepath).name, )

        if found_filepath is None:
            logger.warning( "File non trovato: %s", filepath, )
            return None

        filepath = found_filepath

    # --- 7. Controlli
    if not os.path.exists(filepath):
        logger.warning( "filepath does not exist: %s", filepath, )
        return None

    # if os.path.isdir(filepath):
    #     logger.error( "filepath is a directory: %s", filepath, )
    #     return None

    logger.info( "Resolved location: %s -> %s", location, filepath, )

    return location, filepath


# ============================================================
# Argument parser
# ============================================================

def parserInput() -> argparse.Namespace:

    parser = argparse.ArgumentParser( description="xClip", )

    # parser.add_argument( "--root-dir-file", required=True, metavar="", default=None, help=( "file containing root directories " "[%(default)s]" ) )
    parser.add_argument( "--console", action="store_true", help="console log", )
    parser.add_argument( "--zed", action="store_true", help="compatibility option: use ZED editor", )

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument( "--primary", action="store_true", help="read primary selection", )
    group.add_argument( "--clipboard", action="store_true", help="read clipboard", )

    return parser.parse_args()


#============================================================
def install_envars_vars(system_yaml_vars: str, extra_vars_file: str = None) -> None:
    """
        Install system environment variables from a YAML file.
        Utile per risolvere variabili d'ambiente che potrebbero
        essere presenti nel path che andiamo a processare

    Args:
        system_yaml_vars (str): Path to the YAML file containing system environment variables.
        extra_vars_file (str): Path to the file containing extra environment variables.

    Returns:
        None
    """
    import yaml
    yaml_file=os.path.expandvars(system_yaml_vars)
    with open(yaml_file, 'r') as f:
        content=f.read() # single string
    dvars=yaml.load(content, Loader=yaml.FullLoader)

    for key, value in dvars["system_envars"].items():
        os.environ[key] = value

    if extra_vars_file:
        extra_vars = Path(extra_vars_file)
        if extra_vars.exists() and extra_vars.is_file():
            with open(extra_vars_file, 'r') as f:
                env_vars=f.read() # single string

            for line in env_vars.split('\n'):
                items = line.split('=', 1)
                if len(items) == 2:
                    var_name, value = items
                    os.environ[var_name] = value




#============================================================
def set_env_vars(system_yaml_vars: str, extra_vars_file: str|None = None) -> dict[str, object]:
    """
        Install system environment variables from a YAML file.
        Utile per risolvere variabili d'ambiente che potrebbero
        essere presenti nel path che andiamo a processare

    Args:
        system_yaml_vars (str): Path to the YAML file containing system environment variables.
        extra_vars_file (str): Path to the file containing extra environment variables.

    Returns:
        dict[str, str]: A dictionary containing the environment variables.
    """

    import yaml
    # --- inseriamo le env vars nel dizionario pv.project_env_vars
    dvars: dict=os.environ.copy()  # Start with a copy of the current environment variables

    yaml_file=os.path.expandvars(system_yaml_vars)
    with open(yaml_file, 'r') as f:
        content=f.read() # single string

    # --- aggiungiamo variabili ln_xxxx nel dizionario dvars
    ln_vars=yaml.load(content, Loader=yaml.FullLoader)
    dvars.update(ln_vars["system_envars"])

    # --- aggiungiamo extra_vars_file nel dizionario dvars
    if extra_vars_file:
        extra_vars = Path(extra_vars_file)
        if extra_vars.exists() and extra_vars.is_file():
            with open(extra_vars_file, 'r') as f:
                env_vars=f.read() # single string

            for line in env_vars.split('\n'):
                items = line.split('=', 1) # selection_filename="Loreto_selection_list.yaml"
                if len(items) == 2:
                    var_name, value = items
                    dvars[var_name.strip()] = value.strip()
                else:
                    items = line.split(':', 1) # selection_filename: "Loreto_selection_list.yaml"
                    if len(items) == 2:
                        var_name, value = items
                        dvars[var_name.strip()] = value.strip()


    return dvars



#============================================================
def clean_text(text: str) -> str:
    """
    Pulisce il testo rimuovendo caratteri speciali e spazi bianchi.
    """
    # Rimuove caratteri speciali e spazi bianchi
    # cleaned_text = re.sub(r'[^\w\s\.\-\/]', '', text)
    # cleaned_text = cleaned_text.strip()
    # return cleaned_text
    logger.info( "processing string: %s", text, )

    if not text:
        return None

    cleaned_text = os.path.expandvars(text)
    cleaned_text = Template(cleaned_text).safe_substitute(pv.project_env_vars)
    cleaned_text = cleaned_text.strip().strip('"').strip("'")

    if not cleaned_text:
        return None

    return cleaned_text

def _as_path(value: str | Path | None, fallback: Path) -> Path:
    if value is None:
        return fallback
    return value if isinstance(value, Path) else Path(value)


def read_config(pv: project_vars, filename: StrPath) -> XClipConfig | dict[str, object]:
    config_filename = Path(filename) if filename is not None else Path(__file__).with_name("xclip_config.yaml")
    try:
        # Un solo cast all'ingresso del YAML caricato
        raw_config = cast(XClipConfig, load_config(str(config_filename)))
        main_cfg: MainConfig = raw_config["main"]

        pv.main_config = main_cfg
        pv.handlers = load_handlers(raw_config)
        pv.default_handler = load_default_handler(raw_config)
        pv.system_vars_file = main_cfg.get("system_vars_file", "")

        pv.base_top_dirs_file = _as_path(main_cfg.get("base_top_dirs_file"), BASE_TOP_DIRS_FILE)
        pv.extra_top_dirs_file = _as_path(main_cfg.get("extra_top_dirs_file"), EXTRA_TOP_DIRS_FILE)
        pv.extra_vars_file = _as_path(main_cfg.get("extra_vars_file"), EXTRA_VARS_FILE)

        # Con TypedDict, .get("default_top_dirs", []) è già tipizzato come list[str]
        pv.top_dirs = list(main_cfg.get("default_top_dirs", []))
        pv.exclude_dirnames = list(main_cfg.get("exclude_dirnames", []))

        return raw_config
    except Exception as exc:
        show_error(
            "Errore caricando la configurazione "
            f"di xClip:\n\n{exc}\n\n"
            f"{config_filename}"
        )
        return {}
# def read_config(filename: str|Path) -> dict[str, object]:
#     # --------------------------------------------------------
#     # Load YAML configuration file
#     # --------------------------------------------------------
#     config_filename  = Path(__file__).with_name("xclip_config.yaml")
#     try:
#         config: dict[str, object] = load_config(str(config_filename))
#         main_config: dict[str, object]               = config["main"]
#         # pv.main_config            = config["main"]
#
#         pv.handlers               = load_handlers(config)
#         pv.default_handler        = load_default_handler(config)
#         system_vars_file          = main_config["system_vars_file"] # ignore
#         pv.base_top_dirs_file     = Path(main_config.get("base_top_dirs_file", BASE_TOP_DIRS_FILE)) # get list of top directories
#         pv.extra_top_dirs_file    = Path(main_config.get("extra_top_dirs_file", EXTRA_TOP_DIRS_FILE)) # get filename for extra top directories
#         pv.extra_vars_file        = main_config.get("extra_vars_file", EXTRA_VARS_FILE) # get filename for extra vars
#         pv.top_dirs               = main_config.get("default_top_dirs", [])
#         pv.exclude_dirnames       = main_config.get("exclude_dirnames", [])
#
#
#     except Exception as exc:
#         show_error( "Errore caricando la configurazione " f"di xClip:\n\n{exc}\n\n" f"{config_filename}" )
#         return {}
#
#     pv.system_vars_file = system_vars_file
#     return main_config

# ============================================================
# Main
# ============================================================
def main(pv: project_vars) -> int:
    # --------------------------------------------------------
    # Load YAML configuration file
    # --------------------------------------------------------
    config_filename  = Path(__file__).with_name("xclip_config.yaml")
    pv.main_config = read_config(pv, filename=config_filename)

    # --- Verifica input arguments
    args = parserInput()

    # --- Caricamento delle top variabili
    pv.project_env_vars=set_env_vars(system_yaml_vars=pv.system_vars_file, extra_vars_file=pv.extra_vars_file)  # Install system environment variables from the YAML file


    # --- Caricamento delle top directories
    rootDirs: list[str] = []

    # --- create file if not exists
    if not pv.base_top_dirs_file.exists():
        with pv.base_top_dirs_file.open(mode="w", encoding="utf-8") as f:
            f.write("\n".join(pv.top_dirs))

    if not pv.extra_top_dirs_file.exists():
        with pv.extra_top_dirs_file.open(mode="w", encoding="utf-8") as f:
            f.write("")

    try:
        # --- read root directories
        with pv.base_top_dirs_file.open(mode="r", encoding="utf-8") as f:
            rootDirs = [line.strip() for line in f if line.strip()] # più efficiente, rispetto a f.read(),perché non alloca memoria inutile

        # --- read root directories from file created by .xclip.topdir alias command
        with pv.extra_top_dirs_file.open(mode="r", encoding="utf-8") as f:
            rootDirs2 = [line.strip() for line in f if line.strip()] # più efficiente, rispetto a f.read(),perché non alloca memoria inutile

        rootDirs.extend(rootDirs2)

    except FileNotFoundError:
        show_error( f"File delle root directory non trovato:\n\n{pv.base_top_dirs_file}" )
        return 1

    # --- elimina duplicati
    rootDirs = list(dict.fromkeys(rootDirs))


    if not rootDirs:
        show_error( "No root directories configured." )
        return 1


    # --------------------------------------------------------
    # - Capture Clipboard or selection string
    # --------------------------------------------------------
    clipboard_text = leggi_clipboard(tipo_appunti="clipboard", )
    selection_text = leggi_clipboard(tipo_appunti="primary", )

    if args.primary:
        text = selection_text
        selection_type = "primary_selection"
    else:
        text = clipboard_text
        selection_type = "clipboard"

    # text: str = selection_text if args.primary else clipboard_text
    # selection_type: str = "primary_selection" if args.primary else "clipboard"

    logger.info( "rootDirs: %s", rootDirs, )
    logger.info( "Primary Selection..: %s", selection_text, )
    logger.info( "Clipboard (Ctrl+C).: %s", clipboard_text, )
    logger.info( "working on:          %s", text, )

    # --- pulizia della stringa selezionata
    text_to_be_searched: str = clean_text(text)
    if not text_to_be_searched:
        show_error(f"Selection type: {selection_type}\ntesto non selezionato e clipboard vuota" )
        return  1


    location: SourceLocation | None = None
    filepath: str | None = None

    # --------------------------------------------------------
    # --- 0. Primo controllo: la selezione è un URL o un Indirizzo IP?
    # --------------------------------------------------------
    url_found = is_url_or_ip(text_to_be_searched)
    if url_found:
        location = SourceLocation( filename=url_found, line_no=1, format="url" )
        logger.info("URL/IP detected: %s", location)
        return location, url_found


    # --------------------------------------------------------
    # --- 1. La selezione è direttamente un file?
    # --------------------------------------------------------
    filepath_candidate = (text_to_be_searched)
    if os.path.isfile(filepath_candidate):
        location = SourceLocation( filename=filepath_candidate, line_no=1, format="direct_file", )
        logger.info( "Direct file found: %s", location, )
        # return location, filepath_candidate

    elif os.path.isdir(filepath_candidate):
        logger.error( "selected text is a direcotry: %s", filepath_candidate, )
        show_error(f"selected text is a direcotr y:\n{filepath_candidate}")
        sys.exit(1)


    else:
        for root_dir in rootDirs:
            logger.info( "Trying rootDir: %s", root_dir, )
            result = analizza_riga( riga=filepath_candidate, rootDir=root_dir, )
            if result:
                location, filepath = result
                logger.info( "Found file in: %s", root_dir, )
                break

            logger.info( "NOT found in: %s", root_dir, )




    # --------------------------------------------------------
    # --- File non trovato
    # --------------------------------------------------------
    if location is None:
        roots = "\n".join( f"  {root}" for root in rootDirs )
        logger.warning( "Nessun file trovato per:\n%s", filepath_candidate, )
        show_error( f'Nessun file trovato per:\n"{filepath_candidate}"\n\n'
                    f"selection_type: {selection_type}:\n"
                    f'string: "{filepath_candidate}"\n\n'
                    f"Top directories searched:\n"
                    f"{roots}\n\n"
                    f"\tLog: {pv.log_filename}"
                )

        return 1

    # --------------------------------------------------------
    # Determina handler
    # --------------------------------------------------------
    handler = get_file_handler(filepath=location.filename,
                            handlers=pv.handlers,
                            default_handler=pv.default_handler,
                            is_url=(location.format == "url"),  # Passiamo il flag URL
                        )

    if handler is None:
        logger.error( "No handler available for: %s", filepath, )
        show_error( f"Nessun programma configurato per:\n\n {filepath}" )
        return 1

    # --------------------------------------------------------
    # Costruisce comando
    # --------------------------------------------------------
    editor_command = build_editor_command(filepath=location.filename, line_no=location.line_no, handler=handler, )
    logger.info( "Source location : %s", location, )
    logger.info( "Resolved file   : %s", location.filename, )
    logger.info( "Handler         : %s", handler.name, )
    logger.info( "Command         : %s", editor_command, )


    # --------------------------------------------------------
    # - Avvio programma
    # --------------------------------------------------------
    rcode = run_editor(command=editor_command, filepath=location.filename)


    return rcode


# --------------------------------------------------------
# - Run program
# --------------------------------------------------------
def run_editor(command: list[str], filepath: str) -> int:
    try:
        subprocess.Popen(command)

    except FileNotFoundError as exc:
        logger.error( "Program not found: %s", exc, )
        show_error(f"Programma non trovato:\n\n {command[0]}\n\n - File:\n {filepath}" )
        return 1

    except Exception as exc:
        logger.error( "Error starting program: %s", exc, exc_info=True, )
        show_error("Errore avviando il programma:\n\n" f"{exc}")
        return 1

    return 0






##########################################################################
#               M A I N
##########################################################################
if __name__ == "__main__":

    XCLIP_TEMP_DIR = Path('/tmp/xclip')
    XCLIP_TEMP_DIR.mkdir(parents=True, exist_ok=True)
    pv = project_vars(
            log_filename=XCLIP_TEMP_DIR / 'xclip.log',
            base_top_dirs_file=XCLIP_TEMP_DIR / 'top_dirs.txt',
            extra_top_dirs_file=XCLIP_TEMP_DIR / 'extra_top_dirs.txt',
            extra_vars_file=XCLIP_TEMP_DIR / 'extra_vars.txt',
        )


    """ logger è reso globale per essere utilizzato in tutte le funzioni """
    log_filename =  pv.log_filename
    LOG_CONSOLE = (logging.INFO if '--console' in sys.argv else logging.WARNING)
    logger = setLogger(filename=pv.log_filename, file_Log_level=logging.INFO, console_Log_level=LOG_CONSOLE, )
    logger.info("="*60)
    logger.info("= starting.... %s", pv.log_filename)
    logger.info("="*60)
    main(pv)
