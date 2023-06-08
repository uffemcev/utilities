<#
	Запускать скрипт можно из любого места любым способом, необходимы права администратора

	Скрипт создаёт рабочий каталог "Users\Имя Пользователя\uffemcev utilities", который удаляется после завершения работы скрипта
	
	Для работы скрипта необходим winget, при необходимости установится автоматически

	Команды для управления скриптом одинаковы для CMD и PowerShell
	
	Интерактивный выбор компонентов для установки:
	powershell "&([ScriptBlock]::Create((irm uffemcev.github.io/utilities/script.ps1)))"
	
	Автоматическая установка указанных компонентов:
	powershell "&([ScriptBlock]::Create((irm uffemcev.github.io/utilities/script.ps1))) store office chrome"
	
	Автоматическая установка всех компонентов:
	powershell "&([ScriptBlock]::Create((irm uffemcev.github.io/utilities/script.ps1))) all"
#>

#НАЧАЛЬНЫЕ ПАРАМЕТРЫ
[CmdletBinding()]
param([Parameter(ValueFromRemainingArguments=$true)][System.Collections.ArrayList]$apps = @())
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
function cleaner () {$e = [char]27; "$e[H$e[J" + "`nhttps://uffemcev.github.io/utilities`n"}
function color ($text) {$e = [char]27; "$e[7m" + $text + "$e[0m"}
[console]::CursorVisible = $false
cleaner

#ПРОВЕРКА ДУБЛИКАТА
if (Get-Process | where {$_.mainWindowTitle -match "uffemcev utilities|initialization" -and $_.ProcessName -match "powershell|windowsterminal|cmd"})
{
	"App is already running, try again soon"
	start-sleep 5
	exit
}

#ПРОВЕРКА ИНТЕРНЕТА
if (!(Get-NetAdapterStatistics))
{
	"No internet connection, try again soon"
	start-sleep 5
	$host.ui.RawUI.WindowTitle | where {taskkill /fi "WINDOWTITLE eq $_"}
}

#ПРОВЕРКА ПРАВ
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	$MyInvocation.line | where {Start-Process powershell "-ExecutionPolicy Bypass `"cd '$pwd'; $_`"" -Verb RunAs}
	$host.ui.RawUI.WindowTitle | where {taskkill /fi "WINDOWTITLE eq $_"}
}

#ПРОВЕРКА WINGET
if (!(dir -Path ($env:Path -split ';') -ErrorAction SilentlyContinue -Force | where {$_ -in 'winget.exe'}))
{
	start-job {
		cd (ni -Force -Path "$env:USERPROFILE\uffemcev utilities" -ItemType Directory)
		if (!(Get-AppxPackage -allusers Microsoft.DesktopAppInstaller)) {iwr raw.githubusercontent.com/asheroto/winget-installer/master/winget-install.ps1 -Useb | iex}
		Get-AppxPackage -allusers Microsoft.DesktopAppInstaller | where {Add-AppxPackage -ForceApplicationShutdown -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	} | out-null
}

#ПРОВЕРКА TERMINAL
if ((Get-AppxPackage -allusers Microsoft.WindowsTerminal).Version -lt "1.16.10261.0")
{
	start-job {
		cd (ni -Force -Path "$env:USERPROFILE\uffemcev utilities" -ItemType Directory)
		iwr "https://github.com/microsoft/terminal/releases/download/v1.17.11461.0/Microsoft.WindowsTerminal_1.17.11461.0_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip" -Useb -OutFile ".\Terminal.zip"
		Expand-Archive ".\Terminal.zip" ".\"
		Add-AppxPackage -Path ".\1ff951bd438b4b28b40cb1599e7c9f72.msixbundle" -DependencyPath ".\Microsoft.VCLibs.140.00.UWPDesktop_14.0.30704.0_x64__8wekyb3d8bbwe.appx", ".\Microsoft.UI.Xaml.2.7_7.2208.15002.0_x64__8wekyb3d8bbwe.appx"
		Get-AppxPackage -allusers Microsoft.WindowsTerminal | where {Add-AppxPackage -ForceApplicationShutdown -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
	} | out-null
}

#ОЖИДАНИЕ ПРОВЕРОК
if (get-job | where State -eq "Running")
{
	$host.ui.RawUI.WindowTitle = 'initialization'
	"Please stand by"
	get-job | wait-job | out-null
	$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
	$MyInvocation.line | where {Start-Process powershell "-ExecutionPolicy Bypass `"cd '$pwd'; $_`"" -Verb RunAs}
	$host.ui.RawUI.WindowTitle | where {taskkill /fi "WINDOWTITLE eq $_"}
} else
{
	$host.ui.RawUI.WindowTitle = 'uffemcev utilities ' + [char]::ConvertFromUtf32(0x1F916)
	cd (ni -Force -Path "$env:USERPROFILE\uffemcev utilities" -ItemType Directory)
	get-job | remove-job | out-null
}

#ПРИЛОЖЕНИЯ
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
		Description = "Update all apps on pc"
		Name = "update"
		Code =
		{
			winget upgrade --all --silent --accept-source-agreements
			Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod
			(Get-WmiObject -Namespace "Root\cimv2\mdm\dmmap" -Class "MDM_EnterpriseModernAppManagement_AppManagement01").UpdateScanMethod()
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
		Description = "SignalRGB + uffemcev rgb"
		Name = "open"
		Code =
		{
			winget install --id=WhirlwindFX.SignalRgb --accept-package-agreements --accept-source-agreements --exact --silent
			dir -Path $env:LOCALAPPDATA -Recurse | where Name -match "SignalRgbLauncher.exe" | where {$path = Split-Path -Parent $_.FullName}
			pushd $path
			& ([ScriptBlock]::Create((irm uffemcev.github.io/rgb/script.ps1))) -option install -locktime 1800 -sleeptime 3600
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
			$id = ((irm "https://uup.rg-adguard.net/api/GetVersion?id=1").versions | where name -eq $os).UpdateId
			[string]$link = (iwr -Useb -Uri "https://uup.rg-adguard.net/api/GetFiles?id=$id&lang=ru-ru&edition=core&pack=ru&down_aria2=yes").Links.href | where {$_ -match ".cmd"}
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
		Name = "sophia"
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
	@{
		Description = "Trackers links on desktop"
		Name = "tracker"
		Code =
		{
			$sites = 'https://tapochek.net/', 'https://rutracker.org/', 'https://nnmclub.to/'
			$browser = (Get-Item 'HKCU:\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice' | Get-ItemProperty).ProgId -replace ('URL|HTML|HTTP'),('')
			switch ($browser)
			{
				$null {$browser = (dir "C:\Program Files*" -recurse | where Name -eq "msedge.exe").fullname | select -first 1}
				DEFAULT {$browser = (dir "C:\Program Files*" -recurse | where Name -eq "$browser.exe").fullname | select -first 1}
			}
			foreach ($site in $sites)
			{
				$name = $site -replace ('.*.//|\..*'),('')
				$Shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("$env:USERPROFILE\Desktop\$name.lnk")
				$Shortcut.IconLocation = $browser
				$Shortcut.TargetPath = $site
				$Shortcut.Save()
			}
		}
	}
	<#
	НОВОЕ ПРИЛОЖЕНИЕ
	@{
		Description = ""
		Name = ""
		Code =
		{
			
		}
	}
	#>
)

#ПРОВЕРКА НА АРГУМЕНТЫ
if ($apps -contains "all") {$apps = $data.Name; $status = "install"} elseif ($apps) {$status = "install"}

#МЕНЮ
while ($status -ne "install")
{
	#ВЫВОД
	cleaner
	if ($apps) {"[0] Reset"} else {"[0] All"}
	($data | Select @{Name="Description"; Expression={
		if ($_.Name -in $apps) {(color ("[" + ($data.indexof($_)+1) + "]")) + " " + $_.Description}
		else {"[" + ($data.indexof($_)+1) + "] " + $_.Description}
	}} | ft -HideTableHeaders | Out-String).Trim()
	if ($apps) {write-host -nonewline "`n[ENTER] Confirm "} else {write-host -nonewline "`n[ENTER] Exit "}
		
	#ПОДСЧЁТ	
	switch ([console]::ReadKey($true))
	{
		{$_.Key -match "[1-9]"}
		{
			(New-Object -com "Wscript.Shell").sendkeys($_.KeyChar)
			write-host -nonewline "`r[ENTER] Switch "
			$status = read-host
			if ([int]$status -gt 0 -and [int]$status -le $data.count) {if ($data[$status-1].Name -in $apps) {$apps.Remove($data[$status-1].Name)} else {$apps.Add($data[$status-1].Name)}}
			if ($status -eq 0) {if ($apps) {$apps = @()} else {$apps = $data.Name}}
		}
		{$_.Key -eq "D0"} {if ($apps) {$apps = @()} else {$apps = $data.Name}}
		{$_.Key -eq "Enter"} {$status = "install"}
	}
}

#ПРОВЕРКА ВЫХОДА
if ($apps.count -eq 0) {$status = "finish"}

#УСТАНОВКА
while ($status -ne "finish")
{
	for ($i = 0; $i -lt $apps.count+1; $i++)
	{
		#ЗАПУСК
		Get-job | Wait-Job | out-null
		try {($data | Where Name -eq $apps[$i]).Code | where {Start-Job -Name (($data | Where Name -eq $apps[$i]).Description) -Init ([ScriptBlock]::Create("cd '$pwd'")) -ScriptBlock ($_)} | out-null}
		catch {{throw} | where {Start-Job -Name ($apps[$i]) -ScriptBlock ($_)} | out-null}
		
		#ПОДСЧЁТ
		$Processed = [Math]::Round(($i) / $apps.Count * 47,0)
		$Remaining = 47 - $Processed
		$PercentProcessed = [Math]::Round(($i) / $apps.Count * 100,0)
		$table = $apps | foreach {if ($_ -in $data.name) {($data | where Name -eq $_).Description} else {$_}} | Select @{Name="Name"; Expression={$_}}, @{Name="State"; Expression={
			switch ((get-job -name $_).State)
			{
				"Running" {'Running'}
				"Completed" {'Completed'}
				"Failed" {'Failed'}
				DEFAULT {'Waiting'}
			}
		}}
		
		#ВЫВОД
		cleaner
		($table | ft @{Expression={$_.Name}; Width=35; Alignment="Left"}, @{Expression={$_.State}; Width=15; Alignment="Right"} -HideTableHeaders | Out-String).Trim() + "`n"
		(color "$PercentProcessed%") + (color (" " * $Processed)) + (" " * $Remaining)
	}
	start-sleep 5
	$status = "finish"
}

#ЗАВЕРШЕНИЕ РАБОТЫ
cleaner
"Bye, $Env:UserName"
start-sleep 5
cd $env:USERPROFILE
ri -Recurse -Force "$env:USERPROFILE\uffemcev utilities"
$host.ui.RawUI.WindowTitle | where {taskkill /fi "WINDOWTITLE eq $_"}
