
sudo netstat -tnpa | grep 'ESTABLISHED.*sshd'
last -a | grep -i still
ss | grep -i ssh
ps auxww | grep ssh

sudo apt-get install gawk # per  strftime
tail xxx.log | awk '{$1=strftime("%k", $1); print}' # epoch time to human formta
tail xxx.log | awk '{$1=strftime("%d-%m-%Y %H:%M:%S", $1); print}' # epoch time to human formta

sudo tcptrack -r 1 -i eth0

# https://www.slashroot.in/linux-iptraf-and-iftop-monitor-and-analyse-network-traffic-and-bandwidth
:"
    -h                  display this message
    -n                  don't do hostname lookups
    -N                  don't convert port numbers to services
    -p                  run in promiscuous mode (show traffic between other
                        hosts on the same network segment)
    -b                  don't display a bar graph of traffic
    -B                  Display bandwidth in bytes
    -i interface        listen on named interface
    -f filter code      use filter code to select packets to count (port 80 and host google)
                        (default: none, but only IP packets are counted)
    -F net/mask         show traffic flows in/out of IPv4 network
    -G net6/mask6       show traffic flows in/out of IPv6 network
    -P                  show ports as well as hosts
    -t                  use text interface without ncurses
"



sudo iftop

sudo iftop -b -n -N -P -i eth0
sudo iftop -b -n -N -P -i eth0 -f 'port 41022 and host xxxx' -t # non usa il display

sudo iptraf-ng
sudo iptraf-ng  -I eth0

find . -type f -exec grep -E 'fatal|error|critical|failure|warning' {} +
find / -name '*.*' -exec grep  --color -H 'LnPi22' {} \;
# alias .grep='grep -ri pompe * .[^.]*' # guarda anhce gli hidden non posso passare testo da trovare
find . -type f  | xargs grep  -inr "lnpi22"