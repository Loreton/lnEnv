#!/usr/bin/python
#
# updated by ...: Loreto Notarantonio
# Date .........: 04-10-2022 16.56.58
#
#

import sys; sys.dont_write_bytecode = True

#!/usr/bin/env python

'''Using Webhook and self-signed certificate'''

# This file is an annotated example of a webhook based bot for
# telegram. It does not do anything useful, other than provide a quick
# template for whipping up a testbot. Basically, fill in the CONFIG
# section and run it.
# Dependencies (use pip to install them):
# - python-telegram-bot: https://github.com/leandrotoledo/python-telegram-bot
# - Flask              : http://flask.pocoo.org/
# Self-signed SSL certificate (make sure 'Common Name' matches your FQDN):
# $ openssl req -new -x509 -nodes -newkey rsa:1024 -keyout server.key -out server.crt -days 3650
# You can test SSL handshake running this script and trying to connect using wget:
# $ wget -O /dev/null https://$HOST:$PORT/
import os, yaml, json
from flask import Flask, request

import telegram

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
        print('File: %s not found', filename)
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




app = Flask(__name__)
@app.route('/')
def hello():
    return 'Hello World!'

@app.route('/', methods=['POST'])
def webhook():
    update = telegram.update.Update.de_json(request.get_json(force=True))
    bot.sendMessage(chat_id=update.message.chat_id, text='Hello, there')

    return 'OK'


def setWebhook(myBot):
    # bot.setWebhook(webhook_url='https://%s:%s/%s' % (HOST, PORT, TOKEN), certificate=open(CERT, 'rb'))
    # import pdb; pdb.set_trace(); pass # by Loreto
    myBot.setWebhook(url=webHook_url)
    # bot.setWebhook(webHook_url)


if __name__ == '__main__':
    myBOT='LnBot'
    yaml_file="${ln_SECRET_DIR}/yaml/telegrambot.yaml"
    yaml_file=os.path.expandvars(yaml_file)
    my_dict=loadYamlFile(yaml_file)
    my_bots=my_dict['telegrambot']
    port     = 8443
    host     = 'localhost' # Same FQDN used when generating SSL Cert

    #384405675:AAFXggIdGgcbx3S4ZUYV1arZ7F8v5Za0sFA
    # token=my_bots[myBOT]['token']
    group_name="LnPi31_channel"
    group_name="sh_tasmota_001"
    bot_name, token, chat_id=get_bot_name(d=my_bots, group_name=group_name)


    webHook_url='https://468495220d9ec8.lhr.life' # localhost.run
    webHook_url='https://hroi4y2oqsgkyawwsv5pjzy4yq.srv.us' # srv.us https://docs.srv.us

    print(f'''using:
        bot_name:   {bot_name}
        token:      {token}
        group_name: {group_name}
        chat_id:    {chat_id}
        webHook_url: {webHook_url}
        port:       {port}

        set_webHook: https://api.telegram.org/bot{token}/setWebhook?url={webHook_url}&allowed_updates=["callback_query","message"]
        get_webHook: https://api.telegram.org/bot{token}/getWebhookInfo
        get_update: "https://api.telegram.org/bot{token}/getUpdates
        ''')

    if bot_name:
        # https://gist.github.com/leandrotoledo/4e9362acdc5db33ae16c
        # CONFIG
        # TOKEN    = ''
        CERT     = 'path/to/ssl/server.crt'
        CERT_KEY = 'path/to/ssl/server.key'

        bot = telegram.Bot(token)
        context = (CERT, CERT_KEY)

        setWebhook(myBot=bot)
        '''
        app.run(host='0.0.0.0',
                port=PORT,
                ssl_context=context,
                debug=True)
        '''

        app.run(host='localhost',
                port=port,
                debug=True)

