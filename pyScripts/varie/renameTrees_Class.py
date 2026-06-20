#!/usr/bin/python
#
# updated by ...: Loreto Notarantonio
# Date .........: 27-12-2023 19.10.52
#


import sys; sys.dont_write_bytecode = True
import os
from pathlib import Path, PosixPath
from types import SimpleNamespace



##################################################################
# tg_data nel caso abbia già i dati....
##################################################################
class RenameTrees_Class():
    """docstring for SendTelegram"""
    def __init__(self, *, fProcess: bool=False, fVerbose: bool=False, logger):
        self.logger=logger
        self.fProcess=fProcess
        self.fVerbose=fVerbose



        self.logger.info('Starting program')
        # self.root_dir=root_dir




    ### ##########################################
    ### -
    ### ##########################################
    def replace_chars(self, data: str):
        """ replace chars into the string"""
        strings=[
                    (" ",       "_"),
                    (",",       "-"),
                    ("'",       "-"),
                    ("&",       "+"),
                    ("_-_",     "-"),
                    ("__",      "_"),
                    ("_Di_",    "_di_"),
                    ("_De_",    "_de_"),
                    ("(",       "+"),
                    (")",       "+"),
                    ("`",       "_"),
                    ("--",       "-"),
                    # ("-Chelsea_Morning--",       "Chelsea_Morning-"),
                ]
        for string1, string2 in strings:
            data=data.replace(string1, string2)
        return data



    ### ##########################################
    ### -
    ### ##########################################
    def prepare_pathname(self, root_dir, name, new_name):
        """ prepare new name and check for path"""
        p=SimpleNamespace()
        p.error=None
        p.msg=""
        p.cur=Path(root_dir) / name
        p.new=Path(root_dir) / self.replace_chars(data=new_name)
        if p.new==p.cur:
            p.msg=f'new and cur paths are already the same - "{p.cur}"'
            p.error="warning"
        elif p.new.exists():
            p.msg=f'already exists - "{p.new}"'
            p.error="error"
        else:
            p.msg=f'renaming - "{p.cur}" to "{p.new}"'

        return p



    ### ##########################################
    ### -
    ### ##########################################
    def rename_file(self, root_dir, name, new_name):
        """ rename the path and primt message"""
        if not new_name:
            new_name=name ### facciamo solo il repalace dei chars

        self.processed+=1
        p=self.prepare_pathname(root_dir=root_dir, name=name, new_name=new_name)
        if p.error=="warning":
            if self.fVerbose: self.logger.warning(p.msg)
            self.skipped+=1
        elif p.error=="error":
            self.logger.error(p.msg)
            self.skipped+=1
        else:
            self.logger.info(p.msg)
            if self.fProcess:
                p.cur.rename(p.new)
            self.renamed+=1



    #######################################################
    # devo partire dalla fine
    #######################################################
    def renameTree(self, top_dir: str):
        self.processed=0
        self.renamed=0
        self.skipped=0

        if Path(top_dir).exists():
            ### ---- main loop ----------------------
            ### devo partire dalla fine
            for root, dirs, files in os.walk(top_dir, topdown=False, followlinks=False):
                for filename in files:
                    new_filename=filename
                    self.rename_file(root_dir=root, name=filename, new_name=new_filename)

                for dirname in dirs:
                    if dirname.lower() in ["varie", "the best of", "vari", "best_of"]:
                        new_dirname="bestOf"
                    else:
                        new_dirname=None

                    self.rename_file(root_dir=root, name=dirname, new_name=new_dirname)



            self.logger.info("processded: %s", self.processed)
            self.logger.info("renamed:    %s", self.renamed)
            self.logger.info("skipped:    %s", self.skipped)

            if not self.fProcess:
                self.logger.warning("")
                self.logger.warning("Enter --go to execute the renaming action")
                self.logger.warning("Enter --go to execute the renaming action")
                self.logger.warning("Enter --go to execute the renaming action")

        else:
            self.logger.error("%s not found!", top_dir)





##########################################################################
# https://github.com/borntyping/python-colorlog/blob/main/doc/example.py
##########################################################################
def setup_logger(colored=True, logger_name: str="example_logger", logger_level: str=None):
    import logging
    if not logger_level:
        logger_level=logging.DEBUG

    if colored:
        from colorlog import ColoredFormatter

        """Return a logger with a default ColoredFormatter."""
        formatter = ColoredFormatter(
            # f"""%(cyan)s%(asctime)s %(log_color)s[%(levelname)4s] - %(blue)s[%(module)s.%(funcName)s:%(lineno)4s]: %(log_color)s%(message)s""",
            f"""%(cyan)s%(asctime)s %(blue)s[%(module)s.%(funcName)s:%(lineno)4s] %(log_color)s[%(levelname)4s] : %(log_color)s%(message)s""",
            datefmt="%H:%M:%S",
            reset=True,
            log_colors={
                'TRACE':    'blue',
                'DEBUG':    'cyan',
                # 'NOTIFY':   'yellow',
                'NOTIFY':   'fg_bold_cyan',
                'INFO':     'green',
                'FUNCTION': 'fg_bold_yellow',
                # 'WARNING':  'purple',
                'WARNING':  'yellow',
                'ERROR':    'red',
                'CALLER':   'red',
                'CRITICAL': 'red,bg_white',
            },
        )

        logger = logging.getLogger(logger_name)
        handler = logging.StreamHandler()
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        logger.setLevel(logger_level)

    else:
        logging.basicConfig(level=logger_level,
                            format='[%(levelname)4s] - [%(module)s.%(funcName)s:%(lineno)4s]: %(message)s',
                            )

        logger = logging.getLogger(logger_name)

    return logger



def testLogger(logger):
    logger.debug("this is a DEBUGGING message")
    logger.info("this is an INFORMATIONAL message")
    logger.warning("this is a WARNING message")
    logger.error("this is an ERROR message")
    logger.critical("this is a CRITICAL message")


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

    parser = argparse.ArgumentParser(description='rename Trees')

    parser.add_argument('--root-dir', help='specify root directory starting from', required=True)
    parser.add_argument('--go', help='specify if command must be executed. (dry-run is default)', action='store_true')
    parser.add_argument('--verbose', help='print detailed info', action='store_true')

        # logging and debug options
    parser.add_argument('--display-args', help='Display input paramenters', action='store_true')


    # args = vars(parser.parse_args())
    args = parser.parse_args()
    # print (args); sys.exit()


    if args.display_args:
        import json
        json_data = json.dumps(vars(args), indent=4, sort_keys=True)
        print('input arguments: {json_data}'.format(**locals()))
        sys.exit(0)


    return  args


#############################################
# M A I N
#############################################
if __name__ == '__main__':
    args=ParseInput()
    logger=setup_logger(colored=True, logger_name='Loreto')
    # testLogger(logger=logger)

    top_dir=Path('/home/loreto/ext_EXT4/Filu/myData/TEST')
    top_dir=args.root_dir
    src_pattern='**/*.mp3'

    xx=RenameTrees_Class(fProcess=args.go, fVerbose=args.verbose, logger=logger)
    xx.renameTree(top_dir=top_dir)

    print()
    print()
    sys.exit()

