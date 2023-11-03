#НАЧАЛЬНЫЕ ПАРАМЕТРЫ
[CmdletBinding()]
param([Parameter(ValueFromRemainingArguments=$true)][System.Collections.ArrayList]$apps = @())
function cleaner () {$e = [char]27; "$e[H$e[J" + "`nhttps://uffemcev.github.io/utilities`n"}
function color ($text, $number) {$e = [char]27; "$e[$($number)m" + $text + "$e[0m"}
function error () {$e = [char]27; "$e[1F" + "$e[2K" + "[ERROR]"; [Console]::Beep(); start-sleep 1}
$host.ui.RawUI.WindowTitle = 'utilities ' + [char]::ConvertFromUtf32(0x1F916)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
[console]::CursorVisible = $false
cleaner

#ПРОВЕРКА ПРАВ
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	try {Start-Process wt "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'\; $($MyInvocation.line -replace (";"),("\;"))}" -Verb RunAs}
	catch {Start-Process conhost "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'; $($MyInvocation.line)}" -Verb RunAs}
	(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {stop-process -id $_}
}

#ПРОВЕРКА REGEDIT
if (!(gp -ErrorAction 0 -Path Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Associations) -or !(gp -ErrorAction 0 -Path Registry::HKEY_CURRENT_USER\Console\%%Startup)) {
	start-job {
		$policies = "Software\Microsoft\Windows\CurrentVersion\Policies\Associations"
		$terminal = "Console\%%Startup"
		if (!(gp -ErrorAction 0 -Path Registry::HKEY_CURRENT_USER\$policies)) {
			reg add "HKCU\$policies" /v "LowRiskFileTypes" /t REG_SZ /d ".exe;.msi;.zip;" /f
		}
		if (!(gp -ErrorAction 0 -Path Registry::HKEY_CURRENT_USER\$terminal)) {
			reg add "HKCU\$terminal" /v "DelegationConsole" /t REG_SZ /d "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}" /f
			reg add "HKCU\$terminal" /v "DelegationTerminal" /t REG_SZ /d "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}" /f
		}
		start-sleep 5
	} | out-null
}

#ПРОВЕРКА WINGET
if ((Get-AppxPackage Microsoft.DesktopAppInstaller).Version -lt [System.Version]"1.21.2771.0") {
	if ((get-process | where MainWindowTitle -eq $($host.ui.RawUI.WindowTitle)) -match "Terminal") {
 		Start-Process conhost "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'; $($MyInvocation.line)}" -Verb RunAs
        	(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {stop-process -id $_}
	} else {
 		start-job {&([ScriptBlock]::Create((irm https://raw.githubusercontent.com/asheroto/winget-install/master/winget-install.ps1))) -Force -ForceClose} | out-null
	}
}

#ПРОВЕРКА TERMINAL
if ((Get-AppxPackage Microsoft.WindowsTerminal).Version -lt [System.Version]"1.16.10261.0") {
	start-job {
		$id = "Microsoft.WindowsTerminal"
		if (!(Get-Appxpackage -allusers $id)) {
			while ((Get-AppxPackage -allusers Microsoft.DesktopAppInstaller).Version -lt [System.Version]"1.21.2771.0") {start-sleep 1}
			$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
   			winget install --id=$id --accept-package-agreements --accept-source-agreements --exact --silent
			if (!((winget list) -match $id)) {
   				winget settings --enable InstallerHashOverride
   				runas /trustlevel:0x20000 /machine:amd64 "winget install --id=$id --accept-package-agreements --accept-source-agreements --ignore-security-hash --exact --silent"
				while (!(Get-Appxpackage -allusers $id)) {start-sleep 1}
			}
		} else {
			Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.WindowsTerminal_8wekyb3d8bbwe
			start-sleep 5
		}
	} | out-null
}

#ОЖИДАНИЕ ПРОВЕРОК
if (get-job | where State -eq "Running") {
	for ($i = 0; $i -lt (get-job).count+1; $i++) {
		cleaner
		"Preparing for work"
		$Jobs = (get-job | where State -eq "Running").count
		$Processed = [Math]::Round(($i) / (get-job).count * 49,0)
		$Remaining = 49 - $Processed
		$PercentProcessed = [Math]::Round(($i) / (get-job).count * 100,0)
		$Percent = $PercentProcessed -replace ('^(\d{1})$'), ('  $_%') -replace ('^(\d{2})$'), (' $_%') -replace ('^(\d{3})$'), ('$_%')
		"`n" + (color -text (" " * $Processed) -number 7) + (color -text ("$Percent") -number 7) + (color -text (" " * $Remaining) -number 100)
		if ($Jobs -eq 0) {break}
		while (($Jobs -eq (get-job | where State -eq "Running").count)) {start-sleep 1}
	}
 	if ((get-process | where MainWindowTitle -eq $($host.ui.RawUI.WindowTitle)) -match "Terminal") {
		$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
	} else {
		try {Start-Process wt "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'\; $($MyInvocation.line -replace (";"),("\;"))}" -Verb RunAs}
		catch {Start-Process conhost "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'; $($MyInvocation.line)}" -Verb RunAs}
		(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {stop-process -id $_}
	}
}

#ЗАГРУЗКА ПРИЛОЖЕНИЙ
$data = &([ScriptBlock]::Create((irm uffemcev.github.io/utilities/apps.ini)))
for ($i = 0; $i -lt $data.count+1; $i++) {
	cleaner
	$Processed = [Math]::Round(($i) / $data.count * 49,0)
	$Remaining = 49 - $Processed
	$PercentProcessed = [Math]::Round(($i) / $data.count * 100,0)
	$Percent = $PercentProcessed -replace ('^(\d{1})$'), ('  $_%') -replace ('^(\d{2})$'), (' $_%') -replace ('^(\d{3})$'), ('$_%')
	"Loading apps list"
	"`n" + (color -text (" " * $Processed) -number 7) + (color -text ("$Percent") -number 7) + (color -text (" " * $Remaining) -number 100)
	start-sleep -Milliseconds 100
}

#НАЧАЛО РАБОТЫ
winget settings --enable InstallerHashOverride | out-null
ri -Recurse -Force -ErrorAction 0 ([System.IO.Path]::GetTempPath())
cd ([System.IO.Path]::GetTempPath())
get-job | remove-job | out-null

#ПРОВЕРКА НА АРГУМЕНТЫ
if ($apps -contains "all") {$apps = $data.Name; $status = "install"} elseif ($apps) {$status = "install"}

#МЕНЮ
while ($status -ne "install") {
	#ВЫВОД
	cleaner
	if ($apps) {"[0] Reset"} else {"[0] All"}
	$table = $data | Select @{Name="Description"; Expression= {
		if ($_.Name -in $apps) {(color -text ("[" + ($data.indexof($_)+1) + "]") -number 7) + " " + $_.Description}
		else {"[" + ($data.indexof($_)+1) + "] " + $_.Description}
	}}
	($table | ft -HideTableHeaders | Out-String).Trim()
	if ($apps) {write-host -nonewline "`n[ENTER] Confirm "} else {write-host -nonewline "`n[ENTER] Exit "}
		
	#ПОДСЧЁТ	
	switch ([console]::ReadKey($true)) {
		{$_.Key -match "[1-9]"} {
			(New-Object -com "Wscript.Shell").sendkeys($_.KeyChar)
			write-host -nonewline "`r[ENTER] Select "
			$status = read-host
			try {[int]$status | out-null} catch {$status = $null}
			switch ($status) {
				{[int]$_ -gt 0 -and [int]$_ -le $data.count} {if ($data[$_-1].Name -in $apps) {$apps.Remove($data[$_-1].Name)} else {$apps.Add($data[$_-1].Name)}}
				{[string]$_ -eq 0} {if ($apps) {$apps = @()} else {$apps = $data.Name}}
				DEFAULT {error}
			}
		}
		{$_.Key -eq "D0"} {if ($apps) {$apps = @()} else {$apps = $data.Name}}
		{$_.Key -eq "Enter"} {$status = "install"}
	}
}

#ПРОВЕРКА ВЫХОДА
if ($apps.count -eq 0) {$status = "finish"}

#УСТАНОВКА
while ($status -ne "finish") {
	for ($i = 0; $i -lt $apps.count+1; $i++) {
		#ЗАПУСК
		Get-job | Wait-Job | out-null
		try {Start-Job -Name (($data | Where Name -eq $apps[$i]).Description) -Init ([ScriptBlock]::Create("cd '$pwd'")) -ScriptBlock $(($data | Where Name -eq $apps[$i]).Code) | out-null}
		catch {Start-Job -Name ($apps[$i]) -ScriptBlock {throw} | out-null}
		
		#ПОДСЧЁТ
		$Processed = [Math]::Round(($i) / $apps.count * 49,0)
		$Remaining = 49 - $Processed
		$PercentProcessed = [Math]::Round(($i) / $apps.count * 100,0)
		$Percent = $PercentProcessed -replace ('^(\d{1})$'), ('  $_%') -replace ('^(\d{2})$'), (' $_%') -replace ('^(\d{3})$'), ('$_%')
		$table = $apps | foreach {if ($_ -in $data.name) {($data | where Name -eq $_).Description} else {$_}} | Select @{Name="Name"; Expression={$_}}, @{Name="State"; Expression={
			switch ((get-job -name $_).State) {
				"Running" {'Running'}
				"Completed" {'Completed'}
				"Failed" {'Failed'}
				DEFAULT {'Waiting'}
			}
		}}

		#ВЫВОД
		cleaner
		($table | ft @{Expression={$_.Name}; Width=37; Alignment="Left"}, @{Expression={$_.State}; Width=15; Alignment="Right"} -HideTableHeaders | Out-String).Trim() + "`n"
		(color -text (" " * $Processed) -number 7) + (color -text ("$Percent") -number 7) + (color -text (" " * $Remaining) -number 100)
	}
	start-sleep 5
	$status = "finish"
}

#ЗАВЕРШЕНИЕ РАБОТЫ
cleaner
"Bye, $Env:UserName"
start-sleep 5
cd \
ri -Recurse -Force -ErrorAction 0 ([System.IO.Path]::GetTempPath())
(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {stop-process -id $_}
