$SystemRoot = $env:SystemRoot
$Log_File_Full = "$SystemRoot\Debug\Update_Docker_Full_Log.log"
$Log_File = "$SystemRoot\Debug\Docker_Update.log"
$Appli_name = "Docker for Windows"
If(!(test-path $Log_File)){new-item $Log_File -type file -force}
$Global:Current_Folder = split-path $MyInvocation.MyCommand.Path
Function Write_Log
	{
		param(
		$Message_Type,	
		$Message
		)
		
		$MyDate = "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)		
		Add-Content $Log_File  "$MyDate - $Message_Type : $Message"			
	}

Function Run_Docker_Update_Check
	{				
		Write_Log -Message_Type "INFO" -Message "Starting $Appli_name update process"											

		$New_Version_available = $False
		$Docker_Reg_Path = "HKLM:\software\microsoft\windows\currentversion\uninstall\Docker desktop"

		Function Get_Info_Beetween_Strings
			{
				[CmdletBinding()]
				Param
					(
						[Parameter(Mandatory=$false)]	
						[string]$version
					)	
				$Check_Pattern = ">(.*?)</a>"
				$Get_Info = ([regex]::match($version, $Check_Pattern).Groups[1].Value).Trim()
				Return $Get_Info
			}

		If(Test-Path $Docker_Reg_Path)
			{
				$Get_Current_Docker_Version = (Get-ItemProperty -Path "HKLM:\software\microsoft\windows\currentversion\uninstall\Docker desktop").displayversion
				$Current_Docker_CE_Version = "docker desktop community $Get_Current_Docker_Version"
				$Release_Notes_Page = "https://docs.docker.com/docker-for-windows/release-notes/"
				$Get_Docker_CE_Versions = ((Invoke-WebRequest -Uri $Release_Notes_Page -UseBasicParsing).links | Where {$_.outerhtml -like "*docker desktop community*"}).outerhtml
				$Get_Latest_CE_Version = $Get_Docker_CE_Versions[0]
				$Docker_available_Version = Get_Info_Beetween_Strings -version $Get_Latest_CE_Version
				If($Docker_available_Version -gt $Current_Docker_CE_Version)
					{
						Write_Log -Message_Type "INFO" -Message "A new version of $Appli_name is available"	
						Write_Log -Message_Type "INFO" -Message "This version is: $Docker_available_Version"		
						$New_Version_available = $True
					}				

				If($New_Version_available -eq $True)
					{
						Try
							{
								Write_Log -Message_Type "INFO" -Message "Waiting for user validation"									
								& "$Current_Folder\ServiceUI.exe" -process:explorer.exe C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe " -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File $Current_Folder\Update_Warning\Upgrade_Process.ps1"								
								Write_Log -Message_Type "INFO" -Message "User ha validated the docker update"	
								$Run_Update_Status = $True
							}
						Catch
							{
								$Run_Update_Status = $False
							}
							
						If($Run_Update_Status -eq $True)
							{
								$New_Version_Download_Status = $False
								$Temp_Folder = $env:temp
								$New_Docker_Version_Path = "$Temp_Folder\Docker_Desktop_Installer.exe"
								$Docker_Installer_Link = "https://download.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
								Write_Log -Message_Type "INFO" -Message "The new version will be downloaded"	
												
								Try
									{
										
										$Download_EXE = new-object -typename system.net.webclient
										$Download_EXE.Downloadfile($Docker_Installer_Link,$New_Docker_Version_Path)									
										$New_Version_Download_Status = $True
										Write_Log -Message_Type "SUCCESS" -Message "The new version of $Appli_name has been successfully downloaded"							
									}
								Catch
									{
										$New_Version_Download_Status = $False
										Write_Log -Message_Type "ERROR" -Message "An issue occured while downloading the new version of $Appli_name"							
									}							
							}

					}
				Else
					{
						Write_Log -Message_Type "INFO" -Message "There is no new version for $Appli_name"						
					}

				If(($New_Version_Download_Status -eq $True) -and ($Run_Update_Status -eq $True))
					{
						Write_Log -Message_Type "INFO" -Message "The new version will be installed"	
						
						Try 
						{
							start-process -FilePath $New_Docker_Version_Path -ArgumentList "install --quiet" -RedirectStandardOutput $Log_File_Full -Wait	
							Write_Log -Message_Type "SUCCESS" -Message "The new version of $Appli_name has been successfully installed"							
						}
						Catch 
						{
							Write_Log -Message_Type "ERROR" -Message "An issue occured while installing the new version of $Appli_name"													
						}		
					}	
			}
		Else
			{
				Write_Log -Message_Type "ERROR" -Message "$Appli_name is not installed on your computer"																
			}
	}
	
	
while($true){
	Run_Docker_Update_Check
	Write_Log -Message_Type "INFO" -Message "Docker Desktop auto update will sleep for 5 hours"		
	Add-content $Log_File ""					
	Start-Sleep -Seconds 18000
}	

		