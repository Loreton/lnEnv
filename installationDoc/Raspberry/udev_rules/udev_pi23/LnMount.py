#!/usr/bin/env python3
# -*- coding: iso-8859-1 -*-
# vim:enc=utf-8:nu:ai:si:et:ts=4:sw=4:ft=udevrules:
import sys;     sys.dont_write_bytecode = True
import os
import subprocess
import syslog

# #################################################################
# -  Comandi di utilità
# -     sudo blkid
# -         /dev/sdc1: LABEL="Lacie232GB_B" UUID="B222175022171945" TYPE="ntfs"
# -         ....
# -     sudo blkid -o udev -p /dev/sdc1
# -         ID_FS_LABEL=Lacie232GB_B
# -         ....
# -     udevadm info -a -n /dev/sdc1
# -         KERNEL=="sdc1"
# -         ....
# -     lsusb
# -         Bus 001 Device 002: ID 0424:9512 Standard Microsystems Corp.
# -         ....
# -     lsusb -v -s 001:007
# -         Bus 001 Device 007: ID 059f:101a LaCie, Ltd
# -         ....
# -     udevadm info -a -n /dev/sdc1 | grep -i product
# -         ATTRS{idProduct}=="101a"
# -         ....
# #################################################################

LOG=None
class LnClass(): pass


# ##############################################################
# #
# ##############################################################
def wrConsole(data, fName=None, exitCode=-9999):
    savedConsole = gv.fCONSOLE
    gv.fCONSOLE = True
    wrLog(data, fName, exitCode,  back=2)
    gv.fCONSOLE = savedConsole

def wrLog(data, fName=None, exitCode=-9999, back=1):
    global LOG
    lineNO   = sys._getframe( back ).f_lineno
    funcName = sys._getframe( back ).f_code.co_name
    if funcName == '<module>': funcName = 'main'

    if exitCode != -9999: data = data + ' [exiting]'

    if (fName):
        try:
            LOG = open(fName, "wb")
            print("Using log file:" + fName)

        except (IOError, os.error) as why:
            wrLog("ERROR writing file - {1}".format(str(why)), exitCode=11)

    if (LOG):
        dataLog = '[{FUNCNAME}:{LINENO}] {DATA}'.format(LINENO=lineNO, DATA=data, FUNCNAME=funcName)
        LOG.write(bytes(dataLog + '\n', 'UTF-8'))


    if gv.fCONSOLE:
        print('    ', data)

    if gv.fSysLOG:
        syslog.syslog(syslog.LOG_INFO, "Loreto - [{0:<15}] - {1}".format(gv.UUID, data))

    if exitCode!= -9999 and LOG:
        LOG.close()
        sys.exit(exitCode)




# ###########################################################################
# # esegue il comando df -h
# # Esempio di riga:
# #     Filesystem      Size  Used Avail Use% Mounted on
# #     rootfs          7.2G  2.7G  4.3G  39% /
# #     /dev/root       7.2G  2.7G  4.3G  39% /
# #     devtmpfs        215M     0  215M   0% /dev
# #     /dev/mmcblk0p1   56M  9.7M   47M  18% /boot
# #     /dev/sde5       233G  216G   18G  93% /mnt/Lacie_232GB_A
# ###########################################################################
def getDF(mpRoot='/', fDEBUG=False):
    global gv
    retList = []
        # get  df -h

    res = subprocess.check_output(['/bin/df',  '-h'], stderr=subprocess.STDOUT)  # ritorna <class 'bytes'>
    res = res.decode('utf-8')       # converti in STRing


    for line in res.split('\n'):
        field = line.split()
        if len(field) < 6: continue
        devName = field[0]
        mountPoint = field[5]
        if mountPoint.startswith(mpRoot):
            linea = '   {:<30} - {}'.format(devName, mountPoint)
            retList.append(linea)
            # if fDEBUG: print(linea)
                # aggiungiamo al dictionary dei device
            if not devName in gv.DEVICES.keys(): gv.DEVICES[devName] = {}
            gv.DEVICES[devName]['MountPoint'] = mountPoint

    return retList

# ###########################################################################
# # esegue il comando mount
# # Esempio di riga:
# #     /dev/root   on / type ext4 (rw,noatime,data=ordered)
# #     devtmpfs    on /dev type devtmpfs (rw,relatime,size=219744k,nr_inodes=54936,mode=755)
# #     tmpfs       on /run type tmpfs (rw,nosuid,noexec,relatime,size=44784k,mode=755)
# #     tmpfs       on /run/lock type tmpfs (rw,nosuid,nodev,noexec,relatime,size=5120k)
# #     proc        on /proc type proc (rw,nosuid,nodev,noexec,relatime)
# #     sysfs       on /sys type sysfs (rw,nosuid,nodev,noexec,relatime)
# #     tmpfs       on /run/shm type tmpfs (rw,nosuid,nodev,noexec,relatime,size=89560k)
# #     devpts      on /dev/pts type devpts (rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000)
# #     /dev/mmcblk0p1 on /boot type vfat (rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro)
# #     fusectl     on /sys/fs/fuse/connections type fusectl (rw,relatime)
# #     /dev/sde5   on /mnt/Lacie_232GB_A type fuseblk (rw,nosuid,nodev,relatime,user_id=0,group_id=0,default_permissions,allow_other,blksize=4096)
# #   facciamo lo split su blank e prendiamo il primo e terzo valore
# ###########################################################################
def getMountedFS(mpRoot='/', fDEBUG=False):
    global gv
    res = subprocess.check_output(['/bin/mount'], stderr=subprocess.STDOUT)  # ritorna <class 'bytes'>
    res = res.decode('utf-8')       # converti in STRing


    wrLog('------------------------------------')
    wrLog('Searching for mountPoint: ' + mpRoot)
    for line in res.split('\n'):
        # wrLog(line)
        if not line: continue   # se vuota loop
        field = line.split()
        devName     = field[0]
        mountPoint  = field[2]
        if mountPoint.startswith(mpRoot):
            wrLog("[{0:<15}] - mounted".format(devName))
                # aggiungiamo al dictionary dei device
            if not devName in gv.DEVICES.keys():
                gv.DEVICES[devName] = {}
                wrLog('adding device: ' + devName)
            else:
                wrLog('modifying device: ' + devName)
            # if not devName in gv.DEVICES.keys(): gv.DEVICES[devName] = {}
            gv.DEVICES[devName]['MountPoint'] = field[2]
        else:
            # wrLog("[{0:<15}] - skipping".format(devName))
            wrLog("[{0:<15}]".format(devName))



# ###########################################################################
# # esegue il comando blkid
# # Esempio di riga:
# #   /dev/sdb5: LABEL="Lacie232GB_A" UUID="1448564A48562AAE" TYPE="ntfs"
# ###########################################################################
def getBlockID(reqUUID=None):
    global gv

    blockDev = subprocess.check_output('/sbin/blkid', stderr=subprocess.STDOUT)  # ritorna <class 'bytes'>
    blockDev = blockDev.decode('utf-8')       # converti in STRing

    """
        *** ho riscontrato la non veridicità sui dati della riga del blkid.
        *** Ho scoperto che è meglio interrograre uno per uno i device
    for line in res.split('\n'):
        wrLog(line)
        if not line: continue   # se vuota loop
        devName, rest = line.split(':')                         # prendi nome device ...
        if not devName in gv.DEVICES: gv.DEVICES[devName] = {}    # creiamo l'entry, se non esiste
        vals = rest.split()                                     # la parte restante la spezziamo
        wrLog('adding device: ' + devName)
        for val in vals:
            name, value = val.split('=')
            gv.DEVICES[devName][name] = value.strip('"')
    """


    for line in blockDev.split('\n'):
        wrLog(line)
        if not line: continue   # se vuota loop
        devName, rest = line.split(':')                         # prendi nome device ... rest lo ignoriamo perché ritenuto non valido

           # Skip dei device della scheda SD del RaspBerry
        if devName.startswith('/dev/mmcblk0'):
            wrLog('skipping device: ' + devName + '\n')
            continue

        if not devName in gv.DEVICES.keys():
            gv.DEVICES[devName] = {}
            wrLog('adding device: ' + devName)
        else:
            wrLog('modifying device: ' + devName)


        CMD = 'sudo /sbin/blkid -o udev -p ' + devName
        resBytes = subprocess.check_output( CMD.split() ) #  per usare il sudo
        resList = resBytes.decode('utf-8').split('\n')       # converti in STRing/LIST

        # if not devName in gv.DEVICES.keys(): gv.DEVICES[devName] = {}    # creiamo l'entry
        for line in resList:
            if not line: continue   # se vuota loop
            wrLog ('    ' + line)
            name, value = line.split('=')
            gv.DEVICES[devName][name] = value.strip('"')            # xx = binary_to_dict(result)
        wrLog ('')



# ##############################################################
# #
# ##############################################################
def createMountpoint(MPdir):
    if os.path.isdir(MPdir):
        wrLog(MPdir + ' already exists')
        if os.path.ismount(MPdir):
            wrLog(MPdir + ' already mounted')
            sys.exit()
    else:
        if gv.EXECUTE:
            rCode = subprocess.call( ['sudo', '/bin/mkdir', MPdir ] ) #  per usare il sudo
            wrLog('mkdir rCode: {}'.format(rCode) )






# ##############################################################
# #
# ##############################################################
def removeMountPoint(MPdir):
    wrConsole('Trying to remove directory: ' + MPdir)
    if os.path.isdir(MPdir):
        if os.path.ismount(MPdir):
            wrConsole(MPdir + ' is still mounted. Please uMount the device before removing the directory. ', exitCode=2)
        else:
            if gv.EXECUTE:
                rCode = subprocess.call( ['sudo', 'rmdir', MPdir ] ) # solo per usare il sudo
                wrConsole('rmdir rCode: {}'.format(rCode) )




# ##############################################################
# #
# ##############################################################
def MountDevice(device):
        # for device in gv.DEVICES.items():
    devName, deviceDict = device      # devName=str, val=dict
    mountDIR    = deviceDict.get('MountPoint', None)
    fsTYPE      = deviceDict['ID_FS_TYPE']
    label       = deviceDict.get('ID_FS_LABEL', None)

    if mountDIR and os.path.ismount(mountDIR):
        wrConsole("device already mounted on: {}".format(mountDIR), exitCode=99)

    if not label:
        label = devName.split('/')[-1]

    mountDIR = '/mnt/{}'.format(label)
    wrLog('{:<15} {:<25} {:<15}'.format('deviceName', 'mountPoint', 'fileType'))
    wrLog('{:<15} {:<25} {:<15}'.format(devName, mountDIR, fsTYPE))



        # ----------------------------------------------
        # - preparazione parametri per il mount
        # ----------------------------------------------
    mountOPT = 'defaults,noauto,relatime,nousers,rw,flush,utf8=1,uid=pi,gid=pi,dmask=002,fmask=113'
    if   (fsTYPE == None):      wrLog('filetype: None', exitCode=4)
    elif (fsTYPE == 'ntfs'):    fsTYPE = 'ntfs-3g'
    elif (fsTYPE == 'vfat'):    fsTYPE = 'vfat'
    else:                       fsTYPE = 'auto'


        # ----------------------------------------------
        # - preparazione parametri per il mount
        # ----------------------------------------------
    mountCMD = []
    mountCMD.append('sudo')
    createMountpoint(mountDIR)

    mountCMD.append('/bin/mount')
    mountCMD.append('-t{}'.format(fsTYPE.strip()))
    mountCMD.append("-o {}".format(mountOPT.strip()))
    mountCMD.append(devName.strip())
    mountCMD.append(mountDIR)

        # esecuzione comando
    wrConsole(' '.join(mountCMD))
    if gv.EXECUTE:
        rCode = subprocess.call( mountCMD )         # subprocess.check_call( mountCMD ) # da errore
        wrConsole('mount rCode: {}'.format(rCode) )
    else:
        wrConsole('please enter --GO parameter to execute the command')




# ##############################################################
# #
# ##############################################################
def uMountDevice(device):

    devName, deviceDict = device            # devName=str, val=dict
    mountDIR    = deviceDict['MountPoint']

        # ----------------------------------------------
        # - preparazione parametri per il mount
        # ----------------------------------------------
    if os.path.isdir(mountDIR):
        if os.path.ismount(mountDIR):
            uMountCMD = []
            uMountCMD.append('sudo')
            uMountCMD.append('/bin/umount')
            uMountCMD.append("-l")
            uMountCMD.append(mountDIR)

                # Flush cache
            if gv.EXECUTE:
                rCode = subprocess.call( ['sudo', '/sbin/hdparm', '-f', devName ] ) #  mandalo in sleep
                wrLog('hdparm flush rCode: {}'.format(rCode) )

                    # sleep device
                rCode = subprocess.call( ['sudo', '/sbin/hdparm', '-y', devName ] ) #  mandalo in sleep
                wrLog('hdparm sleep rCode: {}'.format(rCode) )

                    # umount device
                wrConsole(' '.join(uMountCMD))
                rCode = subprocess.call( uMountCMD )
                wrConsole('umount rCode: {}'.format(rCode) )
            else:
               wrConsole('please enter --GO parameter to execute the command')


        else:
            wrConsole(mountDIR + ' is NOT mounted', exitCode=5)

    else:
        wrConsole(mountDIR + " doesn't exists", exitCode=6)

    removeMountPoint(mountDIR)


# ##############################################################
# # reqDEV: può essere la LABEL, UUID, oppure /dev/sda1
# ##############################################################
def getDevice(reqMountPoint=None, reqDEV=None):
    wrConsole ('reqMountPoint:  {0}'.format(reqMountPoint))
    wrConsole ('reqDEV:         {0}'.format(reqDEV))

    for device in gv.DEVICES.items():
        devName, valDict = device       # devName=str, val=dict
        wrLog('working on device ' + devName)

        if devName == reqDEV:           # è stato richiesto il mount di /dev/sdxx
            wrConsole('Matching device' + reqDEV)
            return device

        for key, val in valDict.items():
            # print (key, val, type(key), type(val))
            if key == 'MountPoint' and val == reqMountPoint:
                wrConsole('Matching MountPoint')
                return device

            if key in ['ID_FS_UUID', 'ID_FS_UUID_ENC'] and val == reqDEV:
                wrConsole('Matching UUID')
                return device

            elif key in ['ID_FS_LABEL', 'ID_FS_LABEL_ENC'] and val == reqDEV:
                wrConsole('Matching LABEL')
                return device
        print()
    # wrConsole('11111111111111111111 sono qui', exitCode=99)
    return None

def printOutDevices(gv):
    for device in gv.DEVICES.items():
        devName, valDict = device       # devName=str, val=dict
        print ('\n' + devName)
        for key, val in valDict.items():
            print ("    {:<30} = {}".format(key, val))

# ##############################################################
# #    M  A  I  N
# ==============================================================
# Testing new rules
#       sudo udevadm test $(udevadm info -q path -n /dev/sda1) 2>&1
#
# Loading new rules
#       Udev automatically detects changes to rules files,
#       so changes take effect immediately without requiring udev to be restarted.
#       However, the rules are not re-triggered automatically on already existing devices.
#       Hot-pluggable devices, such as USB devices, will probably have to be reconnected
#       for the new rules to take effect, or at least unloading and reloading the ohci-hcd
#       and ehci-hcd kernel modules and thereby reloading all USB drivers.
#
# If rules fail to reload automatically
#       udevadm control --reload-rules
#
# To manually force udev to trigger your rules (ma sembrano non funzionare)
#       sudo udevadm trigger
#       sudo udevadm trigger --attr-match=subsystem=block
# ##############################################################
if __name__ == "__main__":
    global gv
    gv = LnClass()
    gv.fCONSOLE = False                           # scrive anche a Console
    gv.fSysLOG  = False                          # scrive anche nel logger
    gv.DEVICES   = {}       # contiene la lista dei device ricavati dai comandi: mount (oppure df) e da blkid


        # cerchiamo il parametro --GO oppure e lo togliamo dalla lista
    gv.EXECUTE  = False
    for item in reversed(sys.argv):
        if item in ['--GO']:
            gv.EXECUTE = True
            sys.argv.remove(item)
    # print (sys.argv)
    # print (gv.EXECUTE)


        # - Apertura LOG
    scriptName  = os.path.basename(sys.argv[0]).split('.')[0]
    logFname    = "/tmp/{}.log".format(scriptName)
    wrLog("Apertura - log:{}".format(logFname), fName=logFname)



    # print (gv.FS)
    # print (gv.BLKID)
    # for device in gv.DEVICES.items(): print ('\n{0}'.format(device))
    # sys.exit()
    # wrLog(gv.DEVICES)

    gv.ACTION = None
    inpParam = None
    if len(sys.argv) > 1:
        if sys.argv[1].startswith('/dev/'):
            inpParam = sys.argv[1]
            gv.ACTION = 'mount'
        elif sys.argv[1][0] == '/':
            inpParam = sys.argv[1]
            gv.ACTION = 'umount'
        else:
            inpParam = sys.argv[1]
            gv.ACTION = 'mount'

    device = None

    wrConsole('imput Parameter: {0}'.format(inpParam))
    wrConsole('Action         : {0}'.format(gv.ACTION))

    gv.BLKID = getBlockID()
    gv.FS    = getMountedFS('/mnt/')
    # printOutDevices(gv)
    # wrConsole('0000000000000000 sono qui', exitCode=99)

        # - Processo della richiesta
    if gv.ACTION == 'mount':
        device = getDevice(reqDEV=inpParam)
        if device: MountDevice(device)

    elif gv.ACTION == 'umount':
        device = getDevice(reqMountPoint=inpParam)
        if device: uMountDevice(device)


        # - Se comando non valido oppure device non trovato
    if not device:
        if not inpParam:
            printOutDevices(gv)

        print('''
        Immettere il valore:
            UUID/LABEL/device   per  mount
            mountPoint          per umount

            il valore [{}] immesso non e' valido.
            '''.format(inpParam))

    wrLog("Completed", exitCode=0)



