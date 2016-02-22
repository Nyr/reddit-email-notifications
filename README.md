##reddit-email-notifications
Get notifications about new reddit messages by email.

###Installation
Just edit `MAIL` `FROMMAIL` and `JSON_URL` in the script and add it to your cron tab so it runs periodically.

###Known limitations
The `-a` flag of mail works on Debian but it doesn't in Mac OS X so you may need to remove it.