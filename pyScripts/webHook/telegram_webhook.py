#!/usr/bin/python
#
# updated by ...: Loreto Notarantonio
# Date .........: 18-11-2022 11.37.42
#
#

import sys; sys.dont_write_bytecode = True
import os
import yaml, json

import requests
from flask import Flask
from flask import request, Response

flask_app=Flask(__name__)


# cosa compare sulla root dell call http://xxxxx/
@flask_app.route('/LnBot', methods=['POST', 'GET'])
def index():
    print()
    print('received request.....:', request)
    print('method.....:', request.method)
    if request.method=='POST':
        msg=request.get_json()
        # write_json(msg, 'telegram_request.json')
        print("     msg:", msg)
        return Response('OK', status=200)
    else:
        return '<h1>Loreto WebHooks</h1>'

###############################################
#
###############################################
def write_json(data, filename='response.json'):
    with open(filename, 'w') as f:
        json.dump(data, f, indent=4, ensure_ascii=False, default_flow_style=True)

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
        my_dict=yaml.load(content, Loader=yaml.SafeLoader)

    return my_dict


###############################################
#
###############################################
def get_bot_name(d, group_name):
    token=None
    chat_id=None
    bot_name=None
    for _bot_name in d.keys():
        bot=d[_bot_name]

        groups=bot.get('groups')
        if groups and group_name in groups:
            chat_id=groups[group_name]['chat']['id']
            token=bot['token']
            bot_name=_bot_name
            break
        
        groups=bot.get('channels')
        if groups and group_name in groups:
            chat_id=groups[group_name]['chat']['id']
            token=bot['token']
            bot_name=_bot_name
            break

    return bot_name, token, chat_id



###############################################
# ref:
#   https://www.youtube.com/watch?v=XiBA5LRQFLM
#   - create a basic flask application
#   - Setup a tunnel
#   -       https://docs.srv.us
#   -       http://localhost.run
#   -       https://github.com/antoniomika/sish (creare un docker)
#   -       https://theboroer.github.io/localtunnel-www/
#   -       https://github.com/localtunnel/localtunnel
#   -       https://tunnel.staqlab.com/
#   - Set a webhook
#   - Receive and parse user message
#   - Send a message to user
###############################################
if __name__ == '__main__':
    myBOT='LnBot'
    yaml_file="${ln_SECRET_DIR}/yaml/telegramGroups.yaml"
    yaml_file=os.path.expandvars(yaml_file)
    my_dict=loadYamlFile(yaml_file)
    my_bots=my_dict['telegrambot']

    # token=my_bots[myBOT]['token']
    group_name="sh_tasmota_001"
    group_name="LnPi31_channel"
    tunnel_url='https://468495220d9ec8.lhr.life' # localhost.run
    tunnel_url='https://hroi4y2oqsgkyawwsv5pjzy4yq.srv.us/' # srv.us https://docs.srv.us
    bot_name, token, chat_id=get_bot_name(d=my_bots, group_name=group_name)
    print(f'''using:
        bot_name:   {bot_name}
        token:      {token}
        group_name: {group_name}
        chat_id:    {chat_id}
        tunnel_url: {tunnel_url}
        set_webHook: https://api.telegram.org/bot{token}/setWebhook?url={tunnel_url}&allowed_updates=["callback_query","message"]
        get_webHook: https://api.telegram.org/bot{token}/getWebhookInfo
        get_update: "https://api.telegram.org/bot{token}/getUpdates
        ''')

    if bot_name:
        # flask_app.run(debug=True)
        flask_app.run(host='localhost', port=5000, debug=True)
    else:
        print('BOT not found for group:', group_name)
        # message="ciao sono webhooks"
        # url1=f"https://api.telegram.org/bot{token}/getMe" # get info
        # url2=f"https://api.telegram.org/bot{token}/sendMessage?chat_id={chat_id}&text={message}"
        # url3=f"https://api.telegram.org/bot{token}/getUpdates" # legge quanto scritto sulla chat
        # set_webHook=f"https://api.telegram.org/bot{token}/setWebhook?url=https://2e130e0930511c.lhr.life" # set webhook
        # print('     ', set_webHook)

