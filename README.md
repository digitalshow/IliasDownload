IliasDownload.sh
===
This cute little script logs you into ILIAS and downloads all files from directories you chose which weren't downloaded yet.

Prerequisites
--
You need a working, current bash and curl.
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