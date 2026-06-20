#!/bin/bash

# updated by ...: Loreto Notarantonio
# Date .........: 16-04-2023 17.20.15

The -v option allows us to check if the variable is assigned or not. We can check the variable with the following syntax,
    [ -v variable_name ]


-z String      True if the length of String is zero.
-n String      True if the length of String is nonzero.


https://tldp.org/LDP/abs/html/fto.html
-e      file exists

-a      file exists This is identical in effect to -e. It has been "deprecated," [1] and its use is discouraged.

-f      file is a regular file (not a directory or device file)

-s      file is not zero size

-d      file is a directory

-b      file is a block device "/dev/sda2"

-c      file is a character device "/dev/ttyS1"