Param(
		[string]$Type,	
		[string]$Title,					
		[string]$Message			
	 )	 
	 
$Title = $Title.Replace("_"," ")
$Message = $Message.Replace("_"," ")	 
	 
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | out-null
$path = Get-Process -id $pid | Select-Object -ExpandProperty Path            		
$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)    		
$notify = new-object system.windows.forms.notifyicon
$notify.icon = $icon
$notify.visible = $true
$notify.showballoontip(10,$Title,$Message, [system.windows.forms.tooltipicon]::$Type)	


