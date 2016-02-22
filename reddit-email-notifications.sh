#!/bin/bash
# Get notifications of new reddit messages by email

MAIL="you@example.com"
# FROMMAIL = mail which will appear in the "from" header of the notifications
FROMMAIL="noreply@example.com"
# Get the URL for your inbox in JSON here: https://www.reddit.com/prefs/feeds/
JSON_URL="https://www.reddit.com/message/inbox/.json?feed=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX&user=XXXXX"

# No need to edit from here :)
BASEDIR=$(dirname $0)
mkdir $BASEDIR/output 2>/dev/null
NEWITEMS="$BASEDIR/output/newitems.txt"
SENTITEMS="$BASEDIR/output/sentitems.txt"

# Download the feed, get the content we need
wget -qO- -T 15 -t 3 --no-check-certificate $JSON_URL | sed 's/", "/\n/g' | grep -E 'author": "|id": "' | grep -v 'parent_id' | sed 's/id": "//g' | sed 's/subreddit": "//g' | sed 's/author": "//g' | paste -d " " - - > $NEWITEMS

# If it's the first time, we don't want to spam our inbox
if [ ! -f $SENTITEMS ]; then
	cp $NEWITEMS $SENTITEMS
	exit
fi

# Extract the variables we need and send the emails
while IFS= read -r LINE; do
	IFS=' ' read author id < <(echo "$LINE")
	if ! grep -q $id $SENTITEMS; then # Only if the URL wasn't sent already...
		# Build the email and send it
		echo "Hey,

$author has sent you a message:

https://www.reddit.com/message/inbox/" | mail -a "From: $FROMMAIL" -s "Message from $author on reddit" $MAIL
		# Add it to the log
		echo $author $id >> $SENTITEMS
	fi
done < $NEWITEMS
