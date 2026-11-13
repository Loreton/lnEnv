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

import sys; sys.dont_write_bytecode = True

from dataclasses import dataclass, field
# from gettext import install
from pathlib import Path
import argparse
import logging
import os
import re
import subprocess
import yaml
from string import Template




# ============================================================
# Configuration
# ============================================================




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


@dataclass(slots=True)
class project_vars:
    """
    Mantiene tyutte le variabili di projetto.
    """

    log_filename: str
    project_env_vars: dict[str, object] = field(default_factory=dict)
    exclude_dirnames: list[str] = field(default_factory=list)


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

def load_config(filename: str) -> dict:
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
        logger.debug( "Loaded handler: %s -> %s", name, handler, )

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
    riga='/home/loreto/filu/myData/Songs/mp3_songs/Italiani/Luciano_Rossi/Loreto_selection_list.yaml__##__Albums'
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

    parser.add_argument( "--root-dir-file", required=True, metavar="", default=None, help=( "file containing root directories " "[%(default)s]" ) )
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
def set_env_vars(system_yaml_vars: str, extra_vars_file: str|None = None) -> dict[str, str]:
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
    yaml_file=os.path.expandvars(system_yaml_vars)
    with open(yaml_file, 'r') as f:
        content=f.read() # single string
    dvars=yaml.load(content, Loader=yaml.FullLoader)
    dvars = dvars["system_envars"]
    # env_vars: dict[str, str] = dvars["system_envars"]

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


# ============================================================
# Main
# ============================================================
def main() -> int:
    # --------------------------------------------------------
    # Load YAML configuration file
    # --------------------------------------------------------
    config_filename  = os.environ.get( "ln_XCLIP_CONFIG_FILE", str(Path(__file__).with_name("xclip_config.yaml")) )
    try:
        config = load_config( config_filename)
        handlers = load_handlers( config, )
        default_handler = load_default_handler( config, )
        main_config=config["main"]
        top_dirs: list[str] = main_config["top_dirs"] # get list of top directories
        extra_vars_file: str = main_config["extra_vars_file"] # get filename for extra vars
        system_yaml_vars: str = main_config["system_vars"] # get filename for system vars
        pv.exclude_dirnames = main_config.get("exclude_dirnames", [])

    except Exception as exc:
        show_error( "Errore caricando la configurazione " f"di xClip:\n\n{exc}\n\n" f"{config_filename}" )
        return 1

    args = parserInput()
    # install_envars_vars(system_yaml_vars=system_yaml_vars, extra_vars_file=extra_vars_file)  # Install system environment variables from the YAML file
    pv.project_env_vars=set_env_vars(system_yaml_vars=system_yaml_vars, extra_vars_file=extra_vars_file)  # Install system environment variables from the YAML file


    # --------------------------------------------------------
    # - Root directories from file root_dir_file
    # --------------------------------------------------------
    root_dir_file = Path(args.root_dir_file)
    rootDirs: list[str] = []
    if not root_dir_file.exists():
        # ---- create it
        with root_dir_file.open(mode="w", encoding="utf-8") as f:
            f.write("\n".join(top_dirs))

    try:
        # --- read root directories from file created by .cd alias command
        with root_dir_file.open( mode="r", encoding="utf-8", ) as f:
            content = f.read()
        if content:
            rootDirs = content.split()

    except FileNotFoundError:
        show_error( f"File delle root directory non trovato:\n\n{root_dir_file}" )
        return 1


    # aggiungiamo quelle configurate nel file di configurazione
    # rootDirs.extend(top_dirs)
    rootDirs = list(dict.fromkeys(rootDirs))
    for top_dir in top_dirs:
        if top_dir not in rootDirs:
            rootDirs.append(top_dir)

    if not rootDirs:
        show_error( "No root directories configured." )
        return 1


    # --------------------------------------------------------
    # - Capture Clipboard or selection string
    # --------------------------------------------------------
    clipboard_text = leggi_clipboard(tipo_appunti="clipboard", )
    selection_text = leggi_clipboard(tipo_appunti="primary", )

    logger.info( "rootDirs: %s", rootDirs, )
    logger.info( "Primary Selection..: %s", selection_text, )
    logger.info( "Clipboard (Ctrl+C).: %s", clipboard_text, )

    text_to_be_searched: str = selection_text if args.primary else clipboard_text
    selection_type: str = "primary_selection" if args.primary else "clipboard"
    if not text_to_be_searched:
        show_error(f"Selection type: {selection_type}\ntesto non selezionato e clipboard vuota" )
        return  1


    # --------------------------------------------------------
    # Controllo preliminare: è un URL / IP?
    # --------------------------------------------------------
    location: SourceLocation | None = None
    url_check = is_url_or_ip(text_to_be_searched)
    filepath: str | None = None
    '''
    if url_check:
        location = SourceLocation(filename=url_check, line_no=1, format="url")
        filepath = url_check
        logger.info("URL/IP target identified directly: %s", filepath)

    else:
        # --- Se non è un URL, cerca il file in tutti i rootDirs
        for root_dir in rootDirs:
            logger.info( "Trying rootDir: %s", root_dir, )
            result = analizza_riga( riga=text_to_be_searched, rootDir=root_dir, )
            if result:
                location, filepath = result
                logger.info( "Found file in: %s", root_dir, )
                break

            logger.info( "NOT found in: %s", root_dir, )
    '''
    for root_dir in rootDirs:
        logger.info( "Trying rootDir: %s", root_dir, )
        result = analizza_riga( riga=text_to_be_searched, rootDir=root_dir, )
        if result:
            location, filepath = result
            logger.info( "Found file in: %s", root_dir, )
            break

        logger.info( "NOT found in: %s", root_dir, )




    # --------------------------------------------------------
    # --- File non trovato
    # --------------------------------------------------------
    if location is None or filepath is None:
        roots = "\n".join( f"  {root}" for root in rootDirs )
        logger.warning( "Nessun file trovato per:\n%s", text_to_be_searched, )
        show_error( f'Nessun file trovato per:\n"{text_to_be_searched}"\n\n'
                    f"selection_type: {selection_type}:\n"
                    f'string: "{text_to_be_searched}"\n\n'
                    f"Top directories searched:\n"
                    f"\t{roots}\n\n"
                    f"\tLog: {pv.log_filename}"
                )

        return 1

    # --------------------------------------------------------
    # Determina handler
    # --------------------------------------------------------
    handler = get_file_handler(filepath=filepath,
                            handlers=handlers,
                            default_handler=default_handler,
                            is_url=(location.format == "url"),  # Passiamo il flag URL
                        )

    if handler is None:
        logger.error( "No handler available for: %s", filepath, )
        show_error( f"Nessun programma configurato per:\n\n {filepath}" )
        return 1

    # --------------------------------------------------------
    # Costruisce comando
    # --------------------------------------------------------
    editor_command = build_editor_command(filepath=filepath, line_no=location.line_no, handler=handler, )
    logger.info( "Source location : %s", location, )
    logger.info( "Resolved file   : %s", filepath, )
    logger.info( "Handler         : %s", handler.name, )
    logger.info( "Command         : %s", editor_command, )


    # --------------------------------------------------------
    # - Avvio programma
    # --------------------------------------------------------
    rcode = run_editor(command=editor_command, filepath=filepath)


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

    """ logger è reso globale per essere utilizzato in tutte le funzioni """
    LOG_CONSOLE = (logging.INFO if '--console' in sys.argv else logging.WARNING)

    log_filename = os.environ.get( "ln_XCLIP_LOG_FILENAME", '/tmp/xclip.log' )
    logger = setLogger(filename=log_filename, file_Log_level=logging.INFO, console_Log_level=LOG_CONSOLE, )
    logger.info("starting.... %s", log_filename)


    # pv = dataclass(frozen=True)
    pv = project_vars
    pv.log_filename = log_filename
    main()
