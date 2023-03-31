<#
	Запускать скрипт можно из любого места любым способом, но для его работы необходимы права администратора

	Скрипт создаёт рабочую папку по пути Users\USER\uffemcev_utilities, которая удалется после завершения работы скрипта

	Скрипт понимает нолики, единички и enter:
	enter - ввод значения / пропуск пункта
	0 - нет
	1 - да
	
	Для работы встроенного функционала winget на свежей системе необходимо обновить его в ms store вручную или через параметр store

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

ri -Recurse -Force $env:USERPROFILE\uffemcev_utilities
cd (ni -Force -Path $env:USERPROFILE\uffemcev_utilities -ItemType Directory)
cls

function install([Array]$a)
{
	if ($a[0] -eq 'all')
	{
		#ADD YOUR APP TO THE END OF AN ARRAY
		#ДОБАВЬ СВОЕ ПРИЛОЖЕНИЕ В КОНЕЦ МАССИВА
		$a = 'store', 'office', 'spotx', 'dpi', 'directx', 'vcredist', 'chrome', 'discord', 'steam', 'qbit', 'zip', 'gdrive', 'adguard', 'blender', 'signal', 'codec', 'nvidia'
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'Update store apps') -eq 1) {$a += 'store'}} elseif ($a -eq 'store')
	{
		Get-CimInstance -Namespace 'root\cimv2\mdm\dmmap' -ClassName 'MDM_EnterpriseModernAppManagement_AppManagement01' | Invoke-CimMethod -MethodName UpdateScanMethod
	}

	if ($a[0] -eq 'select') {if ((Read-Host 'Office, Word, Excel 365 mondo volume license') -eq 1) {$a += 'office'}} elseif ($a -eq 'office')
	{
		iwr 'https://github.com/farag2/Office/releases/latest/download/Office.zip' -OutFile '.\Office.zip'
		Expand-Archive '.\Office.zip' '.\'
		ri -Force '.\Office.zip'
		pushd '.\Office'
		iex '.\Download.ps1 -Branch O365ProPlusRetail -Channel Current -Components Word, Excel, PowerPoint'
		iex '.\Install.ps1'
		& ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /KMS-Office /KMS-ActAndRenewalTask /S
		popd
		ri -Recurse -Force '.\Office'
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
		ri -Force '.\goodbyedpi.zip'
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
	#DO NOT FORGET ABOUT 1ST COMMENT
	#НЕ ЗАБУДЬ ПРО ПЕРВЫЙ КОММЕНТАРИЙ
	
	if ($a[0] -eq 'select') {$a[0] = $null; install $a} else
	{
		cd $env:USERPROFILE
		ri -Recurse -Force $env:USERPROFILE\uffemcev_utilities
		cls
		write-host "`nInstallation complete"
		start-sleep -seconds 5
		exit 
	}
}

if (!$args) {
$o = Read-Host "`ngithub.com/uffemcev/utilities `n`n1 install everything `n0 select manually`n"
if ($o -eq 0) {install select}
if ($o -eq 1) {install all}
} else {install $args}
