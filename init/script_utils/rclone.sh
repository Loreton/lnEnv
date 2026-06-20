#!/bin/bash
#
# updated by ...: Loreto Notarantonio
# Date .........: 15-05-2026 13.55.13
#


function _rclone() {
    local RCLONE_BIN='/home/loreto/filu/Applications/linuxPortable/rclone/amd64/rclone'
    local RCLONE_CONFIG='/home/loreto/.config/rclone/rclone.conf'
    local username=${1:-none}
    local action=${2:-none}

    declare -A gdrive_users=(
        [nloreto]=1
        [loreton]=1
        [loretonota]=1
        [notaloreto]=1
        [etonota]=1
        [rinoseraf001]=1
        [rinoseraf002]=1
        [rinoseraf003]=1
        [rinoseraf004]=1
        [agentile0702]=1
    )

    # In Bash -n verifica se una stringa non è vuota.
    if [[ ! -n "${gdrive_users[$username]}" ]]; then
        echo "ERROR: invalid username [$username]"
        echo "valid users:"
        printf '\t%s\n' "${!gdrive_users[@]}" # chiavi (gli username):
        echo
        return 1
    fi

    #----------------------------------------------------------
    # paths
    #----------------------------------------------------------
    local remote="${username}:@${username^^}"
    local remote="${username}:/"
    local mount_dir="${HOME}/gdrive/${username}"
    # local rclonebin="${ln_LINUX_PORTABLE_DIR}/rclone/amd64/rclone --config=$HOME/.config/rclone/rclone.conf"

    if   [[ "$action" == 'mount' ]]; then
        echo "Mounting [$remote] -> [$mount_dir]"
        mkdir -p "$mount_dir"
        # .rclone mount "$remote" "$mount_dir" --daemon --vfs-cache-mode full --dir-cache-time 12h
        # ${RCLONE_BIN} mount "$remote" "$mount_dir" --vfs-cache-mode full --dir-cache-time 12h --attr-timeout 1s --log-level INFO --poll-interval 30s
        CMD="${RCLONE_BIN} --config="${RCLONE_CONFIG}" mount "$remote" "$mount_dir"
            --vfs-cache-mode full \
            --dir-cache-time 12h \
            --poll-interval 30s \
            --attr-timeout 1s"
        echo $CMD
        $CMD

        # Restituisce: 0 → montato  1 → non montato
        if mountpoint -q "$mount_dir"; then
            echo "[$username] mounted correctly"
        else
            echo "[$username] mount failed"
            return 1
        fi


    elif [[ "$action" == 'fusermount' ]]; then
        echo "fusermount -u [$mount_dir]"
        fusermount -u "$mount_dir"

    elif [[ "$action" == 'umount' ]]; then
        echo "umount [$mount_dir]"
        umount "$mount_dir"

    elif [[ "$action" == 'reconnect' ]]; then
        #- nel caso la password sia scaduta
        echo "re-generation password for user: $username"
        echo ${RCLONE_BIN} config reconnect ${username}:

    elif [[ "$action" == 'show_dir' ]]; then
        echo "display remote home dir for: $username"
        ${RCLONE_BIN} lsd ${remote}

    elif [[ "$action" == 'tree' ]]; then
        echo "display remote home dir for: $username"
        ${RCLONE_BIN} ls ${remote}

    else
        echo "Usage:"
        echo "  _rclone {mount|fusermount|umount|reconnect|show_dir|tree} <username>"
        return 1
    fi
}


_rclone "$@"