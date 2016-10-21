#!/bin/bash

# Modify directories at the end of this script

# Enter username and password here
ILIAS_USERNAME=st123456
ILIAS_PASSWORD=meinTollesPasswort

# Choose a relative path to store the file in every data directory or an absolute path for one single file
# Keep it like this if you're not sure
HISTORY_FILE=.il-history

# Don't modify
source IliasDownload.sh

do_login

# Insert the folders you want to fetch here.
# Take the id of the folder out of the URL, e.g.
# https://ilias3.uni-stuttgart.de/goto_Uni_Stuttgart_fold_1086607.html
#                                                         ^^^^^^^
# You find this link at the bottom of every folder page.
# Subfolders are automatically downloaded, too.
# You need to use absolute paths for local folders!

# You might preset your home folder like this:
MY_STUDIES_FOLDER="/D/Files/Documents/Studium/Semester 03"

# Schaltungstechnik I
fetch_folder "1086589" "$MY_STUDIES_FOLDER/ST1/Zusatz"
fetch_folder "1086586" "$MY_STUDIES_FOLDER/ST1/UE"
fetch_folder "1086607" "$MY_STUDIES_FOLDER/ST1/Altklausuren"

# Höhere Mathematik III
fetch_folder "1088694" "$MY_STUDIES_FOLDER/HM3/UE"
fetch_folder "1088459" "$MY_STUDIES_FOLDER/HM3/VO"


# Don't modify
do_logout
rm $COOKIE_PATH