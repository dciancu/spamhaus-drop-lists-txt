#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR"


DROP_V4='https://www.spamhaus.org/drop/drop_v4.json'
DROP_V6='https://www.spamhaus.org/drop/drop_v6.json'
ASN_DROP='https://www.spamhaus.org/drop/asndrop.json'

for list in "$DROP_V4" "$DROP_V6"; do
    filename="${SCRIPT_DIR}/lists/$(basename "$list" .json).txt"
    wget -q -O list.json "$list"
    echo "# timestamp $(jq -r '.timestamp | select(. != null)' list.json)" > "$filename"
    echo "# $(jq -r '.copyright | select(. != null)' list.json)" >> "$filename"
    jq -r '.cidr | select( . != null)' list.json >> "$filename"
done

filename="${SCRIPT_DIR}/lists/asn.txt"
wget -q -O list.json "$ASN_DROP"
echo "# timestamp $(jq -r '.timestamp | select(. != null)' list.json)" > "$filename"
echo "# $(jq -r '.copyright | select(. != null)' list.json)" >> "$filename"
jq -r '.domain | select( . != null)' list.json >> "$filename"

rm list.json
