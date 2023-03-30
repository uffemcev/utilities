If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{ 
  echo "* Respawning PowerShell child process with elevated privileges"
  $pinfo = New-Object System.Diagnostics.ProcessStartInfo
  $pinfo.FileName = "powershell"
  $pinfo.Arguments = "& '" + $myinvocation.mycommand.definition + "'"
  $pinfo.Verb = "RunAs"
  $pinfo.RedirectStandardError = $false
  $pinfo.RedirectStandardOutput = $false
  $pinfo.UseShellExecute = $true
  $p = New-Object System.Diagnostics.Process
  $p.StartInfo = $pinfo
  $p.Start() | Out-Null
  $p.WaitForExit()
  echo "* Child process finished"
  type "C:/jenkins/transcript.txt"
  Exit $p.ExitCode
} Else {
  echo "Child process starting with admin privileges"
  Start-Transcript -Path "C:/jenkins/transcript.txt"
}


cd $env:USERPROFILE

function install([Array]$option)
{
	if ($option[0] -eq 'all')
	{
		[array]$name = 'store', 'office', 'spotx', 'dpi', 'directx', 'vcredist', 'chrome', 'discord', 'steam', 'qbit', 'zip', 'gdrive', 'adguard', 'blender', 'signal', 'codec', 'nvidia'
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'Update store apps') -eq 1) {[array]$name += 'store'}} elseif ($option -eq 'store')
	{
		Get-CimInstance -Namespace 'root\cimv2\mdm\dmmap' -ClassName 'MDM_EnterpriseModernAppManagement_AppManagement01' | Invoke-CimMethod -MethodName UpdateScanMethod
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'Office, Word, Excel 365 mondo volume license') -eq 1) {[array]$name += 'office'}} elseif ($option -eq 'office')
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

	if ($option[0] -eq 'select') {if ((Read-Host 'SpotX spotify modification') -eq 1) {[array]$name += 'spotx'}} elseif ($option -eq 'spotx')
	{
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		iex "& { $((iwr -useb 'https://raw.githubusercontent.com/amd64fox/SpotX/main/Install.ps1').Content) } -premium -new_theme -podcasts_on -block_update_on -cache_on"
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'GoodbyeDPI with -5 option') -eq 1) {[array]$name += 'dpi'}} elseif ($option -eq 'dpi')
	{
		iwr 'https://github.com/ValdikSS/GoodbyeDPI/releases/latest/download/goodbyedpi-0.2.2.zip' -OutFile '.\goodbyedpi.zip'
		Expand-Archive '.\goodbyedpi.zip' $Env:Programfiles
		ri -Force '.\goodbyedpi.zip'
		dir -Path $Env:Programfiles -Recurse -ErrorAction SilentlyContinue -Force | where {$_ -in '0_russia_update_blacklist_file.cmd','service_install_russia_blacklist.cmd'} | %{ '`n' |& $_.FullName }
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'DirectX') -eq 1) {[array]$name += 'directx'}} elseif ($option -eq 'directx')
	{
		winget install --id=Microsoft.DirectX --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'Microsoft Visual C++ 2015-2022') -eq 1) {[array]$name += 'vcredist'}} elseif ($option -eq 'vcredist')
	{
		winget install --id=Microsoft.VCRedist.2015+.x64 --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'Google Chrome') -eq 1) {[array]$name += 'chrome'}} elseif ($option -eq 'chrome')
	{
		winget install --id=Google.Chrome --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'Discord') -eq 1) {[array]$name += 'discord'}} elseif ($option -eq 'discord')
	{
		winget install --id=Discord.Discord --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'Steam') -eq 1) {[array]$name += 'steam'}} elseif ($option -eq 'steam')
	{
		winget install --id=Valve.Steam --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'qBittorrent') -eq 1) {[array]$name += 'qbit'}} elseif ($option -eq 'qbit')
	{
		winget install --id=qBittorrent.qBittorrent --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($option[0] -eq 'select') {if ((Read-Host '7-Zip') -eq 1) {[array]$name += 'zip'}} elseif ($option -eq 'zip')
	{
		winget install --id=7zip.7zip --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'Google Drive') -eq 1) {[array]$name += 'gdrive'}} elseif ($option -eq 'gdrive')
	{
		winget install --id=Google.Drive --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'Adguard') -eq 1) {[array]$name += 'adguard'}} elseif ($option -eq 'adguard')
	{
		winget install --id=AdGuard.AdGuard --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'Blender') -eq 1) {[array]$name += 'blender'}} elseif ($option -eq 'blender')
	{
		winget install --id=BlenderFoundation.Blender --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'SignalRGB') -eq 1) {[array]$name += 'signal'}} elseif ($option -eq 'signal')
	{
		winget install --id=WhirlwindFX.SignalRgb --accept-package-agreements --accept-source-agreements --exact --silent
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'K-Lite Codec Pack Full manual install') -eq 1) {[array]$name += 'codec'}} elseif ($option -eq 'codec')
	{
		winget install --id=CodecGuide.K-LiteCodecPack.Full --accept-package-agreements --accept-source-agreements --exact --interactive
	}

	if ($option[0] -eq 'select') {if ((Read-Host 'NVCleanstall manual install') -eq 1) {[array]$name += 'nvidia'}} elseif ($option -eq 'nvidia')
	{
		winget install --id=TechPowerUp.NVCleanstall --accept-package-agreements --accept-source-agreements --exact --interactive
	}

	if ($name -and !($i)) {$i++; install $name}
}

if (!$args) {
$choose = Read-Host "`ngithub.com/uffemcev/utilities `n`n1 install everything `n0 select manually`n"
if ($choose -eq 0) {install select}
if ($choose -eq 1) {install all}
} else {install $args}
