#!/usr/bin/python

import sys; sys.dont_write_bytecode = True
import os
import requests
import json
try:    ### ref: https://realpython.com/python-yaml/#yaml-syntax
    from yaml import CSafeLoader as SafeLoader CFullLoader as FullLoader
except ImportError:
    from yaml import SafeLoader FullLoader




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

    if isinstance(content, dict):
        my_dict=content
    else:
        my_dict=yaml.load(content, Loader=FullLoader)

    return my_dict

def print_json(data, indent=4, sort_keys=True):
    print(json.dumps(data, indent=indent, sort_keys=sort_keys))

def print_yaml(d, title=None, indent=4, sort_keys=True):
    _json_str=json.dumps(d) # convert benedict to json_str
    _json_dict=json.loads(_json_str) # convert json_str to dict
    print(yaml.dump(_json_dict, indent=indent, sort_keys=sort_keys, default_flow_style=False))


###############################################
#
###############################################
if __name__ == '__main__':
    yaml_file="${ln_SECRET_DIR}/yaml/telegramGroups_V1.0.yaml"
    yaml_file=os.path.expandvars(yaml_file)
    my_dict=loadYamlFile(yaml_file)
    my_bots=my_dict['telegrambot']


    if len(sys.argv) >1:
        BOT_NAME=sys.argv[1]
    else:
        BOT_NAME=None

    if not BOT_NAME in my_bots.keys():
        print()
        print('enter one of the following bots')
        for bot_name in my_bots:
            print('     ', bot_name)
        print()
        sys.exit(1)

    token=my_dict['telegrambot'][BOT_NAME]["token"]
    url=f"https://api.telegram.org/bot{token}/getUpdates"

    data=requests.get(url).json()
    # print_json(data)
    print_yaml(data)

    print(url)
    print()