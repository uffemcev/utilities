#ПАРАМЕТРЫ
[CmdletBinding()]
param ([Parameter(ValueFromRemainingArguments=$true)][System.Collections.ArrayList]$apps = @())

#ФУНКЦИИ
function char ($char) {[char]::ConvertFromUtf32("0x$char")}
function pos ($x, $y) {[Console]::SetCursorPosition($x, $y)}
function draw ($line, $length, $height) {$e = [char]27; pos 0 $line; "$e[J" + (char "256D") + ((char "2500") * $length) + (char "256E") + (("`n" + (char "2502") + (" " * $length) + (char "2502")) * $height) + "`n" + (char "2570") + ((char "2500") * $length) + (char "256F")}
function clean () {$e = [char]27; pos 0 0; "$e[J"; draw 0 55 1; pos 2 1; (" " * 25) + (color "uffemcev.github.io/utilities" 90)}
function color ($text, $number) {$e = [char]27; "$e[$($number)m" + $text + "$e[0m"}

#ЗНАЧЕНИЯ
clean
pos 2 1
"Please wait, $Env:UserName"
$host.ui.RawUI.WindowTitle = (char 1F916) + " utilities"
[array]$data = &([ScriptBlock]::Create((irm uffemcev.github.io/utilities/apps.ps1)))
[string]$path = [System.IO.Path]::GetTempPath() + "utilities"
[string]$stage = "menu"
[string]$mode = "disable"
[int]$ypos = -1
[int]$xpos = 0
[int]$zpos = 0
[int]$kpos = 0

#ПРОВЕРКА CURSOR
if ([console]::CursorVisible -eq $True) {
	[console]::CursorVisible = $False
}

#ПРОВЕРКА PROGRESSBAR
if ($ProgressPreference -ne "SilentlyContinue") {
	$ProgressPreference = "SilentlyContinue"
}

#ПРОВЕРКА ПРАВ
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	try {Start-Process wt "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'\; $($MyInvocation.line -replace (";"),("\;"))}" -Verb RunAs}
	catch {Start-Process conhost "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'; $($MyInvocation.line)}" -Verb RunAs}
	Exit
}

#ПРОВЕРКА ПОЛИТИК
try {
	if ((Get-ExecutionPolicy) -ne "bypass") {throw}
} catch {
	Import-Module -Name "Microsoft.PowerShell.Security" -RequiredVersion 3.0.0.0
	Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
}

#ПРОВЕРКА WINGET
try {
	if ([System.Version]((Get-WinGetVersion) -replace "[a-zA-Z]","") -lt [System.Version]"1.9.25200") {throw}
} catch {
	if ((Get-Process | where MainWindowTitle -eq $($host.ui.RawUI.WindowTitle)).ProcessName -match "Terminal") {
		Start-Process conhost "powershell -ExecutionPolicy Bypass -Command &{cd '$pwd'; $($MyInvocation.line)}" -Verb RunAs
		Exit
	} else {
		powershell "&([ScriptBlock]::Create((irm https://raw.githubusercontent.com/asheroto/winget-install/master/winget-install.ps1))) -Force -ForceClose" | Out-Null
		$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
		Repair-WingetPackageManager -Force -Latest -AllUsers | Out-Null
	}
}

#ПРОВЕРКА ПРИЛОЖЕНИЙ
if ($data) {
	$data | foreach {
		if (($_.Tag -eq "") -or ($_.Tag -eq $null)) {$_ | add-member -force "Tag" "Other"}
		clean
	}
} else {
	throw
}

#ПРОВЕРКА ПАРАМЕТРОВ
if ($apps) {
	foreach ($tag in ($data.tag | Select -Unique))  {
		if ($tag -in $apps) {($data | where tag -eq $tag).Name | foreach {$apps.add($_)}}
		($apps | where {$_ -eq $tag}) | foreach {$apps.Remove($_)}
		clean
	}
	if ($apps -contains "all") {$apps = $data.Name}
	$apps = [array]((([string]$apps).split(" ") | Group-Object -NoElement).Name | Get-Unique)
	$stage = "install"
} else {
	[System.Collections.ArrayList]$apps = @()
}

#ПРОВЕРКА WINGET НАСТРОЕК
if ((Get-WingetSetting).adminSettings.InstallerHashOverride -ne $True) {
	Enable-WinGetSetting InstallerHashOverride
}

#ПРОВЕРКА ZONECHECK
if ($env:SEE_MASK_NOZONECHECKS -ne 1) {
	$env:SEE_MASK_NOZONECHECKS = 1
}

#ПРОВЕРКА ДИРЕКТОРИИ
if (Get-Item $path -ErrorAction 0) {
	cd \
	Remove-Item -Recurse -Force -ErrorAction 0 $path
	cd (New-Item -Path $path -ItemType "directory")
} else {
	cd (New-Item -Path $path -ItemType "directory")
}

#МЕНЮ
while ($stage -eq "menu") {
	
	#ПОДСЧЕТ
	[array]$category = [array]"All" + [array]$($data.tag | select -Unique)
	[string]$confirm = if ($apps) {"Confirm"} else {"Exit"}
	[string]$menu = "Menu"
	[string]$search = "Search"
	[array]$optionList = if ($mode -eq "select") {$category} else {$menu, $search, $confirm}
	
	[array]$elements = switch ($optionList[$xpos]) {
		$menu {if ($category[$kpos] -eq "All") {$data} else {$data | where Tag -eq $category[$kpos]}}
		$search {if ($mode -eq "search" -and ($text)) {$data | where description -match $text}}
		{$_ -in $category} {if ($category[$xpos] -eq "All") {$data} else {$data | where Tag -eq $category[$xpos]}}
		$confirm {$data | where Name -in $apps}
	}

	[array]$options = for ($i = 0; $i -lt $optionList.count; $i++) {
		$option = (Get-Culture).TextInfo.ToTitleCase($optionList[$i])
		if (($i -eq $xpos) -and ($ypos -eq -1)) {color $option 7}
  		elseif ($i -eq $xpos) {color $option 4}
		else {$option}
	}

	[array]$descriptions = for ($i = 0; $i -lt $elements.count; $i++) {
		$element = $elements[$i]
		if (($element.Name -in $apps) -and ($i -eq $ypos)) {color $element.Description 7}
		elseif ($element.Name -in $apps) {color $element.Description 37}
		elseif ($i -eq $ypos) {color (color $element.Description 90) 47}
		else {color $element.Description 90}
	}
	
	[string]$page = (char "0x0001F4C4") + " " + (($zpos/10)+1) + "/" + ([math]::Ceiling($elements.count/10))
	
	#ВЫВОД
	clean
	pos 2 1
	if ($mode -eq "select") {"< " + $options[$xpos] + " >"} else {[string]$options}
	if ($descriptions) {
		draw 3 55 ($descriptions[$zpos..($zpos+9)].count)
		$descriptions[$zpos..($zpos+9)] | foreach {pos 2 ($descriptions[$zpos..($zpos+9)].indexof($_) + 4); $_}
		"`n" + $page
	}
	
	#УПРАВЛЕНИЕ
	switch ([console]::ReadKey($true).key) {
		"UpArrow" {
			$ypos--
			if ($ypos -lt $zpos) {$zpos -= 10}
			if ($mode -eq "select") {$mode = "tags"; $kpos = $xpos; $xpos = 0}
		}
		"DownArrow" {
			$ypos++
			if ($ypos -gt $zpos+9) {$zpos += 10}
			if ($mode -eq "select") {$mode = "tags"; $kpos = $xpos; $xpos = 0}
		}
		"RightArrow" {
			$ypos = -1
			$zpos = 0
			$xpos++
			if ($mode -ne "select") {$mode = "disable"}
		}
		"LeftArrow" {
			$ypos = -1
			$zpos = 0
			$xpos--
			if ($mode -ne "select") {$mode = "disable"}
		}
		"Enter" {
			if ($ypos -ge 0) {
				$app = $elements[$ypos].name
				$option = $optionList[$xpos]
				if ($app -in $apps) {[void]$apps.Remove($app)} else {[void]$apps.Add($app)}
				if (($app -eq $elements[-1].Name) -and ($option -eq $confirm)) {
					$ypos--
					$zpos = [math]::Floor(($elements.count-2)/10)*10
				}
			} else {
				$option = $optionList[$xpos]
				switch ($option) {
					$category[$xpos] {
						$mode = "tags"
						$kpos = $xpos
						$xpos = 0
					}
					$menu {
						$mode = "select"
						$xpos = $kpos
						$optionList = $category
					}
					$search {
						$mode = "search"
						clean
						pos 2 1
						[console]::CursorVisible = $true
						[string]$text = read-host
						[console]::CursorVisible = $false
					}
					$confirm {
						$stage = "install"
						clean
					}
				}
			}
		}
	}
	if ($xpos -lt 0) {$xpos = $optionList.count -1}
	if ($xpos -ge $optionList.count) {$xpos = 0}
	if ($ypos -lt -1) {$ypos = $elements.count -1; $zpos = [math]::Floor(($elements.count-1)/10)*10}
	if ($ypos -ge $elements.count) {$ypos = -1; $zpos = 0}
	if ($zpos -lt 0) {$zpos = 0}
}

#ПРОВЕРКА ВЫХОДА
if ($apps.count -eq 0) {$stage = "exit"}

#УСТАНОВКА
while ($stage -eq "install") {
	[console]::CursorVisible = $true
	for ($i = 0; $i -le $apps.count; $i++) {
		
		#ПОДСЧЕТ
		[array]$install = $apps | Select @{
			Name = "Description"
			Expression = {
				if ($_ -in $data.name) {($data | where Name -eq $_).Description} else {$_}
			}
		}, @{
			Name = "State"
			Expression = {
				$app = $_
				$appindex = $apps.indexof(($data | where Name -eq $_).Name)
				switch ($appindex) {
					{$apps.indexof($app) -gt $i} {"Waiting"; Continue}
					{$apps[$i] -eq $app} {"Running"; Continue}
					{$_ -eq "-1"} {"Failed"; Continue}
					{$_ -lt $i} {"Completed"; Continue}
				}
			}
		}
		[string]$count = "" + $i + "/" + $apps.count
		[string]$percent = " " + [Math]::Round(($i) / $apps.count * 100,0) + "%"
		[int]$filledLength = [Math]::Round(($i) / $apps.count * (53 - $count.length - $percent.length))
		[int]$emptyLength = (53 - $count.length - $percent.length) - $filledLength
		[string]$bar = (color ("$count") 7) + (color (" " * $filledLength) 7) + (color ("$percent") 7) + (color (" " * $emptyLength) 100)
		$install = ($install | ft @{Expression={$_.Description}; Width=37; Alignment="Left"}, @{Expression={$_.State}; Width=15; Alignment="Right"} -HideTableHeaders | Out-String -stream).Trim() | where {$_}
		
		#ВЫВОД
		clean
		pos 2 1
		if ($i -eq $apps.count) {"Installation complete"} else {"Installation process"}
		draw 3 55 ($install[$zpos..($zpos+9)].count + 2)
		if (($i -gt 9) -and ($i -lt $apps.count)) {$zpos++}
		$install[$zpos..($zpos+9)] | where {$_} | foreach {pos 2 ($install[$zpos..($zpos+9)].indexof($_) + 4); $_}
		pos 2 ($install[$zpos..($zpos+9)].count + 5)
		$bar + "`n" + "`n"
		
  		#ЗАПУСК
		if ($i -ne $apps.count) {
			try {
				& ($data | Where Name -eq $apps[$i]).Code
			} catch {
				" " + (color ([string]$apps[$i] + " not found") 91)
				Start-Sleep 5
			}
		}
  		[console]::CursorVisible = $false
	}
	Start-Sleep 5
	$stage = "exit"
}

#ЗАВЕРШЕНИЕ РАБОТЫ
cd \
Remove-Item -Recurse -Force -ErrorAction 0 $path
clean
pos 2 1
"Bye, $Env:UserName"
Start-Sleep 5
Exit
