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

#################################
# --- Riferimento globale all'engine ---
#################################
_yaml_engine: 'YamlEngine' | None = None

def set_yaml_engine(engine: YamlEngine) -> None:
    """Imposta il riferimento globale all'engine YAML."""
    global _yaml_engine
    _yaml_engine = engine

def get_yaml_engine_instance() -> YamlEngine | None:
    """Recupera il riferimento globale all'engine YAML."""
    return _yaml_engine

#################################
# --- Loader Personalizzato ---
#################################
class lnYamlLoader(yaml.FullLoader):
    """Loader che mantiene un riferimento all'oggetto di ambiente per i tag custom."""
    # Non serve più env_ref, usiamo il riferimento globale
    pass

#################################
# --- Costruttori dei Tag ---
#################################
def yaml_include_constructor(loader, node):
    """Costruttore per il tag !include."""
    engine = get_yaml_engine_instance()
    if engine is None:
        raise ValueError("YAML engine not initialized. Call get_yaml_engine() first.")
    return engine.load(node.value)

def yaml_constructor_include_merge(loader, node):
    """Costruttore per il tag !include_merge."""
    engine = get_yaml_engine_instance()
    if engine is None:
        raise ValueError("YAML engine not initialized. Call get_yaml_engine() first.")

    items = loader.construct_sequence(node)
    final_dict = {}
    for filename in items:
        res = engine.load(filename)
        # final_dict.update(res)   # do per scontato che siano tutti dict()
        # if isinstance(res, dict):
        #     final_dict.update(res)
    return final_dict

def yaml_constructor_list_merge(loader, node):
    """Costruttore per il tag !list_merge."""
    engine = get_yaml_engine_instance()
    if engine is None:
        raise ValueError("YAML engine not initialized. Call get_yaml_engine() first.")

    items = loader.construct_sequence(node)
    final_list = []
    for filename in items:
        res = engine.load(filename)
        if isinstance(res, list):
            final_list.extend(res)
        elif res is not None:
            final_list.append(res)
    return final_list\

def join_path(loader, node):
    """Costruttore per il tag !join_path."""
    return os.path.join(*loader.construct_sequence(node))

def join_str(loader, node):
    """Costruttore per il tag !join_str."""
    return ''.join([str(i) for i in loader.construct_sequence(node)])

# ----------------------
# Registrazione Tag
# ----------------------
lnYamlLoader.add_constructor('!include', yaml_include_constructor)
lnYamlLoader.add_constructor('!include_merge', yaml_constructor_include_merge)
lnYamlLoader.add_constructor('!list_merge', yaml_constructor_list_merge)
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
        # self.logger = get_logger()
        self.logger = logger


        # Identifica se stiamo girando da un .pyz o .zip
        self.script_path = sys.argv[0]
        #limina i duplicati
        # self.search_path: set[str] = set(search_path)
        self.search_path = list(dict.fromkeys(search_path)) # non perdo l'odine
        self.data: dict = {}

        # Imposta il riferimento globale a questo engine
        set_yaml_engine(self)

    #################################
    # - get_file_content
    #################################
    def get_file_content(self, file: str) -> str | None:
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
            self.logger.error( "filename: %s not found on fileSystem", filename)
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
    def load(self, filename_with_pointer: str) -> dict:
        """
        Carica un file YAML con supporto per:
        - !include, !include_merge, !list_merge
        - !join_path, !join_str
        - keypath con # (es: 'file.yaml#key.subkey')
        """
        # Estrai keypath se presente
        if '#' in filename_with_pointer:
            target_file, keypath = filename_with_pointer.split('#', 1)
        else:
            target_file, keypath = filename_with_pointer, None

        self.logger.info("trying to load file: %s", target_file)

        # Cerca il file
        content: str | None = self.get_file_content(target_file)
        if not content:
            self.logger.error( "filename: %s is empty or not found", target_file)
            return {}
        else:
            self.logger.info( "file: %s has been loaded", target_file)


        # Espandi variabili d'ambiente
        content = os.path.expandvars(str(content))

        # Carica il contenuto YAML
        data = yaml.load(content, Loader=lnYamlLoader)

        # Estrai keypath se specificato
        if keypath:
            file_data = self._get_keypath(data, keypath)
            if file_data is None:
                self.logger.error( "Key '%s' not found in file: %s", keypath, target_file )
                file_data = data  # Fallback al dato completo
        else:
            file_data = data

        self.data = file_data
        return file_data



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
    engine = YamlEngine(logger, search_path=search_path+extra_search_paths, recursive=False)

    return engine



if __name__ == "__main__":
    logger = PrintLogger(name="prova", console_logger_level="info", time_caller_prefix=True)
    C = get_colors()
    myYaml=get_yaml_engine(logger=logger)
    conf=myYaml.load("yaml_loader_test_file.yaml")
    breakpoint()
    myYaml.save_yaml(filepath="yaml_loader_test_file_out.yaml", title="yaml_loader_test_file", indent=4)
    print(conf)
    # myYaml.load("/home/loreto/filu/myData/Songs/mp3_songs/Italiani/Francesco_Guccini/OK_Loreto_selection_list_Gucc.yaml")
