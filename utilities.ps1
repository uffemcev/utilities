<#
	Запускать скрипт можно из любого места любым способом, необходимы права администратора

	Скрипт создаёт рабочий каталог Users\Имя Пользователя\uffemcev_utilities, который удаляется после завершения работы скрипта
	
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
	pushd (ni -Force -Path $env:USERPROFILE\uffemcev_utilities -ItemType Directory)
	& ([ScriptBlock]::Create((irm raw.githubusercontent.com/asheroto/winget-installer/master/winget-install.ps1)))
	$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
	popd
	Start-Process powershell "-ExecutionPolicy Bypass `"cd '$pwd'; $o`"" -Verb RunAs
	taskkill /fi "WINDOWTITLE eq initialization"
} else
{
	$host.ui.RawUI.WindowTitle = 'uffemcev utilities'
	cd (ni -Force -Path $env:USERPROFILE\uffemcev_utilities -ItemType Directory)
	cls
}

$data = @(
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
			Expand-Archive '.\Office.zip' '.\'
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
		Description = "GoodbyeDPI with -5 option"
		Name = "dpi"
		Code =
		{
			iwr 'https://github.com/ValdikSS/GoodbyeDPI/releases/latest/download/goodbyedpi-0.2.2.zip' -OutFile '.\goodbyedpi.zip'
			Expand-Archive '.\goodbyedpi.zip' $Env:Programfiles
			dir -Path $Env:Programfiles -Recurse -ErrorAction SilentlyContinue -Force | where {$_ -in '0_russia_update_blacklist_file.cmd','service_install_russia_blacklist.cmd'} | %{ '`n' |& $_.FullName }
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
		Description = "SignalRGB"
		Name = "signal"
		Code =
		{
			winget install --id=WhirlwindFX.SignalRgb --accept-package-agreements --accept-source-agreements --exact --silent
		}
	}
	@{
		Description = "K-Lite Codec Pack Full manual install"
		Name = "codec"
		Code =
		{
			winget install --id=CodecGuide.K-LiteCodecPack.Full --accept-package-agreements --accept-source-agreements --exact --interactive
		}
	}
	@{
		Description = "NVCleanstall manual install"
		Name = "nvidia"
		Code =
		{
			winget install --id=TechPowerUp.NVCleanstall --accept-package-agreements --accept-source-agreements --exact --interactive
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

function install([array]$apps)
{	
	if (!$apps)
	{
		cls
		write-host "`ngithub.com/uffemcev/utilities `n`n[1] YES `n[2] NO`n"
		foreach ($app in $data)
		{
			Write-Host -NoNewline $app.Description
			$button = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
			if ($button.VirtualKeyCode -eq 49) {write-host ' [YES]'; [array]$apps += $app.Name} else {write-host ' [NO]'}
		}
	}
	elseif ($apps[0] -eq 'all')
	{
		$apps = $data.name
	}	
	elseif ($apps[0] -eq 'exit')
	{
		$apps = $null
	}
	
	foreach ($app in $apps) {cls; & ($data | Where Name -eq $app).Code}
	
	cd $env:USERPROFILE
	ri -Recurse -Force $env:USERPROFILE\uffemcev_utilities
	cls
	write-host "`nInstallation complete"
	start-sleep -seconds 5
	taskkill /fi "WINDOWTITLE eq uffemcev utilities"
}

if (!$args)
{
	Write-Host "`ngithub.com/uffemcev/utilities `n`n[1] Select manually `n[2] Install everything `n[3] Exit"
	$button = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	if ($button.VirtualKeyCode -eq 49) {install}
	if ($button.VirtualKeyCode -eq 50) {install all}
	if ($button.VirtualKeyCode -eq 51) {install exit}
} else {install $args}
