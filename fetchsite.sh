#!/bin/sh
# Fetch JavaScript files from the specified site

UAGENT='Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0'
SITE="$1"
BACK=".backup.$1"
JSMIMETYPES="application/javascript,text/javascript,text/x-javascript"
HTMLMIMETYPES="text/html"

echo -n "$SITE "

# Create backup to keep if fetch fails
if [ -d $SITE ] ; then
  rm -rf $BACK
  mv $SITE $BACK
fi

mkdir $SITE
cd $SITE


if ! wget --append-output=wget.log	\
  --tries=3 \
  --timeout=120 \
  --adjust-extension \
  --span-hosts \
  --timestamping \
  --user-agent="$UAGENT" \
  --no-check-certificate \
  --convert-links \
  --page-requisites \
  --execute=robots=off \
  --header="Accept: */*,$JSMIMETYPES,$HTMLMIMETYPES" \
  --accept '*.js,*.html' \
  http://$SITE 2>wget.err &&
  test $(find ../$BACK -type f -name \*.js 2>/dev/null | wc -l) -gt 0 -a \
  $(find ../$SITE -type f -name \*.js | wc -l) -eq 0 ; then

  # We fail iff wget fails *and* number of JS files *drops* to 0
  echo FAIL
  # Restore backup, if available
  cd ..
  if [ -d $BACK ] ; then
    rm -rf $SITE
    mv $BACK $SITE
  fi
else
  nice python /home/vitsalis/scripts/parse-html.py .
  #find . -type f -name \*.html -exec sh -c '
  #  nice python /home/vitsalis/scripts/parse-html.py "{}"
  #' \;
  #find . -type f -name \*.html -print0 | \
  #  xargs -0 python /home/vitsalis/scripts/parse-html.py
  #for i in $(find . -type f -name \*.html)
  #do
  #  python /home/vitsalis/scripts/parse-html.py $i
  #done
  echo OK
  # Remove backup
  cd ..
  rm -rf $BACK
fi
