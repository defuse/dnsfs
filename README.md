dnsfs
=====

This is a script for hosting and downloading a static set of files over DNS
*without using a custom DNS server*. If you give `dnsfs.rb` a path to
a directory, it will create TXT entries for hosting the files inside. If you
give `dnsfs.rb` a domain name, it will show you the list of hosted files and ask
which one you want to download.

How fast is it? I downloaded a 568K file from my nameserver in 293 seconds... so
about 1981 bytes/second. Of course it depends on the RTT, and it can probably be
sped up a lot by sending requests in parallel (this script doesn't).

NOTE: I'm pretty sure something like this has been done before... I just wanted
to write it myself and couldn't find the reference. Please let me know of
similar things!

Examples
========

Downloading
-----------

Note: Intermediate nameservers may cache your requests. Please be respectful and
query the authoratative nameserver directly!

    $ ruby dnsfs.rb --download --nameserver dnsfs.defuse.ca dnsfs.defuse.ca
    1. manifesto.txt (size: 3880 bytes)
    2. longcat.jpg (size: 580516 bytes)
    Which one?
    1
    .....................
    File written to /tmp/manifesto.txt.

Generating
----------

    $ ruby dnsfs.rb --generate test
    f1info.dnsfs IN TXT "Name: foo.txt / Size: 31"
    f1p1.dnsfs IN TXT "VGhpcyBpcyAKYSBmaWxlCm5hbWVkCmZvby50eHQhCg=="
    f1p2.dnsfs IN TXT "~EOF~"
    f2info.dnsfs IN TXT "Name: bar.txt / Size: 558"
    f2p1.dnsfs IN TXT "VGhpcyBpcyAKYSBmaWxlCm5hbWVkCmJhci50eHQhClRoaXMgaXMgCmEgZmlsZQpuYW1lZApiYXIudHh0IQpUaGlzIGlzIAphIGZpbGUKbmFtZWQKYmFyLnR4dCEKVGhpcyBpcyAKYSBmaWxlCm5hbWVkCmJhci50eHQhClRoaXMgaXMgCmEgZmlsZQpuYW1lZApiYXIudHh0IQpUaGlzIGlzIAphIGZpbGUKbmFtZWQKYmFyLnR4dCEKVGhp"
    f2p2.dnsfs IN TXT "cyBpcyAKYSBmaWxlCm5hbWVkCmJhci50eHQhClRoaXMgaXMgCmEgZmlsZQpuYW1lZApiYXIudHh0IQpUaGlzIGlzIAphIGZpbGUKbmFtZWQKYmFyLnR4dCEKVGhpcyBpcyAKYSBmaWxlCm5hbWVkCmJhci50eHQhClRoaXMgaXMgCmEgZmlsZQpuYW1lZApiYXIudHh0IQpUaGlzIGlzIAphIGZpbGUKbmFtZWQKYmFyLnR4dCEKVGhpcyBp"
    f2p3.dnsfs IN TXT "cyAKYSBmaWxlCm5hbWVkCmJhci50eHQhClRoaXMgaXMgCmEgZmlsZQpuYW1lZApiYXIudHh0IQpUaGlzIGlzIAphIGZpbGUKbmFtZWQKYmFyLnR4dCEKVGhpcyBpcyAKYSBmaWxlCm5hbWVkCmJhci50eHQhClRoaXMgaXMgCmEgZmlsZQpuYW1lZApiYXIudHh0IQpUaGlzIGlzIAphIGZpbGUKbmFtZWQKYmFyLnR4dCEK"
    f2p4.dnsfs IN TXT "~EOF~"
    f3info.dnsfs IN TXT "~EOL~"


How It Works
============

For each file K in 1..N, there are a set of TXT entries:

- f<i>K</i>info: File K's name and size.
- f<i>N+1</i>info: End of list marker: `~EOL~`
- f<i>K</i>p<i>P</i>: Part *P* of file *K* base64-encoded. Last one is `~EOF~`.
