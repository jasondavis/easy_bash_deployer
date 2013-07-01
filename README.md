Easy Bash Deployer
=====================

This is a script I wrote when I needed to quickly deploy a site that consisted of a couple JS, CSS, 
and HTML files and nothing more.  What it will do is use YUI to minify all CSS and JS in their respective
directories, bundle them up, change all HTML references to point to the new bundle, then SCP the files over to
the server of your choice.

Motivation
----------

The main motivation was to freshen up on bash scripting along with hand-writing some automated deployment scripts.
I know there are a ton of automated release tools, such as capistrano, but I don't think you can really learn something
like automated deployment until you really sit down and have to think through all the scripts/commands that 
need to run.

Prerequisites
-------------

Yahoo YUI Compressor: https://github.com/yui/yuicompressor/downloads
    

Project Structure
-----------------

In order to use this deployer, your project should conform to the following structure:

* ROOT
  * deploy.sh (this script)  
  * site  
    * js  
      * jsfilename.js  
    * css  
      * cssfilename.css  
    * htmlfilename.html  
    * htmlfilename.html  
   
You can adjust the paths within the configuration section of the script if you use different extensions or 
folder names.

Instructions
------------

    Copy the deploy.sh file into the root (not site's root).
    Adjust configuration at the top of the deploy.sh script.
    Run ./deploy.sh from the root.
    Enter password when prompted by the remote server.

Feedback
--------

Any and all feedback is always greatly appreciated!

Contributing
------------

Contributions are always welcome.  Just fork this repo and submit a pull request. Please make sure you test!

**Possible contributions:**

* Refactoring
* Documentation
* Bug fixes
* Unit Tests
* Integration Tests

License
-------

This software is licensed up the GPLv3.  See license for more details.
