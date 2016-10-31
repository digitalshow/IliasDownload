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

OCMS_URL="http://www.inm.uni-stuttgart.de/"
OCMS_LOGIN_URL="login/index.html"
OCMS_LOGOUT_URL="login/index.html?logout=true"

ocms_request() {
	curl -s -L -b $COOKIE_PATH -c $COOKIE_PATH $2 $OCMS_URL$1
}

ocms_login() {
	ocms_request "$OCMS_LOGIN_URL" "--data-urlencode user=$OCMS_USER --data-urlencode password=$OCMS_PASSWORD" > /dev/null
	if [ $? -ne 0 ] ; then
		echo "Failed sending login information."
		exit
	fi
	
	echo "Checking if logged in..."
	ocms_request "$OCMS_LOGIN_URL" | grep Angemeldet > /dev/null
	if [ $? -ne 0 ] ; then
		echo "Login page check failed. Is your login information correct?"
		exit
	fi
}

fetch_ocms_file() {
	ocms_request "$1" "-I -f" > /dev/null
	if [ $? -eq 0 ] ; then
		ocms_request "$1" "-O -J"
		echo "File $1 downloaded."
	else
		echo "File $1 could not be downloaded."
	fi
}

ocms_logout() {
	ocms_request $OCMS_LOGOUT_URL "--data-urlencode submit=Abmelden" > /dev/null
}
