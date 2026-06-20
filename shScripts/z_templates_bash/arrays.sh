#!/bin/bash

# updated by ...: Loreto Notarantonio
# Date .........: 02-11-2022 11.12.58

files=(fileA1 fileA2 fileB1 fileB2)
for (( i=0; i<${#files[@]} ; i+=2 )) ; do
    echo "${files[i]}" "${files[i+1]}"
done

_SIMPLE_ARRAY_="
        duckdns: lncasetta.duckdns.org          98fa7c37-21c7-43b2-92d2-822560984579
        # freedns: lncasetta.crabdance.com        NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjM2
        # freedns: lnmqtt.crabdance.com           NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5ODI4Njgx
        # freedns: nsilvia.crabdance.com          NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjMy

        # freedns: lncasetta.mooo.com             NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5ODI4NjIy
        # freedns: nloreto.mooo.com               NGhzSkRFU2VlVGFVc3FmUGpxNkN5MWFUOjE5Nzg4MjY5

        # put as last because could be found also as a local ip address. see fUPDATE flag
        duckdns: lnmqtt.duckdns.org             98fa7c37-21c7-43b2-92d2-822560984579
    "

readarray -t array < /path/to/filename
readarray -t array < /path/to/filename
mapfile -t arrayDomains <<< "$_SIMPLE_ARRAY_"
readarray -t arrayDomains <<< "$_SIMPLE_ARRAY_"



IFS='-' read -ra ADDR <<< "$IN"
for i in "${ADDR[@]}"; do
    echo "$i"
done

 while IFS='-' read -ra ADDR; do
      for i in "${ADDR[@]}"; do
            echo "$i"
      done
 done <<< "$IN"


# remove word from input arguments
my_args=$@
for word in $@ ; do
    echo ${word}
    if [ $word == '--tags' ]; then
        my_args=${my_args//$word/}
        TAGS='--tags'
    fi
done
echo $my_args
echo $TAGS