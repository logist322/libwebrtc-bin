#!/bin/bash

curl 'https://chromiumdash.appspot.com/fetch_releases?channel=Stable&platform=Linux&num=1&offset=0' |
{
    read res
    if [[ "$res" != *"\"versiown\""* ]]; then
        echo "There is wrong \`Chrome API\`, no \`version\` field there."
        exit 1
    fi

    if [[ "$res" != *"\"webrtc\""* ]]; then
        echo "There is wrong \`Chrome API\`, no \`webrtc\` field there."
        exit 1
    fi
    echo "$res"
} |
sed 's/,/\n/g' |
sed 's/["|\}|\{|\[]//g' |
sed 's/]//g' |
grep '^version\|^webrtc' |
while read p; do
    name=$(echo "$p" | cut -d':' -f1)
    value=$(echo "$p" | cut -d':' -f2)
    field=$([[ $name = version ]] && echo "WEBRTC_VERSION" || echo "WEBRTC_COMMIT")
    grep -n $field ./VERSION |
    cut -d':' -f1 |
    {
        read line
        sed -i "${line}s|.*|${field}=${value}|g" ./VERSION
    }
    if [ $name = version ]; then
        echo "::set-output name=$(echo $name)::$(echo $value)"
    fi
done
