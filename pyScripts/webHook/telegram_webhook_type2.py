#!/usr/bin/python
#
# updated by ...: Loreto Notarantonio
# Date .........: 04-10-2022 16.15.33
#
#

import sys; sys.dont_write_bytecode = True
import os
import yaml, json
# from    telegram.update              import Update
from    telegram.ext import Updater, CommandHandler, MessageHandler, Filters
from    telegram.update              import Update
from    telegram.ext.callbackcontext import CallbackContext

import requests

def start_01():
    TOKEN = token
    updater = Updater(TOKEN)
    dp = updater.dispatcher
    dp.add_handler(CommandHandler('roll', roll))
    dp.add_handler(CommandHandler('taiyi', taiyi))
    dp.add_handler(CommandHandler('choice', choice))
    dp.add_handler(CommandHandler('say', say))
    dp.add_handler(CommandHandler('dice', dice))
    dp.add_handler(CommandHandler('test', test))

    dp.add_handler(CommandHandler('rollstart', rollstart))
    dp.add_handler(CommandHandler('rolljoin', rolljoin))
    dp.add_handler(CommandHandler('rolllists', rolllists))
    dp.add_handler(CommandHandler('rollnow', rollnow))
    dp.add_handler(CommandHandler('rollquit', rollquit))
    dp.add_handler(CommandHandler('rollkick', rollkick))

    dp.add_handler(CommandHandler('currency', curr))
    dp.add_handler(CommandHandler('kuro', kuro))

    dp.add_handler(InlineQueryHandler(inline_battery))
    # dp.add_handler(MessageHandler(Filters.text, logg))

    #updater.start_polling()
    updater.start_webhook(listen="0.0.0.0",port=5000,url_path=path)
    updater.bot.setWebhook("https://{}/{}".format(url, path))
    updater.idle()


def start():
    print('Starting....')

#######################################################################
# Capture all command from any telegram group
#######################################################################
def echo(update: Updater, context: CallbackContext):
    if not update.message: return # per sicurezza in quanto ho avuto problemi
    tg_name=update.message.chat.title
    print('Entering....', "tg_name:", tg_name)

    """Echo the user message."""
    # mi è comodo per eseguire comandi non presenti dell'help
    # if self.telegramCommands(update, context) is False:
    #     command, args=self.splitCommand(update)

    #     reply = f'''Ciao "{update.effective_user.first_name}", sii più chiaro:
    #      "{update.message.text}"'''
    #     update.message.reply_text(reply)


#######################################################
#
#######################################################
def ErrorHandler(update, context):
    """Process incoming message."""
    if update:
        print("ErrorHandler", update.to_dict())
        tg_name=update.message.chat.title
        print('Entering....', "tg_name:", tg_name)

    try:
        print(context.error)
        # raise context.error
    except Unauthorized:
        print("ErrorHandler: %s", "remove update.message.chat_id from conversation list")
    except BadRequest:
        print("ErrorHandler: %s", "handle malformed requests - read more below!")
    except TimedOut:
        print("ErrorHandler: %s", "handle slow connection problems")
    except NetworkError:
        print("ErrorHandler: %s", "handle other connection problems")
    except ChatMigrated as e:
        print("ErrorHandler: %s", "the chat_id of a group has changed, use e.new_chat_id instead")
    except TelegramError:
        print("ErrorHandler: %s", "handle all other telegram related errors")




# https://python.hotexamples.com/examples/telegram.ext/Updater/start_webhook/python-updater-start_webhook-method-examples.html
def start_02(token, host, port, webhook_url, debug):
    # Create the EventHandler and pass it your bot's token.
    updater = Updater(token)

    # Get the dispatcher to register handlers
    dp = updater.dispatcher

    # on different commands - answer in Telegram
    dp.add_handler(CommandHandler("start", start))
    # dp.add_handler(CommandHandler("help", helper))

    # on noncommand i.e message
    dp.add_handler(MessageHandler(Filters.text, echo))

    # inline keyboard handler
    #dp.add_handler(telegram.ext.CallbackQueryHandler(scroll))
    # TODO: update messages with time information

    # log all errors
    dp.add_error_handler(ErrorHandler)

    ''' # Start the Bot
    updater.start_webhook(listen='95.163.114.6',
                      port=88,
                      url_path='CroCodeBot',
                      key='/home/user/cert/private.key',
                      cert='/home/user/cert/cert.pem',
                      webhook_url='https://95.163.114.6:88/CroCodeBot')
    '''
    # Start the Bot
    url_path='LnCodeBot'
    updater.start_webhook(listen=host,
                      port=port,
                      url_path=url_path,
                      # key='/home/user/cert/private.key',
                      # cert='/home/user/cert/cert.pem',
                      webhook_url=f'{webhook_url}/{url_path}')
    updater.idle()

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
    yaml_file="${ln_SECRET_DIR}/yaml/telegrambot.yaml"
    yaml_file=os.path.expandvars(yaml_file)
    my_dict=loadYamlFile(yaml_file)
    my_bots=my_dict['telegrambot']

    #384405675:AAFXggIdGgcbx3S4ZUYV1arZ7F8v5Za0sFA
    # token=my_bots[myBOT]['token']
    group_name="LnPi31_channel"
    group_name="sh_tasmota_001"
    webHook_url='https://468495220d9ec8.lhr.life' # localhost.run
    webHook_url='https://hroi4y2oqsgkyawwsv5pjzy4yq.srv.us' # srv.us https://docs.srv.us
    bot_name, token, chat_id=get_bot_name(d=my_bots, group_name=group_name)
    print(f'''using:
        bot_name:   {bot_name}
        token:      {token}
        group_name: {group_name}
        chat_id:    {chat_id}
        webHook_url: {webHook_url}
        set_webHook: https://api.telegram.org/bot{token}/setWebhook?url={webHook_url}&allowed_updates=["callback_query","message"]
        get_webHook: https://api.telegram.org/bot{token}/getWebhookInfo
        get_update: "https://api.telegram.org/bot{token}/getUpdates
        ''')

    if bot_name:
        # flask_app.run(debug=True)
        start_02(token=token, host='localhost', port=8443, webhook_url=webHook_url, debug=True)
    else:
        print('BOT not found for group:', group_name)
        # message="ciao sono webhooks"
        # url1=f"https://api.telegram.org/bot{token}/getMe" # get info
        # url2=f"https://api.telegram.org/bot{token}/sendMessage?chat_id={chat_id}&text={message}"
        # url3=f"https://api.telegram.org/bot{token}/getUpdates" # legge quanto scritto sulla chat
        # set_webHook=f"https://api.telegram.org/bot{token}/setWebhook?url=https://2e130e0930511c.lhr.life" # set webhook
        # print('     ', set_webHook)

