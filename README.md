# Guestbook

There are many guestbook apps, this one is named [Guestbook](https://itunes.apple.com/us/app/guestbook/id466198467?mt=8) (app store link).

[See release announcement here](http://mbrennek.2nw.net/2013/01/guestbook-open-source.html)

It's halfway through a re-write for version 2.0, but not feature complete or pretty.

Original Guestbook code is under the MIT license.  Third-party code remains under it's own license.

The __master__ branch contains the current 1.4.0 release, which is tagged _1.4.0_.

The __develop__ branch contains work towards the next release.

## Things I want to accomplish before releasing a 2.0 (not in any particular order)

* indicate video on thumbnails
* customize event list cells
* customize signature cells
* replace signature page tableview with fixed layout views?
* password protected event lock 
* theme(s)
* iphone client?
* multi device shared guestbook (iCloud?)
* internationalization
* facebook integration?
* remove navigation bars
* use MagicalRecord for CoreData interface?
* Get everything non-delegate out of the AppDelegate and into it's own class
