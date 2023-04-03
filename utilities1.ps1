<#
	Запускать скрипт можно из любого места любым способом, необходимы права администратора

	Скрипт создаёт рабочий каталог Users\Имя Пользователя\uffemcev_utilities, который удалется после завершения работы скрипта
	
	Для работы скрипта необходим winget, установить или обновить его можно через соотвествующий параметр

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
	$host.ui.RawUI.WindowTitle = 'NotAdmin'
	$o = $MyInvocation.line
	Start-Process powershell "-ExecutionPolicy Bypass `"cd '$pwd'; $o`"" -Verb RunAs
	taskkill /fi "WINDOWTITLE eq NotAdmin"
} else {$host.ui.RawUI.WindowTitle = 'Admin'}

$ProgressPreference = 'SilentlyContinue'
ri -Recurse -Force $env:USERPROFILE\uffemcev_utilities
cd (ni -Force -Path $env:USERPROFILE\uffemcev_utilities -ItemType Directory)
cls

function install([Array]$a)
{
	if ($a[0] -eq 'all')
	{
		#DON'T FORGET TO ADD A NEW APP TO THE END OF THIS ARRAY
		#НЕ ЗАБУДЬ ДОБАВИТЬ НОВОЕ ПРИЛОЖЕНИЕ В КОНЕЦ ЭТОГО МАССИВА
		$a = 'winget', 'store', 'office', 'spotx', 'dpi', 'directx', 'vcredist', 'chrome', 'discord', 'steam', 'qbit', 'zip', 'gdrive', 'adguard', 'blender', 'signal', 'codec', 'nvidia'
	}

	if ($a[0] -eq 'exit') {$a = '$null'}

	if ($a[0] -eq 'select') {if ((Read-Host 'Winget') -eq 1) {$a += 'winget'}} elseif ($a -eq 'winget')
	{
		& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/asheroto/winget-installer/master/winget-install.ps1)))
	}
	
	if ($a[0] -eq 'select') {if ((Read-Host 'Update store apps') -eq 1) {$a += 'store'}} elseif ($a -eq 'store')
	{
		Get-CimInstance -Namespace 'root\cimv2\mdm\dmmap' -ClassName 'MDM_EnterpriseModernAppManagement_AppManagement01' | Invoke-CimMethod -MethodName UpdateScanMethod
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'Office, Word, Excel 365 mondo volume license') -eq 1) {$a += 'office'}} elseif ($a -eq 'office')
	{
		iwr 'https://github.com/farag2/Office/releases/latest/download/Office.zip' -OutFile '.\Office.zip'
		Expand-Archive '.\Office.zip' '.\'
		pushd '.\Office'
		iex '.\Download.ps1 -Branch O365ProPlusRetail -Channel Current -Components Word, Excel, PowerPoint'
		iex '.\Install.ps1'
		& ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /KMS-Office /KMS-ActAndRenewalTask /S
		popd
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'SpotX spotify modification') -eq 1) {$a += 'spotx'}} elseif ($a -eq 'spotx')
	{
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		iex "& { $((iwr -useb 'https://raw.githubusercontent.com/amd64fox/SpotX/main/Install.ps1').Content) } -premium -new_theme -podcasts_on -block_update_on -cache_on"
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'GoodbyeDPI with -5 option') -eq 1) {$a += 'dpi'}} elseif ($a -eq 'dpi')
	{
		iwr 'https://github.com/ValdikSS/GoodbyeDPI/releases/latest/download/goodbyedpi-0.2.2.zip' -OutFile '.\goodbyedpi.zip'
		Expand-Archive '.\goodbyedpi.zip' $Env:Programfiles
		dir -Path $Env:Programfiles -Recurse -ErrorAction SilentlyContinue -Force | where {$_ -in '0_russia_update_blacklist_file.cmd','service_install_russia_blacklist.cmd'} | %{ '`n' |& $_.FullName }
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'DirectX') -eq 1) {$a += 'directx'}} elseif ($a -eq 'directx')
	{
		winget install --id=Microsoft.DirectX --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'Microsoft Visual C++ 2015-2022') -eq 1) {$a += 'vcredist'}} elseif ($a -eq 'vcredist')
	{
		winget install --id=Microsoft.VCRedist.2015+.x64 --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'Google Chrome') -eq 1) {$a += 'chrome'}} elseif ($a -eq 'chrome')
	{
		winget install --id=Google.Chrome --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'Discord') -eq 1) {$a += 'discord'}} elseif ($a -eq 'discord')
	{
		winget install --id=Discord.Discord --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'Steam') -eq 1) {$a += 'steam'}} elseif ($a -eq 'steam')
	{
		winget install --id=Valve.Steam --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'qBittorrent') -eq 1) {$a += 'qbit'}} elseif ($a -eq 'qbit')
	{
		winget install --id=qBittorrent.qBittorrent --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {if ((Read-Host '7-Zip') -eq 1) {$a += 'zip'}} elseif ($a -eq 'zip')
	{
		winget install --id=7zip.7zip --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'Google Drive') -eq 1) {$a += 'gdrive'}} elseif ($a -eq 'gdrive')
	{
		winget install --id=Google.Drive --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'Adguard') -eq 1) {$a += 'adguard'}} elseif ($a -eq 'adguard')
	{
		winget install --id=AdGuard.AdGuard --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'Blender') -eq 1) {$a += 'blender'}} elseif ($a -eq 'blender')
	{
		winget install --id=BlenderFoundation.Blender --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'SignalRGB') -eq 1) {$a += 'signal'}} elseif ($a -eq 'signal')
	{
		winget install --id=WhirlwindFX.SignalRgb --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'K-Lite Codec Pack Full manual install') -eq 1) {$a += 'codec'}} elseif ($a -eq 'codec')
	{
		winget install --id=CodecGuide.K-LiteCodecPack.Full --accept-package-agreements --accept-source-agreements --exact --interactive
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'NVCleanstall manual install') -eq 1) {$a += 'nvidia'}} elseif ($a -eq 'nvidia')
	{
		winget install --id=TechPowerUp.NVCleanstall --accept-package-agreements --accept-source-agreements --exact --interactive
	}

	#ADD NEW APP
	#ДОБАВИТЬ НОВОЕ ПРИЛОЖЕНИЕ
	#if ($a[0] -eq 'select') {if ((Read-Host 'DESCRIPTION') -eq 1) {$a += 'APP'}} elseif ($a -eq 'APP')
	#{
	#	CODE
	#}
	#DON'T FORGET TO ADD A NEW APP TO AN ARRAY AT THE TOP OF THE SCRIPT
	#НЕ ЗАБУДЬ ДОБАВИТЬ НОВОЕ ПРИЛОЖЕНИЕ В МАССИВ В ВЕРХНЕЙ ЧАСТИ СКРИПТА
	
	if ($a[0] -eq 'select') {$a[0] = $null; cls; install $a} else
	{
		cd $env:USERPROFILE
		ri -Recurse -Force $env:USERPROFILE\uffemcev_utilities
		cls
		write-host "`nInstallation complete"
		start-sleep -seconds 5
		taskkill /fi "WINDOWTITLE eq Admin"
		taskkill /fi "WINDOWTITLE eq NotAdmin"
	}
}

if (!$args) {
$o = Read-Host "`ngithub.com/uffemcev/utilities `n`n0 Select manually `n1 Install everything `n2 Exit`n"
if ($o -eq 0) {cls; write-host "`nSelect manually`n"; install select}
if ($o -eq 1) {cls; write-host "`nInstall everything`n"; install all}
if ($o -eq 2) {cls; install exit}
} else {cls; write-host "`nAuto installation`n"; install $args}
