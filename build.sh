#!/bin/sh

# Created By: Javier Pacheco - javier@jpacheco.xyz
# Created On: 26/05/24
# Project: My web page build script

emacs -Q --script build-site.el
# git add .
# git commit -m "commit $(date '+%Y-%m-%d | %r')"
# git push && echo "website updated and pushed to github" || echo "something is wrong..."
