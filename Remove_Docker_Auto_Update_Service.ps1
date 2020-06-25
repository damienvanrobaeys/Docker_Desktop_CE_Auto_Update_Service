$ProgData = $env:PROGRAMDATA
$Docker_Auto_Update_Folder = "$ProgData\Docker_Auto_Update"
$SystemRoot = $env:SystemRoot
$Log_File = "$SystemRoot\Debug\Uninstall_Docker_Auto_Update_Service.log"
$Local_Path_NSSM = "$Docker_Auto_Update_Folder\nssm.exe"
$Docker_Update_ServiceName = "Docker Desktop Auto Update"
& $Local_Path_NSSM remove $Docker_Update_ServiceName confirm
