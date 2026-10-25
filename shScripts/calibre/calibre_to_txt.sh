#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 24-10-2026 16.26.36
#



# Definisce il file di log nella stessa cartella dello script
LOG_FILE="$(dirname "$0")/conversion.log"
LOG_FILE="/tmp/Calibre_to_txt_conversion.log"

# Reindirizza tutto l'output (stdout e stderr) da questo punto in poi al file di log
# exec >> "$LOG_FILE" 2>&1
exec > "$LOG_FILE" 2>&1

# Aggiunge un timestamp per sapere quando è avvenuta la conversione
echo "--- $(date) ---"

# Riceve il percorso completo del file epub passato da Double Commander
EPUB_FILE="$1"


# ...... Conversione
if [ ! -f "$EPUB_FILE" ] || [[ "$EPUB_FILE" != *.epub ]]; then
    echo "Errore: il file fornito non è un file .epub valido: $EPUB_FILE"
    exit 1
fi

TXT_FILE="${EPUB_FILE%.epub}.txt"

echo "Avvio conversione: $EPUB_FILE -> $TXT_FILE"

/usr/bin/flatpak run --command=ebook-convert com.calibre_ebook.calibre "$EPUB_FILE" "$TXT_FILE"

if [ $? -eq 0 ]; then
    echo "Conversione completata: $TXT_FILE"
else
    echo "Conversione fallita per: $EPUB_FILE"
fi

xed "$LOG_FILE"
