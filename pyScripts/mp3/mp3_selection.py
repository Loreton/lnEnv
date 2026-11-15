#!/usr/bin/env python3
# mp3_copy_selected_list by gemini  support
# by Loreto Notarantonio
# ruff: noqa: E402 - Module level import not at top of file (Ruff E402)
# ruff: noqa: E702 - Multiple statements on one line (semicolon) (Ruff E702)


import sys; sys.dont_write_bytecode = True
import shutil
import argparse
from pathlib import Path
import yaml
from dataclasses import dataclass, field



# --- import pyLnLib
pylnlib_path = Path(__file__).parent.parent / "pyLnLib_last.zip"
sys.path.insert(0,str(pylnlib_path))
from pyLnLib import get_logger, lnDict, get_yamlEngine, get_colors
logger = get_logger()
C = get_colors()

@dataclass(slots=True)
class project_vars:
    """
    Mantiene tyutte le variabili di projetto.
    """

    log_filename: str
    top_dir: Path
    target_dir: Path
    project_env_vars: dict[str, object] = field(default_factory=dict)
    exclude_dirnames: list[str] = field(default_factory=list)
    config_data: lnDict = field(default_factory=lnDict)




###################################################################
# parse Input
###################################################################
def parseInput():
    parser = argparse.ArgumentParser(description="Gestore e copiatore di selezioni musicali YAML.")
    # parser.add_argument("--top-dir", required=True, type=Path, help="Directory radice delle canzoni")
    parser.add_argument("--target-dir", required=True, type=Path, help="Directory di destinazione per i file copiati")
    parser.add_argument("--replace", action="store_true", help="Sovrascrive i file se già presenti nella destinazione")
    parser.add_argument("--include-path", action="store_true", help="Includi il percorso relativo originale nella struttura di destinazione")

    # exclusive_group=parser.add_mutually_exclusive_group(required=True)
    parser.add_argument("--create-yaml", action="store_true", help="Crea un file YAML con la lista delle tracce")
    parser.add_argument("--go", action="store_true", help="Esegue la copia dei file")
    # parser.add_argument("--quiet", action="store_true", help="Disabilita i log verbosi")

    args = parser.parse_args()
    return args



# =============================================================================
def scan_and_generate_yaml(author_dir: Path):
    """
    Scansiona le sottodirectory dell'autore per cercare file MP3
    e genera il file YAML mettendo tutte le tracce sotto la voce 'no'.
    """
    author_name = author_dir.name


    albums_data = {}

    # Scansione album
    for album_dir in sorted(author_dir.iterdir()):
        if album_dir.is_dir():
            album_name = album_dir.name
            mp3_files = sorted( [
                                    f"{author_name}/{album_name}/{f.name}"
                                    for f in album_dir.rglob("*.mp3")
                                ]
                            )

            if mp3_files:
                # default: tutte le tracce sono 'exclude'
                albums_data[album_name] = {
                                                "include": [],
                                                "exclude": mp3_files
                                            }

    if not albums_data:
        return

    yaml_structure = {"Albums": albums_data}
    yaml_path = author_dir / FILENAME_YAML

    with open(yaml_path, "w", encoding="utf-8") as f:
        yaml.dump(yaml_structure, f, default_flow_style=False, indent=4, sort_keys=False)

    print(f"[+ CREATO] {yaml_path}")





# =============================================================================
def process_author_directory(args, author_dir: Path, target_dir: Path) -> int:
    """
    Legge il file YAML dell'autore e copia le tracce specificate in 'yes'.
    """
    yaml_path = author_dir / FILENAME_YAML
    author_name = author_dir.name
    if author_name not in INCLUDE_AUTHORS:
        logger.debug(f"skipping author: {author_name}")
        return 0
    print()
    logger.notify(f"Processing author: {author_name}")

    # Se non esiste, crea il file template e salta la copia per questo giro
    if not yaml_path.exists():
        logger.warning(f"Manca YAML per '{author_dir.name}'.")
        if args.create_yaml:
            logger.info("Generazione in corso...")
            scan_and_generate_yaml(author_dir)
        return 0

    try:
        with open(yaml_path, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f) or {}
    except Exception as e:
        logger.error(f"Errore durante la lettura di {yaml_path}: {e}")
        return 0

    author_songs: int = 0
    albums = data.get("Albums", {})
    for _album_name, content in albums.items():
        logger.notify(f"{TAB2}Album: {_album_name}")
        if not content:
            continue

        yes_list = content.get("include") or []
        for rel_path_str in yes_list:
            if not rel_path_str: # potrebbe esserci qualche '-' come refuso
                continue

            author_songs += 1
            # Il path nel file YAML è relativo alla top-dir (author_name/album_name/song.mp3)
            source_file = author_dir.parent / rel_path_str

            if not source_file.exists():
                logger.warning(f"{TAB4}File not found: {source_file}")
                continue


            # Il file di destinazione sarà nella struttura: target_dir/author_name/album_name/song.mp3
            # Manteniamo la struttura ma senza il top_dir
            if args.include_path:
                dest_file = target_dir / rel_path_str
            else:
                # prendiamo le iniziali dell'author e il nome del file
                name, *rest = author_name.split("_")
                if not rest:
                    author = name
                else:
                    author = name[:1] + ''.join(rest)
                dest_file = target_dir / f"{author}_{source_file.name}"  # include il suffix .mp3

            if dest_file.exists() and not args.replace:
                logger.warning(f"{TAB4}already exists...: {dest_file}")
                continue

            if args.go:
                shutil.copy2(source_file, dest_file)
                logger.notify(f"{TAB4}{C.blue}[copied] {C.cyan}{source_file.name}{C.reset} -> {dest_file}")
            else:
                logger.info(f"{TAB4}{C.blue}[dry-run] {C.cyan}{source_file.name}{C.reset} -> {dest_file}")


    # logger.notify(f"author songs: {author_songs}")
    return author_songs



###################################################################
# Read Configuration
###################################################################
def read_configuration(config_file_name, bootstrap_key: str) -> object:
    """
         read application configuration file

         Args:
             configuration file name

         return:
             configuration (lnDict)
    """
    config_debug_out=Path(config_file_name).stem + "_out.yaml"
    myYaml=get_yamlEngine(logger=logger)
    myYaml.bootstrap(config_file_name, main_key=bootstrap_key)
    config_data=myYaml.load(config_file_name)
    _bootstrat=config_data.pop(bootstrap_key)
    myYaml.save_yaml(filepath=f"{config_debug_out}", indent=4)

    return config_data

# ==========================================================
def check_source_path(song_name: str) -> Path| None:
    for path in pv.config_data.main.search_path:
        source_file = Path(path) / song_name
        if source_file.exists():
            break
    else:
        logger.error(f"no path was found for song: {song_name}")
        source_file = None
        breakpoint()

    return source_file



# ==========================================================
def check_dest_path(song_name: str, alias: str) -> Path:
    if args.include_path:
        dest_file = pv.target_dir / song_name
    else:
        dest_file = pv.target_dir / f"{alias}_{Path(song_name).name}"

        # parts = author_name.split('_')
        # dest_song_name = Path(song_name).name
        # if author_name == "Banco_del_Mutuo_Soccorso":
        #     dest_song_name = f"BancodMS_{dest_song_name}"
        # elif len(parts) == 1:
        #     dest_song_name = f"{parts[0]}_{dest_song_name}"
        # elif len(parts) == 2:
        #     dest_song_name = f"{parts[1]}{parts[0][0]}_{dest_song_name}"
        # # elif len(parts) == 3:
        # #     dest_song_name = f"{parts[2]}{parts[0][0]}_{dest_song_name}"
        # else:
        #     breakpoint()


    return dest_file

# #####################################################################
# #
# #####################################################################
def main():
    config_file_name="mp3_selection_config.yaml"
    config_data=read_configuration(config_file_name=config_file_name, bootstrap_key='bootstrap_main_vars')
    pv.config_data=lnDict(config_data)
    top_dir = Path(pv.config_data.main.top_dir).resolve()
    pv.target_dir = Path(args.target_dir).resolve()

    if not top_dir.exists():
        print(f"[ERR] La directory --top-dir specificata non esiste: {top_dir}")
        return

    pv.target_dir.mkdir(parents=True, exist_ok=True)

    # Scansione cartelle degli autori
    TAB3=' '*3
    TAB6=' '*6
    total_songs: int = 0
    for author_name, author_albums in pv.config_data.authors.items():
        alias = author_albums.pop("alias") # remove it
        logger.notify(f"Processing author: {author_name}")
        for album_name, songs in author_albums.items():
            logger.debug(f"{TAB3}Processing album: {album_name}")
            for song_name in songs["include"]:
                logger.debug(f"{TAB3}{song_name}")
                total_songs += 1
                source_file = check_source_path(song_name)
                if not source_file:
                    continue

                dest_file = check_dest_path(song_name, alias)
                if dest_file.exists() and not args.replace:
                    logger.warning(f"{TAB3}already exists: {dest_file}")
                    continue

                # Crea le directory di destinazione se necessario
                dest_file.parent.mkdir(parents=True, exist_ok=True)

                # Copia il file
                try:
                    if args.go:
                        shutil.copy2(source_file, dest_file)
                    logger.info(f"{TAB6}-> {dest_file}")
                except Exception as e:
                    logger.error(f"Errore nella copia di {source_file}: {e}")




    logger.notify(f"total songs: {total_songs}")

if __name__ == "__main__":
    """ logger è reso globale per essere utilizzato in tutte le funzioni """
    logger.initialize(name="mp3_selection_list", console_logger_level='info')
    pv = project_vars
    C = get_colors()
    args = parseInput()
    logger.info("Starting...")
    main()
    sys.exit("programma completato!")
