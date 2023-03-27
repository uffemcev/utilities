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

if ($all)
{
	$store = $office = $spotx = $dpi = $directx = $vcredist = $chrome = $discord = $steam = $qbit = $zip = $gdrive = $adguard = $blender = $signal = $codec = $nvidia = $True
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
	ri -Recurse '.\Office'
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
	Remove-Item '.\goodbyedpi.zip'
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
