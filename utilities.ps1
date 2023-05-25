<#
	Запускать скрипт можно из любого места любым способом, необходимы права администратора

	Скрипт создаёт рабочий каталог "Users\Имя Пользователя\uffemcev utilities", который удаляется после завершения работы скрипта
	
	Для работы скрипта необходим winget, при необходимости установится автоматически

	Команды для управления скриптом одинаковы для CMD и PowerShell
	
	Интерактивный выбор компонентов для установки:
	powershell -ExecutionPolicy Bypass "& ([ScriptBlock]::Create((irm raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1)))"
	powershell -ExecutionPolicy Bypass ".\utilities.ps1"
	
	Автоматическая установка указанных компонентов:
	powershell -ExecutionPolicy Bypass "& ([ScriptBlock]::Create((irm raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1))) store office chrome"
	powershell -ExecutionPolicy Bypass ".\utilities.ps1 store office chrome"
	
	Автоматическая установка всех компонентов:
	powershell -ExecutionPolicy Bypass "& ([ScriptBlock]::Create((irm raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1))) all"
	powershell -ExecutionPolicy Bypass ".\utilities.ps1 all"
#>

[CmdletBinding()]
param([Parameter(ValueFromRemainingArguments=$true)][System.Collections.ArrayList]$apps = @())

if (Get-Process | where {$_.mainWindowTitle -match "uffemcev|initialization" -and $_.ProcessName -eq "powershell"})
{
	cls
	"`nApp is already running"
	start-sleep -seconds 5
	$host.ui.RawUI.WindowTitle | where {taskkill /fi "WINDOWTITLE eq $_"}
} elseif (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	$host.ui.RawUI.WindowTitle = 'initialization'
	$MyInvocation.line | where {Start-Process powershell "-ExecutionPolicy Bypass `"cd '$pwd'; $_`"" -Verb RunAs}
	$host.ui.RawUI.WindowTitle | where {taskkill /fi "WINDOWTITLE eq $_"}
} elseif (!(dir -Path ($env:Path -split ';') -ErrorAction SilentlyContinue -Force | where {$_ -in 'winget.exe'}))
{
	$host.ui.RawUI.WindowTitle = 'initialization'
	pushd (ni -Force -Path "$env:USERPROFILE\uffemcev utilities" -ItemType Directory)
	if (!(Get-AppxPackage -allusers Microsoft.DesktopAppInstaller)) {iwr raw.githubusercontent.com/asheroto/winget-installer/master/winget-install.ps1 -Useb | iex}
	Get-AppxPackage -allusers Microsoft.DesktopAppInstaller | where {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
	popd
	$MyInvocation.line | where {Start-Process powershell "-ExecutionPolicy Bypass `"cd '$pwd'; $_`"" -Verb RunAs}
	$host.ui.RawUI.WindowTitle | where {taskkill /fi "WINDOWTITLE eq $_"}
} else
{
	$host.ui.RawUI.WindowTitle = 'uffemcev utilities'
	cd (ni -Force -Path "$env:USERPROFILE\uffemcev utilities" -ItemType Directory)
	Add-Type -AssemblyName System.Windows.Forms
	cls
}

$data = @(
	@{
		Description = "Cloudflare DNS-over-HTTPS"
		Name = "dns"
		Code =
		{
			$ips = '1.1.1.1', '1.0.0.1', '2606:4700:4700::1111', '2606:4700:4700::1001'
			$doh = "https://cloudflare-dns.com/dns-query"
			foreach ($ip in $ips) {
    				Add-DnsClientDohServerAddress -errorAction SilentlyContinue -ServerAddress $ip -DohTemplate $doh
    				Get-NetAdapter -Physical | ForEach-Object {
        				Set-DnsClientServerAddress $_.InterfaceAlias -ServerAddresses $ips
        				if ($ip -match '\.') {$path = "HKLM:System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\" + $_.InterfaceGuid + "\DohInterfaceSettings\Doh\$ip"}
        				if ($ip -match ':') {$path = "HKLM:System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\" + $_.InterfaceGuid + "\DohInterfaceSettings\Doh6\$ip"}
        				New-Item -Path $path -Force | New-ItemProperty -Name "DohFlags" -Value 1 -PropertyType QWORD
    				}
			}
			New-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name 'EnableAutoDoh' -Value 2 -PropertyType DWord -Force
			Clear-DnsClientCache
		}
	}
	@{
		Description = "Update store apps"
		Name = "store"
		Code =
		{
			Get-CimInstance -Namespace 'root\cimv2\mdm\dmmap' -ClassName 'MDM_EnterpriseModernAppManagement_AppManagement01' | Invoke-CimMethod -MethodName UpdateScanMethod
		}
	}
	@{
		Description = "Office, Word, Excel 365 mondo volume license"
		Name = "office"
		Code =
		{
			iwr 'https://github.com/farag2/Office/releases/latest/download/Office.zip' -Useb -OutFile '.\Office.zip'
			Expand-Archive -ErrorAction SilentlyContinue -Force '.\Office.zip' '.\'
			pushd '.\Office'
			(gc '.\Default.xml').replace('Display Level="Full"', 'Display Level="None"') | sc '.\Default.xml'
			iex '.\Download.ps1 -Branch O365ProPlusRetail -Channel Current -Components Word, Excel, PowerPoint'
			iex '.\Install.ps1'
			& ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /KMS-Office /KMS-ActAndRenewalTask /S
			popd
		}
	}
	@{
		Description = "SpotX spotify modification"
		Name = "spotx"
		Code =
		{
			[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
			iex "& { $((iwr -useb 'https://raw.githubusercontent.com/amd64fox/SpotX/main/Install.ps1').Content) } -premium -new_theme -podcasts_on -block_update_on"
		}
	}
	@{
		Description = "GoodbyeDPI mode 5 + blacklist update"
		Name = "dpi"
		Code =
		{
			iwr 'https://github.com/ValdikSS/GoodbyeDPI/releases/latest/download/goodbyedpi-0.2.2.zip' -Useb -OutFile '.\goodbyedpi.zip'
			Expand-Archive -ErrorAction SilentlyContinue -Force '.\goodbyedpi.zip' $Env:Programfiles
			dir -Path $Env:Programfiles -ErrorAction SilentlyContinue -Force | where {$_ -match 'goodbyedpi*'} | where {$dir = $_.FullName}
			"`n" |& "$dir\service_install_russia_blacklist.cmd"
			(iwr "https://reestr.rublacklist.net/api/v3/domains" -Useb) -split '", "' -replace ('[\[\]"]'), ('') | sc "$dir\russia-blacklist.txt"
		}
	}
	@{
		Description = "DirectX"
		Name = "directx"
		Code =
		{
			winget install --id=Microsoft.DirectX --accept-package-agreements --accept-source-agreements --exact --silent
		}
	}
	@{
		Description = "Microsoft Visual C++ 2015-2022"
		Name = "vcredist"
		Code =
		{
			winget install --id=Microsoft.VCRedist.2015+.x64 --accept-package-agreements --accept-source-agreements --exact --silent
		}
	}
	@{
		Description = "Google Chrome"
		Name = "chrome"
		Code =
		{
			winget install --id=Google.Chrome --accept-package-agreements --accept-source-agreements --exact --silent
		}
	}
	@{
		Description = "Discord"
		Name = "discord"
		Code =
		{
			winget install --id=Discord.Discord --accept-package-agreements --accept-source-agreements --exact --silent
		}
	}
	@{
		Description = "Steam"
		Name = "steam"
		Code =
		{
			winget install --id=Valve.Steam --accept-package-agreements --accept-source-agreements --exact --silent
		}
	}
	@{
		Description = "qBittorrent"
		Name = "qbit"
		Code =
		{
			winget install --id=qBittorrent.qBittorrent --accept-package-agreements --accept-source-agreements --exact --silent
		}
	}
	@{
		Description = "7-Zip"
		Name = "zip"
		Code =
		{
			winget install --id=7zip.7zip --accept-package-agreements --accept-source-agreements --exact --silent
		}
	}
	@{
		Description = "Google Drive"
		Name = "gdrive"
		Code =
		{
			winget install --id=Google.Drive --accept-package-agreements --accept-source-agreements --exact --silent
		}
	}
	@{
		Description = "Adguard"
		Name = "adguard"
		Code =
		{
			winget install --id=AdGuard.AdGuard --accept-package-agreements --accept-source-agreements --exact --silent
		}
	}
	@{
		Description = "Blender"
		Name = "blender"
		Code =
		{
			winget install --id=BlenderFoundation.Blender --accept-package-agreements --accept-source-agreements --exact --silent
		}
	}
	@{
		Description = "OpenRGB + uffemcev rgb"
		Name = "open"
		Code =
		{
			iwr 'https://github.com/uffemcev/rgb/releases/download/0.81/OpenRGB.zip' -Useb -OutFile '.\OpenRGB.zip'
			Expand-Archive -ErrorAction SilentlyContinue -Force '.\OpenRGB.zip' $env:APPDATA
			dir -Path $env:APPDATA -ErrorAction SilentlyContinue -Force -Recurse | where {$_ -match 'OpenRGB.exe'} | where {$file = $_.FullName}
			$Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:USERPROFILE\Desktop\OpenRGB.lnk")
			$Shortcut.TargetPath = "powershell.exe"
			$Shortcut.IconLocation = $file
			$Shortcut.Arguments = "-WindowStyle hidden `"start-process $file `"--noautoconnect`"`" -Verb RunAs"
			$Shortcut.Save()
			pushd (Split-Path -Parent $file)
			& ([ScriptBlock]::Create((irm raw.githubusercontent.com/uffemcev/rgb/main/rgb.ps1))) -option install -locktime 1800 -sleeptime 3600
			popd
		}
	}
	@{
		Description = "K-Lite Codec Pack Full manual setup"
		Name = "codec"
		Code =
		{
			winget install --id=CodecGuide.K-LiteCodecPack.Full --accept-package-agreements --accept-source-agreements --exact --interactive
		}
	}
	@{
		Description = "NVCleanstall manual setup"
		Name = "nvidia"
		Code =
		{
			winget install --id=TechPowerUp.NVCleanstall --accept-package-agreements --accept-source-agreements --exact --interactive
		}
	}
	@{
		Description = "Windows 11 22H2 iso folder"
		Name = "win"
		Code =
		{
			$os = "Windows 11, version 22H2 [x64]"
			$apps = "WindowsStore", "Purchase", "VCLibs", "Photos", "Notepad", "Terminal", "Installer"
			$options = "AutoStart", "AddUpdates", "Cleanup", "ResetBase", "SkipISO", "SkipWinRE", "CustomList", "AutoExit"
			$id = ((irm "https://uup.rg-adguard.net/api/GetVersion?id=1").versions | Select-String -SimpleMatch $os) -replace ('@{UpdateId=|;.*$'),('')
			[string]$link = (iwr -Useb -Uri "https://uup.rg-adguard.net/api/GetFiles?id=$id&lang=ru-ru&edition=core&pack=ru&down_aria2=yes").Links.href | Select-String -SimpleMatch ".cmd"
			iwr $link -Useb -OutFile '.\download-UUP.cmd'
			iwr 'https://github.com/uup-dump/containment-zone/raw/master/7zr.exe' -Useb -OutFile '.\7zr.exe'
			iwr 'https://github.com/uup-dump/containment-zone/raw/master/uup-converter-wimlib.7z' -Useb -OutFile '.\uup.7z'
			.\7zr.exe x *.7z
			(gc ".\download-UUP.cmd") -replace ('^set "destDir.*$'), ('set "destDir=UUPs"') -replace ('pause'), ('') | sc ".\download-UUP.cmd"
			(gc ".\ConvertConfig.ini") -replace (' '), ('') | sc ".\ConvertConfig.ini"
			(gc ".\CustomAppsList.txt") -replace ('^\w'), ('# $&') | sc ".\CustomAppsList.txt"
			foreach ($app in $apps)
			{
				$file = (gc ".\CustomAppsList.txt") -split "# " | Select-String -Pattern $app
				((gc '.\CustomAppsList.txt') -replace ("# " + $file), ($file)) | sc '.\CustomAppsList.txt'
			}
			foreach ($option in $options)
			{
				((gc '.\ConvertConfig.ini') -replace ("^" + $option + "=0"), ($option + "=1")) | sc '.\ConvertConfig.ini'
			}
			iex ".\download-UUP.cmd"
			iex ".\convert-UUP.cmd"
			dir -ErrorAction SilentlyContinue -Force | where {$_ -match '^*.X64.*$'} | mi -Destination ([Environment]::GetFolderPath("Desktop"))
		}
	}
	@{
		Description = "Rufus"
		Name = "rufus"
		Code =
		{
			iwr "https://github.com/pbatard/rufus/releases/download/v4.0/rufus-4.0p.exe" -Useb -OutFile ([Environment]::GetFolderPath("Desktop") + ".\rufus.exe")
		}
	}
	@{
		Description = "SophiApp Tweaker"
		Name = "sophi"
		Code =
		{
			iwr "https://github.com/Sophia-Community/SophiApp/releases/download/1.0.94/SophiApp.zip" -Useb -OutFile ".\SophiApp.zip"
			Expand-Archive -ErrorAction SilentlyContinue -Force ".\SophiApp.zip" $Env:Programfiles
			dir -Path $Env:Programfiles -ErrorAction SilentlyContinue -Force -Recurse | where {$_ -match '^SophiApp.exe$'} | where {$file = $_.FullName}
			$Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:USERPROFILE\Desktop\SophiApp.lnk")
			$Shortcut.TargetPath = $file
			$Shortcut.Save()
		}
	}
	<#
	НОВОЕ ПРИЛОЖЕНИЕ
	NEW APP
	@{
		Description = ""
		Name = ""
		Code =
		{
			
		}
	}
	#>
)

if ($apps -contains "all") {$apps = $data.Name; $b = "install"} elseif ($apps) {$b = "install"}

#МЕНЮ
[console]::WindowHeight = $data.count + 7
[console]::WindowWidth = 54
[console]::BufferWidth = [console]::WindowWidth

while ($b -ne "install")
{
	#ВЫВОД
	"`ngithub.com/uffemcev/utilities`n"
	if ($apps) {"[0] Reset"} else {"[0] Select all"}
	for ($i = 0; $i -lt $data.count; $i++)
	{
		if ($data[$i].Name -in $apps) {"$([char]27)[7m[" + ($i+1) + "]$([char]27)[0m " + $data[$i].Description}
		if ($data[$i].Name -notin $apps) {"[" + ($i+1) + "] " + $data[$i].Description}
	}
	if ($apps) {write-host -nonewline "`n[ENTER] Confirm "} else {write-host -nonewline "`n[ENTER] Exit "}
		
	#ПОДСЧЁТ	
	switch ([console]::ReadKey($true))
	{
		{$_.Key -match "[1-9]"}
		{
			[System.Windows.Forms.SendKeys]::SendWait($_.KeyChar)
			write-host -nonewline "`r[ENTER] Select "
			$b = read-host
			if ($b -gt 0) {if ($data[$b-1].Name -in $apps) {$apps.Remove($data[$b-1].Name)} else {$apps.Add($data[$b-1].Name)}}
			if ($b -eq 0) {if ($apps) {$apps = @()} else {$apps = $data.Name}}
		}
		
		{$_.Key -eq "D0"} {if ($apps) {$apps = @()} else {$apps = $data.Name}}
		
		{$_.Key -eq "Enter"} {$b = "install"}
	}
	cls
}

#УСТАНОВКА
for ($i = 0; $i -lt $apps.count; $i++)
{
	try {($data | Where Name -eq $apps[$i]).Code | where {Start-Job -Name ("[" + ($i+1) + "] " + ($data | Where Name -eq $apps[$i]).Description) -ScriptBlock $_} | out-null}
	catch {{throw} | where {Start-Job -Name ("[" + ($i+1) + "] " + $apps[$i]) -ScriptBlock $_} | out-null}	
}

#ПРОГРЕСС
[console]::WindowHeight = $apps.count + 5
[console]::WindowWidth = 54
[console]::BufferWidth = [console]::WindowWidth
[System.Collections.ArrayList]$counter = @()
$LoadSign = "="
$EmptySign = " "

While ($true)
{
	[Console]::SetCursorPosition(0,0)
	get-job | foreach {if (($_.State -ne "Running") -and ($_.Name -notin $counter)) {[void]$counter.Add($_.Name)}}
	$Processed = [Math]::Round(($counter.count) / $apps.Count * 46,0)
	$Remaining = 46 - $Processed
	$PercentProcessed = [Math]::Round(($counter.count) / $apps.Count * 100,0)
	get-job | ft @{Expression={$_.Name}; Width=35; Alignment="Left"}, @{Expression={$_.State}; Width=16; Alignment="Right"} -HideTableHeaders
	"$PercentProcessed% ["+ ($LoadSign * $Processed) + ($EmptySign * $Remaining) + "]"
	if (!(Get-Job -State "Running")) {break}
	Start-Sleep 1
}

Start-sleep -seconds 5
cd $env:USERPROFILE
ri -Recurse -Force "$env:USERPROFILE\uffemcev utilities"
$host.ui.RawUI.WindowTitle | where {taskkill /fi "WINDOWTITLE eq $_"}
