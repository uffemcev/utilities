#ПАРАМЕТРЫ
[CmdletBinding()]
param ([Parameter(ValueFromRemainingArguments=$true)][System.Collections.ArrayList]$apps = @())

#ФУНКЦИИ
function cleaner () {$e = [char]27; "$e[H$e[J" + "`n" + "uffemcev.github.io/utilities" + $tip + "`n"}
function color ($text, $number) {$e = [char]27; "$e[$($number)m" + $text + "$e[0m"}
function close () {(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {taskkill /PID $_}}

#ЗНАЧЕНИЯ
cleaner
"Please wait, $Env:UserName"
[console]::CursorVisible = $false
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$host.ui.RawUI.WindowTitle = [char]::ConvertFromUtf32(0x1F916) + ' utilities'
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
		cleaner
	}
} else {throw}

#ПРОВЕРКА ПАРАМЕТРОВ
if ($apps) {
	foreach ($tag in ($data.tag | Select -Unique))  {
		if ($tag -in $apps) {($data | where tag -eq $tag).Name | foreach {$apps.add($_)}}
		($apps | where {$_ -eq $tag}) | foreach {$apps.Remove($_)}
		cleaner
	}
	if ($apps -contains "all") {$apps = $data.Name}
	$apps = [array]($apps | Sort-Object -unique)
	$stage = 'install'
} else {[System.Collections.ArrayList]$apps = @()}

#НАЧАЛО РАБОТЫ
winget settings --enable InstallerHashOverride | out-null
ri -Recurse -Force -ErrorAction 0 $path
cd (ni -Path $path -ItemType "directory")
cleaner

#МЕНЮ
while ($stage -eq 'menu') {
	
	#ПОДСЧЕТ
	[array]$category = @('All') + $($data.tag | select -Unique)
	[string]$confirm = if ($apps) {'Confirm'} else {'Exit'}
	[array]$tagList = if ($mode -eq 'select') {$category} else {'Apps', 'Group', $confirm}
	
	[array]$elements = switch ($tagList[$xpos]) {
		'Apps' {if ($category[$kpos] -eq 'All') {$data} else {$data | where Tag -eq $category[$kpos]}}
		'All' {$data}
		{$_ -in $data.tag} {$data | where Tag -eq $tagList[$xpos]}
		$confirm {$data | where Name -in $apps}
	}

	[array]$tags = for ($i = 0; $i -lt $tagList.count; $i++) {
		$tag = $tagList[$i]
		if (($i -eq $xpos) -and ($ypos -eq -1)) {color $tag 7} else {$tag}
	}

	[array]$descriptions = for ($i = 0; $i -lt $elements.count; $i++) {
		$element = $elements[$i]
		if (($element.Name -in $apps) -and ($i -eq $ypos)) {(color "[$($i+1)]" 7) + " " + (color $element.Description 7)}
		elseif ($element.Name -in $apps) {(color "[$($i+1)]" 7) + " " + $element.Description}
		elseif ($i -eq $ypos) {"[$($i+1)]" + " " + (color $element.Description 7)}
		else {"[$($i+1)]" + " " + $element.Description}
	}
	
	[array]$tagTip = if ($ypos -eq -1) {
		switch ($tagList[$xpos]) {
			'Apps' {
				$name = $category[$kpos]
				$names = if ($name -eq 'All') {$data.Name} else {($data | where Tag -eq $name).name}
				$compare = Compare $apps $names -Exclude -Include
				if ($compare) {"/unselect_$($category[$kpos].ToLower())"} else {"/select_$($category[$kpos].ToLower())"}
			}
			$category[$xpos] {"/group_by_$($category[$xpos].ToLower())"}
			'Group' {"/group_by_category"}
			'Exit' {"/exit_from_script"}
			'Confirm' {"/confirm_your_choice"}
		}
	}
	
	[array]$descriptionTip = if ($ypos -ge 0) {
		switch ($elements[$ypos].name) {
			{$_ -notin $apps} {"/select_$($elements[$ypos].name)"}
			{$_ -in $apps} {"/unselect_$($elements[$ypos].name)"}
		}
	}
	
	[array]$tip = $tagTip + $descriptionTip
	
	[string]$page = " " + (($zpos/10)+1) + "/" + ([math]::Ceiling($elements.count/10)) + " "
	
	#ВЫВОД
	cleaner
	if ($mode -eq 'select') {'< ' + $tags[$xpos] + ' >' + "`n"} else {[string]$tags + "`n"}
	if ($descriptions) {
		$descriptions[$zpos..($zpos+9)]
		"`n" + [char]::ConvertFromUtf32(0x0001F4C4) + $page
	}
	
	#УПРАВЛЕНИЕ
	switch ([console]::ReadKey($true).key) {
		"UpArrow" {
			$ypos--
			if ($ypos -lt $zpos) {$zpos -= 10}
			if ($mode -eq 'select') {$mode = 'disable'; $kpos = $xpos; $xpos = 0}
		}
		"DownArrow" {
			$ypos++
			if ($ypos -gt $zpos+9) {$zpos += 10}
			if ($mode -eq 'select') {$mode = 'disable'; $kpos = $xpos; $xpos = 0}
		}
		"RightArrow" {
			$ypos = -1
			$zpos = 0
			$xpos++
		}
		"LeftArrow" {
			$ypos = -1
			$zpos = 0
			$xpos--
		}
		"Enter" {
			$app = $elements[$ypos].name
			$tag = $tagList[$xpos]
			if ($ypos -ge 0) {
				if ($app -in $apps) {$apps.Remove($app)} else {$apps.Add($app)}
				if (($app -eq $elements[-1].Name) -and ($tag -eq 'Confirm')) {
					$ypos--
					$zpos = [math]::Floor(($elements.count-2)/10)*10
				}
			} else {
				switch ($tag) {
					'Apps' {
						$name = $category[$kpos]
						$names = if ($name -eq 'All') {$data.Name} else {($data | where Tag -eq $name).name}
						$compare = Compare $apps $names -Exclude -Include
						if ($compare) {$names | foreach {$apps.remove($_)}}
						else {$names | foreach {$apps.add($_) | out-null}}
					}
					$category[$xpos] {
						if ($mode -eq 'select') {$mode = 'disable'; $kpos = $xpos; $xpos = 0}
					}					
					'Group' {
						$mode = 'select'
						$xpos = $kpos
						$tagList = $category
					}
					$confirm {
						cleaner
						$stage = 'install'
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
	$stage = 'exit'
}

#ЗАВЕРШЕНИЕ РАБОТЫ
cleaner
"Bye, $Env:UserName"
start-sleep 5
cd \
ri -Recurse -Force -ErrorAction 0 $path
close
