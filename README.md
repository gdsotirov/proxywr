# Proxy Workaround

A collection of CGI utilities to put on your web server and use over highly
restrictive http-only web proxies to run commands like dig, finger, nmap, ping,
tr and whois, download files and fetch web pages.

# Requirements

The CGI scripts require `bashlib` for CGI programming with the bash shell (see
[bashlib project page](http://bashlib.sourceforge.net/)), which is included
for convenience. The command `mailsend` is also used for sending mail over
SMTP if SMTP host is configured instead of localhost (see
[mailsend page](http://www.muquit.com/muquit/software/mailsend/mailsend.html)).

# Authors

* George D. Sotirov <gdsotirov@gmail.com>

For `bashlib` see project page and source.

# Copyright

See file [COPYING](COPYING).

