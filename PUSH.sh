#!/bin/ash
VERGEN_BASED="%m.%H.%S.%O"
VERGEN_BIRTH="2022-04-26 07:16:00.0000 UTC"
VERGEN_BUILD="0.13.1637.754184"
VERGEN_BUILT="2022-04-26 20:43:17.7541 UTC"

# run this when ready to commit and push to current branch
./VERGEN.sh -i VERSION -o VERSION
./VERGEN.sh -i VERSION -o $(find . -name "*.sh")
git add .
git commit --allow-empty-message -m "$1"
git push        # assumes git remote set-url has been established https://stackoverflow.com/a/69009871

