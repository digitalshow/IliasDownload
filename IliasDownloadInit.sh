#!/bin/bash

# Modify directories at the end of this script

# Enter ILIAS username and password here
ILIAS_USERNAME=st123456
ILIAS_PASSWORD=meinTollesPasswort

# Enter OpenCMS username and password here (if you want to use)
OCMS_USER=studierende
OCMS_PASSWORD=seinTollesPasswort

# Choose a relative path to store the file in every data directory or an absolute path for one single file
# Keep it like this if you're not sure
HISTORY_FILE=.il-history

# Don't modify
source IliasDownload.sh
source OpenCmsDownload.sh

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

# Steuerungstechnik mit Antriebstechnik
fetch_folder "1088620" "$MY_STUDIES_FOLDER/STAT"


# Don't modify
do_logout
print_stat

#ocms_login

# OpenCMS downloads for TM3 on INM of Uni Stuttgart
# Uncomment everything with ocms_ (also above) if you want to use.
#cd "$MY_STUDIES_FOLDER/TM3"
#fetch_ocms_file "lehre/vorlesungsunterlagen/tmIII/Aufgabensammlung_tmIII.pdf"
#fetch_ocms_file "lehre/vorlesungsunterlagen/tmIII/muloe_tmIII_1.pdf"
#fetch_ocms_file "lehre/vorlesungsunterlagen/tmIII/muloe_tmIII_2.pdf"
#fetch_ocms_file "lehre/vorlesungsunterlagen/tmIII/muloe_tmIII_3.pdf"
#fetch_ocms_file "lehre/vorlesungsunterlagen/tmIII/muloe_tmIII_4.pdf"
#fetch_ocms_file "lehre/vorlesungsunterlagen/tmIII/muloe_tmIII_5.pdf"
#fetch_ocms_file "lehre/vorlesungsunterlagen/tmIII/muloe_tmIII_6.pdf"
#fetch_ocms_file "lehre/vorlesungsunterlagen/tmIII/Arbeitsunterlagen_inm_tmIII.pdf"

# Don't modify
#ocms_logout
rm $COOKIE_PATH
