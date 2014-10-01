##reddit-email-notifications
Get notifications about new reddit messages by email.

###Requeriments
Unix based system with `xmlstarlet` available. Just get it from your package manager.

###Installation
1. `apt-get install xmlstarlet` (or whatever you use on your system)
2. Edit `MAIL` `FROMMAIL` and `RSS_URL` on the script and add it to your cron tab so it runs periodically.

###Known limitations
- The `-a` flag of mail works on Debian but it doesn't in Mac OS X so you may need to remove it.