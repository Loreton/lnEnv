#!/bin/bash



IN="V1.0.5-RPM-1.0-2"
# IFS="-RPM-" read -a a <<< "$string"


# var1=${a[0]}_${a[1]}
# var1=${a[1]}
# var2=${string#${var1}_}

# echo $string
# echo $var1
# echo $var2
g_Args='HelloWorld: This is HelloWorld: another HelloWorld'
first_word=$(echo $g_Args | cut -d " " -f 1)
args=$(echo "${g_Args#* }") #  remove first word (first BLANK)
args=$(echo "${g_Args#*: }") #  remove first word (first ': ')

#############################################
# prefix identifica il valore da usare per la variabile
# questo mi permette di utilizzare la stessa funzione
# per più files senza fare override delle variabili
#############################################
function split_filepath() {
    local fullfile=$1
    local prefix="${2:-g_}"  # If variable not set or null, use default.
    local filename=$(basename -- "$fullfile")

    local path=$(dirname -- "$fullfile")   # fullpath
    local path_fname="${fullfile%.*}"      # fullpath_wo_ext
    local filename="${fullfile##*/}"       # filename.ext
    local fname="${filename%.*}"            # name_wo_et
    local ftype="${filename##*.}"            # extension
    local ftime=$(date "+%Y%m%d_%H%M%S" -r "${fullfile}")


    item='ciao=loreto'
    key="${item%=*}"
    value="${item##*=}"

    if [[ "$g_DISPLAY" -eq "1" ]]; then
        : ' ---comment---
        '
        echo -e "$yellowH"
        echo "${TAB}fullfile:     $fullfile"
        echo "${TAB}path:         $path"
        echo "${TAB}path_name:    $path_fname"
        echo
        echo "${TAB}filename:     $filename"
        echo "${TAB}fname:        $fname"
        echo "${TAB}fext:         $ftype"
        echo
        echo "${TAB}ftime:        $ftime"
        echo -e "$colorReset"
        echo
    fi

    # metto il prefisso richiesto alle var globali
    eval ${prefix}path=$path
    eval ${prefix}path_fname=$path_fname
    eval ${prefix}filename=$filename
    eval ${prefix}fname=$fname
    eval ${prefix}ftype=$ftype
    eval ${prefix}ftime=$ftime
}

function leftStr() {
    local defaultPad=' '
    local str=$1
    local len=$2
    local pad="${3:-${defaultPad}}"
    while ((${#str} < len)); do
      str+=$pad
    done
    echo "$str"
}

function leftStr1() {
    local str=$1
    local pad=$2
    local len=$3
    str+="                                                                  "
    echo ${str:0:$len}
    echo $str
}
function length() {
    local len=${#string}
}

str=AABB
xx=$(leftStr $str 20)
xx=$(leftStr $str 20 'c')

function lStrip() {
    base_string="$1"
    left_part="$2"
    echo ${base_string#"${left_part}"*}
}

function rStrip() {
    base_string="$1"
    right_part="$2"
    echo ${base_string%"${right_part}"*}
}


  root_directory="/media/loreto/LnDisk_SD_ext4/myData"
source_directory="/media/loreto/LnDisk_SD_ext4/myData/MP3/Italiani"
   relative_path="MP3/Italiani"

echo "source_directory  " $source_directory
echo "get_right_part    " $(lStrip "$source_directory" "$root_directory")
echo "get_left_part     " $(rStrip "$source_directory" "$relative_path")
exit





# https://linuxhint.com/bash_split_examples/
function split_string() {
    #Define the string to split
    text="learnHTMLlearnPHPlearnMySQLlearnJavascript"
    #Define multi-character delimiter
    delimiter="learn"

    text=$1
    delimiter=$2
    #Concatenate the delimiter with the main string
    string=$text$delimiter

    #Split the text based on the delimiter
    myarray=()
    while [[ $string ]]; do
      myarray+=( "${string%%"$delimiter"*}" )
      string=${string#*"$delimiter"}
    done

    #Print the words after the split
    for value in ${myarray[@]}
    do
      echo -n "$value "
    done
    printf "\n"
}

split_string "learnHTMLlearnPHPlearnMySQLlearnJavascript" "learn"

function subString() {
    value='Ciao';firstChar=${value: 0:1};echo "word: $value - first char: $firstChar"
    value='Ciao';lastChar=${value: -1};echo "word: $value - last char: $lastChar"
    value='Ciao';middleStr=${value: 1:2};echo "word: $value - last char: $middleStr"
    value='--hostpi@192.168.1.xx';middleStr=${value: 6};echo "word: $value - substr: $middleStr"
}

function replaceString() {
    Test='Today, 12:34'
    Date='12.12.2000'
    echo "${Test/Today/$Date}"
    ---
    12.12.2000, 12:34
}

function splitString() {

    # output of sudo blkid -o list | grep -i uuid
    string="/sda6 swap [SWAP] bbae7341-e76f-4e68-acf0-f96720e1295b /sda5 ext4 / 8d6062a2-d53f-4a92-8917-2fe4589f8417 /sdb2 ntfs LnDisk_SD_ntfs /media/loreto/LnDisk_SD_ntfs 52424AE443D5E32A /sdb1 ext4 LnDisk_SD_ext4 /media/loreto/LnDisk_SD_ext4 76827f6b-bd94-4158-8024-6c1a8fefb52e /sdc1 vfat 102-NOBOOT /media/loreto/102-NOBOOT1 6ABD-70D6 /sda4 ntfs (not mounted) 3CA46968A469261C /sda2 vfat /boot/efi F867-CF35 /sda1 ntfs (not mounted) C6CAF8FFCAF8ED15"

    sep="/dev"
    myArray=()
    i=0
    while test "${string#*$sep}" != "$string" ; do
        line="${string%%$sep*}"
        # echo $line
        if [[ $line != '' ]]; then
            myArray[$i]="${sep}${line}"
            i=$(($i+1))
        fi
        string="${string#*$sep}"
    done
    for item in "${myArray[@]}"; do
      echo $item
    done

}


word='--go';       [[ " $args " == *" $word "* ]] && args=${args//$word/} && g_fEXECUTE=1 && g_DRY_RUN=''

### ---- remove quotes from string
ignore=$(echo ${ignore} | xargs)
