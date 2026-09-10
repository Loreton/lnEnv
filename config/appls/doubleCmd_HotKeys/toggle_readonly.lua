-- toggle_readonly.lua (versione per Lua 5.1)
-- Script per Double Commander per impostare il file sotto il cursore come RO o RW
-- Uso: cm_ExecuteScript con parametri: percorso-dello-script.lua %"0%p

local params = {...}

-- Controlla se è stato passato un parametro (il file)
if #params == 0 then
    Dialogs.MessageBox("Nessun file specificato.", "Errore Script", 0x0030)
    return
end

local sFileName = params[1]
local iAttr = SysUtils.FileGetAttr(sFileName)

-- Se non riesce a leggere gli attributi, esce
if iAttr == -1 then
    Dialogs.MessageBox("Impossibile leggere gli attributi per: " .. sFileName, "Errore Script", 0x0030)
    return
end

-- La costante per l'attributo 'Read-Only' su Linux è 0x00000001
-- Usiamo un'operazione XOR (^) per invertire lo stato del bit 'read-only'
-- Se il bit è 1 (RO), lo toglie; se è 0 (RW), lo imposta.
local iNewAttr = iAttr ~ 0x00000001

-- Applica i nuovi attributi
if SysUtils.FileSetAttr(sFileName, iNewAttr) then
    -- Mostra un messaggio di conferma
    local sStatus = "RW"
    if (SysUtils.FileGetAttr(sFileName) ~ 0x00000001) then
       sStatus = "RW"  -- bit 0 è 0 (falso)
    else
       sStatus = "RO"  -- bit 0 è 1 (vero)
    end
    Dialogs.MessageBox("File impostato a: " .. sStatus, "Successo", 0x0040)
    -- Aggiorna la finestra di Double Commander per mostrare i nuovi attributi
    DC.ExecuteCommand("cm_Refresh")
else
    Dialogs.MessageBox("Errore nell'impostare gli attributi per: " .. sFileName, "Errore Script", 0x0030)
end
