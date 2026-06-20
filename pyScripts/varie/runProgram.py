#!/usr/bin/python
# #############################################
#
# updated by ...: Loreto Notarantonio
# Date .........: 2021-10-15
#
# #############################################

import sys; sys.dont_write_bytecode=True
import os
from    datetime import datetime, timedelta
from pathlib import Path
import subprocess, shlex
from types import SimpleNamespace
from queue import Queue
from benedict import benedict


import select
import threading

this=sys.modules[__name__]


#####################################
# gVars is benedict dictionary
#####################################
def setup(gVars):
    global gv, C
    gv=gVars
    C=gv.logger.getColors()



##################################################################
# tg_data nel caso abbia già i dati....
##################################################################
class RunProgram_Class():
    """docstring for SendTelegram"""
    # def __init__(self, *, to_console=False, exit_on_error: bool=False, logger):
    # def __init__(self, logger, streaming: bool=False, to_console=False, color_str: dict={}, errors_str: list=[], skip_str: list=[], dry_run: bool=False, timeout: int=60):
    def __init__(self, *, args: dict):
        # self.args=benedict(args, keyattr_enabled=True, keyattr_dynamic=False)
        # self.result=benedict(result, keyattr_enabled=True, keyattr_dynamic=False)

        ### validate input
        self.logger = args["logger"]

        self.process_optional_args(init=True, **args)

        self.logger.info('Starting RunProgram_object')


    #######################################################
    # optionals args
    #######################################################
    def process_optional_args(self, init: bool=False, **args):
        if init:
            self.default=SimpleNamespace()
            self.default.color_str    = args.get("color_str",       {})
            self.default.dry_run      = args.get("dry_run",         None)
            self.default.errors_str   = args.get("errors_str",      None)
            self.default.get_output   = args.get("get_output",      False)
            self.default.log_filename = args.get("log_filename",    None)
            self.default.skip_str     = args.get("skip_str",        [])
            self.default.timeout      = args.get("timeout",         60)
            self.default.to_console   = args.get("to_console",      False)
            self.default.use_thread   = args.get("use_thread",      False)

        self.color_str    = args.get("color_str",    self.default.color_str)
        self.dry_run      = args.get("dry_run",      self.default.dry_run)
        self.errors_str   = args.get("errors_str",   self.default.errors_str)
        self.get_output   = args.get("get_output",   self.default.get_output)
        self.log_filename = args.get("log_filename", self.default.log_filename)
        self.skip_str     = args.get("skip_str",     self.default.skip_str)
        self.timeout      = args.get("timeout",      self.default.timeout)
        self.to_console   = args.get("to_console",   self.default.to_console)
        self.use_thread   = args.get("use_thread",   self.default.use_thread)





    #######################################################
    # split command line into list
    #######################################################
    def splitCommand(self, cmdline):
        splitted_args=shlex.split(cmdline) if isinstance(cmdline, str) else cmdline
        colored_dry_run=f"{C.yellowH}[dry-run] - {C.colorReset}" if self.dry_run else ""
        self.logger.info("%sexecuting command: %s", colored_dry_run, cmdline)
        return splitted_args




    #######################################################
    # run specific command and pass optional args
    #######################################################
    def run(self, command_line: (str, list), **override_args):
        self.process_optional_args(init=False, **override_args)
        cmdline=self.splitCommand(command_line)

        self.toFile(line="initialize", init=True)

        if self.dry_run:
            self.logger.warning("command will not be executed due to: --dry-run:%s flag", self.dry_run)

        else:
            """ manteniamo stdout e stderr separati in modo da intercettare l'errorre"""
            # p=subprocess.Popen(cmdline, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, bufsize=1, universal_newlines=True)
            p=subprocess.Popen(cmdline, stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=1, universal_newlines=True)

            result=SimpleNamespace(rcode=0, stdout=[], stderr=[])
            if self.use_thread:
                t = threading.Thread(target=self.read_output, args=[p, result], daemon=True)
                t.start()
                self.logger.info("waiting for reading output")
                t.join()
                self.logger.info("joined")
            else:
                result=self.read_output(p, result)


        return result


        # nResults=resultQ.qsize()
        # aliveHosts={}
        # while nResults>0:
        #     result=resultQ.get()

    # -------------------------------------------------------
    # - Put worker args in queue
    # -------------------------------------------------------
    # def putQ(self, args):
    #     self.inputQ.put(args)

    # -------------------------------------------------------
    # - Start process
    # -------------------------------------------------------
    # def start(self):
    #     self.inputQ.join()



    # -------------------------------------------------------
    # - Read process output
    # -------------------------------------------------------
    def read_output(self, hProcess, result):
        process_completed=False


        while True:
            stdout_ready_to_read, _, _ = select.select([hProcess.stdout], [], [], self.timeout)
            stderr_ready_to_read, _, _ = select.select([hProcess.stderr], [], [], self.timeout)

            if not stdout_ready_to_read and not stderr_ready_to_read:
                self.logger.error("hanging process")
                hProcess.kill()
                process_completed=True
                rcode=999
                break

            err_line = stderr_ready_to_read[0].readline() if stderr_ready_to_read else ""
            line     = stdout_ready_to_read[0].readline() if stdout_ready_to_read else ""

            if line or err_line:
                result.rcode=self.process_line(result, line, err_line)
                if result.rcode:
                    self.logger.error("exit on error")
                    process_completed=True
                    break
            else:
                self.logger.info("data completed, normal exit")
                process_completed=True
                break



        if process_completed:
            xx=hProcess.wait() ### non ho capito a cosa serve, forse ad attendere che non esista piÃÂÃÂÃÂÃÂ¹

        if self.fout:
            self.fout.close()
        return result




    # -------------------------------------------------------
    # - process line
    # -------------------------------------------------------
    def process_line(self, result, line, err_line):
        rcode=0
        if err_line:
            print(f"{C.redH}{err_line}{C.colorReset}")
            self.logger.error(err_line)
            self.toFile(err_line)
            rcode=999


        """ skip line if contains skip_str """
        if self.skip_str and self.skip_str in line:
            pass

        """ save data stdout """
        if self.get_output:
            if line:
                result.stdout.append(line)
            if err_line:
                result.stderr.append(err_line)
                rcode=55

        """ write data to log file """
        self.toFile(line)


        """ write data to console """
        if self.to_console:
            if self.color_str:
                colored_line=line
                for key, value in self.color_str.items():
                    if key in colored_line:
                        colored_line=colored_line.replace(key, f"{value[0]}{key}{value[1]}")

                line=colored_line
            sys.stdout.write(line)
            sys.stdout.flush()

        return rcode


    # -------------------------------------------------------
    # - write to log file
    # -------------------------------------------------------
    def toFile(self, line: str="", init: bool=False):
        if init:
            if self.log_filename:
                fname=Path(self.log_filename)
                if not fname.parent.exists():
                    fname.parent.makedirs(parents=True, exist_ok=True)

                self.fout=open(fname, "w")
            else:
                self.fout=None

        if self.fout:
            self.fout.write(line)
            self.fout.flush()













if __name__ == '__main__':
    prj_name="test_runProgram"
    __ln_version__=f"{prj_name} version V2024-01-26_090250"

    sys.path.insert(0, os.path.expandvars('${HOME}/GIT-REPO/lnPyLib/Utils'))
    sys.path.insert(0, os.path.expandvars('${HOME}/GIT-REPO/lnPyLib/Logger'))
    from    ColoredLogger_V103             import setColoredLogger, testLogger

    # ---- Loggging(
    logger=setColoredLogger(logger_name=prj_name,
                            console_logger_level="info",
                            file_logger_level="warning",
                            logging_dir=f"/tmp/{prj_name}", # logging file--> logging_dir + logger_name
                            threads=False,
                            create_logging_dir=True)

    logger.info('------- Starting -----------')
    logger.warning(__ln_version__)

    gv=SimpleNamespace()
    gv.logger=logger

    this.setup(gVars=gv)


    colored_str={
                ".ln": [C.redH, C.colorReset],
                "cLc": [C.yellowH, C.colorReset],
                }

    proc=RunProgram_Class(args=dict(logger=logger,
                                    # streaming=True,
                                    to_console=True,
                                    color_str=colored_str,
                                    errors_str=[],
                                    skip_str=[],
                                    dry_run=False,
                                    timeout=60,
                                    use_thread=True,
                                    )
                        )


    # from LnUtils import keyb_prompt
    cmdline='''/home/loreto/lnprofile/bin/rclone_x86/rclone --config=/tmp/conf/rclone.lnk.conf sync -v --ignore-case --modify-window 2s --links --one-file-system --retries-sleep=15s --retries 11 --multi-thread-cutoff=256M --multi-thread-streams=4 --exclude-from "/tmp/lnSync/rclone/nloreto/nloreto_exclude_files.txt" --dry-run "/media/loreto/LnDisk_SD_ext4/Filu/Lesla/" "nloreto:/_@NLORETO/Lesla/"'''



    cmdline='''/usr/bin/rsync --archive --verbose --update --partial --itemize-changes --links --info=progress1 --times --compress --timeout=15 --exclude-from "/tmp/lnSync/rsync/lnpi41/lnpi41_exclude_files1.txt" --dry-run -e 'ssh -o ServerAliveInterval=5 -o ServerAliveCountMax=3 -i ~/.ssh/ln_tunnel_ed25519 -p 22 ' --dry-run "/home/loreto/lnprofile/" "pi@192.168.1.41:/home/pi/lnprofile/"'''

    data=proc.run(cmdline, **{"log_filename":"/tmp/prova01.log", "get_output": True})
    print(data)

    # cmdline='''ls -la'''
    # data=proc.run(cmdline, **{"log_filename": "/tmp/prova02.log", "get_output": True})
    # print(data)

