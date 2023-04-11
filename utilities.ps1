<#
	Запускать скрипт можно из любого места любым способом, необходимы права администратора

	Скрипт создаёт рабочий каталог Users\Имя Пользователя\uffemcev_utilities, который удалется после завершения работы скрипта
	
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

function press([string]$description, [string]$name)
{
	Write-Host -NoNewline "`n$description"
	$button = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	if ($button.VirtualKeyCode -eq 49) {write-host ' [YES]'; $Global:a += "$name"} else {write-host ' [NO]'}
}

function install([array]$Global:a)
{	
	if ($a[0] -eq 'all')
	{
		#DON'T FORGET TO ADD A NEW APP TO THE END OF THIS ARRAY
		#НЕ ЗАБУДЬ ДОБАВИТЬ НОВОЕ ПРИЛОЖЕНИЕ В КОНЕЦ ЭТОГО МАССИВА
		$a = 'store', 'office', 'spotx', 'dpi', 'directx', 'vcredist', 'chrome', 'discord', 'steam', 'qbit', 'zip', 'gdrive', 'adguard', 'blender', 'signal', 'codec', 'nvidia'
	}

	if ($a[0] -eq 'exit') {$a = '$null'}
	
	if ($a[0] -eq 'select') {press 'Update store apps' 'store'} elseif ($a -eq 'store')
	{
		Get-CimInstance -Namespace 'root\cimv2\mdm\dmmap' -ClassName 'MDM_EnterpriseModernAppManagement_AppManagement01' | Invoke-CimMethod -MethodName UpdateScanMethod
	}

	if ($a[0] -eq 'select') {press 'Office, Word, Excel 365 mondo volume license' 'office'} elseif ($a -eq 'office')
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

	if ($a[0] -eq 'select') {press 'SpotX spotify modification' 'spotx'} elseif ($a -eq 'spotx')
	{
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		iex "& { $((iwr -useb 'https://raw.githubusercontent.com/amd64fox/SpotX/main/Install.ps1').Content) } -premium -new_theme -podcasts_on -block_update_on -cache_on"
	}

	if ($a[0] -eq 'select') {press 'GoodbyeDPI with -5 option' 'dpi'} elseif ($a -eq 'dpi')
	{
		iwr 'https://github.com/ValdikSS/GoodbyeDPI/releases/latest/download/goodbyedpi-0.2.2.zip' -OutFile '.\goodbyedpi.zip'
		Expand-Archive '.\goodbyedpi.zip' $Env:Programfiles
		dir -Path $Env:Programfiles -Recurse -ErrorAction SilentlyContinue -Force | where {$_ -in '0_russia_update_blacklist_file.cmd','service_install_russia_blacklist.cmd'} | %{ '`n' |& $_.FullName }
	}

	if ($a[0] -eq 'select') {press 'DirectX' 'directx'} elseif ($a -eq 'directx')
	{
		winget install --id=Microsoft.DirectX --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {press 'Microsoft Visual C++ 2015-2022' 'vcredist'} elseif ($a -eq 'vcredist')
	{
		winget install --id=Microsoft.VCRedist.2015+.x64 --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {press 'Google Chrome' 'chrome'} elseif ($a -eq 'chrome')
	{
		winget install --id=Google.Chrome --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {press 'Discord' 'discord'} elseif ($a -eq 'discord')
	{
		winget install --id=Discord.Discord --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {press 'Steam' 'steam'} elseif ($a -eq 'steam')
	{
		winget install --id=Valve.Steam --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {press 'qBittorrent' 'qbit'} elseif ($a -eq 'qbit')
	{
		winget install --id=qBittorrent.qBittorrent --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {press '7-Zip' 'zip'} elseif ($a -eq 'zip')
	{
		winget install --id=7zip.7zip --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {press 'Google Drive' 'gdrive'} elseif ($a -eq 'gdrive')
	{
		winget install --id=Google.Drive --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {press 'Adguard' 'adguard'} elseif ($a -eq 'adguard')
	{
		winget install --id=AdGuard.AdGuard --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {press 'Blender' 'blender'} elseif ($a -eq 'blender')
	{
		winget install --id=BlenderFoundation.Blender --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {press 'SignalRGB' 'signal'} elseif ($a -eq 'signal')
	{
		winget install --id=WhirlwindFX.SignalRgb --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {press 'K-Lite Codec Pack Full manual install' 'codec'} elseif ($a -eq 'codec')
	{
		winget install --id=CodecGuide.K-LiteCodecPack.Full --accept-package-agreements --accept-source-agreements --exact --interactive
	}

	if ($a[0] -eq 'select') {press 'NVCleanstall manual install' 'nvidia'} elseif ($a -eq 'nvidia')
	{
		winget install --id=TechPowerUp.NVCleanstall --accept-package-agreements --accept-source-agreements --exact --interactive
	}

	<# ADD NEW APP
	ДОБАВИТЬ НОВОЕ ПРИЛОЖЕНИЕ
	if ($a[0] -eq 'select') {press 'DESCRIPTION' 'APP'} elseif ($a -eq 'APP')
	{
		CODE
	}
	DON'T FORGET TO ADD A NEW APP TO AN ARRAY AT THE TOP OF THE SCRIPT
	НЕ ЗАБУДЬ ДОБАВИТЬ НОВОЕ ПРИЛОЖЕНИЕ В МАССИВ В ВЕРХНЕЙ ЧАСТИ СКРИПТА #>
	
	if ($a[0] -eq 'select') {$a[0] = $null; cls; install $a} else
	{
		cd $env:USERPROFILE
		ri -Recurse -Force $env:USERPROFILE\uffemcev_utilities
		cls
		write-host "`nInstallation complete"
		start-sleep -seconds 5
		taskkill /fi "WINDOWTITLE eq uffemcev utilities"
	}
}

if (!$args)
{
	Write-Host "`ngithub.com/uffemcev/utilities `n`n[1] Select manually `n[2] Install everything `n[3] Exit"
	$button = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")
	if ($button.VirtualKeyCode -eq 49) {cls; write-host "`ngithub.com/uffemcev/utilities `n`n[1] YES `n[2] NO"; install select}
	if ($button.VirtualKeyCode -eq 50) {cls; install all}
	if ($button.VirtualKeyCode -eq 51) {cls; install exit}
} else {cls; install $args}
