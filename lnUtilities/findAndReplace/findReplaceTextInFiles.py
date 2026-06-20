#!/usr/bin/env python3
# -*- coding: iso-8859-1 -*-
#
# updated by ...: Loreto Notarantonio
# Date .........: 25-11-2025 16.51.27
#
# ######################################################################################
import sys; sys.dont_write_bytecode = True
from types import SimpleNamespace
from pathlib import Path
import fnmatch
import os

class color:
    red        = '\033[31m'; redH       = '\033[91m'
    green      = '\033[32m'; greenH     = '\033[92m'
    yellow     = '\033[33m'; yellowH    = '\033[93m'
    blue       = '\033[34m'; blueH      = '\033[94m'
    purple     = '\033[35m'; purpleH    = '\033[95m'
    cyan       = '\033[36m'; cyanH      = '\033[96m'
    gray       = '\033[37m'; white      = '\033[97m'
    reset      = '\033[0m'

C=color



include_ext=[
        ".py",
        ".yaml",
        ".json",
        ".sh",
        ".function",
        ".txt",
        ".ini",
        ".alias",
        ".conf",
        ".csv",
        ".tpl",
        ".yml",
        ".cfg",
        ".sublime-project",
        ".ffs_gui",
        ".c", ".h", ".cpp",
        "*",
        ]


include_stem=[
        "Loretorc",
        "etc_motd",
        ]

include_name=[
        "Loretorc",
        "project_links.lst",
        "etc_motd",
        ".bashrc_append",
        ]

exclude_ext=[
        ".zip",
        ".sublime-workspace",
        ".pdf",
        ".xlsx",
        ".cmd",
        ".old",
        ".cache",
        ".bin",
        ".log",
        ".xml",
    ]

exclude_pattern=[
                ".sync.ffs_db",
                ]

# exclude_filename_pattern=[
#                 "/Logs/",
#                 "/logs/",
#                 "/log/",
#                 "/Log/",
#                 ".git/",
#                 ]
exclude_subdir=[
                "Logs",
                "logs",
                "log",
                "Log",
                "bin",
                ".git",
                ".pio",
                "lnFreex",
                ]

topDirLen = 0

def is_binary(filepath, my_encoding):
    try:
        with open(filepath, 'rb') as f:
            data = f.read(1024)
        if not data:
            return False
        if b'\x00' in data:
            return True
        # prova decodifica
        data.decode(my_encoding)
        return False

    except UnicodeDecodeError:
        return True


def printInfo():
    print(C.cyanH)
    print('\ttopDir:           ', topdir)
    print('\tfile_pattern:     ', file_pattern)
    print('\texclude_pattern:  ', exclude_pattern)
    print('\texclude_subdir:   ', exclude_subdir)
    print('\tinclude_ext:      ', include_ext)
    print('\texclude_ext:      ', exclude_ext)
    print('\tinclude_name:     ', include_name)
    print('\tinclude_stem:     ', include_stem)
    print(C.reset)

def getFileList_glob(topdir, file_pattern):
    global topDirLen

    topDirLen = topdir.__sizeof__()+1
    print('\n'*3)
    print('-'*80)
    print('TOP dir:', topdir)
    print('-'*80)
    print('\n'*3)

    for filepath in Path(topdir).glob(f"**/{file_pattern}"): ### mettere /* in modo che prenda anche i file senza extension e le directories
        # print(filepath)
        fExclude=False
        if filepath.is_file():
            if args.verbose: print(filepath, C.blue, end="")

            if filepath.is_symlink():
                fExclude=True
                excl_msg=" excluded due to: it's a symlink"

            elif filepath.suffix in exclude_ext:
                excl_msg=f"excluded due to: {filepath.suffix} extension"
                fExclude=True

            elif filepath.name in exclude_pattern:
                fExclude=True
                excl_msg=f"excluded due to: {filepath.name} pattern"

            else:
                parts = filepath.parts
                for subdir in exclude_subdir:
                    if subdir in parts:
                        excl_msg=f"excluded due to: {subdir} subdir"
                        fExclude=True
                        break

            if fExclude:
                if args.verbose: print(f"{C.red}{excl_msg} - {filepath} ", C.reset)
                continue

            if ("*" in include_ext) or (filepath.suffix in include_ext) or (filepath.name in include_name) or (filepath.stem in include_stem):
                if args.verbose: print(C.yellow, " - it's OK", C.reset)
                # print(C.yellow, f"{filepath} - it's OK", C.reset)
                yield filepath






import stat
# ######################################################
# # se newSTR == '' andiamo in FIND only
# ######################################################
def findText(filepath: str, cur_str: str, new_str: str = None):
    my_encoding="iso-8859-1"
    my_encoding="utf-8"
    TAB12=' '*12
    if is_binary(str(filepath), my_encoding):
        if args.verbose: print(f"{C.redH}BINARY: {filepath}")
        return

    # Read in the file
    # print(filepath)
    filedata = None
    with open(filepath, 'r', encoding=my_encoding) as hFile:
        filedata = hFile.read()

    if cur_str in filedata:
        print(C.green + f'.... {filepath.__str__():{topDirLen:}}', C.reset)
        gv.changed_files+=1

        for index, line in enumerate(filedata.split('\n')):
            if cur_str in line:
                gv.occurrencies+=1
                ### display current line
                cur_line = line.replace(cur_str, C.yellowH + cur_str + C.reset) # inseriamo il colore
                print ("    ", f"[{index+1:3}]: {cur_line.strip()}")
                if new_str:
                    ### display new target line
                    new_line = line.replace(cur_str, C.cyanH + new_str + C.reset) # inseriamo il colore
                    print ("    ", f"[{index+1:3}]: {new_line.strip()}")

                    mode=filepath.stat().st_mode
                    saved_mode = stat.S_IMODE(mode)

                    if args.go:
                        if saved_mode & stat.S_IWUSR: ### it's write mode
                            new_mode=saved_mode
                        else:
                            new_mode=saved_mode | stat.S_IWUSR  # add user  write permission
                            print(f"{TAB12}{C.blueH}file is READ-ONLY mode{C.reset}")
                            print(f"{TAB12}{C.blue}enable user WRITE mode{C.reset}")
                            filepath.chmod(new_mode)

                        # Replace target string
                        newData = filedata.replace(cur_str, new_str)
                        print(f'{TAB12}{C.blue}replacing file.... {str(filepath)[topDirLen:]}{C.reset}')
                        with open(filepath, 'w', encoding=my_encoding) as hFile:
                            hFile.write(newData)

                        if new_mode != saved_mode: # se il mode è cambiato
                            print(f"{TAB12}{C.blue}re-enable READ-ONLY mode{C.reset}")
                            filepath.chmod(saved_mode)

        print('\n')












##############################################################
# - Parse Input
##############################################################
def ParseInput():
    import argparse
    # =============================================
    # = Parsing
    # =============================================
    if len(sys.argv) == 1:
        sys.argv.append('-h')

    parser = argparse.ArgumentParser(description='find/replace string in text files')

    parser.add_argument('--ignore-case', help='ignore-case', action='store_true')
    parser.add_argument('--go', help='command must be executed. (dry-run is default)', action='store_true')
    parser.add_argument('--verbose', help='Display all messages', action='store_true')
    parser.add_argument('--display-args', help='Display input paramenters', action='store_true')
    parser.add_argument('--search-string', help='string to be searched (set string in SingleQuote)', type=str, default=None, required=True, metavar="")
    parser.add_argument('--replace-with', help='string to be used on replace', type=str, default=None, required=False, metavar="")
    parser.add_argument('--top-dir', help='/home/path', type=str, default= os.getcwd(), required=False, metavar="")


    args = parser.parse_args()


    if args.display_args:
        import json
        json_data = json.dumps(vars(args), indent=4, sort_keys=True)
        print('input arguments: {json_data}'.format(**locals()))
        sys.exit(0)


    return  args



##########################################################################
# Example:
#
#   alias cf='python /mnt/data/custom_repos/jboss/JBossAdmin-REPO/Common/ReplaceTextInFiles.py'
#
#   python ReplaceTextInFiles.py './Config-2016-05-12/*.ini' '£{'
#   or...
#   python ReplaceTextInFiles.py '/Common/Main/TemplatesEAP7/.ini "£{" "#@#{"
#
##########################################################################

if __name__ == '__main__':
    global gv
    gv=SimpleNamespace()
    args=ParseInput()


    path=Path(args.top_dir).resolve()

    print ("\n\n")
    gv.occurrencies=0
    gv.changed_files=0

    # if args.replace_with is None:
    #     args.replace_with=args.search_string
        # args.go=False
    topdir=args.top_dir
    file_pattern="*"
    printInfo()
    for filepath in getFileList_glob(topdir=topdir, file_pattern=file_pattern):
        findText(filepath=filepath, cur_str=args.search_string, new_str=args.replace_with)
    printInfo()


    print (C.yellowH, "involved files............:", gv.changed_files, C.reset)
    print (C.yellowH, "total lines occurrencies..:", gv.occurrencies, C.reset)
    sys.exit()


