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
##
# ruff: noqa: E402 Module level import not at top of file

# from pickletools import stringnl
# from select import select
import sys; sys.dont_write_bytecode = True

from dataclasses import dataclass
from pathlib import Path
import argparse
import subprocess
import os
import re
from string import Template




# --- import pyLnLib
pylnlib_path = Path(__file__).parent.parent / "pyLnLib_last.zip"
pylnlib_path = '/home/loreto/filu/Programming/gitREPO/pyLnLib/src'
sys.path.insert(0,str(pylnlib_path))

# from pyLnLib import get_logger, lnDict, get_yamlEngine, get_colors
from pyLnLib import ctx, get_logger, get_colors, lnDict
logger = get_logger()
C = get_colors()
pvars = ctx.project_vars


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
    format: str # direct_file, generic, url

    def __str__(self) -> str:
        # return f"{self.filename}:{self.line_no}"
        return f"""filepath: {self.filename}\n
                line_no: {self.line_no}\n
                format: {self.format}
                """

@dataclass(slots=True)
class FileHandler:
    """
    Programma utilizzato per aprire un determinato tipo
    di file.
    """

    name: str
    extensions: list[str]
    command: list[str]
    req_line_number: bool = False

    # def handles(self, filename: str) -> bool:
    #     """
    #     Verifica se questo handler gestisce il file.
    #     """
    #     suffix = Path(filename).suffix.lower()
    #     return suffix in self.extensions




# ============================================================
# Argument parser
# ============================================================
def parserInput() -> argparse.Namespace:
    parser = argparse.ArgumentParser( description="xClip", )

    parser.add_argument( "--console", action="store_true", help="console log", )
    # parser.add_argument( "--zed", action="store_true", help="compatibility option: use ZED editor", )

    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument( "--primary", action="store_true", help="read primary selection", )
    group.add_argument( "--clipboard", action="store_true", help="read clipboard", )

    return parser.parse_args()

#============================================================
# --- clean_text
def clean_text(text: str, *, strip_chars: str|None=None, replace_chars: str|None=None) -> str:
    """
    Pulisce il testo rimuovendo caratteri speciali e spazi bianchi.
    e risolvendoventuali variabili
    """
    # Rimuove caratteri speciali e spazi bianchi
    # cleaned_text = re.sub(r'[^\w\s\.\-\/]', '', text)
    # cleaned_text = cleaned_text.strip()
    # return cleaned_text
    logger.debug( "processing string: %s", text, )

    if not text:
        return ""

    cleaned_text = os.path.expandvars(text)
    cleaned_text = Template(cleaned_text).safe_substitute(pvars.env_vars)
    cleaned_text = cleaned_text.strip().strip('"').strip("'")

    # --- 1. Stripping filename
    # strip_chars=''' "'[]: '''
    if strip_chars:
        cleaned_text = cleaned_text.strip(strip_chars)
        logger.info( "Cleaned selected text: %s", cleaned_text )
        if not cleaned_text:
            return ""

    if replace_chars:
        for char in replace_chars:
            cleaned_text = cleaned_text.replace(char , ' ')
        logger.info( "Cleaned selected text: %s", cleaned_text )
        if not cleaned_text:
            return ""

    return cleaned_text

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
# --- GUI messages
def show_error(message: str) -> None:
    """ Mostra un errore tramite zenity.

    Se zenity non è disponibile, registra solamente
    il messaggio nel log.
    """
    logger.error(message)
    try:
        subprocess.run( [ "zenity", "--error", "--title=xClip", f"--text={message}" ], check=False, )

    except FileNotFoundError:
        logger.error( "zenity non installato: %s", message, )


# ============================================================
# - Clipboard
# ============================================================
def leggi_clipboard(tipo_appunti: str = "clipboard", ) -> str:
    """ Legge il contenuto del clipboard o della Primary Selection. """
    try:
        comando = [ "xclip", "-o", "-selection", tipo_appunti, ]
        risultato = subprocess.run( comando, capture_output=True, text=True, check=True, )
        return Template(risultato.stdout.strip()).safe_substitute(pvars.env_vars)

    except subprocess.CalledProcessError as exc:
        logger.error( "Errore durante la lettura degli appunti: %s", exc, )
        return ""

    except FileNotFoundError:
        logger.error( "Il comando 'xclip' non è installato " "o non è nel PATH.", )
        return ""


#============================================================
def set_env_vars(system_vars_file: str, extra_vars_file: str|None = None) -> dict[str, object]:
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
    # --- inseriamo le env vars nel dizionario pvars.env_vars
    dvars: dict=os.environ.copy()  # Start with a copy of the current environment variables

    yaml_file=os.path.expandvars(system_vars_file)
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


# ============================================================
# --- Command builder
def build_editor_command(filepath: str, line_no: int, handler: FileHandler, ) -> list[str]:
    """
    Costruisce il comando da passare a subprocess.

    If line_number is True:
        /path/file.py:123

    else:
        /path/file.epub
    """

    command = list(handler.command)

    if handler.req_line_number:
        command.append( f"{filepath}:{line_no}" )
    else:
        command.append(filepath)

    logger.info( "Command built: %s", command, )

    return command



# ============================================================
# ---- Generic parser
def parse_generic_location(riga: str, ) -> SourceLocation | None:
    """
    Fallback per formati generici.
    riga già ripulita

    Esempi:

        file.py 123
        file.py line 123
        file.py:123
        module.func 123
    """
    riga = clean_text(riga, replace_chars=''' "'[]:, ''')
    tokens = riga.split()

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
# --- Source location parser
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

        location = SourceLocation( filename=match.group(1).strip(), line_no=int(match.group(2)), format=format_name, )
        logger.debug( "SourceLocation found: %s", location, )
        return location

    return None

# ============================================================
# - File search
# ============================================================
def findFileInDir(path: str, filenames_to_be_searched: list[str]) -> str | None:
    """ Cerca filename direttamente nella directory. """
    for fn in filenames_to_be_searched:
        candidate = Path(path) / fn
        logger.info( "\tchecking for: %s", candidate, )
        if candidate.is_file():
            return str(candidate)
    return None


# ============================================================
def findFileInPath(root: str, filepath: str, format: str) -> str|None:
    """ Cerca ricorsivamente filename sotto root. """
    # filepath = location.filename.strip()
    # format = location.format
    logger.info( "findFileInPath: root=%s, filename=%s", root, filepath, )

    # verifica se il file esiste già
    if Path(filepath).is_file():
        logger.info( "File found: %s", filepath, )
        return Path(filepath).resolve()

    filename = Path(filepath).name
    if format == 'logger':
        extensions = pvars.xclip_config.main.code_extensions
    else:
        extensions = pvars.xclip_config.main.code_extensions + pvars.xclip_config.main.default_extensions

    if Path(filename).suffix: # se già contiene il suffix....
        filenames_to_be_searched = [ filename, ]
    else:
        filenames_to_be_searched = [ f"{filename}{ext}" for ext in extensions]
        filenames_to_be_searched.insert( 0, filename, )

    logger.info("filenames_to_be_searched:\n%s", filenames_to_be_searched, )

    for dirpath, dirnames, files in os.walk(root):
        # Non scendere nei .build_stage.
        logger.debug( "checking on path: %s", dirpath, )
        dirnames[:] = [
            dirname
            for dirname in dirnames
            if dirname[0]!='.' and dirname not in pvars.xclip_config.main.exclude_dirnames
        ]


        for candidate_name in filenames_to_be_searched:
            full_path = os.path.join( dirpath, candidate_name, )
            logger.debug( "\tsearching: %s", candidate_name, )

            # if candidate_name in files:
            if Path(full_path).is_file():
                logger.info( "FOUND: %s", full_path, )
                return full_path

    return None










# ==========================================================
def getRootDirs(xc: lnDict) -> list[str]:
    base_top_dirs_file = Path(xc.main.base_top_dirs_file)
    if not base_top_dirs_file.exists():
        # --- se non esiste, crealo e copia dentro le base root directories
        with base_top_dirs_file.open(mode="w", encoding="utf-8") as f:
            f.write("\n".join(xc.main.default_top_dirs))

    extra_top_dirs_file = Path(xc.main.extra_top_dirs_file)
    if not extra_top_dirs_file.exists():
        with extra_top_dirs_file.open(mode="w", encoding="utf-8") as f:
            f.write("")

    try:
        # --- Caricamento delle top directories
        with base_top_dirs_file.open(mode="r", encoding="utf-8") as f:
            rootDirs = [line.strip() for line in f if line.strip()] # più efficiente, rispetto a f.read(),perché non alloca memoria inutile

        # --- read root directories from file created by .xclip.topdir alias command
        with extra_top_dirs_file.open(mode="r", encoding="utf-8") as f:
            extra_rootDirs = [line.strip() for line in f if line.strip()] # più efficiente, rispetto a f.read(),perché non alloca memoria inutile

        rootDirs.extend(extra_rootDirs)

    except FileNotFoundError:
        show_error( f"File delle root directory non trovato:\n\n{xc.main.base_top_dirs_file}" )
        return 1

    # --- elimina duplicati
    rootDirs = list(dict.fromkeys(rootDirs))
    if not rootDirs:
        show_error( "No root directories configured." )
        return []
    return rootDirs



def getSelectedText(xc: lnDict) -> str:
    # --------------------------------------------------------
    # - Capture Clipboard or selection string
    # --------------------------------------------------------
    clipboard_text = leggi_clipboard(tipo_appunti="clipboard", )
    selection_text = leggi_clipboard(tipo_appunti="primary", )

    if pvars.args.primary:
        text = selection_text
        pvars.selection_type = "primary_selection"
    else:
        text = clipboard_text
        pvars.selection_type = "clipboard"

    logger.info("Primary Selection..: %s", selection_text, )
    logger.info("Clipboard (Ctrl+C).: %s", clipboard_text, )
    logger.info("working on:          %s", text, )

    return text.strip()




# ===============================================================
# --- load_handlers
# def load_handlers( config: dict, ) -> list[FileHandler]:
#     """
#     Converte la sezione 'handlers' del YAML in FileHandler.
#     """
#
#     handlers_config = config.get( "handlers", {}, )
#
#     if not isinstance(handlers_config, dict):
#         raise TypeError( "'handlers' must be a dictionary" )
#
#     handlers: list[FileHandler] = []
#
#     for name, data in handlers_config.items():
#
#         if name == "default":
#             continue
#
#         if not isinstance(data, dict):
#             logger.warning( "Ignoring invalid handler: %s", name, )
#             continue
#
#         extensions = data.get( "extensions", [], )
#         command = data.get( "command", [], )
#         line_number = data.get( "line_number", False, )
#
#
#         if not isinstance(extensions, list):
#             raise TypeError( f"Handler '{name}': " "'extensions' must be a list" )
#
#         if not isinstance(command, list):
#             raise TypeError( f"Handler '{name}': " "'command' must be a list" )
#
#         extensions = [ str(ext).lower() for ext in extensions ]
#         command = [ str(item) for item in command ]
#         handler = FileHandler( name=name, extensions=extensions, command=command, line_number=bool(line_number), )
#         handlers.append(handler)
#         logger.debug( "Loaded handler: %s -> %s", name, handler, )
#
#     return handlers

# ===============================================================
# def load_default_handler( config: dict, ) -> FileHandler | None:
#     """
#     Carica l'handler 'default'.
#     """
#
#     data = config.get( "handlers", {}, ).get( "default", )
#
#     if not data:
#         return None
#
#     command = data.get( "command", [], )
#
#     line_number = data.get( "line_number", False, )
#
#     if not isinstance(command, list):
#         raise TypeError( "Default handler: command must be a list" )
#
#     return FileHandler(
#         name="default",
#         extensions=[],
#         command=[ str(item) for item in command ],
#         line_number=bool(line_number),
#     )






# ============================================================
# --- Analizza riga
def analizza_riga(filepath_candidate: str | None, rootDir: str | None, ) -> SourceLocation | None:
    """
    Analizza il percorso del file e risolve il riferimento.
    prima verifica il formato della riga, poi cerca il file nei root directories.

    Return:
        - (SourceLocation, filepath)
        - None.
    """

    logger.debug("processing filepath_candidate: %s", filepath_candidate, )

    if not filepath_candidate:
        return None


    # --- 1. Parser specifici (logger and python traceback))
    location = parse_source_location(filepath_candidate)

    # --- 2. Parser generico
    if location is None:
        location = parse_generic_location(filepath_candidate)

    if location is None:
        logger.warning( "Nessun riferimento sorgente trovato: %s", filepath_candidate, )
        return None

    # --- 6. Proviamo con la root dir relativo
    if rootDir is None:
        logger.error( "rootDir is None", )
        return None

    # modifica opportunamente format e filename
    found_filepath = findFileInPath(root=rootDir, filepath=location.filename, format=location.format)
    if not found_filepath:
        return None

    if os.path.isdir(found_filepath):
        logger.error( "filepath is a directory: %s", found_filepath, )
        return None

    location.filename=found_filepath
    logger.info( "Resolved location: %s", location)

    return location

# ============================================================
# get_file_handler
# ============================================================
def get_file_handler( location: SourceLocation ) -> FileHandler | None:
    """Determina quale handler utilizzare per filepath o URL."""
    ext_hndl=pvars.xclip_config.extensions_handler
    req_line_number = False
    default_command = ext_hndl["default"].command

    if location.format == 'url':
        suffix=".browser"
    else:
        suffix = Path(location.filename).suffix.lower()

    suffix = suffix.lstrip('.') # remove starting dot
    if suffix:
        logger.info("Looking for handler for extension: %s", suffix[1:])

        command = ext_hndl[suffix].get("command", None)
        req_line_number = ext_hndl[suffix].get("req_line_number", False)
        if command is None:
            logger.warning("No specific handler found for: %s", suffix)
            command = default_command
    else:
        command = default_command

    return FileHandler(name=suffix, extensions=[suffix], command=command, req_line_number=req_line_number)





# ============================================================
# --- Run program
def run_handler_program(location: SourceLocation) -> int:
    filepath = location.filename
    # --------------------------------------------------------
    # Determina handler
    # --------------------------------------------------------
    handler = get_file_handler(location=location)
    if handler is None:
        logger.error( "No handler available for: %s", filepath, )
        show_error( f"Nessun programma configurato per:\n\n {filepath}" )
        return 1

    # --------------------------------------------------------
    # Costruisce comando
    # --------------------------------------------------------
    command = build_editor_command(filepath=filepath, line_no=location.line_no, handler=handler, )
    # logger.info( "Resolved file   : %s", location.filename, )
    logger.info( "filepath  : %s", location.filename, )
    logger.info( "line_no   : %s", location.line_no, )
    logger.info( "format    : %s", location.format, )
    logger.info( "Handler   : %s", handler.name, )
    logger.info( "Command   : %s", command, )


    # --------------------------------------------------------
    # - Avvio programma
    # --------------------------------------------------------
    # rcode = run_handler_program(command=editor_command, filepath=location.filename)

    try:
        subprocess.Popen(command)

    except FileNotFoundError as exc:
        show_error(f"Programma non trovato:\n\n {command[0]}\n\n - File:\n {filepath}" )
        return 1

    except Exception as exc:
        show_error("Errore avviando il programma:\n\n" f"{exc}")
        return 1

    return 0

# ============================================================
# Main
# ============================================================
def main(pvars: lnDict) -> int:
    rootDirs: list[str] = []
    xc = pvars.xclip_config


    # --- Caricamento delle top variabili
    pvars.env_vars=set_env_vars(system_vars_file=xc.main.system_vars_file, extra_vars_file=xc.main.extra_vars_file)  # Install system environment variables from the YAML file

    # --- Verifica root directories
    rootDirs = getRootDirs(xc)
    logger.info("rootDirs: %s", rootDirs, )

    # --- preleviamo selected text
    selected_text = getSelectedText(xc)
    selected_text = clean_text(selected_text) # --- pulizia della stringa selezionata
    if not selected_text:
        show_error(f"Selection type: {pvars.selection_type}\ntesto non selezionato e clipboard vuota" )
        return 1

    location: SourceLocation | None = None
    logger.debug( "processing text: %s", selected_text, )


    # --------------------------------------------------------
    # 0. La selezione è un URL o un Indirizzo IP?
    # --------------------------------------------------------
    url_found = is_url_or_ip(selected_text)
    if url_found:
        location = SourceLocation(filename=url_found, line_no=1, format="url")
        logger.info("URL/IP detected: %s", location)
        return run_handler_program(location=location)
    # --------------------------------------------------------
    # 1. La selezione è direttamente un file? magari absoolute?
    # --------------------------------------------------------
    if location is None and os.path.isfile(selected_text):
        location = SourceLocation(filename=selected_text, line_no=1, format="direct_file", )
        logger.notify( "Direct file found: %s", location, )
        return run_handler_program(location=location)



    rootDirs.insert(0, str(Path(os.curdir).resolve())) # insert a dummy root dir to manage absolute paths and direct file references
    # rootDirs.insert(0, '') # insert a dummy root dir to manage absolute paths and direct file references
    for root_dir in rootDirs:
        logger.notify("Trying rootDir:\n%s", root_dir, )
        location = analizza_riga(filepath_candidate=selected_text, rootDir=root_dir, )
        logger.info( "location: %s", location, )

        if location:
            logger.info( "Found file:\n%s\nin: %s", selected_text, root_dir, )
            return run_handler_program(location=location)

        logger.info( "NOT found in: %s", root_dir, )

    else:
        # --------------------------------------------------------
        # --- File non trovato
        # --------------------------------------------------------
        roots = "\n".join( f"  {root}" for root in rootDirs )
        logger.warning( "Nessun file trovato per:\n%s", selected_text, )
        show_error( f'Nessun file trovato per:\n"{selected_text}"\n\n'
                    f"selection_type: {pvars.selection_type}:\n"
                    f'string: "{selected_text}"\n\n'
                    f"Top directories searched:\n"
                    f"{roots}\n\n"
                    f"\tLog: {logger.filename}"
                )

        return 1

    # --------------------------------------------------------
    # Determina handler
    # --------------------------------------------------------
#     handler: FileHandler = get_file_handler(location=location)
#
#     if handler is None:
#         logger.error( "No handler available for: %s", filepath, )
#         show_error( f"Nessun programma configurato per:\n\n {filepath}" )
#         return 1
#
#     # --------------------------------------------------------
#     # Costruisce comando
#     # --------------------------------------------------------
#     editor_command = build_editor_command(filepath=location.filename, line_no=location.line_no, handler=handler, )
#     logger.info( "Source location : %s", location, )
#     logger.info( "Resolved file   : %s", location.filename, )
#     logger.info( "Handler         : %s", handler.name, )
#     logger.info( "Command         : %s", editor_command, )


    # --------------------------------------------------------
    # - Avvio programma
    # --------------------------------------------------------
    return run_handler_program(location=location)


















if __name__ == "__main__":
    if any(arg.startswith('--cons') for arg in sys.argv[1:]):
        LOG_CONSOLE_LEVEL = "INFO"
    else:
        LOG_CONSOLE_LEVEL = "CRITICAL"
        LOG_CONSOLE_LEVEL = "INFO"

    log_dir='/tmp/xclip'
    logger.initialize("xclip",
                        console_logger_level=LOG_CONSOLE_LEVEL,
                        file_logger_level="INFO",
                        logging_dir=log_dir,
                    )
    ctx.initialize(project_name="xclip",
                   version='1.0.0',
                   logger=logger,
                    project_temp_dir='/tmp/xclip',
                    project_log_dir=log_dir,
                    project_config_dir='.'
    )

    # --- read project configuration data
    pvars.xclip_config = ctx.read_yaml_configuration('xclip_config.yaml', log_action=logger.FORCE)

    # --- Verifica input arguments
    pvars.args  = parserInput()


    logger.info("="*60)
    logger.info("= starting.... %s", logger.filename)
    logger.info("="*60)
    rcode = main(pvars)
    if rcode != 0:
        logger.error("Error (rcode:%d) occurred while running xclip", rcode)
        sys.exit(rcode)
