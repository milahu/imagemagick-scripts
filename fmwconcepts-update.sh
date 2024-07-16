#! /bin/sh -uex

# this takes about 10 minutes

cd "$(dirname "$0")"

wget 'http://www.fmwconcepts.com/imagemagick/script_list.txt' -O script_list.txt

git add script_list.txt

[ ! -d tmp ] && mkdir tmp

time (
    cd tmp

    awk -F\- '{ print $1}' ../script_list.txt | egrep '^\w' |
    #head -n 2 | # debug: fetch only the first 2
    while read name
    do
        echo "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=${name}&dirname=${name}"
    done | wget --input-file=-

    for f in "downloadcounter.php?scriptname="*
    do
        n=$(echo "$f" | sed -E 's/^.*=([^=]+)$/\1/')
        mv -v "$f" ../bin/"$n"
    done
)

chmod +x bin/*

# postprocess: fix shebang lines
# a: #!/bin/bash
# b: #!/usr/bin/env bash
sed -i 's|^#!/bin/bash|#!/usr/bin/env bash|' bin/*

git add bin
git commit -m "sync with master site"
