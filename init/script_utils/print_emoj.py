#!/usr/bin/env python3
#
# updated by ...: Loreto Notarantonio
# Date .........: 17-05-2026 15.45.03
#

import sys; sys.dont_write_bytecode = True
import os

# ref: https://www.compart.com/en/unicode/

def print_unicode():
    values = [
        0x1f310,
        0x1f40d,
        0x1f427,
        0x1f4a5,
        0x1f4c1,
        0x1f4c4,
        0x1f4e1,
        0x1f4e6,
        0x1f504,
        0x1f511,
        0x1f512,
        0x1f525,
        0x1f527,
        0x1f680,
        0x1f6d1,
        0x1f6e0,
        0x1f9ea,
        0x2139,
        0x2194,
        0x21aa,
        0x231b,
        0x23f3,
        0x25b6,
        0x2699,
        0x26a0,
        0x2705,
        0x274c,
        0x279c,
        0x27a1,
        0x27a4,
        0x2b05,
        0x2b06,
        0x2b07,
        0xfe0f,
        ]


    my_emoj_str=' ✅ ❌ ⚠️ ℹ️ 🔥 🚀 ⏳ ⌛ 🔄 💥 🛑 🐍 🐧 ⚙️ 🔧 📦 📁 📄 🧪 🛠️ 🔒 🔑 🌐 📡 ➡️ ⬅️ ⬆️ ⬇️ ↔️ ↪️ ➜ ➤ ▶️ '

    my_emoj_list=[  '✅', '❌', '⚠️', 'ℹ️', '🔥', '🚀', '⏳', '⌛', '🔄', '💥', '🛑',
                    '🐍', '🐧', '⚙️', '🔧', '📦', '📁', '📄', '🧪', '🛠️', '🔒', '🔑', '🌐', '📡',
                    '➡️', '⬅️', '⬆️', '⬇️', '↔️', '↪️', '➜', '➤', '▶️',
                ]

    for char in my_emoj_str:
        value = hex(ord(char))
        value = ord(char)
        if char == ' ':
            continue
        print(f"\t0x{value:X} ({value:8}): char={char}")

    print()
    '''
    for char in my_emoj_list:
        value = hex(ord(char))
        print(f"\t{value = }: {char = }")
    '''

    for value in values:
        char = chr(value) + chr(0xFE0F)         ### + ''
        # print(f"\t{value = }: {char = }")
        print(f"\t0x{value:X} ({value:8}): char={char}")


print_unicode()