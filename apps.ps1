@(
  	[pscustomobject]@{
		Description = "Adguard DOH"
		Name = "adns"
		Tag = "tweaks"
		Code = {
			$ips = "94.140.14.14", "94.140.15.15", "2a10:50c0::ad1:ff", "2a10:50c0::ad2:ff"
			$doh = "https://dns.adguard-dns.com/dns-query/"
			foreach ($ip in $ips) {
    				Add-DnsClientDohServerAddress -errorAction 0 -ServerAddress $ip -DohTemplate $doh
    				Get-NetAdapter -Physical | ForEach-Object {
        				Set-DnsClientServerAddress $_.InterfaceAlias -ServerAddresses $ips
        				if ($ip -match "\.") {$path = "HKLM:System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\" + $_.InterfaceGuid + "\DohInterfaceSettings\Doh\$ip"}
        				if ($ip -match ":") {$path = "HKLM:System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\" + $_.InterfaceGuid + "\DohInterfaceSettings\Doh6\$ip"}
        				New-Item -Path $path -Force | New-ItemProperty -Name "DohFlags" -Value 1 -PropertyType QWORD
    				}
			}
			New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" -Name "EnableAutoDoh" -Value 2 -PropertyType DWord -Force
			Clear-DnsClientCache
		}
	}	
	[pscustomobject]@{
		Description = "Office, Word, Excel licensed"
		Name = "office"
		Tag = "system"
		Code = {
			iwr "https://github.com/farag2/Office/releases/latest/download/Officer.zip" -Useb -OutFile ".\Office.zip"
			Expand-Archive -ErrorAction 0 -Force ".\Office.zip" ".\"
			$dir = "$pwd\Office"
			[xml]$Config = Get-Content -Path "$dir\Default.xml" -Encoding Default -Force
   			$Config.Configuration.Display.Level = "None"
      			$Config.Save("$dir\Default.xml")
			& "$dir\Download.ps1" -Branch O365ProPlusRetail -Channel Current -Components Word, Excel, PowerPoint
			& "$dir\Install.ps1"
			& ([ScriptBlock]::Create((irm https://get.activated.win))) /KMS-Office /KMS-ActAndRenewalTask /S
		}
	}
	[pscustomobject]@{
		Description = "SpotX - modified Spotify app"
		Name = "spotx"
		Tag = "audio"
		Code = {
	 		[Net.ServicePointManager]::SecurityProtocol = 3072
      			iex "& { $(iwr -useb 'https://spotx-official.github.io/run.ps1') } -premium -new_theme -podcasts_on -block_update_on -sp-uninstall"
		}
	}
	[pscustomobject]@{
		Description = "Google Chrome"
		Name = "chrome"
		Tag = "web"
		Code = {
			$id = "Google.Chrome"
   			$run = "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
			iex $run
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
	[pscustomobject]@{
		Description = "Vencord - modified Discord app"
		Name = "vencord"
		Tag = "audio"
		Code = {
			$id = "Vendicated.Vencord"
			$run = "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
			iex $run
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
	[pscustomobject]@{
		Description = "Steam"
		Name = "steam"
		Tag = "games"
		Code = {
			$id = "Valve.Steam"
			$run = "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
			iex $run
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
	[pscustomobject]@{
		Description = "qBittorrent"
		Name = "qbit"
		Tag = "storage"
		Code = {
			$id = "qBittorrent.qBittorrent"
   			$run = "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
			iex $run
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
	[pscustomobject]@{
		Description = "7-Zip"
		Name = "zip"
		Tag = "system"
		Code = {
			$id = "7zip.7zip"
   			$run = "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
			iex $run
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
	[pscustomobject]@{
		Description = "Google Drive"
		Name = "gdrive"
		Tag = "storage"
		Code = {
			$id = "Google.GoogleDrive"
   			$run = "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
			iex $run
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
	[pscustomobject]@{
		Description = "Adguard"
		Name = "adguard"
		Tag = "web"
		Code = {
			$id = "AdGuard.AdGuard"
   			$run = "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
			iex $run
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
	[pscustomobject]@{
		Description = "SignalRGB"
		Name = "signal"
		Tag = "games"
		Code = {
			$id = "WhirlwindFX.SignalRgb"
   			$run = "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
			iex $run
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
	[pscustomobject]@{
		Description = "K-Lite Codec Pack Full"
		Name = "codec"
		Tag = "video"
		Code = {
			$id = "CodecGuide.K-LiteCodecPack.Full"
   			$run = "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
			iex $run
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
	[pscustomobject]@{
		Description = "NVCleanstall"
		Name = "nvcleanstall"
		Tag = "system"
		Code = {
			$id = "TechPowerUp.NVCleanstall"
   			$run = "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
			iex $run
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
	[pscustomobject]@{
		Description = "Rufus portable"
		Name = "rufus"
		Tag = "other"
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
		Tag = "tweaks"
		Code = {
			$uri = "https://api.github.com/repos/Sophia-Community/SophiApp/releases/latest"
			$get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
			$data = $get.assets | Where-Object name -match "SophiApp.zip" | select -first 1
   			iwr $data.browser_download_url -Useb -OutFile ".\SophiApp.zip"
			Expand-Archive -ErrorAction 0 -Force ".\SophiApp.zip" ([Environment]::GetFolderPath("Desktop"))
		}
	}
	[pscustomobject]@{
		Description = "Win 11 24H2 iso"
		Name = "win"
		Tag = "other"
		Code = {
			$apps = "WindowsStore", "Purchase", "VCLibs", "Photos", "Notepad", "Terminal", "Installer"
			$options = "AutoStart", "AddUpdates", "Cleanup", "ResetBase", "wim2esd", "SkipWinRE", "CustomList", "AutoExit"
			while (!(dir -errorAction 0 ".\UUP.zip")) {
				try {
					$id = ((irm "https://api.uupdump.net/fetchupd.php?arch=amd64&ring=retail&build=26100.1&pack=ru-ru").response.updateArray | Where updateTitle -match "^Windows 11.*$" | Sort -Descending -Property foundBuild | Select -First 1).updateId
     					start-sleep 10
     					iwr -Useb -Uri "https://uupdump.net/get.php?id=$id&pack=ru-ru&edition=core" -Method "POST" -Body "autodl=2" -OutFile ".\UUP.zip"
				} catch {
					start-sleep 10
				}
			}
			Expand-Archive -ErrorAction 0 -Force ".\UUP.zip" ".\"
			(Get-Content ".\ConvertConfig.ini") -replace (" "), ("") | Set-Content ".\ConvertConfig.ini"
			foreach ($option in $options) {
				((Get-Content ".\ConvertConfig.ini") -replace ("^" + $option + "=0"), ($option + "=1")) | Set-Content ".\ConvertConfig.ini"
			}
			Start-Job -Name ("UUP") -Init ([ScriptBlock]::Create("cd '$pwd'")) -ScriptBlock {& ".\uup_download_windows.cmd"}			
			while (!(dir -errorAction 0 ".\CustomAppsList.txt")) {start-sleep 1}
			(Get-Content ".\CustomAppsList.txt") -replace ("^\w"), ("# $&") | Set-Content ".\CustomAppsList.txt"
			foreach ($app in $apps) {
				$file = (Get-Content ".\CustomAppsList.txt") -split "# " | Select-String -Pattern $app
				if ($file) {((Get-Content ".\CustomAppsList.txt") -replace ("# " + $file), ($file)) | Set-Content ".\CustomAppsList.txt"}
			}
			Get-Job -errorAction 0 -name UUP | Wait-Job
			dir -ErrorAction 0 -Force | where {$_ -match "^*.X64.*$"} | Move-Item -Destination ([Environment]::GetFolderPath("Desktop"))
		}
	}
	[pscustomobject]@{
		Description = "MSEdgeRedirect"
		Name = "redirect"
		Tag = "tweaks"
		Code = {
			$id = "rcmaehl.MSEdgeRedirect"
   			$run = "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
			iex $run
			if (!((winget list) -match $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
 	[pscustomobject]@{
		Description = "NV Updater"
		Name = "nvupdater"
		Tag = "system"
		Code = {
			$uri = "https://www.sys-worx.net/filebase/file/11-nv-updater-nvidia-driver-updater/#versions"
   			$data = iwr -Useb -Uri "https://www.sys-worx.net/filebase/file/11-nv-updater-nvidia-driver-updater/#versions"
      			$download = ($data.Links | select-string -pattern ".zip" | select -first 1) -match '[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)'
	 		iwr -Useb -Uri $matches[0] -OutFile ".\NV Updater.zip"
    			Expand-Archive -ErrorAction 0 -Force ".\NV Updater.zip" "$Env:Programfiles\NV Updater"
       			$dir = (dir -Path $Env:Programfiles -ErrorAction 0 -Force | where {$_ -match "NV Updater*"}).FullName
	 		& "$dir\nv_updater.exe"
		}
	}
)
