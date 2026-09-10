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



pyutils_path = Path(__file__).parent / ".." / "pyutils"
sys.path.insert(0,str(pyutils_path))
from print_logger import PrintLogger
from colors import get_colors

C = get_colors()




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
def process_author_directory(args, author_dir: Path, target_dir: Path):
    """
    Legge il file YAML dell'autore e copia le tracce specificate in 'yes'.
    """
    yaml_path = author_dir / FILENAME_YAML
    author_name = author_dir.name
    if author_name not in INCLUDE_AUTHORS:
        log.debug(f"skipping author: {author_name}")
        return
    print()
    log.notify(f"Processing author: {author_name}")

    # Se non esiste, crea il file template e salta la copia per questo giro
    if not yaml_path.exists():
        log.warning(f"Manca YAML per '{author_dir.name}'.")
        if args.create_yaml:
            log.info("Generazione in corso...")
            scan_and_generate_yaml(author_dir)
        return

    try:
        with open(yaml_path, "r", encoding="utf-8") as f:
            data = yaml.safe_load(f) or {}
    except Exception as e:
        log.error(f"Errore durante la lettura di {yaml_path}: {e}")
        return

    albums = data.get("Albums", {})
    for _album_name, content in albums.items():
        log.notify(f"\tAlbum: {_album_name}")
        if not content:
            continue

        yes_list = content.get("include") or []
        for rel_path_str in yes_list:
            if not rel_path_str: # potrebbe esserci qualche '-' come refuso
                continue

            # Il path nel file YAML è relativo alla top-dir (author_name/album_name/song.mp3)
            source_file = author_dir.parent / rel_path_str

            if not source_file.exists():
                log.warning(f"File non trovato: {source_file}")
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
                log.warning(f"skipping...: {dest_file} - already exists")
                continue

            if args.go:
                shutil.copy2(source_file, dest_file)
                log.notify(f"{C.blue}[COPIED] {C.cyan}{source_file.name}{C.reset} -> {target_dir}")
            else:
                log.info(f"{C.blue}[DRY RUN] {C.cyan}{source_file.name}{C.reset} -> {dest_file}")


    log.notify(f"total songs: {len(songs)}")








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
    for author_dir in sorted(top_dir.iterdir()):
        if author_dir.is_dir():
            process_author_directory(args=args, author_dir=author_dir, target_dir=target_dir)
            # process_author_directory(author_dir, target_dir, args.replace, args.include_path, args.create_yaml)


if __name__ == "__main__":
    FILENAME_YAML = "Loreto_selection_list.yaml"
    INCLUDE_AUTHORS =[  "Francesco_Guccini",
                        "Arisa",
                        "Amedeo_Minghi",
                        "Francesco_de_Gregori",
                    ]

    # C = PrintLogger.Color
    log = PrintLogger(name="prova", console_logger_level="info", time_caller_prefix=True)
    log.info("Starting...")
    main()
    log.info("Completed...")
