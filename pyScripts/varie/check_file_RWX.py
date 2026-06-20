#!/usr/bin/python
#
# updated by ...: Loreto Notarantonio
# Date .........: 23-11-2022 14.44.26
#


import os
import stat
import sys

sys.dont_write_bytecode = True

# https://stackoverflow.com/questions/28492685/change-file-to-read-only-mode-in-python
# https://docs.python.org/3/library/stat.html


# def removeFilePermission(filename, permissionBits):
#     current = stat.S_IMODE(os.stat(file_to_fix).st_mode)
#     new = current & ~stat.S_IWGRP & ~stat.S_IWOTH  # Removes group/other write permission
#     os.chmod(file_to_fix, new)

# def setFilePermission(file_to_fix):
#     current = stat.S_IMODE(os.stat(file_to_fix).st_mode)
#     new = current | stat.S_IXGRP | stat.S_IXOTH  # Add group/other execute permission
#     os.chmod(file_to_fix, new)


def removeFilePermission(filename, permissionBits):
    current = stat.S_IMODE(os.stat(file_to_fix).st_mode)
    new = current & permissionBits  # Removes group/other write permission
    os.chmod(file_to_fix, new)


def setFilePermission(filename, permissionBits):
    current = stat.S_IMODE(os.stat(filename).st_mode)
    new = current | permissionBits  # Add group/other execute permission
    os.chmod(file_to_fix, new)


#############################################
# M A I N
#############################################
if __name__ == "__main__":
    filename = "test.txt"

    mode = os.stat(filename).st_mode
    current = stat.S_IMODE(mode)

    if current & stat.S_IWUSR:
        print("setting READ mode")
        import pdb

        pdb.set_trace()
        pass  # by Loreto
        # pBits=~stat.S_IWUSR & ~stat.S_IWGRP & ~stat.S_IWOTH
        # new=current & pBits  # Removes user/group/other write permission
        new = (
            current & ~stat.S_IWUSR & ~stat.S_IWGRP & ~stat.S_IWOTH
        )  # Removes user/group/other write permission
    else:
        print("setting WRITE mode")
        new = current | stat.S_IWUSR  # Add  user/group/other write permission

    os.chmod(filename, new)
