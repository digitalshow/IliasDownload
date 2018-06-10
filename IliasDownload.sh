#!/bin/bash

# IliasDownload.sh: A download script for ILIAS, an e-learning platform.
# Copyright (C) 2016 - 2018 Ingo Koinzer
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

if [ -z "$COOKIE_PATH" ] ; then
	COOKIE_PATH=/tmp/ilias-cookies.txt
fi

# If you're not at Uni Stuttgart, you might still be able to use this script by changing stuff below

ILIAS_URL="https://ilias3.uni-stuttgart.de/"
ILIAS_PREFIX="Uni_Stuttgart"
ILIAS_LOGIN_GET="login.php?target=&client_id=Uni_Stuttgart&cmd=force_login&lang=de"
ILIAS_HOME="ilias.php?baseClass=ilPersonalDesktopGUI&cmd=jumpToSelectedItems"
ILIAS_LOGOUT="logout.php?lang=de"

# DON'T TOUCH FROM HERE ON

ILIAS_DL_COUNT=0
ILIAS_IGN_COUNT=0
ILIAS_FAIL_COUNT=0
ILIAS_DL_NAMES=""

check_grep_availability() {
	echo "abcde" | grep -oP "abc\Kde"
	GREP_AV=`echo "$?"`
}

do_grep() {
	if [ "$GREP_AV" -eq 0 ] ; then
		grep -oP "$1"
	else
		# Workaround if no Perl regex supported
		local prefix=`echo "$1" | awk -F: 'BEGIN {FS="\\\\K"}{print $1}'`
		local match=`echo "$1" | awk -F: 'BEGIN {FS="\\\\K"}{print $2}'`
		grep -o "$prefix$match" | grep -o "$match"
	fi
}

ilias_request() {
	curl -s -L -b $COOKIE_PATH -c $COOKIE_PATH $2 $ILIAS_URL$1
}

do_login() {
	if [ -f $COOKIE_PATH ] ; then
		rm $COOKIE_PATH
	fi
	echo "Getting form url..."
	local LOGIN_PAGE=`ilias_request "$ILIAS_LOGIN_GET"`
	ILIAS_LOGIN_POST=`echo "$LOGIN_PAGE" | tr -d "\r\n" | do_grep "name=\"formlogin\".*action=\"\K[^\"]*"`
	if [ "$?" -ne 0 ] ; then
		echo "Failed getting login form url."
		exit 1
	fi
	ILIAS_LOGIN_POST=`echo "$ILIAS_LOGIN_POST" | sed 's/&amp;/\&/g'`
	echo "Sending login information..."
	ilias_request "$ILIAS_LOGIN_POST" "--data-urlencode username=$ILIAS_USERNAME --data-urlencode password=$ILIAS_PASSWORD --data-urlencode cmd[doStandardAuthentication]=Anmelden" > /dev/null
	result="$?"
	if [ "$result" -ne 0 ] ; then
		echo "Failed sending login information: $result."
		exit 2
	fi
	
	echo "Checking if logged in..."
	ilias_request "$ILIAS_HOME" | grep ilMailGUI > /dev/null
	if [ $? -ne 0 ] ; then
		echo "Home page check failed. Is your login information correct?"
		exit 3
	fi
}

function do_logout {
	echo "Logging out."
	ilias_request "$ILIAS_LOGOUT" > /dev/null
}

function get_filename {
	ilias_request "$1" "-I" | do_grep "Content-Description: \K(.*)" | tr -cd '[:print:]'
}

function fetch_folder {
	if [ ! -d "$2" ] ; then
		echo "$2 is not a directory!"
		return
	fi
	cd "$2"
	if [ ! -f "$HISTORY_FILE" ] ; then
		touch "$HISTORY_FILE"
	fi
	local HISTORY_CONTENT=`cat "$HISTORY_FILE"`
	
	echo "Fetching folder $1 to $2"

	echo "$1" | do_grep "^[0-9]*$" > /dev/null
	if [ $? -eq 0 ] ; then
		local CONTENT_PAGE=`ilias_request "goto_Uni_Stuttgart_fold_$1.html"`
	else
		local CONTENT_PAGE=`ilias_request "goto_Uni_Stuttgart_$1.html"`
	fi
	
	# Files
	local ITEMS=`echo $CONTENT_PAGE | do_grep "<h4 class=\"il_ContainerItemTitle\"><a href=\"${ILIAS_URL}\Kgoto_${ILIAS_PREFIX}_file_[0-9]*_download.html"`
	
	for file in $ITEMS ; do
		local DO_DOWNLOAD=1
		local NUMBER=`echo "$file" | do_grep "[0-9]*"`
		echo -n "[$NUMBER] "
		echo "$HISTORY_CONTENT" | grep "$file" > /dev/null
		if [ $? -eq 0 ] ; then
			local ITEM=`echo $CONTENT_PAGE | do_grep "<h4 class=\"il_ContainerItemTitle\"><a href=\"${ILIAS_URL}${file}.*<div style=\"clear:both;\"></div>"`
			echo "$ITEM" | grep "geändert" > /dev/null
			if [ $? -eq 0 ] ; then
				local FILENAME=`get_filename "$file"`
				echo -n "$FILENAME changed "
				local PART_NAME="${FILENAME%.*}"
				local PART_EXT="${FILENAME##*.}"
				local PART_DATE=`date +%Y%m%d-%H%M%S`
				mv "$FILENAME" "${PART_NAME}.${PART_DATE}.${PART_EXT}"
			else
				echo "exists"
				((ILIAS_IGN_COUNT++))
				DO_DOWNLOAD=0
			fi
		fi
		if [ $DO_DOWNLOAD -eq 1 ] ; then
			local FILENAME=`get_filename "$file"`
			echo -n "$FILENAME downloading... "
			
			ilias_request "$file" "-O -J"
			local RESULT=$?
			if [ $RESULT -eq 0 ] ; then
				echo "$file" >> "$HISTORY_FILE"
				((ILIAS_DL_COUNT++))
				echo "done"
				ILIAS_DL_NAMES="${ILIAS_DL_NAMES} - ${FILENAME}
"
			else
				echo "failed: $RESULT"
				((ILIAS_FAIL_COUNT++))
			fi
		fi
	done
	
	# Folders
	local ITEMS=`echo "$CONTENT_PAGE" | do_grep "<h4 class=\"il_ContainerItemTitle\"><a href=\"${ILIAS_URL}\Kgoto_${ILIAS_PREFIX}_fold_[0-9]*.html"`
	
	for folder in $ITEMS ; do
		local FOLDER_NAME=`echo "$CONTENT_PAGE" | do_grep "<h4 class=\"il_ContainerItemTitle\"><a href=\"${ILIAS_URL}${folder}\" class=\"il_ContainerItemTitle\"[^>]*>\K[^<]*"`
		
		# Replace / character
		local FOLDER_NAME=${FOLDER_NAME//\//-}
		echo "Entering folder $FOLDER_NAME"
		local FOLD_NUM=`echo "$folder" | do_grep "fold_\K[0-9]*"`
		if [ ! -e "$2/$FOLDER_NAME" ] ; then
			mkdir "$2/$FOLDER_NAME"
		fi
		fetch_folder "$FOLD_NUM" "$2/$FOLDER_NAME"
	done
}

function print_stat() {
	echo
	echo "Downloaded $ILIAS_DL_COUNT new files, ignored $ILIAS_IGN_COUNT files, $ILIAS_FAIL_COUNT failed."
	echo "$ILIAS_DL_NAMES"
}

check_grep_availability
