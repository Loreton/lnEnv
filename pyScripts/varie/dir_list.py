#!/usr/bin/python
#
# updated by ...: Loreto Notarantonio
# Date .........: 17-04-2025 07.31.44
#


import sys; sys.dont_write_bytecode = True
import os
import glob
import random
import shutil
from pathlib import Path

def scan_01(fname, myPaths):
    for _path in myPaths:
        import pdb; pdb.set_trace() # by Loreto
        print(f"searching {fname} in path: {_path} (glob: **/{fname})")
        p=Path(_path)
        for file in p.rglob(fname):
        # for file in p.rglob(f"**/{fname}"):
            resolved_file=file.resolve()
            files.append(str(resolved_file))
            print(f"    found: {resolved_file}")


def scan_02(fname, myPaths):
    projects = []
    for path in myPaths:
        path = os.path.expandvars(path)
        files=os.listdir(path)

        # note_file_path = os.path.join(self.note_dir,dir,self.settings.setdefault("note_file_name", "todo"))
        for file in files:
            file=os.path.join(path, file)
            if os.path.isdir(file):
                projects.append(file)
    print(projects)




def readTreePath(pattern, root_path):
    file_list=[]
    main_dir = Path(root_path).resolve()
    if main_dir.is_dir():
        for root, dirs, files in main_dir.walk(on_error=print, follow_symlinks=True):
            # for dir_name in dirs: print(dir_name)
            # for name in files: print(name)
            for name in files:
                if name == pattern:
                    fpath=Path(root / name).resolve()
                    print(str(fpath))

    return file_list


def dirlist(file_pattern, path):
    import pdb; pdb.set_trace() # by Loreto
    files=Path(path).glob(file_pattern)
    _list=[]
    for file in files:
        _list.append(file.name)
        print(file.name)

    return _list


def dirlist2(file_pattern, path):
    import glob
    # _path=Path(path).resolve()
    files = glob.glob(f'{_path}/**/{file_pattern}', recursive=True)
    for file in files:
        print(file)


#############################################
# M A I N
#############################################
if __name__ == '__main__':
    projects_dirs= [
        "${HOME}/lnprofile/projects",
    ]

    src_path='/media/loreto/LnDataDisk/Filu/MyData/MP3/@PresepeVC/MusicaEsterna_dirs'
    dst_path='/media/loreto/LnDataDisk/Filu/MyData/MP3/@PresepeVC/MusicaEsterna_shuffled'
    dst_path='/media/loreto/MP3PRESEPE/MP3'
    myPaths=['/media/loreto/LnDisk_SD_ext4/Filu/GIT-REPO/ESP32/pressControl/esp32_relay-X2']
    myPaths=['/media/loreto/LnDisk_SD_ext4/Filu/GIT-REPO/ESP32/pressControl/esp32_relay-X2/lib']
    myPaths=['/home/loreto/GIT-REPO/ESP32/pressControl/esp32_relay-X2/lib']

    # self.projects_dirs = self.settings.get("projects_dirs", [])
    # lnprint("projects_dirs:", self.projects_dirs)


    # scan_01("@logMacros.h", myPaths)
    # scan_02("@logMacros.h", myPaths)
    # readTreePath("@logMacros.h", myPaths[0])
    # dirlist("*.h", myPaths[0])
    dirlist2("@ln*.h", myPaths[0])
    '''
    projects = []
    import pdb; pdb.set_trace(); pass # by Loreto
    for path in projects_dirs:
        path = os.path.expandvars(path)
        files=os.listdir(path)

        # note_file_path = os.path.join(self.note_dir,dir,self.settings.setdefault("note_file_name", "todo"))
        for file in files:
            file=os.path.join(path, file)
            if os.path.isdir(file):
                projects.append(file)


    print(projects)
    '''