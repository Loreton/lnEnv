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



pyutils_path = Path(__file__).parent.parent / "py_common_utils"
sys.path.insert(0,str(pyutils_path))
from print_logger import PrintLogger  # type: ignore[import-not-found]
from colors import get_colors         # type: ignore[import-not-found]

C = get_colors()

TAB2='  '
TAB4='    '


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




# #####################################################################
# #
# #####################################################################
def main():
    parser = argparse.ArgumentParser(description="Gestore e copiatore di selezioni musicali YAML.")
    parser.add_argument("--top-dir", required=True, type=Path, help="Directory radice delle canzoni")
    parser.add_argument("--target-dir", required=True, type=Path, help="Directory di destinazione per i file copiati")
    parser.add_argument("--replace", action="store_true", help="Sovrascrive i file se già presenti nella destinazione")
    parser.add_argument("--include-path", action="store_true", help="Includi il percorso relatico originale nella struttura di destinazione")

    # exclusive_group=parser.add_mutually_exclusive_group(required=True)
    parser.add_argument("--create-yaml", action="store_true", help="Crea un file YAML con la lista delle tracce")
    parser.add_argument("--go", action="store_true", help="Esegue la copia dei file")
    # parser.add_argument("--quiet", action="store_true", help="Disabilita i log verbosi")

    args = parser.parse_args()

    top_dir: Path = args.top_dir.resolve()
    target_dir: Path = args.target_dir.resolve()

    if not top_dir.exists():
        print(f"[ERR] La directory --top-dir specificata non esiste: {top_dir}")
        return

    target_dir.mkdir(parents=True, exist_ok=True)

    # Scansione cartelle degli autori
    total_songs: int = 0
    for author_dir in sorted(top_dir.iterdir()):
        if author_dir.is_dir():
            songs = process_author_directory(args=args, author_dir=author_dir, target_dir=target_dir)
            if songs:
                total_songs += songs
                logger.notify(f"author songs: {songs}")

    logger.notify(f"total songs: {total_songs}")

if __name__ == "__main__":
    FILENAME_YAML = "Loreto_selection_list.yaml"
    INCLUDE_AUTHORS =[  "Francesco_Guccini",
                        "Arisa",
                        "Alice",
                        "Amedeo_Minghi",
                        "Francesco_de_Gregori",
                        "Delirium",
                        "Banco_del_Mutuo_Soccorso",
                        "Dik_Dik",
                        "Fabrizio_Moro",
                        "Franco_Battiato",
                        "Gianfranco_Manfredi",
                        "Giorgio_Gaber",
                        "Goran_Kuzminac",
                        "Le_Orme",
                        "Luca_Barbarossa",
                        "Luciano_Rossi",
                        "Lucio_Dalla",
                        "Marco_Ferradini",
                        "Pierangelo_Bertoli",
                        "",
                    ]

    # C = PrintLogger.Color
    logger = PrintLogger(name="prova", console_logger_level="info", time_caller_prefix=True)
    logger.info("Starting...")
    main()
    logger.info("Completed...")
