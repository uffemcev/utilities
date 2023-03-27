<#
	Скрипт понимает только нолики, единички и enter:
	enter - ввод / пропуск
	0 - нет
	1 - да
	
	Для работы встроенного функционала winget на свежей системе необходимо обновить его в ms store вручную или через параметр -store
	
	Ручной выбор компонентов для установки:
	powershell -command "Set-ExecutionPolicy Bypass -Scope Process -Force; &{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); manual}"
	powershell -command "Set-ExecutionPolicy Bypass -Scope Process -Force; &{. .\utilities.ps1; manual}"
	&{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); manual}
	&{. .\utilities.ps1; manual}
	
	Автоматическая установка указанных компонентов:
	powershell -command "Set-ExecutionPolicy Bypass -Scope Process -Force; &{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); auto -store -office -chrome}"
	powershell -command "Set-ExecutionPolicy Bypass -Scope Process -Force; &{. .\utilities.ps1; auto -store -office -chrome}"
	&{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); auto -store -office -chrome}
	&{. .\utilities.ps1; auto -store -office -chrome}
	
	Автоматическая установка всех компонентов:
	powershell -command "Set-ExecutionPolicy Bypass -Scope Process -Force; &{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); auto -all}"
	powershell -command "Set-ExecutionPolicy Bypass -Scope Process -Force; &{. .\utilities.ps1; auto -all}"
	&{iex (iwr https://raw.githubusercontent.com/uffemcev/utilities/main/utilities.ps1); auto -all}
	&{. .\utilities.ps1; auto -all}
#>
function manual
{
	$Number = Read-Host "github.com/uffemcev/utilities `n1 install everything `n0 select manually`n"
	if ($Number -eq 0) {choose}
	if ($Number -eq 1) {$all = $True; run}
}

function auto
{
	param
	(
		[switch]$all,
		[switch]$store,
		[switch]$office,
		[switch]$spotx,
		[switch]$dpi,
		[switch]$directx,
		[switch]$vcredist,
		[switch]$chrome,
		[switch]$discord,
		[switch]$steam,
		[switch]$qbit,
		[switch]$zip,
		[switch]$gdrive,
		[switch]$adguard,
		[switch]$blender,
		[switch]$signal,
		[switch]$codec,
		[switch]$nvidia
	)
	run
}

function choose
{
	param
	(
		[Parameter(Mandatory = $true)][int]$store,
		[Parameter(Mandatory = $true)][int]$office,
		[Parameter(Mandatory = $true)][int]$spotx,
		[Parameter(Mandatory = $true)][int]$dpi,
		[Parameter(Mandatory = $true)][int]$directx,
		[Parameter(Mandatory = $true)][int]$vcredist,
		[Parameter(Mandatory = $true)][int]$chrome,
		[Parameter(Mandatory = $true)][int]$discord,
		[Parameter(Mandatory = $true)][int]$steam,
		[Parameter(Mandatory = $true)][int]$qbit,
		[Parameter(Mandatory = $true)][int]$zip,
		[Parameter(Mandatory = $true)][int]$gdrive,
		[Parameter(Mandatory = $true)][int]$adguard,
		[Parameter(Mandatory = $true)][int]$blender,
		[Parameter(Mandatory = $true)][int]$signal,
		[Parameter(Mandatory = $true)][int]$codec,
		[Parameter(Mandatory = $true)][int]$nvidia
	)
	run
}

function run
{
	if ($all)
	{
		auto -store -office -spotx -dpi -directx -vcredist -chrome -discord -steam -qbit -zip -gdrive -adguard -blender -signal -codec -nvidia
	}

	if ($store)
	{
		Get-CimInstance -Namespace 'root\cimv2\mdm\dmmap' -ClassName 'MDM_EnterpriseModernAppManagement_AppManagement01' | Invoke-CimMethod -MethodName UpdateScanMethod
	}

	if ($office)
	{
		iwr 'https://github.com/farag2/Office/releases/latest/download/Office.zip' -OutFile '.\Office.zip'
		Expand-Archive '.\Office.zip' '.\'
		ri '.\Office.zip'
		pushd '.\Office'
		iex '.\Download.ps1 -Branch O365ProPlusRetail -Channel Current -Components Word, Excel, PowerPoint'
		iex '.\Install.ps1'
		& ([ScriptBlock]::Create((irm https://massgrave.dev/get))) /KMS-Office /KMS-ActAndRenewalTask /S
		popd
		ri -Recurse -Force '.\Office'
	}

	if ($spotx)
	{
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		iex "& { $((iwr -useb 'https://raw.githubusercontent.com/amd64fox/SpotX/main/Install.ps1').Content) } -premium -new_theme -podcasts_on -block_update_on -cache_on"
	}

	if ($dpi)
	{
		iwr 'https://github.com/ValdikSS/GoodbyeDPI/releases/latest/download/goodbyedpi-0.2.2.zip' -OutFile '.\goodbyedpi.zip'
		Expand-Archive '.\goodbyedpi.zip' $Env:Programfiles
		ri -Force '.\goodbyedpi.zip'
		dir -Path $Env:Programfiles -Recurse -ErrorAction SilentlyContinue -Force | where {$_ -in '0_russia_update_blacklist_file.cmd','service_install_russia_blacklist.cmd'} | %{ '`n' |& $_.FullName }
	}

	if ($directx)
	{
		winget install --id=Microsoft.DirectX --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($vcredist)
	{
		winget install --id=Microsoft.VCRedist.2015+.x64 --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($chrome)
	{
		winget install --id=Google.Chrome --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($discord)
	{
		winget install --id=Discord.Discord --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($steam)
	{
		winget install --id=Valve.Steam --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($qbit)
	{
		winget install --id=qBittorrent.qBittorrent --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($zip)
	{
		winget install --id=7zip.7zip --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($gdrive)
	{
		winget install --id=Google.Drive --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($adguard)
	{
		winget install --id=AdGuard.AdGuard --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($blender)
	{
		winget install --id=BlenderFoundation.Blender --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($signal)
	{
		winget install --id=WhirlwindFX.SignalRgb --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($codec)
	{
		winget install --id=CodecGuide.K-LiteCodecPack.Full --accept-package-agreements --accept-source-agreements --exact --interactive
	}

	if ($nvidia)
	{
		winget install --id=TechPowerUp.NVCleanstall --accept-package-agreements --accept-source-agreements --exact --interactive
	}
}
