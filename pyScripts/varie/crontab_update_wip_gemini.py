#!/usr/bin/env python3
# ========================================
# updated by ...: Loreto Notarantonio
# Date .........: 11-05-2026 15.33.17
# ========================================
#### gemini

import sys; sys.dont_write_bytecode = True
#!/usr/bin/env python3
import os
import sys
import subprocess
import shutil
from datetime import datetime
from pathlib import Path

# --- Configurazione Colori (Semplificata) ---
class Colors:
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    PURPLE = '\033[95m'
    GRAY = '\033[90m'
    RESET = '\033[0m'
    BOLD = '\033[1m'

# --- Variabili Globali ---
VERSION = "V2026-05-11_153317"
EXECUTE = False
DRY_RUN = '--dry-run'


###################################################
#
###################################################
def get_base_vars():
    """Imposta le variabili di base e l'ambiente."""
    now = datetime.now().strftime("%Y%m%d_%H%M")
    hostname = subprocess.getoutput("hostname -s").lower()

    # Simula il caricamento di variabili d'ambiente (ln_HOST_CONFIG_DIR)
    # Se non definita, usa una di default
    config_dir = os.getenv('ln_HOST_CONFIG_DIR', f"{os.getenv('HOME')}/.config/ln")

    return now, hostname, config_dir






###################################################
#
###################################################
def esegui(descr, cmd, hostname):
    """Esegue un comando o lo stampa in caso di dry-run."""
    print(f"{Colors.RESET}")
    print(f"    {Colors.GRAY}------[{hostname}]------------------------")
    print(f"    {Colors.CYAN}{descr}{Colors.RESET}")
    print(f"    {Colors.PURPLE}[{DRY_RUN}]{Colors.CYAN}: {cmd} {Colors.RESET}")

    rcode = 0
    ret_val = DRY_RUN

    if EXECUTE:
        try:
            # shell=True permette di usare i redirect come '>'
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            rcode = result.returncode
            ret_val = result.stdout.strip()

            if rcode != 0:
                print(f"    {Colors.PURPLE}        rcode={rcode}{Colors.RESET}")
                print(f"Error: {result.stderr}")
                sys.exit(rcode)
        except Exception as e:
            print(f"Exception: {e}")
            sys.exit(1)

    print(f"    {Colors.YELLOW}rcode:   {rcode}")
    print(f"    {Colors.YELLOW}ret_val: {ret_val}")
    return rcode




###################################################
#
###################################################
def display_diff(new_crontab, current_crontab_backup):
    """Confronta il crontab attuale con quello desiderato."""
    print(f"\n{Colors.CYAN}----------- diff result ------------------------------------")

    # Prepariamo il comando diff
    diff_cmd = [
        "diff",
        "--ignore-space-change",
        "--ignore-blank-lines",
        "--text",
        current_crontab_backup,
        new_crontab
    ]

    print(f"    {Colors.GREEN}diff {current_crontab_backup} {new_crontab}{Colors.RESET}")

    # Eseguiamo diff (senza shell=True per sicurezza, passando lista)
    result = subprocess.run(diff_cmd, capture_output=True, text=True)

    if result.stdout:
        print(result.stdout)

    print(f"    {Colors.YELLOW}rcode: {result.returncode}")
    print(f"{Colors.CYAN}------------------------------------------------------------{Colors.RESET}")

    return result.returncode




###################################################
#
###################################################
def parse_input():
    """Gestisce gli argomenti della riga di comando."""
    global EXECUTE, DRY_RUN
    args = sys.argv[1:]

    if '--version' in args:
        print(f"\n    Version: {VERSION}\n")
        sys.exit(0)

    if '--go' in args:
        EXECUTE = True
        DRY_RUN = ''
        args.remove('--go')

    return " ".join(args)




###################################################
#
###################################################
def main():
    now, hostname, config_dir = get_base_vars()
    parse_input()

    # Percorsi file
    source_file = Path(config_dir) / "crontab" / "crontab.conf"
    backup_file = Path(f"/tmp/crontab/crontab_{now}.conf")

    # Validazione
    if not source_file.exists():
        print(f"{Colors.RED}File {source_file} not found!{Colors.RESET}")
        sys.exit(1)

    # Crea directory di backup
    backup_file.parent.mkdir(parents=True, exist_ok=True)

    # 1. Salva crontab corrente
    crontab_bin = shutil.which("crontab")
    if not crontab_bin:
        print(f"{Colors.RED}Command 'crontab' not found!{Colors.RESET}")
        sys.exit(1)

    esegui("save current crontab", f"{crontab_bin} -l > {backup_file}", hostname)

    # 2. Mostra differenze
    # Nota: nello script bash passi source_file come primo argomento di displayDiff
    diff_rcode = display_diff(str(source_file), str(backup_file))

    # 3. Se ci sono differenze, carica il nuovo crontab
    if diff_rcode != 0:
        esegui("load new crontab", f"{crontab_bin} {source_file}", hostname)
    else:
        print(f"    {Colors.GREEN}No differences found...crontab is not changed\n")





###################################################
#
###################################################
if __name__ == "__main__":
    main()