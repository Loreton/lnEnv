#!/bin/bash
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# Simple BASH Dynamic DNS updater Script by R. Anthony Kolstee.
# tkolstee@idealcorp.com
#
# updated by ...: Loreto Notarantonio
# Date .........: 21-07-2022 16.51.04
#

# duckdns https://www.duckdns.org/spec.jsp
    # You can update your domain(s) with a single HTTPS get to DuckDNS
    # https://www.duckdns.org/update?domains={YOURVALUE}&token={YOURVALUE}[&ip={YOURVALUE}][&ipv6={YOURVALUE}][&verbose=true][&clear=true]
    # The domain can be a single domain - or a comma separated list of domains.
    # The domain does not need to include the .duckdns.org part of your domain, just the subname.
    # If you do not specify the IP address, then it will be detected - this only works for IPv4 addresses
    # You can put either an IPv4 or an IPv6 address in the ip parameter
    # If you want to update BOTH of your IPv4 and IPv6 records at once, then you can use the optional parameter ipv6
    # to clear both your records use the optional parameter clear=true


# Q: can I script my own update?
# A: yes you can do this on http or https.
    # you can comma separate the domains if you want to update more than one,
    # the ip parameter is optional, if you leave it blank we detect your gateway ip
    # https://www.duckdns.org/update?domains=ben&token=064a0540-864c-4f0f-8bf5-23857452b0c1&ip=
    # see the spec page for all the details and options.


function @_lnpi31_eth0_domains() {
    _valid_domains="
        freedns lncasetta.crabdance.com        NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjM2
        freedns lnmqtt.crabdance.com           NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5ODI4Njgx
        # freedns nsilvia.crabdance.com          NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjMy

        freedns lncasetta.mooo.com             NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5ODI4NjIy
        freedns nloreto.mooo.com               NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjY5

        duckdns lncasetta.duckdns.org          98fa7c37-21c7-43b2-92d2-822560984579
        duckdns lnmqtt.duckdns.org             98fa7c37-21c7-43b2-92d2-822560984579
    "
}


function @_lnpi22_eth0_domains() {
    @_lnpi31_eth0_domains
}


function @_lnpi23_eth0_domains() {
    @_lnpi31_eth0_domains
}

# http://freedns.afraid.org/dynamic/update.php?NUswOUF2UXVWRGE4eElUUktuVU9iYVVqOjIwNTgzODcz

function @_lnpi41_eth0_domains() {
    _valid_domains="
        duckdns    rm-pina.duckdns.org    98fa7c37-21c7-43b2-92d2-822560984579
        duckdns    rmpina.duckdns.org     98fa7c37-21c7-43b2-92d2-822560984579
        duckdns    beverino.duckdns.org   3205e711-7af1-405c-a64a-7dabb3895869
    "
}


