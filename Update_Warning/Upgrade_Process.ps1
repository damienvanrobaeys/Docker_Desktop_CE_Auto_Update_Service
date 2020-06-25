Param(
		[string]$Version_Installed,		
		[string]$Version_Available			
	 )	 
	 
$Version_Available = $Version_Available.split(" ")[-1]	 

$Global:Current_Folder = split-path $MyInvocation.MyCommand.Path

Function Show_WPF_Message
{
	[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  				| out-null
	[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
	[System.Reflection.Assembly]::LoadFrom("$Current_Folder\assembly\MahApps.Metro.dll")       				| out-null
	[System.Reflection.Assembly]::LoadFrom("$Current_Folder\assembly\MahApps.Metro.IconPacks.dll")      | out-null  

	function LoadXml ($global:filename)
	{
		$XamlLoader=(New-Object System.Xml.XmlDocument)
		$XamlLoader.Load($filename)
		return $XamlLoader
	}

	$XamlMainWindow=LoadXml("$Current_Folder\Upgrade_Warning.xaml")

	$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
	$Form=[Windows.Markup.XamlReader]::Load($Reader)

	$Logo_CM = $Form.findname("Logo_CM") 
	$Label_Close = $Form.findname("Label_Close") 
	$Message_Part1 = $Form.findname("Message_Part1") 
	$Message_Part2 = $Form.findname("Message_Part2") 	
	$Logo_Picture = $Form.findname("Logo_Picture") 
	$Main_Title = $Form.findname("Main_Title") 
	$Block_Header = $Form.findname("Block_Header") 
	$Block_Logo = $Form.findname("Block_Logo") 
	$Header_Image = $Form.findname("Header_Image") 
	$Docker_Warning = $Form.findname("Docker_Warning") 
	$Update_Docker = $Form.findname("Update_Docker") 
	$Installed_Version = $Form.findname("Installed_Version") 
		
	$XML_Config = "$Current_Folder\Warning_Config.xml"
	[xml]$Get_Config = get-content $XML_Config
	$Form.Title = $Get_Config.Config.GUI_Title
	$Get_Logo_Picture = $Get_Config.Config.Logo_File
	$Get_StatusBar_Text = $Get_Config.Config.GUI_StatusBar
	
	$Message_Part1.Text = $Get_Config.Config.Text_Part1
	$Message_Part2.Text = $Get_Config.Config.Text_Part2
	$Main_Title.Content = $Get_Config.Config.Title
	$Label_Close.Content = $Get_Config.Config.GUI_StatusBar	
	$Logo_Type = $Get_Config.Config.Image_Type
	
	$Docker_Warning.Text = $Get_Config.Config.Media_Warning
	$Docker_Warning.FontWeight = "Bold"
	$Docker_Warning.Foreground = "Red"
		
	$Installed_Version.Text = "Current version is: $Version_Installed - New version is: $Version_Available"
	
	$Update_Docker.Add_Click({
		$Form.Close()
	})

	
	If($Logo_Type -eq "Header")
		{
			$Block_Header.Visibility = "Visible"
			$Block_Logo.Visibility = "Collapsed"	
			$Header_Image.Width = $Form.Width
			$Header_Image.Source = "$Current_Folder\images\$Get_Logo_Picture"
			
		}
	Else
		{
			$Block_Header.Visibility = "Collapsed"
			$Block_Logo.Visibility = "Visible"	
			$Logo_Picture.Source = "$Current_Folder\images\$Get_Logo_Picture"		
			
		}	
	$Form.ShowDialog() | Out-Null
}

Show_WPF_Message
