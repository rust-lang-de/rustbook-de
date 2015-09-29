#!/bin/bash
TARGET="../rustbook-de-gh-pages/"
gitbook build
cp -rf _book/* "$TARGET" || exit
cd "$TARGET"
git add -A && git commit && git push

