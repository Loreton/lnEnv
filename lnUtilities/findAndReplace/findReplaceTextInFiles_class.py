#!/usr/bin/env python3
# ruff: noqa: I001 - Import block is un-sorted or un-formatted help: Organize imports (Ruff I001)
# ruff: noqa: BLE001 - Do not catch blind exception: `Exception` (Ruff BLE001)

import sys; sys.dont_write_bytecode = True
from pathlib import Path
import os
import stat
import argparse
import json

class Colors:
    """Gestione colori per output console"""
    red = '\033[31m'; redH = '\033[91m'
    green = '\033[32m'; greenH = '\033[92m'
    yellow = '\033[33m'; yellowH = '\033[93m'
    blue = '\033[34m'; blueH = '\033[94m'
    purple = '\033[35m'; purpleH = '\033[95m'
    cyan = '\033[36m'; cyanH = '\033[96m'
    gray = '\033[37m'; white = '\033[97m'
    reset = '\033[0m'

class FileFinder:
    """Gestione ricerca file con filtri configurabili"""

    def __init__(self, config=None):

        self.DEFAULT_INCLUDE_EXT = [".py", ".yaml", ".json", ".sh", ".function", ".txt",
                            ".ini", ".alias", ".conf", ".csv", ".tpl", ".yml",
                            ".cfg", ".sublime-project", ".ffs_gui",
                            ".c", ".h", ".cpp", "*"]

        self.DEFAULT_INCLUDE_STEM = ["Loretorc", "etc_motd"]
        self.DEFAULT_INCLUDE_NAME = ["Loretorc", "project_links.lst", "etc_motd", ".bashrc_append"]
        self.DEFAULT_EXCLUDE_EXT = [".zip", ".sublime-workspace", ".pdf", ".xlsx",
                            ".cmd", ".old", ".cache", ".bin", ".log", ".xml"]
        self.DEFAULT_EXCLUDE_PATTERN = [".sync.ffs_db"]
        self.DEFAULT_EXCLUDE_SUBDIR = ["Logs", "logs", "log", "Log", "bin", ".git", ".pio", "lnFreex"]

        self.config = config or {}
        self.top_dir_length = 0
        self._setup_defaults()

    def _setup_defaults(self):
        """Inizializza i filtri con valori di default"""
        self.include_ext = self.config.get('include_ext', self.DEFAULT_INCLUDE_EXT)
        self.include_stem = self.config.get('include_stem', self.DEFAULT_INCLUDE_STEM)
        self.include_name = self.config.get('include_name', self.DEFAULT_INCLUDE_NAME)
        self.exclude_ext = self.config.get('exclude_ext', self.DEFAULT_EXCLUDE_EXT)
        self.exclude_pattern = self.config.get('exclude_pattern', self.DEFAULT_EXCLUDE_PATTERN)
        self.exclude_subdir = self.config.get('exclude_subdir', self.DEFAULT_EXCLUDE_SUBDIR)

    def set_top_dir(self, top_dir):
        """Imposta la directory root e calcola la lunghezza per output formattato"""
        self.top_dir = top_dir
        self.top_dir_length = len(str(top_dir)) + 1

    def get_file_list(self, top_dir, file_pattern="*", verbose=False):
        """Genera lista file che soddisfano i filtri"""
        self.set_top_dir(top_dir)
        colors = Colors()

        for filepath in Path(top_dir).glob(f"**/{file_pattern}"):
            if not filepath.is_file():
                continue

            if self._should_exclude(filepath):
                if verbose:
                    print(f"{colors.red}Excluded: {filepath}{colors.reset}")
                continue

            if self._should_include(filepath):
                if verbose:
                    print(f"{colors.yellow}Included: {filepath}{colors.reset}")
                yield filepath

    def _should_exclude(self, filepath):
        """Verifica se il file deve essere escluso"""
        if filepath.is_symlink():
            return True

        if filepath.suffix in self.exclude_ext:
            return True

        if filepath.name in self.exclude_pattern:
            return True

        for subdir in self.exclude_subdir:
            if subdir in filepath.parts:
                return True

        return False

    def _should_include(self, filepath):
        """Verifica se il file deve essere incluso"""
        if "*" in self.include_ext:
            return True
        return (filepath.suffix in self.include_ext or
                filepath.name in self.include_name or
                filepath.stem in self.include_stem)

class TextReplacer:
    """Gestione ricerca e sostituzione testo nei file"""

    def __init__(self, file_finder, dry_run=True, verbose=False, encoding='utf-8'):
        self.file_finder = file_finder
        self.dry_run = dry_run
        self.verbose = verbose
        self.encoding = encoding
        self.stats = {'files_changed': 0, 'occurrences': 0}
        self.colors = Colors()

    def is_binary(self, filepath):
        """Verifica se il file è binario"""
        try:
            with open(filepath, 'rb') as f:
                data = f.read(1024)
            if not data or b'\x00' in data:
                return True
            data.decode(self.encoding)
            return False
        except UnicodeDecodeError:
            return True

    def process_file(self, filepath, search_str, replace_str=None):
        """Processa un singolo file"""
        if self.is_binary(str(filepath)):
            if self.verbose:
                print(f"{self.colors.redH}BINARY: {filepath}")
            return

        try:
            with open(filepath, 'r', encoding=self.encoding) as f:
                content = f.read()

            if search_str not in content:
                return

            print(f"{self.colors.green}.... {filepath}{self.colors.reset}")
            self.stats['files_changed'] += 1

            self._display_matches(content, search_str, replace_str)

            if replace_str and not self.dry_run:
                self._replace_content(filepath, content, search_str, replace_str)

        except Exception as e:
            print(f"Error processing {filepath}: {e}")

    def _display_matches(self, content, search_str, replace_str=None):
        """Mostra le corrispondenze trovate"""
        for idx, line in enumerate(content.split('\n')):
            if search_str in line:
                self.stats['occurrences'] += 1
                # Mostra riga corrente con evidenziazione
                highlighted = line.replace(search_str,
                                         f"{self.colors.yellowH}{search_str}{self.colors.reset}")
                print(f"    [{idx+1:3}]: {highlighted.strip()}")

                if replace_str:
                    new_line = line.replace(search_str,
                                          f"{self.colors.cyanH}{replace_str}{self.colors.reset}")
                    print(f"    [{idx+1:3}]: {new_line.strip()}")

    def _replace_content(self, filepath, content, search_str, replace_str):
        """Sostituisce il contenuto del file gestendo permessi"""
        # Gestione permessi
        mode = filepath.stat().st_mode
        saved_mode = stat.S_IMODE(mode)
        new_mode = saved_mode

        if not (saved_mode & stat.S_IWUSR):
            new_mode = saved_mode | stat.S_IWUSR
            print(f"        {self.colors.blueH}File è READ-ONLY, attivo scrittura{self.colors.reset}")
            filepath.chmod(new_mode)

        # Sostituzione
        new_content = content.replace(search_str, replace_str)
        print(f"        {self.colors.blue}Scrivo su: {filepath}{self.colors.reset}")

        with open(filepath, 'w', encoding=self.encoding) as f:
            f.write(new_content)

        # Ripristino permessi originali
        if new_mode != saved_mode:
            print(f"        {self.colors.blue}Ripristino READ-ONLY{self.colors.reset}")
            filepath.chmod(saved_mode)

    def process_directory(self, top_dir, search_str, replace_str=None):
        """Processa l'intera directory"""
        self.file_finder.set_top_dir(top_dir)

        for filepath in self.file_finder.get_file_list(
            top_dir=top_dir,
            verbose=self.verbose
        ):
            self.process_file(filepath, search_str, replace_str)

        return self.stats

class FindReplaceApp:
    """Applicazione principale"""

    def __init__(self):
        self.colors = Colors()
        self.file_finder = FileFinder()
        self.replacer = None

    def parse_arguments(self):
        """Parsea gli argomenti della riga di comando"""
        parser = argparse.ArgumentParser(description='find/replace string in text files')
        parser.add_argument('--ignore-case', action='store_true', help='ignore-case')
        parser.add_argument('--go', action='store_true', help='execute replacement (dry-run default)')
        parser.add_argument('--verbose', action='store_true', help='Display all messages')
        parser.add_argument('--display-args', action='store_true', help='Display input parameters')
        parser.add_argument('--search-string', type=str, required=True, help='string to search')
        parser.add_argument('--replace-with', type=str, default=None, help='string to replace with')
        parser.add_argument('--top-dir', type=str, default=os.getcwd(), help='top directory path')
        return parser.parse_args()

    def run(self):
        """Esegue l'applicazione"""
        args = self.parse_arguments()

        if args.display_args:
            print(json.dumps(vars(args), indent=4, sort_keys=True))
            return

        # Configura il replacer
        self.replacer = TextReplacer(
            file_finder=self.file_finder,
            dry_run=not args.go,
            verbose=args.verbose
        )

        print("\n\n")
        print(self.colors.cyanH)
        print(f"\ttop-dir:         {args.top_dir}")
        print(f"\tsearch-string:   {args.search_string}")
        print(f"\treplace-with:    {args.replace_with if args.replace_with else 'None'}")
        print(f"\tmode:            {'REPLACE' if args.go else 'FIND ONLY'}")
        print(self.colors.reset)

        # Processa i file
        stats = self.replacer.process_directory(
            top_dir=args.top_dir,
            search_str=args.search_string,
            replace_str=args.replace_with
        )

        print(f"\n{self.colors.yellowH}Files modificati....: {stats['files_changed']}")
        print(f"{self.colors.yellowH}Occorrenze trovate..: {stats['occurrences']}{self.colors.reset}")

if __name__ == '__main__':
    app = FindReplaceApp()
    app.run()
