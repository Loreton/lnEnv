#!/usr/bin/env python3
# ruff: noqa: I001 - Import block is un-sorted or un-formatted help: Organize imports (Ruff I001)
# updated by ...: Loreto Notarantonio

# ruff: noqa E402 - Module level import not at top of file
#
from __future__ import annotations

import sys; sys.dont_write_bytecode = True  # type: ignore[assignment]

import os
import yaml
import zipfile
from pathlib import Path
from datetime import datetime


#
pyutils_path = Path(__file__).parent.parent / "py_common_utils"
sys.path.insert(0,str(pyutils_path))
from print_logger import PrintLogger  # type: ignore[import-not-found]
from colors import get_colors         # type: ignore[import-not-found]



# --------------------------------
# Costruttori dei tag
# --------------------------------
def yaml_include_constructor(loader, node):
    """Include di un file YAML, con eventuale keypath."""
    filename = loader.construct_scalar(node)
    return loader.engine.load( filename, _stack=loader.include_stack )


def yaml_constructor_include_merge(loader, node):
    """Include e fusione di più dizionari."""
    filenames = loader.construct_sequence(node, deep=True)
    final_dict = {}
    for filename in filenames:
        data = loader.engine.load( filename, _stack=loader.include_stack )

        if not isinstance(data, dict):
            raise TypeError( f"!include_merge richiede un dizionario: {filename}" )

        final_dict.update(data)

    return final_dict


def yaml_constructor_list_merge(loader, node):
    """Include e concatenazione di più liste."""
    filenames = loader.construct_sequence(node, deep=True)
    final_list = []
    for filename in filenames:
        data = loader.engine.load( filename, _stack=loader.include_stack )
        if isinstance(data, list):
            final_list.extend(data)
        elif data is not None:
            final_list.append(data)

    return final_list


def join_path(loader, node):
    """Composizione di un percorso."""
    items = loader.construct_sequence(node, deep=True)
    return os.path.join(*(str(item) for item in items))


def join_str(loader, node):
    """Concatenazione di stringhe."""
    items = loader.construct_sequence(node, deep=True)
    return ''.join(str(item) for item in items)



#################################
# --- Loader Personalizzato ---
#################################
class lnYamlLoader(yaml.SafeLoader):
    """Loader YAML con supporto ai tag personalizzati."""

    def __init__( self,
                    stream,
                    *,
                    engine: YamlEngine,
                    current_file: Path,
                    include_stack: tuple[Path, ...],
                ):

        super().__init__(stream)

        self.engine = engine
        self.current_file = current_file
        self.include_stack = include_stack




# --------------------------------
# Registrazione dei tag
# --------------------------------
lnYamlLoader.add_constructor('!include', yaml_include_constructor)
lnYamlLoader.add_constructor('!include_merge', yaml_constructor_include_merge )
lnYamlLoader.add_constructor('!list_merge', yaml_constructor_list_merge )
lnYamlLoader.add_constructor('!join_path', join_path)
lnYamlLoader.add_constructor('!join_str', join_str)


#################################
# --- YamlEngine Class ---
#################################
class YamlEngine:
    #################################
    # - Costruttore
    #################################
    def __init__(self, logger: PrintLogger, search_path: list[str], recursive: bool=False):
        self.logger = logger

        #limina i duplicati
        # self.search_path: set[str] = set(search_path)
        self.search_path = list(dict.fromkeys(
            str(Path(p).expanduser()) for p in search_path
        ))

        self.data: object = {}
        self.keypath_separator = '##'



    def _resolve_file( self, filename: str | Path, parent: Path | None = None ) -> Path:
        filename = os.path.expandvars( os.path.expanduser(str(filename)) )
        file_path = Path(filename)

        # Percorso assoluto
        if file_path.is_absolute():
            candidates = [file_path]
        else:
            candidates = []

            # Prima la directory del file chiamante
            if parent is not None:
                candidates.append(parent / file_path)

            # Poi i percorsi di ricerca
            candidates.extend( Path(directory) / file_path for directory in self.search_path )

        for candidate in candidates:
            candidate = candidate.resolve()
            if candidate.is_file():
                return candidate

        raise FileNotFoundError(f"File YAML non trovato: {filename}" )











    #################################
    # - get_file_content
    #################################
    def XXXXX_get_file_content(self, file: str) -> str | None:
        """Cerca un file nei percorsi di ricerca."""
        content_str = None

        self.logger.debug("searching for file: %s ", file)
        for _dir in self.search_path:
            filename = (Path(_dir).expanduser() / file).resolve()

            if os.path.exists(filename):
                fTYPE=1
                if fTYPE==1:
                    with open(filename, 'r') as f: # modalita testo
                        content_str   = f.read()  # Già una stringa (str)
                        # se si ha bisogno dei bytes prima...
                        # content_bytes = f.read().encode('utf-8')  # bytes
                        # content_str   = content_bytes.decode('utf-8')  # str
                else:
                    with open(filename, 'rb') as f: # modalità binaria
                        content_bytes = f.read()  # bytes
                        _content_str   = content_bytes.decode('utf-8')  # str
                break
        else:
            self.logger.error( "filename: %s not found on fileSystem", file)
            sys.exit(1)


        return content_str

    #################################
    # - _get_keypath
    #################################
    def _get_keypath(self, data: dict[str, object], keypath: str) -> dict:
        """Recupera un valore da un dizionario usando un percorso di chiavi."""
        current_data: dict = data
        try:
            for key in keypath.split('.'):
                if isinstance(current_data, dict):
                    current_data = current_data.get(key)
                    if current_data is None:
                        break
                else:
                    break
        except Exception as e:
            self.logger.error(f"Error accessing keypath '{keypath}': {e}")

        return current_data

    #################################
    # - load
    #################################
    def load( self, filename_with_pointer: str, *, _stack: tuple[Path, ...] = () ) -> object:
        """
        Carica un file YAML.

        Supporta:
            !include
            !include_merge
            !list_merge
            !join_path
            !join_str
            keypath con # (file.yaml#key.subkey)
        """

        # Separazione file / keypath
        # target_file, separator, keypath = ( filename_with_pointer.partition('#') )
        target_file, separator, keypath = ( filename_with_pointer.partition(self.keypath_separator) )

        keypath = keypath if separator else None

        # Directory del file chiamante
        parent = _stack[-1].parent if _stack else None

        try:
            filename = self._resolve_file(target_file, parent)

            # Controllo inclusioni circolari
            if filename in _stack:
                chain = " -> ".join(str(p) for p in (*_stack, filename))
                raise ValueError(f"Include circolare rilevato: {chain}" )

            self.logger.info("Loading YAML: %s", filename)

            # Caricamento contenuto
            content = filename.read_text(encoding="utf-8")

            # Espansione variabili ambiente
            content = os.path.expandvars(content)

            # Aggiorna la catena di inclusione
            current_stack = (*_stack, filename)

            # Creazione Loader associato a questa istanza
            loader = lnYamlLoader(content, engine=self, current_file=filename, include_stack=current_stack )

            try:
                data = loader.get_single_data()
            finally:
                loader.dispose()

            # Estrazione keypath
            if keypath:
                file_data = self._get_keypath(data, keypath)
                if file_data is None:
                    raise KeyError(f"Keypath '{keypath}' non trovato in {filename}" )
            else:
                file_data = data

            self.data = file_data

            return file_data

        except Exception as e:
            self.logger.error( "Errore durante il caricamento di %s: %s", filename_with_pointer, e )
            raise




    # #############################################################################
    # # title: se valorizzato viene messo in testa al dict
    # #############################################################################
    def to_yaml(self, title: Path|str|None=None, indent: int=4, sort_keys=False, **kwargs):
        """Converte lo lnDict in una stringa YAML pulita."""
        d={title: self.data} if title else self.data
        return yaml.dump(d, indent=indent, default_flow_style=False, **kwargs)


    # #############################################################################
    # # title: se valorizzato viene messo in testa al dict
    # #  utile per avere un'idea di massima del contenuto del dictionary
    # #############################################################################
    def save_yaml(self, filepath, title: str='', indent: int=4, **kwargs):
        """Salva lo lnDict in un file .yaml."""
        yaml_data = self.to_yaml(title=title, indent=indent, **kwargs)
        now = datetime.now().strftime("%d-%m-%Y_%H:%M")
        _cmnt=f"#{'-'*20}"
        yaml_data = f"{_cmnt}\n#- {now}\n{_cmnt}\n{yaml_data}"
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(yaml_data)

        # self.logger.notify("lnd_file: [%s] has been written", filepath, stacklevel=stacklevel, stack_trace=False)
        self.logger.notify("file: [%s] has been written", filepath, stack_trace=False)


#################################
# --- Funzione Factory ---
#################################
def get_yaml_engine(logger: PrintLogger, search_path: list[str]|None = None ) -> YamlEngine:
    """
    Crea e restituisce un'istanza di YamlEngine.

    Args:
        search_paths: Lista di percorsi dove cercare i file YAML
        recursive: Se cercare ricorsivamente nelle sottodirectory

    Returns:
        Un'istanza configurata di YamlEngine
    """
    search_path = search_path or []
    search_path.append(str(Path(os.curdir).resolve()))
    search_path.append(str(Path(sys.argv[0]).resolve().parent))
    search_path.insert(0, "")


    # Crea l'engine (il costruttore imposta automaticamente il riferimento globale)
    engine = YamlEngine(logger, search_path=search_path, recursive=False)

    return engine



if __name__ == "__main__":
    logger = PrintLogger(name="prova", console_logger_level="info", time_caller_prefix=True)
    C = get_colors()
    myYaml=get_yaml_engine(logger=logger)
    conf=myYaml.load("yaml_loader_test_file.yaml")
    myYaml.save_yaml(filepath="yaml_loader_test_file_out.yaml", title="yaml_loader_test_file", indent=4)
    # print(conf)
    # myYaml.load("/home/loreto/filu/myData/Songs/mp3_songs/Italiani/Francesco_Guccini/OK_Loreto_selection_list_Gucc.yaml")
