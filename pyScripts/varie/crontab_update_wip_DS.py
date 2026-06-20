#!/usr/bin/env python3
# ========================================
# updated by ...: Loreto Notarantonio
# Date .........: 11-05-2026 15.29.27
# Script per gestire l'aggiornamento del crontab
# ========================================

#### DeepSeek

import sys; sys.dont_write_bytecode = True
import os
import sys
import subprocess
import shutil
import datetime
from pathlib import Path
from typing import Tuple, Optional

# Colori per output (simulando i colori del bash)
class Colors:
    RESET = '\033[0m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    PURPLE = '\033[95m'
    GRAY = '\033[90m'

    # Extra spazi di indentazione simulati
    TAB = '    '

colors = Colors()

# Variabile di versione
LN_VERSION = f"{__file__}\n    version V2026-05-11_152927"


def setup_environment():
    """Carica le variabili di ambiente dal file .loreto_setup"""
    loreto_setup_path = Path.home() / ".loreto_setup"

    if not loreto_setup_path.exists():
        print(f"{colors.RED}File {loreto_setup_path} non trovato!{colors.RESET}")
        sys.exit(1)

    # Leggi il file e imposta le variabili d'ambiente necessarie
    with open(loreto_setup_path, 'r') as f:
        exec(f.read())

    # Verifica che la variabile ln_HOST_CONFIG_DIR sia impostata
    global ln_HOST_CONFIG_DIR
    ln_HOST_CONFIG_DIR = os.getenv('ln_HOST_CONFIG_DIR', '')
    if not ln_HOST_CONFIG_DIR:
        print(f"{colors.RED}Variabile ln_HOST_CONFIG_DIR non impostata in .loreto_setup{colors.RESET}")
        print("Assicurati che il file .loreto_setup contenga: export ln_HOST_CONFIG_DIR='/path/to/config'")
        sys.exit(1)


def base_vars() -> dict:
    """Inizializza le variabili di base"""
    now = datetime.datetime.now().strftime("%Y%m%d_%H%M")

    # Profile management (disabilitato per default)
    profile = False
    profile_data = None

    if profile:
        script_dir = os.path.dirname(os.path.abspath(__file__))
        script_name = os.path.splitext(os.path.basename(__file__))[0]
        profile_data = os.path.join(script_dir, f"{script_name}_profiles.sh")

        if not os.path.exists(profile_data):
            print(f"profile {profile_data} not found!")
            sys.exit(1)
        # Nota: Caricare uno script bash da Python è complesso
        print(f"{colors.YELLOW}Nota: I profili bash non sono supportati in questa conversione{colors.RESET}")

    return {
        'now': now,
        'profile_data': profile_data
    }


class CrontabManager:
    def __init__(self):
        self.f_execute = 0
        self.dry_run = '--dry-run'
        self.args = []
        self.crontab_bin = shutil.which('crontab')

        if not self.crontab_bin:
            print(f"{colors.RED}Crontab non trovato nel sistema!{colors.RESET}")
            sys.exit(1)

    def parse_input(self, args_list: list):
        """Analizza gli argomenti della riga di comando"""
        args_str = ' '.join(args_list)

        # Check per --go
        if '--go' in args_str:
            args_str = args_str.replace('--go', '')
            self.f_execute = 1
            self.dry_run = ''

        # Check per --version
        if '--version' in args_str:
            print(f"\n      {LN_VERSION}\n")
            sys.exit(0)

        # Rimuovi spazi multipli
        self.args = ' '.join(args_str.split())

    def display_diff(self, new_crontab: str, backup_crontab: str) -> int:
        """
        Mostra le differenze tra il nuovo crontab e quello corrente
        Returns: diff_rcode (0 se uguali, !=0 se diversi)
        """
        temp_crontab = '/tmp/_crontab_tmp.conf'

        # Salva il crontab corrente in un file temporaneo
        try:
            current_crontab = subprocess.run(
                [self.crontab_bin, '-l'],
                capture_output=True,
                text=True,
                check=False
            )
            with open(temp_crontab, 'w') as f:
                f.write(current_crontab.stdout)
        except Exception as e:
            print(f"{colors.RED}Errore nel leggere il crontab corrente: {e}{colors.RESET}")
            return 1

        saved_execute = self.f_execute

        print()
        print(f"{colors.CYAN}----------- diff result ------------------------------------")
        diff_options = ['--ignore-space-change', '--ignore-blank-lines', '--text']

        print(f"{colors.TAB}{colors.GREEN}diff {temp_crontab} {new_crontab}{colors.GREEN}")

        # Esegui diff
        result = subprocess.run(
            ['/usr/bin/diff'] + diff_options + [temp_crontab, new_crontab],
            capture_output=True,
            text=True
        )

        if result.stdout:
            print(result.stdout)

        diff_rcode = result.returncode
        print(f"{colors.TAB}{colors.YELLOW}rcode: {diff_rcode}")
        print(f"{colors.CYAN}------------------------------------------------------------")
        print(colors.RESET)

        self.f_execute = saved_execute
        return diff_rcode

    def esegui(self, cmd_descr: str, cmd: str) -> Tuple[Optional[str], int]:
        """
        Esegue un comando con eventuale dry-run
        Returns: (ret_val, rcode)
        """
        hostname_lc = os.uname().nodename.lower()

        print(colors.RESET)
        print(f"{colors.TAB}{colors.GRAY}------[{hostname_lc}]------------------------")
        print(f"{colors.TAB}{colors.CYAN}{cmd_descr}{colors.RESET}")
        print(f"{colors.TAB}{colors.PURPLE}[{self.dry_run}]{colors.CYAN}: {cmd}{colors.RESET}")

        if self.f_execute == 1:
            try:
                result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=False)
                ret_val = result.stdout.strip() if result.stdout else None
                rcode = result.returncode

                if rcode != 0:
                    print(f"{colors.TAB}{colors.PURPLE}{colors.TAB}{colors.TAB}rcode={rcode}{colors.RESET}")
                    sys.exit(rcode)
            except Exception as e:
                ret_val = None
                rcode = 1
                print(f"{colors.RED}Errore nell'esecuzione: {e}{colors.RESET}")
                sys.exit(1)
        else:
            ret_val = self.dry_run
            rcode = 0

        print(f"{colors.TAB}{colors.YELLOW}rcode:   {rcode}")
        print(f"{colors.TAB}{colors.YELLOW}ret_val: {ret_val}")

        return ret_val, rcode


def main():
    """Funzione principale"""
    # Setup iniziale
    if not os.getenv('ln_HOST_CONFIG_DIR'):
        setup_environment()

    # Inizializza le variabili di base
    vars_dict = base_vars()
    now = vars_dict['now']

    # Crea il manager del crontab
    manager = CrontabManager()
    manager.parse_input(sys.argv[1:])

    # Percorso del file sorgente crontab
    source_crontab_file = os.path.join(ln_HOST_CONFIG_DIR, 'crontab/crontab.conf')

    if not os.path.exists(source_crontab_file):
        print(f"{colors.TAB}{colors.RED}file {source_crontab_file} not found!{colors.RESET}")
        sys.exit(1)

    # Crea directory di backup
    crontab_backup_file = f"/tmp/crontab/crontab_{now}.conf"
    backup_dir = os.path.dirname(crontab_backup_file)

    # Crea la directory se non esiste
    Path(backup_dir).mkdir(parents=True, exist_ok=True)

    if not os.path.exists(backup_dir):
        print(f"{colors.TAB}{colors.RED}directory {backup_dir} not exists!{colors.RESET}")
        sys.exit(1)

    # Salva il crontab corrente
    manager.esegui(
        "save current crontab",
        f"{manager.crontab_bin} -l > {crontab_backup_file}"
    )

    # Mostra le differenze
    diff_rcode = manager.display_diff(source_crontab_file, crontab_backup_file)

    # Se ci sono differenze, carica il nuovo crontab
    if diff_rcode != 0:
        manager.esegui(
            "load new crontab",
            f"{manager.crontab_bin} {source_crontab_file}"
        )
    else:
        print(f"{colors.TAB}{colors.GREEN}No differences found...crontab is not changed")
        print()


if __name__ == "__main__":
    main()