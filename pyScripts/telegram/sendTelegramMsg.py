#!/usr/bin/python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 28-11-2025 18.24.21
#

__ln_version__="(L.N.) sendTelegramMsg Version: V2025-11-28_182421"

import sys; sys.dont_write_bytecode = True
import os
import requests

try:    ### ref: https://realpython.com/python-yaml/#yaml-syntax
    from yaml import CSafeLoader as SafeLoader, CFullLoader as FullLoader
except ImportError:
    from yaml import SafeLoader, FullLoader

import json, yaml
from  datetime import datetime

###############################################
# formatStr='%Y/%m/%d %H:%M:%S')
###############################################
def secs_to_DHMS(seconds):
    if isinstance(seconds, (int,float)):
        m, s = divmod(seconds, 60)
        h, m = divmod(m, 60)
        d, h = divmod(h, 24)
        return f'{d}T{h:02}:{m:02}:{s:02}'
    else:
        return ''

###############################################
# formatStr='%Y/%m/%d %H:%M:%S')
###############################################
def get_uptime():
    with open('/proc/uptime', 'r') as f:
        uptime_seconds = float(f.readline().split()[0])

    return secs_to_DHMS(int(uptime_seconds))



###############################################
# formatStr='%Y/%m/%d %H:%M:%S')
###############################################
def get_boottime(formatStr='%d/%m/%Y %H:%M:%S'):
    """A way to figure out the boot time directly on Linux."""
    boot_time=0
    try:
        f = open('/proc/stat', 'r')
        for line in f:
            if line.startswith('btime'):
                boot_time = int(line.split()[1])

        dt=datetime.fromtimestamp(boot_time)
        return dt.strftime(formatStr)
    except (IOError, IndexError):
        return None








##############################################################
# - Parse Input
##############################################################
import argparse
def ParseInput():
    #- --------------------------
    class SmartFormatter(argparse.HelpFormatter):
        # ref: https://stackoverflow.com/questions/3853722/how-to-insert-newlines-on-argparse-help-text
        def _split_lines(self, text, width, indent=4):

            if text.startswith('LN|'):
                lines=text[3:].splitlines()
                ret_lines=[lines[0]]
                for line in lines[1:]:
                    ret_lines.append(' '*indent + line.strip())
                return ret_lines

            # this is the RawTextHelpFormatter._split_lines
            return argparse.HelpFormatter._split_lines(self, text, width)
    #- --------------------------

    if len(sys.argv) == 1:
        sys.argv.append('-h')

    # parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter,
    parser = argparse.ArgumentParser(formatter_class=SmartFormatter,
            description='telegram send message')


        # logging and debug options
    parser.add_argument('--display-args', help='Display input paramenters', action='store_true')
    parser.add_argument('--go', action='store_true',
            help='''LN|action command
                    (dry-run is default)''')


    parser.add_argument('--text', required=False, metavar='', default='',
            help='text message to send')


    fixed_msg=parser.add_mutually_exclusive_group(required=False)
    fixed_msg.add_argument('--boottime', action='store_true', help='get last system boot time')
    fixed_msg.add_argument('--uptime', action='store_true', help='get uptime in seconds')

    args = parser.parse_args()


    if args.display_args:
        import json
        json_data = json.dumps(vars(args), indent=4, sort_keys=True)
        print('input arguments: {json_data}'.format(**locals()))
        sys.exit(0)

    return  args



###############################################
#
###############################################
if __name__ == '__main__':

    args=ParseInput()

    import socket
    hostname=socket.gethostname().split()[0]

    message={'text': args.text}

    if args.boottime or args.uptime:
        message['boot time']=get_boottime(formatStr='%d/%m/%Y %H:%M:%S')
        message['uptime']=get_uptime()

    json_data=json.dumps({hostname: message}, indent=4, sort_keys=False)
    yaml_data=yaml.dump(yaml.load(json_data, Loader=FullLoader), indent=4, sort_keys=False, default_flow_style=False)
    message=yaml_data
    bot={
        "name":         "LnChannelBot",
        "token":        '5652707405:AAHj_P0Ps1K_j3vOyNpgDRpcEZBqxBBEpf8',
        "group_name":   "LnServers_Channel",
        "chat_id":      -1001516798950,
    }

    url = f'''https://api.telegram.org/bot{bot["token"]}/sendMessage?chat_id={bot["chat_id"]}&text={message}'''
    print('     bot_name:   ',   bot["name"])
    print('     token:      ',   bot["token"])
    print('     group_name: ',   bot["group_name"])
    print('     chat_id:    ',   bot["chat_id"])
    print('     url:        ',   url)

    if bot["name"] and bot["token"]:
        if args.go:
            print(requests.get(url).json()) # this sends the message
    else:
        print()
        print('     command cannot be executed....missing some values!')
    print()