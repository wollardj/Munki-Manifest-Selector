Munki-Manifest-Selector
=======================

A script+application that provides the selection of a Munki manifest template as part of a Deploy Studio workflow.

**For a more detailed description, please visit http://denisonmac.wordpress.com/2013/02/09/munki-manifest-selector/**

**Compiled download: https://dl.dropbox.com/u/12228667/Linked%20Files/Munki%20Manifest%20Selector.dmg**

To install, compile the Xcode project then copy the resulting application and script found within DeployStudioScripts/ to your Scripts directory within DeployStudio's repo. In DeployStudio, add a *Generic* task in your workflow and direct it to the launch-munki-manifest-selector.sh. The script is simply used to launch Munki Manifest Selector.app with some default options selected.
