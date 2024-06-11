#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR"

if ! command -v jq &>/dev/null; then
    echo 'ERROR: jq command not found, please install jq'
    return 1
elif ! command -v whois &>/dev/null; then
    echo 'ERROR: whois command not found, please install whois'
    return 1
elif ! command -v sort &>/dev/null; then
    echo 'ERROR: sort command not found, please install sort'
    return 1
elif ! command -v uniq &>/dev/null; then
    echo 'ERROR: uniq command not found, please install uniq'
    return 1
fi


DROP_V4='https://www.spamhaus.org/drop/drop_v4.json'
DROP_V6='https://www.spamhaus.org/drop/drop_v6.json'
ASN_DROP='https://www.spamhaus.org/drop/asndrop.json'

for list in "$DROP_V4" "$DROP_V6"; do
    echo "Processing $(basename "$list") ..."
    filename="${SCRIPT_DIR}/lists/$(basename "$list" .json).txt"
    wget -q -O list.json "$list"
    echo "# timestamp $(jq -r '.timestamp | select(. != null)' list.json)" > "$filename"
    echo "# $(jq -r '.copyright | select(. != null)' list.json)" >> "$filename"
    jq -r '.cidr | select( . != null)' list.json >> "$filename"
done

echo 'Processing asndrop.json ...'
filename="${SCRIPT_DIR}/lists/asn.txt"
wget -q -O list.json "$ASN_DROP"
echo "# timestamp $(jq -r '.timestamp | select(. != null)' list.json)" > "$filename"
echo "# $(jq -r '.copyright | select(. != null)' list.json)" >> "$filename"
jq -r '.asn | select(. != null)' list.json | while read -r asn; do
    echo "Processing AS${asn}"
    echo "# AS${asn}" >> "$filename"
    whois -h whois.radb.net -- "-i origin AS${asn}" | awk '/^route6?:/ {print $2;}' | sort | uniq >> "$filename"
done

rm list.json
