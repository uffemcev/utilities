#НАЧАЛЬНЫЕ ПАРАМЕТРЫ
[CmdletBinding()]
param ([Parameter(ValueFromRemainingArguments=$true)][System.Collections.ArrayList]$apps = @())
function cleaner () {$e = [char]27; "$e[H$e[J" + "`nhttps://uffemcev.github.io/utilities`n"}
function color ($text, $number) {$e = [char]27; "$e[$($number)m" + $text + "$e[0m"}
$host.ui.RawUI.WindowTitle = 'utilities ' + [char]::ConvertFromUtf32(0x1F916)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
[console]::CursorVisible = $false
cleaner

#ПРОВЕРКА ПРАВ
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	try {Start-Process wt "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'\; $($MyInvocation.line -replace (";"),("\;"))}" -Verb RunAs}
	catch {Start-Process conhost "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'; $($MyInvocation.line)}" -Verb RunAs}
	(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {taskkill /PID $_}
}

#ПРОВЕРКА REGEDIT
if (!(gp -ErrorAction 0 -Path Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Associations)) {
	start-job {
		$policies = "Software\Microsoft\Windows\CurrentVersion\Policies\Associations"
		reg add "HKCU\$policies" /v "LowRiskFileTypes" /t REG_SZ /d ".exe;.msi;.zip;" /f
		start-sleep 5
	} | out-null
}

#ПРОВЕРКА WINGET
if ((Get-AppxPackage Microsoft.DesktopAppInstaller).Version -lt [System.Version]"1.21.2771.0") {
	if ((get-process | where MainWindowTitle -eq $($host.ui.RawUI.WindowTitle)) -match "Terminal") {
		Start-Process conhost "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'; $($MyInvocation.line)}" -Verb RunAs
		(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {taskkill /PID $_}
	} else {
		start-job {&([ScriptBlock]::Create((irm https://raw.githubusercontent.com/asheroto/winget-install/master/winget-install.ps1))) -Force -ForceClose} | out-null
	}
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
 	$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
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
$tagItems = [array]'All' + ($data.tag | select -Unique) + [array]'Confirm'
$ypos = -1
$xpos = 0

#МЕНЮ
:menu while ($true) {
	
	#ПРОВЕРКА НА АРГУМЕНТЫ
	$compare = Compare $apps $tagItems -Exclude -Include
	if ($compare) {
		foreach ($tag in ($data.tag | Select -Unique))  {
			if ($apps -contains $tag) {($data | where tag -eq $tag).Name | foreach {$apps.add($_)}}
			($apps | where {$_ -eq $tag}) | foreach {$apps.Remove($_)}
		}
		if ($apps -contains "all") {$apps = $data.Name}
		cleaner
		break menu
	}
	
	#ПОДСЧЕТ
	cleaner
	$menu = $tagItems | Select @{Name="Tag"; Expression={
		$tag = $_
		if (($tagItems.IndexOf($tag) -eq $xpos) -and ($ypos -eq -1)) {color -text $tag -number 7}
		else {$tag}	
	}}, @{Name="App"; Expression={
		$tag = $_
		if ($tagItems.IndexOf($tag) -eq $xpos) {
			switch ($tag) {
				{$_ -in $data.tag} {[array]$result = $data | where Tag -eq $tag}
				'All' {[array]$result = $data}
				'Confirm' {[array]$result = $data | where Name -in $apps}
			}

			$result | foreach {
				$element = $_
				$index = $result.IndexOf($element)
				if (($element.Name -in $apps) -and ($index -eq $ypos)) {$description = (color "[$($index+1)]" 7) + " " + (color $element.Description 7)}
				elseif ($element.Name -in $apps) {$description = (color "[$($index+1)]" 7) + " " + $element.Description}
				elseif ($index -eq $ypos) {$description = "[$($index+1)]" + " " + (color $element.Description 7)}
				else {$description = "[$($index+1)]" + " " + $element.Description}
				@{Description = $Description; Name = $element.Name}
			}
		}
	}}
	
	#ОТРИСОВКА
	[string]($menu.Tag) + "`n"
	$menu.App.Description
	[array]$appItems = $menu.App.Name
	
	#УПРАВЛЕНИЕ
	switch ([console]::ReadKey($true).key) {
		"UpArrow" {if ($appItems[$ypos] -ne $null) {$ypos--}}
		"DownArrow" {if ($appItems[$ypos] -ne $null) {$ypos++}}
		"RightArrow" {$ypos = -1; $xpos++}
		"LeftArrow" {$ypos = -1; $xpos--}
		"Enter" {
			if ($ypos -ge 0) {
				if ($appItems[$ypos] -in $apps) {$apps.Remove($appItems[$ypos])}
				else {$apps.Add($appItems[$ypos])}
			} else {
				switch ($tagItems[$xpos]) {
					"All" {if ($apps) {$apps = @()} else {$apps = $data.Name}}
					"Confirm" {cleaner; break menu}
					DEFAULT {
						$names = ($data | where Tag -eq $tagItems[$xpos]).name
						$compare = Compare $apps $names -Exclude -Include
						if ($compare) {$names | foreach {$apps.remove($_)}}
						else {$names | foreach {$apps.add($_)}}
					}
				}
			}
		}
	}
	if ($xpos -lt 0) {$xpos = $tagItems.count -1}
	if ($xpos -ge $tagItems.count) {$xpos = 0}
	if ($ypos -lt -1) {$ypos = $appItems.count -1}
	if (($ypos -lt 0) -or ($ypos -ge $appItems.count)) {$ypos = -1}
}

#УСТАНОВКА
:install while ($true) {

	#ПРОВЕРКА ВЫХОДА
	if ($apps.count -eq 0) {break install}

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
	break install
}

#ЗАВЕРШЕНИЕ РАБОТЫ
cleaner
"Bye, $Env:UserName"
start-sleep 5
cd \
ri -Recurse -Force -ErrorAction 0 ([System.IO.Path]::GetTempPath())
(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {taskkill /PID $_}
