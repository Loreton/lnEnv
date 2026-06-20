#!/bin/bash
# come input chiede due interfacce di rete ... eth0 wlan1
#
# updated by ...: Loreto Notarantonio
# Date .........: 08-07-2025 20.11.51
#



# Dizionario Bash: nome livello → valore
# Mappa diretta
declare -A log_level_map=(
    [NONE]=0
    [ERROR]=1
    [WARN]=2
    [INFO]=3
    [NOTIFY]=4
    [DEBUG]=5
    [TRACE]=6
)

# Creazione dinamica della mappa inversa
#    declare -A log_level_name=(
#        [0]=NONE
#        [1]=ERROR
#        [2]=WARN
#        [3]=INFO
#        [4]=NOTIFY
#        [5]=DEBUG
#        [6]=TRACE
#    )
declare -A log_level_name
for key in "${!log_level_map[@]}"; do
    val=${log_level_map[$key]}
    log_level_name[$val]=$key
done

# Esempio di utilizzo
level_index=5
echo "Indice $level_index → Livello: ${log_level_name[$level_index]}"
level_name="DEBUG"
echo "Livello $level_name ha valore ${log_level_map[$level_name]}"
