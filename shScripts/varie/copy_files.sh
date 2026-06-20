#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 27-01-2023 08.24.27
#


dest="/media/loreto/LnDiskExt4/LnData/Photos/2022"
source="/media/loreto/LnDiskExt4/LnData/Photos/2021/APPO/Camera_2021"

mesi="01 02 03 04 05 06 07 08 09 10 11 12"
year='2022'

cd $dest
for month in $mesi; do
    subdir="${year}-${month}"
    mkdir $subdir >/dev/null 2>&1
    echo mv "*${year}${month}*.jpg" "./$subdir/"
done

