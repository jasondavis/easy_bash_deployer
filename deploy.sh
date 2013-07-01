#!/bin/bash

###################################################################
# easy_bash_deployer
# A Bashscript HTML site deployer.
# Copyright (C) 2013, Matthew N. Ruggio (matt@mattruggio.com)
#
#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
###################################################################

############################################
# BASIC SETTINGS
# Change these settings per your environment
############################################

# Remote server credentials
SERVER_USER="USERNAME"
SERVER_HOST="FTPFQDN.COM"
SERVER_PATH="public/SITENAME/public"

# Point this to your instance of YUI compressor
YUI_COMPRESSOR="$HOME/tools/yuicompressor-2.4.7/build/yuicompressor-2.4.7.jar"

#####################################################
# ADVANCED SETTINGS
# Change these settings if you need more control over
# folder or program structure, but if you follow the
# guidelines you should not need to.
#####################################################

# Root will be relative to the current location of this script
ROOT="."

# the sub-directories where the JS and CSS files are located
BUNDLE_FILE_NAME="bundled"
HTML_EXT="html"
JS_SUBDIR_NAME="js"
JS_EXT="js"
CSS_SUBDIR_NAME="css"
CSS_EXT="css"

SITE_DIR="$ROOT/site"

# Unique name to represent this deployment
CURRENT_DEPLOYMENT_LABEL="$(date +"%Y_%m_%d_%H_%M_%S")_$RANDOM"

# Base directory of the deployments, each will be stored here before deployment
DEPLOYMENT_DIR="./deployments"

# The directory of the current deployment
CURRENT_DEPLOYMENT_DIR="$DEPLOYMENT_DIR/$CURRENT_DEPLOYMENT_LABEL"

################################################################
################################################################
## BEGIN DEPLOYMENT EXECUTION STEPS
################################################################
################################################################

echo ""
echo "BEGIN DEPLOYMENT"

##################################
# CREATE: New folder for deployment
##################################

# Make sure the base deployment dir exists, if not, then create it
if [ ! -d "$DEPLOYMENT_DIR" ]
then
	echo "Creating base deployment dir: $DEPLOYMENT_DIR"
	mkdir $DEPLOYMENT_DIR
fi

# Create a new folder for our current deployment, but make sure it doesn't already exist
if [ -d "$CURRENT_DEPLOYMENT_DIR" ]
then
	echo "Aborting deployment... $CURRENT_DEPLOYMENT_DIR already exists!"
	exit 1
else
	echo "Creating current deployment dir: $CURRENT_DEPLOYMENT_DIR"
	mkdir $CURRENT_DEPLOYMENT_DIR
fi

####################################
# COPY: Site into deployment sandbox
####################################

echo "Copying site from: $SITE_DIR to: $CURRENT_DEPLOYMENT_DIR"
cp -r $SITE_DIR/* $CURRENT_DEPLOYMENT_DIR

#################################################
# BUNDLE JS: All JS files in javascript directory
#################################################

JS_BUNDLE_FILE_NAME="$BUNDLE_FILE_NAME.$JS_EXT" 
CURRENT_DEPLOYMENT_JS_DIR="$CURRENT_DEPLOYMENT_DIR/$JS_SUBDIR_NAME"
CURRENT_DEPLOYMENT_JS_BUNDLE="$CURRENT_DEPLOYMENT_JS_DIR/$JS_BUNDLE_FILE_NAME"

echo -e "Minifying and bundling JavaScripts in directory: $CURRENT_DEPLOYMENT_JS_DIR"
jslist=`find $CURRENT_DEPLOYMENT_JS_DIR -type f -name \*.$JS_EXT`

for jsfile in $jslist
do
	echo "Processing: ${jsfile}"
	java -jar $YUI_COMPRESSOR ${jsfile} >> $CURRENT_DEPLOYMENT_JS_BUNDLE
	rm ${jsfile}
done

echo "Bundling of JS complete at: $CURRENT_DEPLOYMENT_JS_BUNDLE"

#################################################
# BUNDLE CSS: All CSS files in stylesheet directory
#################################################

CSS_BUNDLE_FILE_NAME="$BUNDLE_FILE_NAME.$CSS_EXT"
CURRENT_DEPLOYMENT_CSS_DIR="$CURRENT_DEPLOYMENT_DIR/$CSS_SUBDIR_NAME"
CURRENT_DEPLOYMENT_CSS_BUNDLE="$CURRENT_DEPLOYMENT_CSS_DIR/$CSS_BUNDLE_FILE_NAME"

echo -e "Minifying and bundling stylesheets in directory: $CURRENT_DEPLOYMENT_CSS_DIR to: $CURRENT_DEPLOYMENT_CSS_BUNDLE"
csslist=`find $CURRENT_DEPLOYMENT_CSS_DIR -type f -name \*.$CSS_EXT`

for cssfile in $csslist
do
	echo "Processing: ${cssfile}"
	java -jar $YUI_COMPRESSOR ${cssfile} >> $CURRENT_DEPLOYMENT_CSS_BUNDLE
	rm ${cssfile}
done

echo "Bundling of CSS complete at: $CURRENT_DEPLOYMENT_CSS_BUNDLE"

##########################################
# UPDATE: HTML Files with new bundles
##########################################

echo -e "Updating HTML in directory: $CURRENT_DEPLOYMENT_DIR"
htmllist=`find $CURRENT_DEPLOYMENT_DIR -type f -name \*.$HTML_EXT`

for htmlfile in $htmllist
do
	echo "Processing: ${htmlfile}"
	cat ${htmlfile} |\
	 sed -e 's/<script[^>]*>//g' |\
	 sed -e 's/<\/script>//g' |\
	 sed -e 's/<link[^>]*>//g' |\
	 sed -e "s/<\/body>/<script type=\"text\/javascript\" src=\"$JS_SUBDIR_NAME\/$JS_BUNDLE_FILE_NAME\"><\/script><\/body>/g" |\
	 sed -e "s/<\/head>/<link rel=\"stylesheet\" type=\"text\/css\" href=\"$CSS_SUBDIR_NAME\/$CSS_BUNDLE_FILE_NAME\"><\/head>/g" >>\
	 ${htmlfile}.new
	rm ${htmlfile}
	mv ${htmlfile}.new ${htmlfile}
done

##########################################
# DEPLOY: All files to server
##########################################

echo "Deploying files in: $CURRENT_DEPLOYMENT_DIR to: $SERVER_USER@$SERVER_HOST:$SERVER_PATH"
scp -r $CURRENT_DEPLOYMENT_DIR/* $SERVER_USER@$SERVER_HOST:$SERVER_PATH

################################################################
################################################################
## END DEPLOYMENT EXECUTION STEPS
################################################################
################################################################

echo "DEPLOYMENT COMPLETE"
echo ""