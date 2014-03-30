dnsfs
=====

This is a script for hosting and downloading a static set of files over DNS
*without using a custom DNS server*. If you give `dnsfs.rb` a path to
a directory, it will create TXT entries for hosting the files inside. If you
give `dnsfs.rb` a domain name, it will show you the list of hosted files and ask
which one you want to download.

Examples
========

Downloading
-----------

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
