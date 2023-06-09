#НАЧАЛЬНЫЕ ПАРАМЕТРЫ
[CmdletBinding()]
param([Parameter(ValueFromRemainingArguments=$true)][System.Collections.ArrayList]$apps = @())
function cleaner () {$e = [char]27; "$e[H$e[J" + "`nhttps://uffemcev.github.io/utilities`n"}
function color ($text) {$e = [char]27; "$e[7m" + $text + "$e[0m"}
[console]::CursorVisible = $false
cleaner

#ПРОВЕРКА ДУБЛИКАТА
if (Get-Process | where {$_.mainWindowTitle -match "uffemcev utilities|initialization" -and $_.ProcessName -match "powershell|windowsterminal|cmd"})
{
	"Script is already running"
	start-sleep 5
	(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {taskkill /PID $_}
}

#ПРОВЕРКА ИНТЕРНЕТА
if (!(Get-NetAdapterStatistics))
{
	"No internet connection"
	start-sleep 5
	(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {taskkill /PID $_}
}

#ПРОВЕРКА ПОЛИТИК
if ((Get-ExecutionPolicy) -ne "Bypass")
{
	Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
}

#ПРОВЕРКА ПРАВ
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	try {Start-Process wt "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'\; $($MyInvocation.line -replace (";"),("\;"))}" -Verb RunAs}
	catch {Start-Process conhost "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'; $($MyInvocation.line)}" -Verb RunAs}
	(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {taskkill /PID $_}
}

#ПРОВЕРКА WINGET
if (!(dir -Path ($env:Path -split ';') | where Name -match 'winget.exe'))
{
	start-job {
		cd (ni -Force -Path "$env:USERPROFILE\uffemcev utilities" -ItemType Directory)
		if (!(Get-AppxPackage -allusers Microsoft.DesktopAppInstaller)) {&([ScriptBlock]::Create((irm raw.githubusercontent.com/asheroto/winget-installer/master/winget-install.ps1)))}
		Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
	} | out-null
}

#ПРОВЕРКА TERMINAL
if ((Get-AppxPackage -allusers Microsoft.WindowsTerminal).Version -lt "1.16.10261.0")
{
	start-job {
		while ($true) {try {winget | out-null; break} catch {start-sleep 1}}
		winget install --id=Microsoft.WindowsTerminal --accept-package-agreements --accept-source-agreements --exact --silent
	} | out-null
}

#ОЖИДАНИЕ ПРОВЕРОК
if (get-job | where State -eq "Running")
{
	$host.ui.RawUI.WindowTitle = 'initialization'
	"Please stand by"
	get-job | wait-job | out-null
	$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
	try {Start-Process wt "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'\; $($MyInvocation.line -replace (";"),("\;"))}" -Verb RunAs}
	catch {Start-Process conhost "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'; $($MyInvocation.line)}" -Verb RunAs}
	(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {taskkill /PID $_}
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
			$uri = "https://api.github.com/repos/ValdikSS/GoodbyeDPI/releases/latest"
			$get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
			$data = $get.assets | Where-Object name -match "goodbyedpi.*.zip$" | select -first 1
   			iwr $data.browser_download_url -Useb -OutFile '.\goodbyedpi.zip'
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
			$id = "Google.Chrome"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {throw; exit}
		}
	}
	@{
		Description = "Discord"
		Name = "discord"
		Code =
		{
			$id = "Discord.Discord"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {throw; exit}
		}
	}
	@{
		Description = "Steam"
		Name = "steam"
		Code =
		{
			$id = "Valve.Steam"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {throw; exit}
		}
	}
	@{
		Description = "qBittorrent"
		Name = "qbit"
		Code =
		{
			$id = "qBittorrent.qBittorrent"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {throw; exit}
		}
	}
	@{
		Description = "7-Zip"
		Name = "zip"
		Code =
		{
			$id = "7zip.7zip"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {throw; exit}
		}
	}
	@{
		Description = "Google Drive"
		Name = "gdrive"
		Code =
		{
			$id = "Google.Drive"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {throw; exit}
		}
	}
	@{
		Description = "Adguard"
		Name = "adguard"
		Code =
		{
			$id = "AdGuard.AdGuard"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {throw; exit}
		}
	}
	@{
		Description = "Blender"
		Name = "blender"
		Code =
		{
			$id = "BlenderFoundation.Blender"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {throw; exit}
		}
	}
	@{
		Description = "SignalRGB + uffemcev rgb"
		Name = "open"
		Code =
		{
			$id = "WhirlwindFX.SignalRgb"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {throw; exit}
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
			$id = "CodecGuide.K-LiteCodecPack.Full"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --interactive
			if (!((winget list) -match $id)) {throw; exit}
		}
	}
	@{
		Description = "NVCleanstall manual setup"
		Name = "nvidia"
		Code =
		{
			$id = "TechPowerUp.NVCleanstall"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --interactive
			if (!((winget list) -match $id)) {throw; exit}
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
		Description = "Rufus portable"
		Name = "rufus"
		Code =
		{
			$uri = "https://api.github.com/repos/pbatard/rufus/releases/latest"
			$get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
			$data = $get.assets | Where-Object name -match "rufus.*.exe$" | select -first 1
   			iwr $data.browser_download_url -Useb -OutFile ([Environment]::GetFolderPath("Desktop") + ".\rufus.exe")
		}
	}
	@{
		Description = "SophiApp Tweaker portable"
		Name = "sophia"
		Code =
		{
			$uri = "https://api.github.com/repos/Sophia-Community/SophiApp/releases/latest"
			$get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
			$data = $get.assets | Where-Object name -match "SophiApp.zip" | select -first 1
   			iwr $data.browser_download_url -Useb -OutFile ".\SophiApp.zip"
			Expand-Archive -ErrorAction SilentlyContinue -Force ".\SophiApp.zip" ([Environment]::GetFolderPath("Desktop"))
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
	$table = $data | Select @{Name="Description"; Expression={
		if ($_.Name -in $apps) {(color ("[" + ($data.indexof($_)+1) + "]")) + " " + $_.Description}
		else {"[" + ($data.indexof($_)+1) + "] " + $_.Description}
	}}
	($table | ft -HideTableHeaders | Out-String).Trim()
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
		try {Start-Job -Name (($data | Where Name -eq $apps[$i]).Description) -Init ([ScriptBlock]::Create("cd '$pwd'")) -ScriptBlock $(($data | Where Name -eq $apps[$i]).Code) | out-null}
		catch {Start-Job -Name ($apps[$i]) -ScriptBlock {throw} | out-null}
		
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
cd \
ri -Recurse -Force "$env:USERPROFILE\uffemcev utilities"
(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {taskkill /PID $_}
