$ProgData = $env:PROGRAMDATA
$Docker_Auto_Update_Folder = "$ProgData\Docker_Auto_Update"

$SystemRoot = $env:SystemRoot
$Log_File = "$SystemRoot\Debug\Create_Docker_Auto_Update_Content.log"
$Current_Folder = split-path $MyInvocation.MyCommand.Path
$Service_UI = "$Current_Folder\ServiceUI.exe"
$Path_NSSM = "$Current_Folder\nssm.exe"
$Local_Path_NSSM = "$Docker_Auto_Update_Folder\nssm.exe"
$Update_Warning_Folder = "$Current_Folder\Update_Warning"
$Service_Description = "Update Docker Desktop for Windows"
$Docker_Update_ServiceName = "Docker Desktop Auto Update"
$Auto_Update_Script = "$Current_Folder\Docker_Auto_Update_Script.ps1"
$Remove_Auto_Update_Service = "$Current_Folder\Remove_Docker_Auto_Update_Service.ps1"
$Auto_Update_Notifcations_Script = "$Current_Folder\Toast_Notifications.ps1"

If(test-path $Log_File){Remove-item $Log_File -Recurse -Force}

Function Write_Log
	{
		param(
		$Message_Type,	
		$Message
		)
		
		$MyDate = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)		
		Add-Content $Log_File  "$MyDate - $Message_Type : $Message"			
	}

Write_Log -Message_Type "INFO" -Message "Starting Docker Auto Update process"		
									
Add-content $Log_File ""	
If(test-path $Docker_Auto_Update_Folder){Remove-item $Docker_Auto_Update_Folder -Recurse -Force}

Try
	{
		New-item $Docker_Auto_Update_Folder -Force -Type directory
		Write_Log -Message_Type "SUCCESS" -Message "Following folder has been created: $Docker_Auto_Update_Folder"		
		$Docker_Create_Folder_Status = $True
	}
Catch
	{
		Write_Log -Message_Type "ERROR" -Message "An issue occured while creating the following folder: $Docker_Auto_Update_Folder"		
		$Docker_Create_Folder_Status = $False		
	}
	
Add-content $Log_File ""					
If($Docker_Create_Folder_Status -eq $True)
	{
		Try
			{
				copy-item $Auto_Update_Script $Docker_Auto_Update_Folder -Force						
				copy-item $Path_NSSM $Docker_Auto_Update_Folder -Force			
				copy-item $Service_UI $Docker_Auto_Update_Folder -Force
				copy-item $Update_Warning_Folder $Docker_Auto_Update_Folder -Recurse -Force		
				copy-item $Remove_Auto_Update_Service $Docker_Auto_Update_Folder -Recurse -Force	
				copy-item $Auto_Update_Notifcations_Script $Docker_Auto_Update_Folder -Recurse -Force		
						
				Write_Log -Message_Type "SUCCESS" -Message "Files have been successfully copied in: $Docker_Auto_Update_Folder"		
				$ServiceUI_Copy_Status = $True				
			}
		Catch
			{
				Write_Log -Message_Type "ERROR" -Message "An issue occured while copying files in $Docker_Auto_Update_Folder"		
				$ServiceUI_Copy_Status = $False								
			}
	}
	
Add-content $Log_File ""				
If($ServiceUI_Copy_Status -eq $True)
	{
		$PathPowerShell = (Get-Command Powershell).Source
		$PS1_To_Run = "$Docker_Auto_Update_Folder\Docker_Auto_Update_Script.ps1"
		$ServiceArguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}"' -f $PS1_To_Run
		Try
			{
				& $Local_Path_NSSM install $Docker_Update_ServiceName $PathPowerShell $ServiceArguments
				sleep 5
				Write_Log -Message_Type "SUCCESS" -Message "The $Docker_Update_ServiceName service has been successfully created"	
				$Create_Service_Status = $True								
			}
		Catch
			{
				Write_Log -Message_Type "ERROR" -Message "An issue occured while creating the service $Docker_Update_ServiceName"	
				$Create_Service_Status = $False												
			}	
	}	
	
	
Add-content $Log_File ""				
If($Create_Service_Status -eq $True)
	{
		$PathPowerShell = (Get-Command Powershell).Source
		$PS1_To_Run = "$Docker_Auto_Update_Folder\Docker_Auto_Update_Service.ps1"
		$ServiceArguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}"' -f $PS1_To_Run
		Try
			{
				& $Local_Path_NSSM start $Docker_Update_ServiceName
				& $Local_Path_NSSM set $Docker_Update_ServiceName description $Service_Description	
				Write_Log -Message_Type "SUCCESS" -Message "Starting service $Docker_Update_ServiceName"							
			}
		Catch
			{
				Write_Log -Message_Type "ERROR" -Message "An issue occured while starting service $Docker_Update_ServiceName"																		
			}	
	}	