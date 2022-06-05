#!/bin/ash
VERGEN_BASED="%m.%H.%S.%O"
VERGEN_BIRTH="2022-04-26 07:16:00.0000 UTC"
VERGEN_BUILD="1.225.3381.655549"
VERGEN_BUILT="2022-06-05 03:12:21.6555 UTC"

# https://github.com/michaelmannelson/scripts
# No warranty is expressed or implied. Run at your own risk.

# run this when ready to commit and push to current branch
./VERGEN.sh -i VERSION -o VERSION
./VERGEN.sh -i VERSION -o $(find . -name "*.sh")
git add .
git commit --allow-empty-message -m "$1"
git push        # assumes git remote set-url has been established https://stackoverflow.com/a/69009871

