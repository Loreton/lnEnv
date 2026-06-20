#!/usr/bin/python
#
# updated by ...: Loreto Notarantonio
# Date .........: 27-11-2022 17.42.05
#


import sys; sys.dont_write_bytecode = True
import os
import glob
import random
import shutil

#############################################
# M A I N
#############################################
if __name__ == '__main__':
    src_path='/media/loreto/LnDataDisk/Filu/MyData/MP3/@PresepeVC/MusicaEsterna_dirs'
    dst_path='/media/loreto/LnDataDisk/Filu/MyData/MP3/@PresepeVC/MusicaEsterna_shuffled'
    dst_path='/media/loreto/MP3PRESEPE/MP3'
    mp3_file_list=glob.glob(f'{src_path}/**/*.mp3', recursive=True)

    for index in range(6):
        random.shuffle(mp3_file_list)

    nFiles=len(mp3_file_list)
    for index, file_path in enumerate(mp3_file_list):
        print(f"{index:04}/{nFiles}", file_path, end='')
        shutil.copy(file_path, dst_path)
        print('         ....copied')

