#!/bin/bash

set -e

TARGET_DIR="$1"

# Controllo se è stato passato il punto di montaggio
if [ -z "$TARGET_DIR" ]; then
    echo "Utilizzo: $0 /percorso/punto/di/montaggio"
    exit 1
fi

echo -e "\n\n"
echo "=============================="
echo " Test disco: $TARGET_DIR"
echo "=============================="

# echo
# echo "[1] Test lettura (hdparm)"
# sudo hdparm -Tt "$TARGET_DIR"


TEST_FILE="$TARGET_DIR/test_speed_file"
bs=1G count=1   ### Crea un file da 1 GB. È una dimensione sufficiente per evitare che la cache della RAM falsi i risultati su dischi moderni.
oflag=dsync     ### Forza la scrittura fisica sul disco saltando il buffer del sistema operativo (essenziale per misurare la vera velocità del disco).
iflag=direct    ### Legge direttamente dal disco bypassando il buffer del kernel.

# echo -e "\n\n"
# echo "--- Inizio Test Disco su: $TARGET_DIR ---"

# 1. Test di Scrittura (Write)
echo -e "\n\n"
echo "-------------------------------------------"
echo "Test Scrittura in corso...: $TEST_FILE"
echo "-------------------------------------------"
dd if=/dev/zero of="$TEST_FILE" bs=$bs count=$count oflag=$oflag status=progress

# Svuota la cache per rendere il test di lettura veritiero
#   vm.drop_caches=3: Comando "aggressivo" per svuotare la cache della memoria.
#   Senza questo, il test di lettura leggerebbe dalla RAM e vedresti velocità assurde (tipo 10 GB/s).
echo -e "\n\n"
echo "-------------------------------------------"
echo "Svuotamento cache di sistema..."
echo "-------------------------------------------"
sync && sudo /sbin/sysctl -w vm.drop_caches=3

# 2. Test di Lettura (Read)
echo -e "\n\n"
echo "-------------------------------------------"
echo "Test Lettura in corso...: $TEST_FILE"
echo "-------------------------------------------"
dd if="$TEST_FILE" of=/dev/null bs=$bs count=$count iflag=$iflag status=progress

# Pulizia
rm "$TEST_FILE"
echo -e "\n\n"
echo "-------------------------------------------"
echo "--- Test Completato ---"
echo "-------------------------------------------"

