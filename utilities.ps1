function install
{
param
(  
	[Parameter(Mandatory = $true)]
	[string]
	$auto
)

if ($auto -eq 0) {Choose}
if ($auto -eq 1) {All}
}


function Choose
{
param
(
	[Parameter(Mandatory=$true)][int]$age,
	[Parameter(Mandatory=$true)][int]$sex,
	[Parameter(Mandatory=$true)][int]$location
)

if ($age){Age}

if ($sex){Sex}

if ($location){Location}
}

function All
{
	Age; Sex; Location
}

function Age
{
	Write-host "Age"
}

function Sex
{
	Write-host "Sex"
}

function Location
{
	Write-host "Location"
}
