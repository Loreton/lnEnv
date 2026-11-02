#!/usr/bin/env python3
# ruff: noqa: I001 - Import block is un-sorted or un-formatted help: Organize imports (Ruff I001)
# updated by ...: Loreto Notarantonio

# ruff: noqa E402 - Module level import not at top of file
#
from __future__ import annotations

import sys; sys.dont_write_bytecode = True  # type: ignore[assignment]

import os
import yaml
from pathlib import Path
from datetime import datetime
from string import Template
# import re



#
pyutils_path = Path(__file__).parent.parent / "py_common_utils"
sys.path.insert(0,str(pyutils_path))
from print_logger import PrintLogger  # type: ignore[import-not-found]
from colors import get_colors         # type: ignore[import-not-found]




def yaml_include_constructor(loader, node):
    filename = loader.construct_scalar(node)

    return loader.engine.load( filename, _parent=loader.current_file, _stack=loader.include_stack, )


def yaml_constructor_include_merge(loader, node):
    filenames = loader.construct_sequence(node, deep=True)
    result = {}
    for filename in filenames:
        data = loader.engine.load( filename, _parent=loader.current_file, _stack=loader.include_stack, )
        if not isinstance(data, dict):
            raise TypeError( f"!include_merge requires a dictionary: {filename}" )
        result.update(data)

    return result


def yaml_constructor_list_merge(loader, node):
    filenames = loader.construct_sequence(node, deep=True)
    result = []

    for filename in filenames:
        data = loader.engine.load( filename, _parent=loader.current_file, _stack=loader.include_stack, )
        if isinstance(data, list):
            result.extend(data)
        elif data is not None:
            result.append(data)

    return result


def join_path(loader, node):
    items = loader.construct_sequence(node, deep=True)
    return os.path.join(*(str(item) for item in items))


def join_str(loader, node):
    items = loader.construct_sequence(node, deep=True)
    return "".join(str(item) for item in items)



#################################
# --- Loader Personalizzato ---
#################################
class lnYamlLoader(yaml.SafeLoader):
    """Loader YAML con riferimento all'engine e al file corrente."""

    def __init__(
        self,
        stream,
        *,
        engine: "YamlEngine",
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

    def __init__( self, logger, search_path: list[str] | None = None, ):
        self.logger = logger

        self.search_path = self._unique_paths( search_path or [] )

        self.keypath_separator = "#"
        self.project_env_vars: dict[str, str] = {}
        self.main_config_file: Path | None = None
        self.bootstrapped = False
        self.data: object = {}

    # --------------------------------------------------
    # Utility
    # --------------------------------------------------
    def _unique_paths(self, paths: list[str]) -> list[Path]:
        """Normalizza i percorsi ed elimina i duplicati mantenendo l'ordine."""
        result = []
        for item in paths:
            path = Path(item).expanduser().resolve()
            if path not in result:
                result.append(path)

        return result


    # ====================================================
    def _expand_vars(self, value: str) -> str:
        """Espande le variabili di sistema e quelle del progetto."""
        value = os.path.expandvars(value)
        return Template(value).safe_substitute( self.project_env_vars )


    # ====================================================
    def _expand_path(self, value: str) -> Path:
        value = self._expand_vars(value)
        return Path(value).expanduser()



    # --------------------------------------------------
    # Risoluzione file
    # --------------------------------------------------
    def _resolve_file( self, filename: str, parent: Path | None = None, ) -> Path:
        filename = self._expand_vars(filename)
        path = Path(filename).expanduser()

        candidates = []

        if path.is_absolute():
            candidates.append(path)
        else:
            if parent is not None:
                candidates.append(parent / path)

            candidates.extend(base / path for base in self.search_path)

        for candidate in candidates:
            candidate = candidate.resolve()
            if candidate.is_file():
                return candidate

        raise FileNotFoundError( f"YAML file not found: {filename}" )



    # --------------------------------------------------
    # lettura file
    # --------------------------------------------------
    def get_file_content(self, file: str) -> str:
        """Legge un file YAML usando i percorsi configurati."""

        filename = self._resolve_file(file)

        self.logger.debug("Reading YAML file: %s", filename)

        return filename.read_text(encoding="utf-8")

    # --------------------------------------------------
    # Bootstrap
    # --------------------------------------------------
    def bootstrap(self, filename: str) -> None:
        """
        Legge main_vars dal file principale e configura l'engine.

        Non costruisce il resto del documento YAML:
        questo permette di avere tag personalizzati nel documento
        senza doverli interpretare durante il bootstrap.
        """

        config_file = self._resolve_file(filename)
        self.logger.info("Bootstrapping YAML engine: %s", config_file)
        content = config_file.read_text(encoding="utf-8")
        loader = yaml.SafeLoader(content)

        try:
            root = loader.get_single_node()
            if root is None:
                raise ValueError("Empty main configuration file")

            if not isinstance(root, yaml.MappingNode):
                raise TypeError("Main YAML document must be a mapping")

            main_vars_node = None
            for key_node, value_node in root.value:
                if ( isinstance(key_node, yaml.ScalarNode) and key_node.value == "bootstrap_main_vars" ):
                    main_vars_node = value_node
                    break

            if main_vars_node is None:
                main_vars = {}
            else:
                # Costruisce soltanto il nodo main_vars.
                main_vars = loader.construct_object( main_vars_node, deep=True, )

        finally:
            loader.dispose()

        if not isinstance(main_vars, dict):
            raise TypeError("main_vars must be a YAML mapping")

        # ----------------------------------------------
        # keypath_separator
        # ----------------------------------------------
        separator = main_vars.get("keypath_separator", "#")
        if not isinstance(separator, str) or not separator:
            raise ValueError( "main_vars.keypath_separator must be a non-empty string" )

        self.keypath_separator = separator

        # ----------------------------------------------
        # project_env_vars
        # ----------------------------------------------
        project_env_vars = main_vars.get("project_env_vars", {})

        if not isinstance(project_env_vars, dict):
            raise TypeError( "main_vars.project_env_vars must be a mapping" )

        self.project_env_vars = {}

        for name, value in project_env_vars.items():
            if not isinstance(name, str) or not isinstance(value, str):
                raise TypeError( "project_env_vars keys and values must be strings" )

            expanded_value = os.path.expandvars(value)
            self.project_env_vars[name] = expanded_value




        # ----------------------------------------------
        # search_path
        # ----------------------------------------------
        config_paths = main_vars.get("search_path", [])
        if not isinstance(config_paths, list):
            raise TypeError("main_vars.search_path must be a list")

        # Il percorso del file principale è sempre disponibile.
        paths = [config_file.parent]
        for item in config_paths:
            if not isinstance(item, str):
                raise TypeError("search_path entries must be strings")

            path = self._expand_path(item)
            if not path.is_absolute():
                path = config_file.parent / path

            paths.append(str(path))

        # Combined: conserva i percorsi del costruttore.
        # paths.extend(str(path) for path in self.search_path)
        paths.extend(path for path in self.search_path)
        self.search_path = self._unique_paths(paths)
        self.main_config_file = config_file
        self.bootstrapped = True

        self.logger.info(
            "YAML engine configured: separator=%r, search paths=%d, env vars=%d",
            self.keypath_separator,
            len(self.search_path),
            len(self.project_env_vars),
        )

    # --------------------------------------------------
    # Keypath
    # --------------------------------------------------
    def _get_keypath(self, data: object, keypath: str) -> object:
        current = data
        for key in keypath.split("."):
            if not isinstance(current, dict):
                raise KeyError( f"Cannot access '{key}' in keypath '{keypath}'" )

            if key not in current:
                raise KeyError( f"Key '{key}' not found in keypath '{keypath}'" )

            current = current[key]

        return current

    # --------------------------------------------------
    # Load
    # --------------------------------------------------
    def load( self, filename_with_pointer: str, *, _parent: Path | None = None, _stack: tuple[Path, ...] = (), ) -> object:
        if not self.bootstrapped:
            raise RuntimeError( "YamlEngine is not bootstrapped. " "Call bootstrap() before load()." )

        target_file, separator, keypath = ( filename_with_pointer.partition(self.keypath_separator) )
        keypath = keypath if separator else None
        filename = self._resolve_file(target_file, parent=_parent)

        # Controllo dei cicli nella catena degli include.
        if filename in _stack:
            chain = " -> ".join(str(path) for path in (*_stack, filename))
            raise ValueError(f"Circular YAML include detected: {chain}")

        self.logger.info("Loading YAML file: %s", filename)

        content = filename.read_text(encoding="utf-8")
        content = self._expand_vars(content)

        current_stack = (*_stack, filename)
        loader = lnYamlLoader( content, engine=self, current_file=filename, include_stack=current_stack, )

        try:
            data = loader.get_single_data()
        finally:
            loader.dispose()

        # main_vars appartiene al bootstrap, non ai dati applicativi.
        if filename == self.main_config_file and isinstance(data, dict):
            data.pop("main_vars", None)

        if keypath:
            data = self._get_keypath(data, keypath)

        self.data = data

        return data

    # --------------------------------------------------
    # Export
    # --------------------------------------------------
    def to_yaml( self, title: Path | str | None = None, indent: int = 4, sort_keys: bool = False, **kwargs, ) -> str:
        """Converte lo lnDict in una stringa YAML pulita.
            title: se valorizzato viene messo in testa al dict
        """
        data = {title: self.data} if title else self.data
        return yaml.dump( data, indent=indent, sort_keys=sort_keys, default_flow_style=False, **kwargs, )


    def save_yaml( self, filepath, title: str = "", indent: int = 4, **kwargs, ) -> None:
        """Salva lo lnDict in un file .yaml."""
        yaml_data = self.to_yaml( title=title, indent=indent, **kwargs, )
        now = datetime.now().strftime("%d-%m-%Y_%H:%M")
        comment = f"#{'-' * 20}"
        yaml_data = ( f"{comment}\n" f"#- {now}\n" f"{comment}\n" f"{yaml_data}" )
        Path(filepath).write_text(yaml_data, encoding="utf-8")
        self.logger.notify( "file: [%s] has been written", filepath, stack_trace=False, )

#################################
# --- Funzione Factory ---
#################################
def get_yaml_engine( logger, search_path: list[str] | None = None, ) -> YamlEngine:
    """
    Crea e restituisce un'istanza di YamlEngine.

    Args:
        search_paths: Lista di percorsi dove cercare i file YAML
        recursive: Se cercare ricorsivamente nelle sottodirectory

    Returns:
        Un'istanza configurata di YamlEngine
    """

    extra_search_paths = [str(Path.cwd()), str(Path(sys.argv[0]).resolve().parent), ]

    paths = list(search_path or [])
    paths.extend(extra_search_paths)
    paths.insert(0, "")

    return YamlEngine( logger=logger, search_path=paths, )













if __name__ == "__main__":
    logger = PrintLogger(name="prova", console_logger_level="info", time_caller_prefix=True)
    C = get_colors()
    myYaml=get_yaml_engine(logger=logger)
    myYaml.bootstrap("yaml_loader_test_file.yaml")
    conf=myYaml.load("yaml_loader_test_file.yaml")
    myYaml.save_yaml(filepath="yaml_loader_test_file_out.yaml", title="yaml_loader_test_file", indent=4)
    # print(conf)
    # myYaml.load("/home/loreto/filu/myData/Songs/mp3_songs/Italiani/Francesco_Guccini/OK_Loreto_selection_list_Gucc.yaml")
