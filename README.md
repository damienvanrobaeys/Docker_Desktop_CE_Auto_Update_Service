# Auto Update Docker Desktop for Windows with a Windows Service

This allows you to create a Windows Service to Auto update Docker Desktop for Windows even with no admin rights.
The Windows Service will be executed each 5 hours (you can change it)

The service name is: **Docker Desktop Auto Update**
To proceed run the file **Create_Docker_Auto_Update.ps1** with admin rights.

See below what do all scripts:
- Create_Docker_Auto_Update.ps1: Copy content and create the service
- Docker_Auto_Update_Script.ps1: Script that will check for new version and install it
- Remove_Docker_Auto_Update_Service: Remove the auto update service

The auto update script will proceed as below:
- Check new version on the relase web page
- Compare latest available version with this one installed
- If new one is available, it will be installed

> *View the full blog post here*
http://www.systanddeploy.com/2019/06/run-file-in-windows-sandbox-from-right.html
