@(
	[pscustomobject]@{
		Description = "Cloudflare DOH"
		Name = "dns"
		Tag = "Tweaks"
		Code = {
			$ips = '1.1.1.1', '1.0.0.1', '2606:4700:4700::1111', '2606:4700:4700::1001'
			$doh = "https://cloudflare-dns.com/dns-query"
			foreach ($ip in $ips) {
    				Add-DnsClientDohServerAddress -errorAction 0 -ServerAddress $ip -DohTemplate $doh
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
	[pscustomobject]@{
		Description = "Office, Word, Excel licensed"
		Name = "office"
		Tag = "Programs"
		Code = {
			iwr 'https://github.com/farag2/Office/releases/latest/download/Office.zip' -Useb -OutFile '.\Office.zip'
			Expand-Archive -ErrorAction 0 -Force '.\Office.zip' '.\'
			pushd '.\Office'
			(gc '.\Default.xml').replace('Display Level="Full"', 'Display Level="None"') | sc '.\Default.xml'
			iex '.\Download.ps1 -Branch O365ProPlusRetail -Channel Current -Components Word, Excel, PowerPoint'
			iex '.\Install.ps1'
			& ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /KMS-Office /KMS-ActAndRenewalTask /S
			popd
		}
	}
	[pscustomobject]@{
		Description = "SpotX"
		Name = "spotx"
		Tag = "Programs"
		Code = {
			[Net.ServicePointManager]::SecurityProtocol = 3072
   			iex "& { $(iwr -useb 'https://spotx-official.github.io/run.ps1') } -premium -new_theme -podcasts_on -block_update_on"
		}
	}
	[pscustomobject]@{
		Description = "GoodbyeDPI mode 5"
		Name = "dpi"
		Tag = "Tweaks"
		Code = {
			$uri = "https://api.github.com/repos/ValdikSS/GoodbyeDPI/releases/latest"
			$get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
			$data = $get.assets | Where-Object name -match "goodbyedpi.*.zip$" | select -first 1
   			iwr $data.browser_download_url -Useb -OutFile '.\goodbyedpi.zip'
			Expand-Archive -ErrorAction 0 -Force '.\goodbyedpi.zip' $Env:Programfiles
			dir -Path $Env:Programfiles -ErrorAction 0 -Force | where {$_ -match 'goodbyedpi*'} | where {$dir = $_.FullName}
			"`n" |& "$dir\service_install_russia_blacklist.cmd"
			(iwr "https://reestr.rublacklist.net/api/v3/domains" -Useb) -split '", "' -replace ('[\[\]"]'), ('') | sc "$dir\russia-blacklist.txt"
		}
	}
	[pscustomobject]@{
		Description = "Google Chrome"
		Name = "chrome"
		Tag = "Programs"
		Code = {
			$id = "Google.Chrome"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "Discord"
		Name = "discord"
		Tag = "Programs"
		Code = {
			$id = "Discord.Discord"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "Steam"
		Name = "steam"
		Tag = "Programs"
		Code = {
			$id = "Valve.Steam"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "qBittorrent"
		Name = "qbit"
		Tag = "Programs"
		Code = {
			$id = "qBittorrent.qBittorrent"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "7-Zip"
		Name = "zip"
		Tag = "Programs"
		Code = {
			$id = "7zip.7zip"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "Google Drive"
		Name = "gdrive"
		Tag = "Programs"
		Code = {
			$id = "Google.GoogleDrive"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "Adguard"
		Name = "adguard"
		Tag = "Programs"
		Code = {
			$id = "AdGuard.AdGuard"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "SignalRGB"
		Name = "signal"
		Tag = "Programs"
		Code = {
			$id = "WhirlwindFX.SignalRgb"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "K-Lite Codec Pack Full"
		Name = "codec"
		Tag = "Programs"
		Code = {
			$id = "CodecGuide.K-LiteCodecPack.Full"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "NVCleanstall"
		Name = "nvidia"
		Tag = "System"
		Code = {
			$id = "TechPowerUp.NVCleanstall"
			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"}
		}
	}
	[pscustomobject]@{
		Description = "Rufus portable"
		Name = "rufus"
		Tag = "Other"
		Code = {
			$uri = "https://api.github.com/repos/pbatard/rufus/releases/latest"
			$get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
			$data = $get.assets | Where-Object name -match "rufus.*.exe$" | select -first 1
   			iwr $data.browser_download_url -Useb -OutFile ([Environment]::GetFolderPath("Desktop") + ".\rufus.exe")
		}
	}
	[pscustomobject]@{
		Description = "SophiApp Tweaker portable"
		Name = "sophia"
		Tag = "Tweaks"
		Code = {
			$uri = "https://api.github.com/repos/Sophia-Community/SophiApp/releases/latest"
			$get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
			$data = $get.assets | Where-Object name -match "SophiApp.zip" | select -first 1
   			iwr $data.browser_download_url -Useb -OutFile ".\SophiApp.zip"
			Expand-Archive -ErrorAction 0 -Force ".\SophiApp.zip" ([Environment]::GetFolderPath("Desktop"))
		}
	}
	[pscustomobject]@{
		Description = "Win 11 23H2 iso folder"
		Name = "win"
		Tag = "Other"
		Code = {
			$apps = "WindowsStore", "Purchase", "VCLibs", "Photos", "Notepad", "Terminal", "Installer"
			$options = "AutoStart", "AddUpdates", "Cleanup", "ResetBase", "SkipISO", "SkipWinRE", "CustomList", "AutoExit"
			$id = (irm "https://api.uupdump.net/fetchupd.php?arch=amd64&ring=retail&build=22631.1").response.updateId
			iwr -Useb -Uri "https://uupdump.net/get.php?id=$id&pack=ru-ru&edition=core" -Method "POST" -Body "autodl=2" -OutFile '.\UUP.zip'
			Expand-Archive -ErrorAction 0 -Force '.\UUP.zip' '.\'
			(gc ".\ConvertConfig.ini") -replace (' '), ('') | sc ".\ConvertConfig.ini"
			foreach ($option in $options) {
				((gc '.\ConvertConfig.ini') -replace ("^" + $option + "=0"), ($option + "=1")) | sc '.\ConvertConfig.ini'
			}
			start-job -Name ("UUP") -Init ([ScriptBlock]::Create("cd '$pwd'")) -ScriptBlock {iex ".\uup_download_windows.cmd"}			
			while (!(dir -errorAction 0 "CustomAppsList.txt")) {start-sleep 1}
			(gc ".\CustomAppsList.txt") -replace ('^\w'), ('# $&') | sc ".\CustomAppsList.txt"
			foreach ($app in $apps) {
				$file = (gc ".\CustomAppsList.txt") -split "# " | Select-String -Pattern $app
				((gc '.\CustomAppsList.txt') -replace ("# " + $file), ($file)) | sc '.\CustomAppsList.txt'
			}
			get-job -errorAction 0 -name UUP | wait-job
			dir -ErrorAction 0 -Force | where {$_ -match '^*.X64.*$'} | mi -Destination ([Environment]::GetFolderPath("Desktop"))
		}
	}
)
