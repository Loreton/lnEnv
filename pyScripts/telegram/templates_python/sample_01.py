#!/usr/bin/python3
# -*- coding: utf-8 -*-
# -*- coding: iso-8859-1 -*-

# updated by ...: Loreto Notarantonio
# Date .........: 13-08-2022 21.39.57

import sys; sys.dont_write_bytecode=True




def coloredLogger(level):
    import colorlog
    # ----------------------------
    def getFormatter():
        formatter=colorlog.ColoredFormatter(
            """%(cyan)s%(asctime)s %(blue)s[%(funcName)s:%(lineno)4s]: %(log_color)s[%(levelname)4s] %(message)s""",
            datefmt="%H:%M:%S",
            reset=True,
            log_colors={
                'TRACE':    'yellow',
                'DEBUG':    'cyan',
                'NOTIFY':   'fg_bold_cyan',
                'INFO':     'green',
                'FUNCTION': 'purple',
                'WARNING':  'yellow',
                'ERROR':    'red',
                'CRITICAL': 'red,bg_white',
            },
            secondary_log_colors={},
            style='%'
        )
        return formatter
    # ----------------------------

    handler = colorlog.StreamHandler()
    handler.setFormatter(getFormatter())
    logger = colorlog.getLogger("example")
    logger.addHandler(handler)
    logger.setLevel(level)
    return logger
    # dict_config=yaml.load(yaml_config, Loader=yaml.FullLoader)


def testLogger(logger):
    logger.debug("this is a debugging message")
    logger.info("this is an informational message")
    logger.warning("this is a warning message")
    logger.error("this is an error message")
    logger.critical("this is a critical message")

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

    parser = argparse.ArgumentParser(description='rclone + rsync')

    parser.add_argument('--profile', help='specify profile to be processed', required=True, default=None)
    parser.add_argument('--go', help='specify if command must be executed. (dry-run is default)', action='store_true')
    parser.add_argument('--verbose', help='Display all messages', action='store_true')


        # logging and debug options
    parser.add_argument('--display-args', help='Display input paramenters', action='store_true')
    parser.add_argument('--log-console', help='log write to console too.', action='store_true')

    args = parser.parse_args()

    if args.display_args:
        import json
        json_data = json.dumps(vars(args), indent=4, sort_keys=True)
        print('input arguments: {json_data}'.format(**locals()))
        sys.exit(0)

    return  args


def readIniFile(filename):
    import configparser
    config = configparser.ConfigParser()
    config.read(filename)
    return config


if __name__ == '__main__':
    logger=coloredLogger('DEBUG')
    testLogger(logger)
    args=ParseInput()

    rclone_conf=readIniFile('./conf/rclone_Ubuntu.conf')
    print(rclone_conf)