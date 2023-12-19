#ПАРАМЕТРЫ
[CmdletBinding()]
param ([Parameter(ValueFromRemainingArguments=$true)][System.Collections.ArrayList]$apps = @())

#ФУНКЦИИ
function cleaner () {$e = [char]27; "$e[H$e[J" + "`n" + "uffemcev.github.io/utilities" + $tips + "`n"}
function color ($text, $number) {$e = [char]27; "$e[$($number)m" + $text + "$e[0m"}
function close () {(get-process | where MainWindowTitle -eq $host.ui.RawUI.WindowTitle).id | where {taskkill /PID $_}}

#ЗНАЧЕНИЯ
cleaner
"Please wait, $Env:UserName"
[console]::CursorVisible = $false
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$host.ui.RawUI.WindowTitle = 'utilities ' + [char]::ConvertFromUtf32(0x1F916)
[array]$data = &([ScriptBlock]::Create((irm uffemcev.github.io/utilities/apps.ps1)))
[string]$path = [System.IO.Path]::GetTempPath() + "utilities"
[bool]$install = $false
[bool]$menu = $false
[bool]$select = $false
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
	$menu = $true
} else {[System.Collections.ArrayList]$apps = @()}

#НАЧАЛО РАБОТЫ
winget settings --enable InstallerHashOverride | out-null
ri -Recurse -Force -ErrorAction 0 $path
cd (ni -Path $path -ItemType "directory")
cleaner

#МЕНЮ
while ($menu -ne $true) {
	
	#ПОДСЧЕТ
	[array]$category = [array]'All' + [array]$($data.tag | select -Unique)
	[array]$reset = 'Reset'
	[array]$confirm = if ($apps) {'Confirm'} else {'Exit'}
	[array]$tagsList = if ($select -eq $true) {[array]$category} else {[array]$category[$kpos] + [array]$reset + [array]$confirm}
	
	[array]$elements = for ($i = 0; $i -lt $tagsList.count; $i++) {
		$tag = $tagsList[$i]
		if ($i -eq $xpos) {
			switch ($tag) {
				'All' {$data}
				{$_ -in $data.tag} {$data | where Tag -eq $tag}
				$confirm {$data | where Name -in $apps}
				$reset {}
			}
		}
	}

	[array]$tags = for ($i = 0; $i -lt $tagsList.count; $i++) {
		$tag = $tagsList[$i]
		if (($i -eq $xpos) -and ($ypos -eq -1)) {color $tag 7}
		elseif ($i -eq $xpos) {color $tag 4}
		else {$tag}
	}

	[array]$descriptions = for ($i = 0; $i -lt $elements.count; $i++) {
		$element = $elements[$i]
		if (($element.Name -in $apps) -and ($i -eq $ypos)) {(color "[$($i+1)]" 7) + " " + (color $element.Description 7)}
		elseif ($element.Name -in $apps) {(color "[$($i+1)]" 7) + " " + $element.Description}
		elseif ($i -eq $ypos) {"[$($i+1)]" + " " + (color $element.Description 7)}
		else {"[$($i+1)]" + " " + $element.Description}
	}
	
	[array]$tagsTips = for ($i = 0; $i -lt $tagsList.count; $i++) {
		$tag = $tagsList[$i]
		if (($i -eq $xpos) -and ($ypos -eq -1)) {
			switch ($tag) {
				DEFAULT {"/change_category"}
				'Reset' {"/full_reset"}
				'Exit' {"/exit_from_script"}
				'Confirm' {"/confirm_your_choice"}
			}
		}
	}
	
	[array]$descriptionsTips = for ($i = 0; $i -lt $elements.count; $i++) {
		$app = $elements[$i].name
		if ($i -eq $ypos) {
			switch ($app) {
				{$_ -notin $apps} {"/select_$($app)"}
				{$_ -in $apps} {"/unselect_$($app)"}
			}
		}
	}
	
	[array]$tips = [array]$tagsTips + [array]$descriptionsTips
	
	[string]$page = " " + (($zpos/10)+1) + "/" + ([math]::Ceiling($elements.count/10)) + " "
	
	#ВЫВОД
	cleaner
	if ($select -eq $true) {'< ' + $tags[$xpos] + ' >' + "`n"} else {[string]$tags + "`n"}
	if ($descriptions) {
		$descriptions[$zpos..($zpos+9)]
		"`n" + [char]::ConvertFromUtf32(0x0001F4C4) + $page
	}
	
	#УПРАВЛЕНИЕ
	switch ([console]::ReadKey($true).key) {
		"UpArrow" {
			$ypos--
			if ($ypos -lt $zpos) {$zpos -= 10}
			if ($select -eq $true) {$select = $false; $kpos = $xpos; $xpos = 0; [array]$tagsList = [array]$category}
		}
		"DownArrow" {
			$ypos++
			if ($ypos -gt $zpos+9) {$zpos += 10}
			if ($select -eq $true) {$select = $false; $kpos = $xpos; $xpos = 0; [array]$tagsList = [array]$category}
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
			$tag = $tagsList[$xpos]
			if ($ypos -ge 0) {
				if ($app -in $apps) {$apps.Remove($app)} else {$apps.Add($app)}
				if (($app -eq $elements[-1].Name) -and ($tag -eq 'Confirm')) {
					$ypos--
					$zpos = [math]::Floor(($elements.count-2)/10)*10
				}
			} else {
				switch ($tag) {
					DEFAULT {
						if ($select -eq $true) {$select = $false; $kpos = $xpos; $xpos = 0}
						else {$select = $true; $xpos = $kpos; [array]$tagsList = [array]$category}
					}
					$confirm {
						cleaner
						$menu = $true
					}
					$reset {
						[System.Collections.ArrayList]$apps = @()
						[bool]$select = $false
						[int]$ypos = -1
						[int]$xpos = 0
						[int]$zpos = 0
						[int]$kpos = 0
					}
				}
			}
		}
	}
	if ($xpos -lt 0) {$xpos = $tagsList.count -1}
	if ($xpos -ge $tagsList.count) {$xpos = 0}
	if ($ypos -lt -1) {$ypos = $elements.count -1; $zpos = [math]::Floor(($elements.count-1)/10)*10}
	if ($ypos -ge $elements.count) {$ypos = -1; $zpos = 0}
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
ri -Recurse -Force -ErrorAction 0 $path
close
