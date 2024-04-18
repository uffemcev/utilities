#ПАРАМЕТРЫ
[CmdletBinding()]
param ([Parameter(ValueFromRemainingArguments=$true)][System.Collections.ArrayList]$apps = @())

#ФУНКЦИИ
function char ($char) {[char]::ConvertFromUtf32("0x$char")}
function pos ($x, $y) {[Console]::SetCursorPosition($x, $y)}
function draw ($line, $length, $height) {$e = [char]27; pos 0 $line; "$e[J" + (char 250C) + ((char 2500) * $length) + (char 2510) + (("`n" + (char 2502) + (" " * $length) + (char 2502)) * $height) + "`n" + (char 2514) + ((char 2500) * $length) + (char 2518)}
function clean () {$e = [char]27; pos 0 0; "$e[J"; draw 0 55 1; pos 2 1; (" " * 25) + (color "uffemcev.github.io/utilities" 90)}
function color ($text, $number) {$e = [char]27; "$e[$($number)m" + $text + "$e[0m"}
function close () {(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {taskkill /PID $_}}

#ЗНАЧЕНИЯ
clean
pos 2 1
"Please wait, $Env:UserName"
[console]::CursorVisible = $false
$host.ui.RawUI.WindowTitle = (char 1F916) + ' utilities'
[array]$data = &([ScriptBlock]::Create((irm uffemcev.github.io/utilities/apps.ps1)))
[string]$path = [System.IO.Path]::GetTempPath() + "utilities"
[string]$stage = 'menu'
[string]$mode = 'disable'
[int]$ypos = -1
[int]$xpos = 0
[int]$zpos = 0
[int]$kpos = 0

#ПРОВЕРКА ПРАВ
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	try {Start-Process wt "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'\; $($MyInvocation.line -replace (";"),("\;"))}" -Verb RunAs}
	catch {Start-Process conhost "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'; $($MyInvocation.line)}" -Verb RunAs}
	close
}

#ПРОВЕРКА ПОЛИТИК
if ($PSVersionTable.PSVersion.Major -gt 5) {
	import-module microsoft.powershell.security
	if ((get-ExecutionPolicy) -ne 'bypass') {Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force}
}

#ПРОВЕРКА WINGET
if ((Get-AppxPackage Microsoft.DesktopAppInstaller).Version -lt [System.Version]"1.21.2771.0") {
	if ((get-process | where MainWindowTitle -eq $($host.ui.RawUI.WindowTitle)) -match "Terminal") {
		Start-Process conhost "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'; $($MyInvocation.line)}" -Verb RunAs
		close
	} else {
		powershell "&([ScriptBlock]::Create((irm https://raw.githubusercontent.com/asheroto/winget-install/master/winget-install.ps1))) -Force -ForceClose" | out-null
		$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
	}
}

#ПРОВЕРКА REGEDIT
if (!(gp -ErrorAction 0 -Path Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Associations)) {
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v "LowRiskFileTypes" /t REG_SZ /d ".exe;.msi;.zip;" /f
}

#ПРОВЕРКА ПРИЛОЖЕНИЙ
if ($data) {
	$data | foreach {
		if (($_.Tag -eq '') -or ($_.Tag -eq $null)) {$_ | add-member -force 'Tag' 'Other'}
		clean
	}
} else {throw}

#ПРОВЕРКА ПАРАМЕТРОВ
if ($apps) {
	foreach ($tag in ($data.tag | Select -Unique))  {
		if ($tag -in $apps) {($data | where tag -eq $tag).Name | foreach {$apps.add($_)}}
		($apps | where {$_ -eq $tag}) | foreach {$apps.Remove($_)}
		clean
	}
	if ($apps -contains "all") {$apps = $data.Name}
	$apps = [array]($apps | Sort-Object -unique)
	$stage = 'install'
} else {[System.Collections.ArrayList]$apps = @()}

#НАЧАЛО РАБОТЫ
winget settings --enable InstallerHashOverride | out-null
ri -Recurse -Force -ErrorAction 0 $path
cd (ni -Path $path -ItemType "directory")
clean

#МЕНЮ
while ($stage -eq 'menu') {
	
	#ПОДСЧЕТ
	[array]$category = [array]'All' + [array]$($data.tag | select -Unique)
	[string]$confirm = if ($apps) {'Confirm'} else {'Exit'}
	[string]$menu = 'Menu'
	[string]$search = 'Search'
	[array]$tagList = if ($mode -eq 'select') {$category} else {$menu, $search, $confirm}
	
	[array]$elements = switch ($tagList[$xpos]) {
		$menu {if ($category[$kpos] -eq 'All') {$data} else {$data | where Tag -eq $category[$kpos]}}
		$search {if ($mode -eq 'search' -and ($text)) {$data | where description -match $text}}
		{$_ -in $category} {if ($category[$xpos] -eq 'All') {$data} else {$data | where Tag -eq $category[$xpos]}}
		$confirm {$data | where Name -in $apps}
	}

	[array]$tags = for ($i = 0; $i -lt $tagList.count; $i++) {
		$tag = ($tagList[$i]).ToUpper()
		if (($i -eq $xpos) -and ($ypos -eq -1)) {color $tag 7}
  		elseif ($i -eq $xpos) {color -text $tag -number 4}
		else {$tag}
	}

	[array]$descriptions = for ($i = 0; $i -lt $elements.count; $i++) {
		$element = $elements[$i]
		if (($element.Name -in $apps) -and ($i -eq $ypos)) {color $element.Description 7}
		elseif ($element.Name -in $apps) {color $element.Description 37}
		elseif ($i -eq $ypos) {color (color $element.Description 90) 47}
		else {color $element.Description 90}
	}
	
	[string]$page = " " + (($zpos/10)+1) + "/" + ([math]::Ceiling($elements.count/10)) + " "
	
	#ВЫВОД
	clean
	pos 2 1
	if ($mode -eq 'select') {'< ' + $tags[$xpos] + ' >'} else {[string]$tags}
	if ($descriptions) {
		draw 3 55 ($descriptions[$zpos..($zpos+9)].count)
		$descriptions[$zpos..($zpos+9)] | foreach {pos 2 ($descriptions[$zpos..($zpos+9)].indexof($_) + 4); $_}
		"`n" + [char]::ConvertFromUtf32(0x0001F4C4) + $page
	}
	
	#УПРАВЛЕНИЕ
	switch ([console]::ReadKey($true).key) {
		"UpArrow" {
			$ypos--
			if ($ypos -lt $zpos) {$zpos -= 10}
			if ($mode -eq 'select') {$mode = 'tags'; $kpos = $xpos; $xpos = 0}
		}
		"DownArrow" {
			$ypos++
			if ($ypos -gt $zpos+9) {$zpos += 10}
			if ($mode -eq 'select') {$mode = 'tags'; $kpos = $xpos; $xpos = 0}
		}
		"RightArrow" {
			$ypos = -1
			$zpos = 0
			$xpos++
			if ($mode -ne 'select') {$mode = 'disable'}
		}
		"LeftArrow" {
			$ypos = -1
			$zpos = 0
			$xpos--
			if ($mode -ne 'select') {$mode = 'disable'}
		}
		"Enter" {
			if ($ypos -ge 0) {
				$app = $elements[$ypos].name
				$tag = $tagList[$xpos]
				if ($app -in $apps) {[void]$apps.Remove($app)} else {[void]$apps.Add($app)}
				if (($app -eq $elements[-1].Name) -and ($tag -eq $confirm)) {
					$ypos--
					$zpos = [math]::Floor(($elements.count-2)/10)*10
				}
			} else {
				$tag = $tagList[$xpos]
				switch ($tag) {
					$category[$xpos] {
						$mode = 'tags'
						$kpos = $xpos
						$xpos = 0
					}
					$menu {
						$mode = 'select'
						$xpos = $kpos
						$tagList = $category
					}
					$search {
						$mode = 'search'
						clean
						pos 2 1
						[console]::CursorVisible = $true
						[string]$text = read-host
						[console]::CursorVisible = $false
					}
					$confirm {
						$stage = 'install'
						clean
					}
				}
			}
		}
	}
	if ($xpos -lt 0) {$xpos = $tagList.count -1}
	if ($xpos -ge $tagList.count) {$xpos = 0}
	if ($ypos -lt -1) {$ypos = $elements.count -1; $zpos = [math]::Floor(($elements.count-1)/10)*10}
	if ($ypos -ge $elements.count) {$ypos = -1; $zpos = 0}
	if ($zpos -lt 0) {$zpos = 0}
}

#ПРОВЕРКА ВЫХОДА
if ($apps.count -eq 0) {$stage = 'exit'}

#УСТАНОВКА
while ($stage -eq 'install') {
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
		$progress = (color -text (" " * $Processed) -number 7) + (color -text ("$Percent") -number 7) + (color -text (" " * $Remaining) -number 100)
		[array]$install = $apps | foreach {if ($_ -in $data.name) {($data | where Name -eq $_).Description} else {$_}} | Select @{Name="Name"; Expression={$_}}, @{Name="State"; Expression={
			switch ((get-job -name $_).State) {
				"Running" {'Running'}
				"Completed" {'Completed'}
				"Failed" {'Failed'}
				DEFAULT {'Waiting'}
			}
		}}
		$install = ($install | ft @{Expression={$_.Name}; Width=37; Alignment="Left"}, @{Expression={$_.State}; Width=15; Alignment="Right"} -HideTableHeaders | Out-String -stream).Trim() | where {$_}

		#ВЫВОД
		clean
		pos 2 1
		'Installation process'
		draw 3 55 ($install[$zpos..($zpos+9)].count + 2)
		pos 2 4
		if (($i -gt 9) -and ($i -lt $apps.count)) {$zpos++}
		$install[$zpos..($zpos+9)] | where {$_} | foreach {pos 2 ($install[$zpos..($zpos+9)].indexof($_) + 4); $_}
		pos 2 ($install[$zpos..($zpos+9)].count + 5)
		$progress
		
	}
	clean
	pos 2 1
	'Installation complete'
	draw 3 55 ($install[$zpos..($zpos+9)].count + 2)
	$install[$zpos..($zpos+9)] | where {$_} | foreach {pos 2 ($install[$zpos..($zpos+9)].indexof($_) + 4); $_}
	pos 2 ($install[$zpos..($zpos+9)].count + 5)
	$progress
	start-sleep 5
	$stage = 'exit'
}

#ЗАВЕРШЕНИЕ РАБОТЫ
clean
pos 2 1
"Bye, $Env:UserName"
start-sleep 5
cd \
ri -Recurse -Force -ErrorAction 0 $path
close
