@(	
	[pscustomobject]@{
		Description = "MS Office, Word, Excel licensed"
		Name = "msoffice"
		Tag = "system"
		Code = {
			$uri = "https://api.github.com/repos/farag2/Install-Office/releases/latest"
			$get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
			$data = $get.assets | select -first 1      			
      			iwr $data.browser_download_url -Useb -OutFile ".\Office.zip"
			Expand-Archive -ErrorAction 0 -Force ".\Office.zip" ".\"
			$dir = (dir "$pwd\default.xml" -Recurse).DirectoryName
			[xml]$Config = Get-Content -Path "$dir\Default.xml" -Encoding Default -Force
   			$Config.Configuration.Display.Level = "None"
      			$Config.Save("$dir\Default.xml")
			& "$dir\Download.ps1" -Branch O365ProPlusRetail -Channel Current -Components Word, Excel, PowerPoint
   			dir -ErrorAction 0 -Force | where {$_ -match "^Office$"} | Move-Item -Destination $dir
			& "$dir\Install.ps1"
			& ([ScriptBlock]::Create((irm https://get.activated.win))) /KMS-Office /KMS-ActAndRenewalTask /S
		}
	}
 	[pscustomobject]@{
		Description = "OnlyOffice"
		Name = "ooffice"
		Tag = "system"
		Code = {
			$id = "ONLYOFFICE.DesktopEditors"
   			$run = "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
			iex $run
			if (!(Get-WinGetPackage $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}	
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
			if (!(Get-WinGetPackage $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
	[pscustomobject]@{
		Description = "Discord"
		Name = "discord"
		Tag = "games"
		Code = {
			$id = "Discord.Discord"
			$run = "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
			iex $run
			if (!(Get-WinGetPackage $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
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
			if (!(Get-WinGetPackage $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
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
			if (!(Get-WinGetPackage $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
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
			if (!(Get-WinGetPackage $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
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
			if (!(Get-WinGetPackage $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
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
			if (!(Get-WinGetPackage $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
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
			if (!(Get-WinGetPackage $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
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
			if (!(Get-WinGetPackage $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
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
			if (!(Get-WinGetPackage $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
	[pscustomobject]@{
		Description = "Rufus portable"
		Name = "rufus"
		Tag = "other"
		Code = {		
   			$uri = "https://api.github.com/repos/pbatard/rufus/releases/latest"
			$get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop
			$data = $get.assets | select -first 1
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
			$data = $get.assets | select -first 1
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
			while (!(dir -errorAction 0 ".\ConvertConfig.ini")) {start-sleep 1}
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
			while (!(dir -errorAction 0 ".\ISOFOLDER\sources\boot.wim")) {start-sleep 1}
			New-Item -Path ".\mountdir" -ItemType "directory"
			while (!((dism /Get-MountedImageInfo) -match "mountdir")) {
				DISM /Mount-Wim /Quiet /wimfile:.\ISOFOLDER\sources\boot.wim /index:2 /mountdir:.\mountdir
				if ($LASTEXITCODE -ne 0) {
					start-sleep 10
				}
			}
			reg.exe load HKLM\TEMP .\mountdir\Windows\System32\config\SYSTEM
			reg.exe add HKLM\TEMP\Setup /v "CmdLine" /t REG_SZ /d "X:\\sources\\setup.exe" /f
			reg.exe unload HKLM\TEMP
			DISM /Unmount-Wim /mountdir:.\mountdir /commit
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
			if (!(Get-WinGetPackage $id)) {runas /trustlevel:0x20000 /machine:amd64 "$run"}
		}
	}
)
