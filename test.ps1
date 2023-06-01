Import-Module Selenium

$options = [OpenQA.Selenium.Chrome.ChromeOptions]::new() 
$options.BinaryLocation = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$driver = [OpenQA.Selenium.Chrome.ChromeDriver]::new($options)

$Url = "https://reserves.dkrasnov.dev/"
Enter-SeUrl -Driver $Driver -Url $Url

function finds ($object, $type)
{
	switch ($type)
	{
		"name" {Find-SeElement -Driver $driver -name $object -Timeout 30}
		"class" {Find-SeElement -Driver $driver -ClassName $object -Timeout 30}
		"id" {Find-SeElement -Driver $driver -Id $object -Timeout 30}
		"text" {Find-SeElement -Driver $driver -XPath "//*[text()=`'$object`']" -Timeout 30}
	}
}

function writes ($object, $type, $text)
{
	$element = finds -object $object -type $type
	Send-SeKeys -Element $element -Keys $text
}

function clicks ($object, $type)
{
	$element = finds -object $object -type $type
	Send-SeClick -Driver $driver -Element $element -JavaScriptClick
}

writes -object "login" -type "name" -text "expert"

writes -object "password" -type "name" -text "654321"

clicks -object "Войти" -type "text"

clicks -object "Фотографии" -type "text"