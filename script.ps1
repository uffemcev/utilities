#НАЧАЛЬНЫЕ ПАРАМЕТРЫ
[CmdletBinding()]
param ([Parameter(ValueFromRemainingArguments=$true)][System.Collections.ArrayList]$apps = @())
function cleaner () {$e = [char]27; "$e[H$e[J" + "`n" + "uffemcev.github.io/utilities" + "`n"}
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
	start-job -Name "Checking policies" {
		$policies = "Software\Microsoft\Windows\CurrentVersion\Policies\Associations"
		reg add "HKCU\$policies" /v "LowRiskFileTypes" /t REG_SZ /d ".exe;.msi;.zip;" /f
		start-sleep 3
	} | out-null
}

#ПРОВЕРКА WINGET
if ((Get-AppxPackage Microsoft.DesktopAppInstaller).Version -lt [System.Version]"1.21.2771.0") {
	if ((get-process | where MainWindowTitle -eq $($host.ui.RawUI.WindowTitle)) -match "Terminal") {
		Start-Process conhost "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'; $($MyInvocation.line)}" -Verb RunAs
		(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {taskkill /PID $_}
	} else {
		start-job -Name "Installing winget" {
			&([ScriptBlock]::Create((irm https://raw.githubusercontent.com/asheroto/winget-install/master/winget-install.ps1))) -Force -ForceClose
		} | out-null
	}
}

#ПРОВЕРКА ПРИЛОЖЕНИЙ
if (!$data) {
	Start-Job -Name "Loading apps" {
		try {$data = &([ScriptBlock]::Create((irm uffemcev.github.io/utilities/apps.ps1)))}
		catch {throw}
		start-sleep 3
	} | out-null
	$data = &([ScriptBlock]::Create((irm uffemcev.github.io/utilities/apps.ps1)))
 	$data | foreach {if (($_.Tag -eq '') -or ($_.Tag -eq $null)) {$_ | add-member -force 'Tag' 'Other'}}
}

#ПРОВЕРКА ПАРАМЕТРОВ
if ($apps) {
	foreach ($tag in ($data.tag | Select -Unique))  {
		if ($tag -in $apps) {($data | where tag -eq $tag).Name | foreach {$apps.add($_)}}
		($apps | where {$_ -eq $tag}) | foreach {$apps.Remove($_)}
	}
	if ($apps -contains "all") {$apps = $data.Name}
	$apps = [array]($apps | Sort-Object -unique)
	cleaner
	$menu = $true
} else {[System.Collections.ArrayList]$apps = @()}

#ОЖИДАНИЕ ПРОВЕРОК
if (get-job) {
	$job = get-job
	for ($i = 0; $i -le $job.count; $i++) {
		cleaner
		if ($i -lt $job.count) {$job[$i].Name} else {$job[$i-1].Name}
		$processed = [Math]::Round(($i) / $job.count * 49,0)
		$remaining = 49 - $processed
		$percentProcessed = [Math]::Round(($i) / $job.count * 100,0)
		$percent = $percentProcessed -replace ('^(\d{1})$'), ('  $_%') -replace ('^(\d{2})$'), (' $_%') -replace ('^(\d{3})$'), ('$_%')
		"`n" + (color -text (" " * $processed) -number 7) + (color -text ("$percent") -number 7) + (color -text (" " * $remaining) -number 100)
		$job[$i] | wait-job -ErrorAction 0 | out-null
	}
	$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
	get-job | remove-job | out-null
	start-sleep 1
}

#НАЧАЛО РАБОТЫ
winget settings --enable InstallerHashOverride | out-null
ri -Recurse -Force -ErrorAction 0 ([System.IO.Path]::GetTempPath())
cd ([System.IO.Path]::GetTempPath())
$tagsList = [array]'All' + ($data.tag | select -Unique) + [array]'Confirm'
$ypos = -1
$xpos = 0
$zpos = 0

#МЕНЮ
while ($menu -ne $true) {
	
	#ПОДСЧЕТ
	cleaner
	[array]$pattern = for ($i = 0; $i -lt $tagsList.count; $i++) {
		$tag = $tagsList[$i]
		if ($i -eq $xpos) {
			switch ($tag) {
				{$_ -in $data.tag} {$data | where Tag -eq $tag}
				'All' {$data}
				'Confirm' {$data | where Name -in $apps}
			}
		}
	}

	[string]$tags = for ($i = 0; $i -lt $tagsList.count; $i++) {
		$tag = $tagsList[$i]
		if (($i -eq $xpos) -and ($ypos -eq -1)) {color -text $tag -number 7}
		elseif ($i -eq $xpos) {color -text $tag -number 4}
		else {$tag}
	}

	[array]$descriptions = for ($i = 0; $i -lt $pattern.count; $i++) {
		$element = $pattern[$i]
		if (($element.Name -in $apps) -and ($i -eq $ypos)) {(color "[$($i+1)]" 7) + " " + (color $element.Description 7)}
		elseif ($element.Name -in $apps) {(color "[$($i+1)]" 7) + " " + $element.Description}
		elseif ($i -eq $ypos) {"[$($i+1)]" + " " + (color $element.Description 7)}
		else {"[$($i+1)]" + " " + $element.Description}
	}

	[array]$names = for ($i = 0; $i -lt $pattern.count; $i++) {
		$element = $pattern[$i]
		$element.Name
	}
	
	[string]$page = " " + (($zpos/10)+1) + "/" + ([math]::Ceiling($names.count/10)) + " "
	
	#ВЫВОД
	$tags + "`n"
	if ($descriptions) {
		$descriptions[$zpos..($zpos+9)]
		"`n" + [char]::ConvertFromUtf32(0x0001F4C4) + $page
	}
	
	#УПРАВЛЕНИЕ
	switch ([console]::ReadKey($true).key) {
		"UpArrow" {$ypos--; if ($ypos -lt $zpos) {$zpos -= 10}}
		"DownArrow" {$ypos++; if ($ypos -gt $zpos+9) {$zpos += 10}}
		"RightArrow" {$ypos = -1; $zpos = 0; $xpos++}
		"LeftArrow" {$ypos = -1; $zpos = 0; $xpos--}
		"Enter" {
			$app = $names[$ypos]
			$tag = $tagsList[$xpos]			
			if ($ypos -ge 0) {
				if ($app -in $apps) {$apps.Remove($app)} else {$apps.Add($app)}
				if (($app -eq $names[-1]) -and ($tag -eq 'Confirm')) {
					$ypos--
					$zpos = [math]::Floor(($names.count-2)/10)*10
				}
			} else {
				switch ($tag) {
					"All" {if ($apps) {$apps = @()} else {$apps = $data.Name}}
					"Confirm" {cleaner; $menu = $true}
					DEFAULT {
						$names = ($data | where Tag -eq $tag).name
						$compare = Compare $apps $names -Exclude -Include
						if ($compare) {$names | foreach {$apps.remove($_)}}
						else {$names | foreach {$apps.add($_)}}
					}
				}
			}
		}
	}
	if ($xpos -lt 0) {$xpos = $tagsList.count -1}
	if ($xpos -ge $tagsList.count) {$xpos = 0}
	if ($ypos -lt -1) {$ypos = $names.count -1; $zpos = [math]::Floor(($names.count-1)/10)*10}
	if ($ypos -ge $names.count) {$ypos = -1; $zpos = 0}
	if ($zpos -lt 0) {$zpos = 0}
}

#ПРОВЕРКА ВЫХОДА
if ($apps.count -eq 0) {$install = $true}

#УСТАНОВКА
while ($install -ne $true) {
	for ($i = 0; $i -le $apps.count; $i++) {
		#ЗАПУСК
		Get-job | Wait-Job | out-null
		try {Start-Job -Name (($data | Where Name -eq $apps[$i]).Description) -Init ([ScriptBlock]::Create("cd '$pwd'")) -ScriptBlock $(($data | Where Name -eq $apps[$i]).Code) | out-null}
		catch {Start-Job -Name ($apps[$i]) -ScriptBlock {start-sleep 1; throw} | out-null}
		
		#ПОДСЧЕТ
		$processed = [Math]::Round(($i) / $apps.count * 49,0)
		$remaining = 49 - $Processed
		$percentProcessed = [Math]::Round(($i) / $apps.count * 100,0)
		$percent = $percentProcessed -replace ('^(\d{1})$'), ('  $_%') -replace ('^(\d{2})$'), (' $_%') -replace ('^(\d{3})$'), ('$_%')
		[array]$menu = $apps | foreach {if ($_ -in $data.name) {($data | where Name -eq $_).Description} else {$_}} | Select @{Name="Name"; Expression={$_}}, @{Name="State"; Expression={
			switch ((get-job -name $_).State) {
				"Running" {'Running'}
				"Completed" {'Completed'}
				"Failed" {'Failed'}
				DEFAULT {'Waiting'}
			}
		}}

		#ВЫВОД
		cleaner
		if (($i -gt 9) -and ($i -lt $apps.count)) {$zpos++}
		($menu[$zpos..($zpos+9)] | ft @{Expression={$_.Name}; Width=37; Alignment="Left"}, @{Expression={$_.State}; Width=15; Alignment="Right"} -HideTableHeaders | Out-String).Trim()
		"`n" + (color -text (" " * $Processed) -number 7) + (color -text ("$Percent") -number 7) + (color -text (" " * $Remaining) -number 100)
	}
	start-sleep 5
	$install = $true
}

#ЗАВЕРШЕНИЕ РАБОТЫ
cleaner
"Bye, $Env:UserName"
start-sleep 5
cd \
ri -Recurse -Force -ErrorAction 0 ([System.IO.Path]::GetTempPath())
(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {taskkill /PID $_}
