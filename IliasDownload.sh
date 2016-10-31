#!/bin/bash

# IliasDownload.sh: A download script for ILIAS, an e-learning platform.
# Copyright (C) 2016 Ingo Koinzer
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
ILIAS_LOGIN_POST="ilias.php?lang=de&client_id=Uni_Stuttgart&cmd=post&cmdClass=ilstartupgui&cmdNode=t6&baseClass=ilStartUpGUI&rtoken="
ILIAS_HOME="ilias.php?baseClass=ilPersonalDesktopGUI&cmd=jumpToSelectedItems"
ILIAS_LOGOUT="logout.php?lang=de"

# DON'T TOUCH FROM HERE ON

ILIAS_DL_COUNT=0
ILIAS_IGN_COUNT=0
ILIAS_FAIL_COUNT=0

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
	echo "Sending login information..."
	ilias_request "$ILIAS_LOGIN_POST" "--data-urlencode username=$ILIAS_USERNAME --data-urlencode password=$ILIAS_PASSWORD" > /dev/null
	if [ $? -ne 0 ] ; then
		echo "Failed sending login information."
		exit
	fi
	
	echo "Checking if logged in..."
	ilias_request "$ILIAS_HOME" | grep ilMailGUI > /dev/null
	if [ $? -ne 0 ] ; then
		echo "Home page check failed. Is your login information correct?"
		exit
	fi
}

function do_logout {
	echo "Logging out."
	ilias_request "$ILIAS_LOGOUT" > /dev/null
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
	
	echo "Fetching folder $1 to $2"
	local CONTENT_PAGE=`ilias_request "goto_Uni_Stuttgart_fold_$1.html"`
	
	# Files
	local ITEMS=`echo $CONTENT_PAGE | do_grep "<h4 class=\"il_ContainerItemTitle\"><a href=\"${ILIAS_URL}\Kgoto_${ILIAS_PREFIX}_file_[0-9]*_download.html"`
	
	for file in $ITEMS ; do
		cat "$HISTORY_FILE" | grep "$file" > /dev/null
		if [ $? -eq 0 ] ; then
			echo "File already downloaded."
			((ILIAS_IGN_COUNT++))
		else
			echo "Downloading $file"
			ilias_request "$file" "-O -J"
			local RESULT=$?
			if [ $RESULT -eq 0 ] ; then
				echo "$file" >> "$HISTORY_FILE"
				((ILIAS_DL_COUNT++))
			else
				echo "Download failed: $RESULT"
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
	echo
}

check_grep_availability