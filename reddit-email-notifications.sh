#!/bin/bash
# Get notifications of new reddit messages by email

MAIL="you@example.com"
# FROMMAIL = mail which will appear in the "from" header of the notifications
FROMMAIL="noreply@example.com"
# Get your private inbox feed here: https://ssl.reddit.com/prefs/feeds/
RSS_URL="http://www.reddit.com/message/inbox/.rss?feed=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX&user=XXXXX"

# No need to edit from here :)
BASEDIR=$(dirname $0)
mkdir $BASEDIR/output 2>/dev/null
NEWITEMS="$BASEDIR/output/newitems.txt"
SENTITEMS="$BASEDIR/output/sentitems.txt"
MAILTMP="$BASEDIR/output/mail.tmp"

# Get the feed, remove crap and the empty line at the end
wget -qO- -T 15 -t 3 $RSS_URL | xmlstarlet sel -t -m //channel/item -v "link" -o " %#%#%#%#%" -v "title" -n | \
sed 's/ via .*//' | sed 's/ sent.*//' | sed 's/%#%#%#%#%.*from //g' | sed '/^$/d'> $NEWITEMS

# Check if feed download was successful
if ! egrep -q -i "www.reddit.com/r/|www.reddit.com/message/messages/" $NEWITEMS ; then
	exit
fi

# If it's the first time, we don't want to spam our inbox
if [ ! -f $SENTITEMS ]; then
	cp $NEWITEMS $SENTITEMS
	exit
fi

# Extract the variables we need and send the emails
while IFS= read -r LINE; do
	IFS=' ' read url user < <(echo "$LINE")
	if ! grep -q $url $SENTITEMS; then # Only if the URL wasn't sent already...
		# Build the email and send it
		echo "Hey," > $MAILTMP
		echo >> $MAILTMP
		echo "$user has sent you a message:" >> $MAILTMP
		echo >> $MAILTMP
		echo "$url" >> $MAILTMP
		cat $MAILTMP | mailx -r $FROMMAIL -s "Message from $user on reddit" $MAIL
		# Add it to the log
		echo $url $user >> $SENTITEMS
	fi
done < $NEWITEMS