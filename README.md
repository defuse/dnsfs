dnsfs
=====

This is a script for hosting and downloading a static set of files over DNS
*without using a custom DNS server*. If you give `dnsfs.rb` a path to
a directory, it will create TXT entries for hosting the files inside. If you
give `dnsfs.rb` a domain name, it will show you the list of hosted files and ask
which one you want to download.
