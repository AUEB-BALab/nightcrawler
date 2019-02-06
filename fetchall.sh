#!/bin/sh

cd /home/vitsalis/js-evolution

mkdir -p js-evol-data
cd js-evol-data

date

parallel --jobs 50 ../fetchsite.sh <../sites 2>&1 >../progress

# Remove non-JavaScript files
find . -name .git -prune -o -type f -print |
grep -v '.js$\|.html$\|\-jsf' |
xargs rm -f

mv ../progress fetchlog.txt

# Commit the files into the repository
if [ -d .git ] ; then
  git add .
  git commit -m "Update for $(date -I)"
else
  git init
  git add .
  git commit -q -m "Initial commit"
fi

git gc
#git push

date
