#!/usr/bin/python
#
# updated by ...: Loreto Notarantonio
# Date .........: 17-12-2024 14.30.35
#


import sys; sys.dont_write_bytecode = True
import os
# import glob
# import random
# import shutil
import shlex
import subprocess

from types import SimpleNamespace
from benedict import benedict


############################################################à
# cattura tutto l'output
############################################################à
def run_sh_get_output(cmdline, descr: str=None, exit_on_error=False, fExecute=True):
    splitted_args=shlex.split(cmdline)
    dry_run="" if fExecute else f"{C.yellowH}[dry-run] - "
    dry_run="" if fExecute else f"{C.yellowH}[dry-run] - {C.colorReset}"
    gv.logger.info('%s cmdline: %s', dry_run, cmdline)

    if descr:
        gv.logger.info("%s %s", dry_run, descr)

    gv.logger.info("%s command: %s", dry_run, cmdline)

    result=benedict(rcode=0, stdout='', stderr='', keyattr_enabled=True, keyattr_dynamic=False)

    # import pdb; pdb.set_trace()
    if fExecute:
        p=subprocess.run(splitted_args,  timeout=10, capture_output=True, universal_newlines=True, text=True)
        result.rcode=p.returncode
        result.stderr=p.stderr.split("\n")
        result.stdout=p.stdout.split('\n')

        if result.rcode and exit_on_error:
            gv.logger.info("stdout: %s", result.stdout)
            gv.logger.info("stderr: %s", result.stderr)
            gv.logger.info("rcode: %s", result.rcode )
            sys.exit(result.rcode)
        else:
            gv.logger.info("result: %s", result)

    return result




##########################################################################
# https://github.com/borntyping/python-colorlog/blob/main/doc/example.py
##########################################################################
def setup_logger(logger_name: str, logger_level: str, colored=True):
    import logging

    my_levels={
        "critical": 50,
        "caller": 45,
        "error": 40,
        "notify": 33,
        "warning": 30,
        "function": 25,
        "info": 20,
        "debug": 10,
        "trace": 5,
        "notset": 0,
    }


    # --------- Adding NOTIFY level -------------------
    def addNotifyLevel(level):
        logging.NOTIFY=level
        def _notify(logger, message, *args, **kwargs):
            if logger.isEnabledFor(logging.NOTIFY):
                logger._log(logging.NOTIFY, message, args, **kwargs)
        logging.Logger.notify = _notify
        logging.addLevelName(logging.NOTIFY, "NOTIFY")
    # --------- Adding NOTIFY level -------------------

    # create logging formatter
    if colored:
        from colorlog import ColoredFormatter
        formatter = ColoredFormatter(
            "%(cyan)s%(asctime)s %(blue)s[%(module)s.%(funcName)s:%(lineno)4s] %(log_color)s[%(levelname)4s] : %(log_color)s%(message)s",
            datefmt="%H:%M:%S",
            reset=True,
            log_colors={
                'TRACE':    'blue',
                'DEBUG':    'cyan',
                'NOTIFY':   'fg_bold_cyan',
                'INFO':     'green',
                'FUNCTION': 'fg_bold_yellow',
                'WARNING':  'yellow',
                'ERROR':    'red',
                'CALLER':   'red',
                'CRITICAL': 'red,bg_white',
            },
        )


    else:
        formatter=logging.Formatter(
            fmt="%(asctime)s [%(module)s.%(funcName)s:%(lineno)4s] [%(levelname)4s] : %(message)s",
            datefmt="%H:%M:%S",
            style="%"
            )


    addNotifyLevel(level=my_levels["notify"])

    # create logger
    logger = logging.getLogger(logger_name)
    logger.setLevel("DEBUG")

    # create console handler
    consoleHandler = logging.StreamHandler()
    consoleHandler.setFormatter(formatter)
    consoleHandler.setLevel(logger_level.upper())

    # Add console handler to logger
    logger.addHandler(consoleHandler)

    logger.propagate = False # se messo a True mi trovo due righe di log, una colorata e l'altra no.

    return logger


###############################################################
# Extract string between delimiters
# if fLAST==True search for the last occurrency
# return:
#        pattern if data==None
#        result  if data
###############################################################
import re
def regex_search(data: str, prefix: str, suffix: str, fLAST=False):
    _prefix=prefix.replace('$', '\\$')
    _suffix=suffix.replace('$', '\\$')
    pattern=f'{_prefix}(.*?){_suffix}'
    regex=re.compile(pattern, re.IGNORECASE)

    import pdb; pdb.set_trace()
    ret=None
    if isinstance(data, (str, bytes)):
        start_pos=data.rfind(prefix) if fLAST else 0
        if start_pos>=0:
            matched=regex.search(data, start_pos)
            if matched:
                gv.logger.info('MATCH FOUND: %s', matched)
                llen=len(prefix)
                rlen=len(suffix)

                ret=SimpleNamespace()
                matched_str, ret.start_pos, ret.end_pos=matched.group(), matched.start(), matched.end()
                ret.name=matched_str[llen:-rlen] #- strip prefix and suffix

    return ret




#############################################
# M A I N
#############################################
if __name__ == '__main__':
    global gv
    gv=benedict()
    gv.logger=setup_logger(colored=True, logger_name='Loreto', logger_level="info")

    _format = "sudo nmap -sn 192.168.1.{}/32"

    for host in range(1, 254):
        cmd = _format.format(host)
        result = run_sh_get_output(cmd)
        if result.rcode == 0:
            host_is_up=False
            producer=""
            dns=""
            ip_addr=""
            for line in result.stdout:
                gv.logger.notify("Line: %s", line)

            gv.logger.notify("-------------")
            for line in result.stdout:
                if line.startswith("Starting Nmap"):
                    continue
                if line.startswith("Nmap scan report for "):
                    dns_name, *ip_addr = line[21:].split()
                    if ip_addr:
                        # import pdb; pdb.set_trace()
                        ip_addr = ip_addr[0].replace("(", "").replace(")", "")
                    else:
                        ip_addr = dns_name
                        dns_name = ""
                elif line.startswith("MAC Address: "):
                    mac_addr, *producer = line[14:].split()
                    if producer:
                        producer = producer[0].replace("(", "").replace(")", "")
                elif line.startswith("Host is up"):
                    host_is_up=True

            gv.logger.info("dns_name: %s", dns_name)
            gv.logger.info("ip_addr:  %s", ip_addr)
            gv.logger.info("producer: %s", producer)


        # dns_name=regex_search(data=output, prefix="scan report for ", suffix= "\(192.", fLAST=False)
        # print(dns_name)

