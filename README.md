koha_batch_items_mod is a command line tool to modify Koha items in a
batch. It's design for older version of Koha (like 3.2) where batch
modification for items may be buggy or unusable.

Warning
=======

It doesn't check for authorised values. You can stuff your catalogue
with whatever garbage your sending this command. Be careful, don't
blame me :).

Installation, Deinstallation
============================

Installs in /usr/local/bin.

    $ sudo make install
    $ sudo make deinstall

Usage
=====

    koha_batch_items_mod 5055 notforloan 6
    Dry run:
    
    5055, notforloan: 99 -> 6


    $ koha_batch_items_mod -a 5055 notforloan 6
    Applying changes:
    
    5055, notforloan: 99 -> 6

    $ cat liste
    367
    25348

    $ koha_batch_items_mod -a 5055 notforloan 6 liste
    367, notforloan: 9 -> 6
    25348, notforloan: 0 -> 6
