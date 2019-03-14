#!/usr/bin/env sh

PASS=$(gpg -qd ~/.mutt/password.gpg)
OUT=$(./mail imaps://imap.gmail.com gibsonhugo@gmail.com $PASS) 

echo $OUT | cut -d "(" -f2 | cut -d ")" -f1 | grep -o '.$'

