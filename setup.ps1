# List of the dir to turn into linked lists
$lib_list = "Videos","Pictures","Music","Documents","Desktop"


# ================================================================
$id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$p = New-Object System.Security.Principal.WindowsPrincipal($id)
if (-Not $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) 
{
	Write-Host "pls run script as admin >: ["
	exit 1
}  
else
{ 
	Write-Host "Setting up Libary Links"
	Foreach ($item in $lib_list)
	{
		if (-Not (Get-Item ~/$item).LinkType -eq "SymbolicLink" )
		{
			Write-Host "Delete Dir: "$item
			if ( (Get-ChildItem ~/$item -ErrorAction SilentlyContinue | Measure-Object).count -eq 0 )
			{
				Remove-Item ~/$item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
			}
			else
			{	
				$dir_backup=$item+"_backup_$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')"
				Write-Host "create backup named $dir_backup"
				
				New-Item ~/$dir_backup -ItemType "directory" | Out-Null
				Move-Item ~/$item/* ~/$dir_backup
				Remove-Item ~/$item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
			}
			
			Write-Host "Create SymbolicLink: "$item
			Write-Host "./Libary/$item"
			New-Item -ItemType SymbolicLink -Path ~/$item -Target ../Libary/$item
		}
	
	}
	
	Write-Host "Created all Libary Links"
	Write-Host "============================"
	
	Write-Host "Installing Winget and import apps"	
	Write-Host "Install Git..."
	winget install Git.Git -h
	
	Write-Host "Downloading Windows10Debloater (https://github.com/Sycnex/Windows10Debloater.git)"
	Remove-Item Windows10Debloater -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
	git clone https://github.com/Sycnex/Windows10Debloater.git
	Write-Host "Run Windows10DebloaterGUI..."
	./Windows10Debloater/Windows10DebloaterGUI.ps1
	Write-Host "Finished Windows10Debloater"
	
	Write-Host "Importing Apps (Unsupported apps get written to non_winget_apps.txt)"
	winget.exe export -o winget_import.json | Set-Content ./non_winget_apps.txt
	exit 0
}
	
