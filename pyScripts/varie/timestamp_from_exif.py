#!/usr/bin/python
#
# updated by ...: Loreto Notarantonio
# Date .........: 19-06-2022 17.08.55

# https://exif.readthedocs.io/en/latest/usage.html

import sys
import os
from exif import Image
from  pathlib import Path


photos_dir='/media/loreto/LnDisk/Filu/MyData/Photos'
photos_dir='/mnt/k/Filu/MyData/Photos'
sample_files=[
    f'{photos_dir}/2021/APPO/Camera_2021/IMG_20211213_123609_780.jpg',
    f'{photos_dir}/1990/Foto zio Demetrio.jpg',
    f'{photos_dir}/1990/Foto zio Demetrio.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-06.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-06.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-16.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-16.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-24.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-24.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-30.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-30.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-36.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-36.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-42.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-42.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-48.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-48.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-54.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-55-54.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-56-02.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-56-02.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-56-10.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-56-10.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-56-14.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-56-14.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-56-20.jpg',
    f'{photos_dir}/2007/2007-05 Laura Concorso Danza/Laura Danza 2007-05-26_12-56-20.jpg',
    f'{photos_dir}/2007/2007-08 Piemonte Garessio/Garessio .jpg',
    f'{photos_dir}/2007/2007-08 Piemonte Garessio/Garessio .jpg',
    f'{photos_dir}/2007/2007-08 Piemonte Garessio/Garessio _02.jpg',
    f'{photos_dir}/2007/2007-08 Piemonte Garessio/Garessio _02.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-01.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-01.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-02.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-02.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-03.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-03.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-04.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-04.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-05.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-05.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-06.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-06.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-07.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-07.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-08.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-08.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-09.jpg',
    f'{photos_dir}/2010/2010-11 Casetta Ulivo/Ulivo - 2010-11-09.jpg',
    f'{photos_dir}/2015/2015-06 Langhe/Langhe 2015-06-14_16-38-53.jpg',
    f'{photos_dir}/2015/2015-06 Langhe/Langhe 2015-06-14_16-39-22.jpg',
    f'{photos_dir}/2018/2018-11 - Loreto_62/IMG_20181112_084253.jpg',
    f'{photos_dir}/2018/2018-11 - Loreto_62/IMG_20181112_084253.jpg',
    f'{photos_dir}/2018/2018-11 - Loreto_62/IMG_20181112_084315.jpg',
    f'{photos_dir}/2018/2018-11 - Loreto_62/IMG_20181112_084315.jpg',
    f'{photos_dir}/2018/2018-11 - Loreto_62/IMG_20181112_084328.jpg',
    f'{photos_dir}/2018/2018-11 - Loreto_62/IMG_20181112_084328.jpg',
    f'{photos_dir}/2018/2018-11 - Loreto_62/IMG_20181112_084408.jpg',
    f'{photos_dir}/2018/2018-11 - Loreto_62/IMG_20181112_084408.jpg',
    f'{photos_dir}/2018/2018-11 - Loreto_62/IMG_20181112_084419.jpg',
    f'{photos_dir}/2018/2018-11 - Loreto_62/IMG_20181112_084419.jpg',
    f'{photos_dir}/2019/Other/PANO_20181006_104510.jpg',
    f'{photos_dir}/2019/Other/PANO_20181006_104521.jpg',
    f'{photos_dir}/2019/Other/PANO_20181006_104622.jpg',
    f'{photos_dir}/2019/Other/PANO_20181006_104633.jpg',
    f'{photos_dir}/2019/Other/PANO_20181006_104643.jpg',
    f'{photos_dir}/2019/Other/PANO_20181006_115847.jpg',
    f'{photos_dir}/2019/Other/PANO_20181006_115910.jpg',
    f'{photos_dir}/2019/Other/PANO_20190517_123949.jpg',
    f'{photos_dir}/2020/PANO_20200212_103142.jpg',
    f'{photos_dir}/2020/PANO_20191016_152905.jpg',
    f'{photos_dir}/2020/PANO_20191226_155534.jpg',
    f'{photos_dir}/2020/PANO_20191226_155538.jpg',
    f'{photos_dir}/2020/PANO_20200212_103153.jpg',
    f'{photos_dir}/2020/PANO_20200212_103254.jpg',
    f'{photos_dir}/2020/PANO_20200326_072800.jpg',
    f'{photos_dir}/2020/PANO_20201124_095450.jpg',
    f'{photos_dir}/2020/PANO_20201124_095501.jpg',
    f'{photos_dir}/2020/PANO_20201206_084822.jpg',
    f'{photos_dir}/2020/PANO_20201206_084827.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/IMG_20211213_083318_727.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/IMG_20211213_083318_727.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/IMG_20211213_122845_666.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/IMG_20211213_122845_666.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/PANO_20200212_103142.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/PANO_20200212_103153.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/PANO_20200212_103254.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/PANO_20200326_072800.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/PANO_20201124_095450.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/PANO_20201124_095501.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/SAVE_20210815_192106.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/SAVE_20210815_192106.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/SAVE_20210815_192118.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/SAVE_20210815_192118.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/SAVE_20210815_192159.jpg',
    f'{photos_dir}/2021/APPO/Camera_2021/SAVE_20210815_192159.jpg',
    f'{photos_dir}/2021/APPO/FotoTecniche_2021/PANO_20191016_152905.jpg',
    f'{photos_dir}/2021/APPO/FotoTecniche_2021/PANO_20191226_155534.jpg',
    f'{photos_dir}/2021/APPO/FotoTecniche_2021/PANO_20191226_155538.jpg',
    f'{photos_dir}/2021/APPO/FotoTecniche_2021/PANO_20201206_084822.jpg',
    f'{photos_dir}/2021/APPO/FotoTecniche_2021/PANO_20201206_084827.jpg',
    f'{photos_dir}/Avatar/Loreto Avatar 01.jpg',
    f'{photos_dir}/Avatar/Loreto Avatar 01.jpg',
    f'{photos_dir}/Avatar/Loreto Avatar 02.jpg',
    f'{photos_dir}/Avatar/Loreto Avatar 02.jpg',
    f'{photos_dir}/PhotoDOC/CartaConadFront1.jpg',
    f'{photos_dir}/PhotoDOC/CartaConadFront1.jpg',
    f'{photos_dir}/PhotoDOC/CartaConadRear1.jpg',
    f'{photos_dir}/PhotoDOC/CartaConadRear1.jpg',
    ]



def fileList(root_path, folder='', pattern='*.*'):
    root_path=Path(root_path)
    root_path=root_path / folder

    file_list=list(root_path.glob(f'**/{pattern}'))

    return file_list

def get_dt(file):
    dt_original, dt_digitized=None, None
    with open(file, 'rb') as image_file:
        my_image = Image(image_file)
        if my_image.has_exif:
            dt_digitized=my_image.get('datetime_digitized')
            dt_original=my_image.get('datetime_original')

        else:
            # print('no EXIF', file)
            pass

    return dt_original, dt_digitized

# def capture_date_from_filename(file):
def capture_date_from_filename(file):
    pattern=[]
    pattern.append(['%Y-%m-%d_%H-%M-%S', re.compile(r'(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})[.-_]')])
    pattern.append(['%Y-%m-%d', re.compile(r'(\d{4}-\d{2}-\d{2})[.-_]')])
    pattern.append(['%Y%m%d_%H%M%S', re.compile(r'(\d{8}_\d{6})[.-_]')])

    date_value=None
    for x in range(len(pattern)):
        date_fmt, regex=pattern[x]
        matches=regex.findall(file)
        for match in matches:
            try:
                date_value = datetime.strptime(match, date_fmt)
                break
            except ValueError:
                pass # ignore, this isn't a date

        if date_value:
            break

    return date_value


epoch = datetime(1970, 1, 1)
def capture_date_from_filename_(file, regex, date_fmt):
    matches=regex.findall(file)

    date_value=None # ignore, this isn't a date
    for match in matches:
        try:
            date_value = (datetime.strptime(match, date_fmt) - epoch).total_seconds()
        except ValueError:
            pass # ignore, this isn't a date


    return date_value

from datetime import datetime
import re
if __name__ == '__main__':
    files=fileList(photos_dir, folder='', pattern='*.jpg')
    files=sample_files

    for file in files[:]:
        # file=f'{photos_dir}/{file}'
        dt_original, dt_digitized=get_dt(file)
        if dt_original:
            pass
        elif dt_digitized:
            pass

        else:
            # pattern=[]
            # pattern.append(['%Y-%m-%d_%H-%M-%S', re.compile(r'(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})[.-]')])
            # pattern.append(['%Y-%m-%d', re.compile(r'(\d{4}-\d{2}-\d{2})[.-]')])
            # pattern.append(['%Y%m%d_%H%M%S', re.compile(r'(\d{8}_\d{6})[.-]')])
            # # xx[0]=re.compile(r'(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})[.-]')
            # # xx[1]=re.compile(r'(\d{4}-\d{2}-\d{2})[.-]')
            # # xx[2]=re.compile(r'(\d{8}_\d{6})[.-]')

            # for x in range(len(pattern)):
            #     date_val=capture_date_from_filename(file, date_fmt=pattern[x][0], regex=pattern[x][1] )
            #     if date_val:
            #         print(date_val, file)
            #         break
            #     else:
            #         print('no TIME', file)
            date_val=capture_date_from_filename(file) # epoch time

            if not date_val:
                date_val=os.path.getmtime(file) # epoch-time
            if date_val:
                # print(date_val, file)
                pass
            else:
                print('no TIME', file)

