OAUTHP5
=====================

A library by [New York Times R&D Lab](http://www.nytlabs.com) for the Processing programming environment.

Allows Processing to access data from [OAuth](http://www.oauth.net) services such as Twitter, Facebook, and [OpenPaths](http://www.openpaths.cc); based on the excellent [Scribe](https://github.com/fernandezpablo85/scribe-java/) Java library by Pablo Fernandez.

Help
-------------
For usage feedback on the oauthP5 library, please post to the Processing's [contributed library forum](http://forum.processing.org/contributed-library-questions).  For bugs reports, and feature requests, please post to our Bitbucket [issue tracker](https://bitbucket.org/nytlabs/oauthp5/issues).

Setting Up for Development
-------------

First, if you are only interested in using the project and _viewing_ the source but _not editing_ the source, you do not need to fork this repository.  Source files are included in the zipped distribution download found on the [oauthP5 homepage](http://www.nytlabs.com/oauthp5); the distribution source is easier to navigate your way around because it doesn't contain all the Eclipse support files.

Ok, so if you're still reading along here it's because you want to do more with the source code than just look at it. This repository is setup as an Eclipse project. Once you have acquired a copy of the repository by either downloading the zipped file provided by Bitbucket or by cloning in mercurials, you can import it into Eclipse as an existing project and browse around the source, making any changes you want.

This project was set up using the Processing Library template, so it might be useful to familiarize yourself with the original template instructions [here](http://code.google.com/p/processing/wiki/LibraryTemplate).

To compile using Ant:
+ From the Eclipse menu bar, choose Window > Show View > Ant. A tab with the title "Ant" will pop up on the right side of your Eclipse editor.
+ Drag the "resources/build.xml" file in there, and a new item "ProcessingLibs" will appear.
+ Press the "Play" button inside the "Ant" tab.
+ A `/distribution` folder will be created, holding the website files, and the library itself will be compiled to your Processing `/libraries` folder.