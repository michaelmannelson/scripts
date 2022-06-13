#!/bin/ash
VERGEN_BASED="%m.%H.%S.%O"
VERGEN_BIRTH="2022-04-26 07:16:00.0000 UTC"
VERGEN_BUILD="1.436.2283.118401"
VERGEN_BUILT="2022-06-13 21:54:03.1184 UTC"

# https://github.com/michaelmannelson/scripts
# No warranty is expressed or implied. Run at your own risk.

# run this when ready to commit and push to current branch
./VERGEN.sh -i VERSION -o VERSION
./VERGEN.sh -i VERSION -o $(find . -name "*.sh")
git add .
git commit --allow-empty-message -m "$1"
git push        # assumes git remote set-url has been established https://stackoverflow.com/a/69009871

