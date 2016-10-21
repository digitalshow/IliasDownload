IliasDownload.sh
===
This cute little script logs you into ILIAS and downloads all files from directories you chose which weren't downloaded yet.

Prerequisites
--
You need a working, current bash and curl.
If you're on windows, you might want to try [MSYS2](https://msys2.github.io/).

Setup
--
Download both IliasDownload.sh and IliasDownload-Init.sh or clone via git into a directory.
Open IliasDownload-Init.sh in an editor, add your login credentials, specify which folders you need and save the file.

Run
--
Run the script IliasDownload-Init.sh.
```
#Make it runnable
chmod +x IliasDownload-Init.sh
#Run
./IliasDownload-Init.sh
```
or
```
bash IliasDownload.sh
```