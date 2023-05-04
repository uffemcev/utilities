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

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	$host.ui.RawUI.WindowTitle = 'initialization'
	$o = $MyInvocation.line
	Start-Process powershell "-ExecutionPolicy Bypass `"cd '$pwd'; $o`"" -Verb RunAs
	taskkill /fi "WINDOWTITLE eq initialization"
} elseif (!(dir -Path ($env:Path -split ';') -ErrorAction SilentlyContinue -Force | where {$_ -in 'winget.exe'}))
{
	$host.ui.RawUI.WindowTitle = 'initialization'
	$o = $MyInvocation.line
	pushd (ni -Force -Path "$env:USERPROFILE\uffemcev utilities" -ItemType Directory)
	& ([ScriptBlock]::Create((irm raw.githubusercontent.com/asheroto/winget-installer/master/winget-install.ps1)))
	$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
	popd
	Start-Process powershell "-ExecutionPolicy Bypass `"cd '$pwd'; $o`"" -Verb RunAs
	taskkill /fi "WINDOWTITLE eq initialization"
} else
{
	$host.ui.RawUI.WindowTitle = 'uffemcev utilities'
	cd (ni -Force -Path "$env:USERPROFILE\uffemcev utilities" -ItemType Directory)
	cls
}

$data = @(
	@{
		Description = "Cloudflare DNS-over-HTTPS"
		Name = "dns"
		Code =
		{
			Get-NetAdapter -Physical | ForEach-Object {
				Set-DnsClientServerAddress $_.InterfaceAlias -ServerAddresses ("1.1.1.1","1.0.0.1","2606:4700:4700::1111","2606:4700:4700::1001")
				$path = 'HKLM:System\CurrentControlSet\Services\Dnscache\InterfaceSpecificParameters\' + $_.InterfaceGuid + '\DohInterfaceSettings'
				New-Item -Path $path\Doh\1.1.1.1 -Force | New-ItemProperty -Name "DohFlags" -Value 1 -PropertyType QWORD
				New-Item -Path $path\Doh\1.0.0.1 -Force | New-ItemProperty -Name "DohFlags" -Value 1 -PropertyType QWORD
				New-Item -Path $path\Doh6\2606:4700:4700::1111 -Force | New-ItemProperty -Name "DohFlags" -Value 1 -PropertyType QWORD
				New-Item -Path $path\Doh6\2606:4700:4700::1001 -Force | New-ItemProperty -Name "DohFlags" -Value 1 -PropertyType QWORD
			}
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
			iwr 'https://github.com/farag2/Office/releases/latest/download/Office.zip' -OutFile '.\Office.zip'
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
			iex "& { $((iwr -useb 'https://raw.githubusercontent.com/amd64fox/SpotX/main/Install.ps1').Content) } -premium -new_theme -podcasts_on -block_update_on -cache_on"
		}
	}
	@{
		Description = "GoodbyeDPI mode 5 + blacklist update"
		Name = "dpi"
		Code =
		{
			iwr 'https://github.com/ValdikSS/GoodbyeDPI/releases/latest/download/goodbyedpi-0.2.2.zip' -OutFile '.\goodbyedpi.zip'
			Expand-Archive -ErrorAction SilentlyContinue -Force '.\goodbyedpi.zip' $Env:Programfiles
			dir -Path $Env:Programfiles -ErrorAction SilentlyContinue -Force | where {$_ -match 'goodbyedpi*'} | %{$dir = $_.FullName}
			'`n' |& "$dir\service_install_russia_blacklist.cmd"
			write-host "`nBlacklist updating process`n"
			for ($i = 1; $i -lt 6; $i++)
			{   
    				try
				{
        				write-host -NoNewline "Attempt $i of 5"
        				iwr "https://antizapret.prostovpn.org/domains-export.txt" -OutFile "$dir\russia-blacklist.txt"
					write-host ": success"
        				break
    				} catch
				{
        				write-host ": server not responding"
        				Start-Sleep -Seconds 1
    				}
			}
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
			iwr 'https://github.com/uffemcev/OpenRGB/releases/download/0.81/OpenRGB.zip' -OutFile '.\OpenRGB.zip'
			Expand-Archive -ErrorAction SilentlyContinue -Force '.\OpenRGB.zip' $env:APPDATA
			& ([ScriptBlock]::Create((irm raw.githubusercontent.com/uffemcev/rgb/main/rgb.ps1)))
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

function install([System.Collections.ArrayList]$apps = @())
{	
	if ($apps -contains "all") {$apps = $data.Name; $button = "install"} elseif ($apps) {$button = "install"}
	
	while ($button -ne "install")
	{
		"`ngithub.com/uffemcev/utilities`n"

		for ($i = 0; $i -lt $data.count; $i++)
		{
			if ($data[$i].Name -in $apps)
			{
				"$([char]27)[7m[" + ($i+1) + "]$([char]27)[0m " + $data[$i].Description
			} else
			{
				"[" + ($i+1) + "] " + $data[$i].Description
			}
		}
		
		if ($apps) {$number = "Confirm"} else {$number = "Exit"}
		$button = read-host "`n[ENTER] $number [R] Reset [A] All"
		
		for ($i = 0; $i -lt $data.count; $i++)
		{
			switch ($button)
			{
				($i+1) {if ($data[$i].Name -in $apps) {$apps.Remove($data[$i].Name)} else {$apps.Add($data[$i].Name)}}
				"R" {$apps = @()}
				"A" {$apps = $data.Name}
				"" {$button = "install"}
			}
		}
		cls
	}
	
	for ($i = 0; $i -lt $apps.count; $i++)
	{
		Write-Progress -Activity "   Installing" -Status (($data | Where Name -eq $apps[$i]).Description) -PercentComplete ($i * (100 / $apps.count))
		$null = & ($data | Where Name -eq $apps[$i]).Code
	}
	
	Write-Progress -Activity "   Installation" -Status "complete"
	cd $env:USERPROFILE
	ri -Recurse -Force "$env:USERPROFILE\uffemcev utilities"
	start-sleep -seconds 5
	taskkill /fi "WINDOWTITLE eq uffemcev utilities"
}

if (!$args) {install} else {install $args}
