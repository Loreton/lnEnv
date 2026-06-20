#!/usr/bin/python
#
# updated by ...: Loreto Notarantonio
# Date .........: 17-11-2022 14.17.14
#

import sys; sys.dont_write_bytecode = True
import os
import requests
import yaml, json



###############################################
#
###############################################
def loadYamlFile(filename):
    if os.path.exists(filename):
        with open(filename, 'r') as f:
            content=f.read() # single string
    else:
        self.logger.error('File: %s not found', filename)
        sys.exit(1)

    my_dict=yaml.load(content, Loader=yaml.SafeLoader)

    return my_dict

###############################################
#
###############################################
def get_bot_name(d, group_name):
    token=chat_id=bot_name=None
    for _bot_name in d.keys():
        bot=d[_bot_name]

        for group_type in ['groups', 'channels']:
            groups=bot.get(group_type)
            if not groups: continue
            for group in groups:
                if group.lower() == group_name.lower():
                    group_name=group # mettiamolo nel case corretto
                    chat_id=groups[group]['chat']['id']
                    token=bot['token']
                    bot_name=_bot_name
                    break

        # groups=bot.get('channels')
        # if groups:
        #     for group in groups:
        #         if group.lower() == group_name.lower():
        #             chat_id=groups[group_name]['chat']['id']
        #             token=bot['token']
        #             bot_name=_bot_name
        #             break

        # groups=bot.get('groups')
        # if groups and group_name in groups:
        #     chat_id=groups[group_name]['chat']['id']
        #     token=bot['token']
        #     bot_name=_bot_name
        #     break

        # groups=bot.get('channels')
        # if groups and group_name in groups:
        #     chat_id=groups[group_name]['chat']['id']
        #     token=bot['token']
        #     bot_name=_bot_name
        #     break

    return bot_name, token, chat_id, group_name


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

    parser.add_argument('--bot-name', required=False, default=None, metavar='',
            help="""LN|bot name
                        (group_name OR chat_id must be provided)""")

    parser.add_argument('--group-name', required=False, metavar='',
            help="""LN|name of destination group
                        (bot_name and chat-id will be automatically retrieved)""")

    parser.add_argument('--chat-id', required=False, metavar='',
            help='''LN|chat_id of destination group
                        (bot_name and group-name will be automatically retrieved)''')


    args = parser.parse_args()


    if args.display_args:
        import json
        json_data = json.dumps(vars(args), indent=4, sort_keys=True)
        print('input arguments: {json_data}'.format(**locals()))
        sys.exit(0)

    if args.bot_name:
        if args.chat_id or args.group_name:
            pass
        else:
            print()
            print('with bot_name also group_name or chat_id must be specified.')
            print()
            sys.exit(1)
    return  args


###############################################
#
###############################################
if __name__ == '__main__':
    yaml_file="${ln_SECRET_DIR}/yaml/telegramGroups.yaml"
    yaml_file=os.path.expandvars(yaml_file)
    my_dict=loadYamlFile(yaml_file)
    my_bots=my_dict['telegrambot']

    args=ParseInput()
    bot_name, token, chat_id, groupName=get_bot_name(d=my_bots, group_name=args.group_name)


    message = "hello from your telegram bot"
    url = f"https://api.telegram.org/bot{token}/sendMessage?chat_id={chat_id}&text={message}"
    print('     bot_name:   ',   bot_name)
    print('     token:      ',   token)
    print('     group_name: ',   groupName)
    print('     chat_id:    ',   chat_id)
    print('     url:        ',   url)

    if bot_name and token:
        if args.go:
            print(requests.get(url).json()) # this sends the message
    else:
        print()
        print('     command cannot be executed....missing some values!')
    print()