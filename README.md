IliasDownload.sh
===
This cute little script logs you into ILIAS and downloads all files from directories you chose which weren't downloaded yet.
There's also another file, OpenCmsDownload.sh, to download files from an OpenCms site with authentication. See the IliasDownloadInit.sh script for an example on how to use.

Prerequisites
--
You need a working, current bash, curl and grep with Perl regex support or awk additionally.
If you're on windows, you might want to try [MSYS2](https://msys2.github.io/).

Setup
--
Download both IliasDownload.sh and IliasDownloadInit.sh or clone via git into a directory.
Open IliasDownloadInit.sh in an editor, add your login credentials, specify which folders you need and save the file.

Run
--
Run the script IliasDownloadInit.sh.
```
#Make it runnable
chmod +x IliasDownloadInit.sh
#Run
./IliasDownloadInit.sh
```
or
```
bash IliasDownloadInit.sh
```