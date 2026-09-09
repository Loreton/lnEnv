# mp3_copy_selected_list by deepseek support
# by Loreto Notarantonio

# ruff: noqa: E402 - Module level import not at top of file (Ruff E402)
"""
    Scan delle directory delle canzoni MP3_Songs alla ricerca dei file Loreto_selection_list.yaml
    all'interno delle directori degli autori.ù
    L'verranno letti solo quelli sooto la key: include:
        Due anni dopo:
            include:
                Francesco_Guccini/Due_anni_dopo/Due_anni_dopo.mp3
                .....
        exclude:
                Francesco_Guccini/Due_anni_dopo/Al_trist.mp3

    se --create allora crea il file Loreto_selection_list.yaml con tutti disabilitati
"""


#!/usr/bin/env python3
"""
Script per gestire la selezione di canzoni tramite file Loreto_selection_list.yaml
"""

import os
import sys
import argparse
import shutil
import yaml
from pathlib import Path


def parse_arguments():
    """Parsa gli argomenti della linea di comando."""
    parser = argparse.ArgumentParser(
        description="Scansiona directory di canzoni e gestisce la selezione tramite file YAML"
    )
    parser.add_argument(
        "--top-dir",
        required=True,
        help="Directory principale contenente le directory degli autori"
    )
    parser.add_argument(
        "--target-dir",
        required=True,
        help="Directory di destinazione per copiare i file selezionati"
    )
    parser.add_argument(
        "--replace",
        action="store_true",
        help="Sostituisci i file esistenti nella directory di destinazione"
    )
    parser.add_argument("--include-path", action="store_true", help="Includi il percorso relatico originale nella struttura di destinazione")

    return parser.parse_args()


def find_mp3_files(directory: Path) -> list[Path]:
    """Trova tutti i file .mp3 in una directory e sottodirectory."""
    mp3_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.lower().endswith('.mp3'):
                mp3_files.append(Path(root) / file)
    return mp3_files


def extract_album_info(file_path: Path, author_name: str) -> str:
    """
    Estrae il nome dell'album dal percorso del file.
    Assumiamo che la struttura sia: author_name/album_name/song.mp3
    """
    parts = file_path.parts
    try:
        # Cerca l'indice del nome dell'autore
        author_index = -1
        for i, part in enumerate(parts):
            if part == author_name:
                author_index = i
                break

        if author_index != -1 and author_index + 1 < len(parts):
            return parts[author_index + 1]
    except:
        pass

    # Fallback: usa il nome della directory padre
    return file_path.parent.name


def create_selection_list(author_dir: Path, author_name: str) -> dict:
    """
    Crea un nuovo file Loreto_selection_list.yaml per un autore.
    """
    # Trova tutti i file mp3 nelle sottodirectory
    mp3_files = find_mp3_files(author_dir)

    # Raggruppa per album
    albums = {}
    for file_path in mp3_files:
        album_name = extract_album_info(file_path, author_name)
        if album_name not in albums:
            albums[album_name] = []
        # Crea il percorso relativo come richiesto: author_name/album_name/song.mp3
        rel_path = file_path.relative_to(author_dir.parent)
        albums[album_name].append(str(rel_path))

    # Crea la struttura YAML
    selection_data = {'Albums': {}}
    for album_name, songs in albums.items():
        selection_data['Albums'][album_name] = {
            'include': [],
            'exclude': songs  # Tutti i file sono disabilitati di default
        }

    return selection_data


def load_or_create_selection_list(author_dir: Path, author_name: str) -> dict:
    """
    Carica un file Loreto_selection_list.yaml esistente o ne crea uno nuovo.
    """
    yaml_file = author_dir / 'Loreto_selection_list.yaml'

    if yaml_file.exists():
        try:
            with open(yaml_file, 'r', encoding='utf-8') as f:
                return yaml.safe_load(f)
        except Exception as e:
            print(f"Errore nella lettura di {yaml_file}: {e}")
            print("Creazione di un nuovo file...")
            return create_selection_list(author_dir, author_name)
    else:
        print(f"File {yaml_file} non trovato. Creazione automatica...")
        return create_selection_list(author_dir, author_name)


def save_selection_list(author_dir: Path, data: dict):
    """Salva il file Loreto_selection_list.yaml."""
    yaml_file = author_dir / 'Loreto_selection_list.yaml'
    if yaml_file.exists(): # sesiste non modificarlo
        return
    with open(yaml_file, 'w', encoding='utf-8') as f:
        yaml.dump(data, f, default_flow_style=False, indent=4, allow_unicode=True)


def copy_selected_files(top_dir: Path, target_dir: Path, replace: bool, include_path:bool=False):
    """
    Copia i file selezionati (nella sezione 'include') nella directory di destinazione.
    """
    # Crea la directory di destinazione se non esiste
    target_dir.mkdir(parents=True, exist_ok=True)

    # Scansiona tutte le directory degli autori
    for author_dir in top_dir.iterdir():
        author_name = author_dir.name
        # print(f"Processing author: {author_name}")
        if not author_dir.is_dir():
            continue

        print(f"\nProcessing author: {author_name}")

        # Carica o crea il file di selezione
        selection_data = load_or_create_selection_list(author_dir, author_name)

        # Copia i file selezionati
        albums = selection_data.get('Albums', {})
        for album_name, album_data in albums.items():
            include_files = album_data.get('include', [])

            for rel_path_str in include_files:
                rel_path = Path(rel_path_str)
                source_file = top_dir / rel_path

                if not source_file.exists():
                    print(f"  Attenzione: File non trovato: {source_file}")
                    continue

                # Il file di destinazione sarà nella struttura: target_dir/author_name/album_name/song.mp3
                # Manteniamo la struttura ma senza il top_dir
                if include_path:
                    dest_file = target_dir / rel_path
                else:
                    dest_file = target_dir / f"{author_name}_{source_file.name}"  # include il suffix .mp3

                # Crea le directory di destinazione se necessario
                dest_file.parent.mkdir(parents=True, exist_ok=True)

                # Copia il file
                try:
                    if dest_file.exists() and not replace:
                        print(f"  Salta (esiste già): {dest_file}")
                        continue

                    shutil.copy2(source_file, dest_file)
                    print(f"  Copiato: {source_file} -> {dest_file}")
                except Exception as e:
                    print(f"  Errore nella copia di {source_file}: {e}")

        # Salva eventuali modifiche al file YAML
        save_selection_list(author_dir, selection_data)


def main():
    """Funzione principale."""
    args = parse_arguments()

    top_dir = Path(args.top_dir)
    target_dir = Path(args.target_dir)

    if not top_dir.exists() or not top_dir.is_dir():
        print(f"Errore: {top_dir} non è una directory valida")
        sys.exit(1)

    print(f"Directory principale: {top_dir}")
    print(f"Directory di destinazione: {target_dir}")
    print(f"Sostituisci file esistenti: {args.replace}")
    print(f"Includi percorso relativo: {args.include_path}")
    print("=" * 50)

    copy_selected_files(top_dir, target_dir, args.replace, args.include_path)

    print("\nOperazione completata!")


if __name__ == "__main__":
    main()
