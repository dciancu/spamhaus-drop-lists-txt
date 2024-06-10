#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR"


DROP_V4='https://www.spamhaus.org/drop/drop_v4.json'
DROP_V6='https://www.spamhaus.org/drop/drop_v6.json'
ASN_DROP='https://www.spamhaus.org/drop/asndrop.json'

for list in "$DROP_V4" "$DROP_V6"; do
    name="$(basename "$list" .json).txt"
     wget -q --output-document - "$list" | \
        jq -r '.cidr | select( . != null )' > "${SCRIPT_DIR}/lists/${name}"
done

wget -q --output-document - "$ASN_DROP" |
    jq -r '.domain | select( . != null )' >"${SCRIPT_DIR}/lists/asn.txt"
