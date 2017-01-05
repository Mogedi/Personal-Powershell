function exp {
  explorer.exe .
}

function shortenPrompt {
    #Put in your custom PS profile
    $p = Split-Path -leaf -path (Get-Location)
    "$p> "
}

function YelpRequestToken {
    $url = 'https://api.yelp.com/oauth2/token?grant_type=client_credentials&client_secret=' + $global:YelpAppSecret + '&client_id=' + $global:YelpAppID
    Invoke-WebRequest $url -OutFile "C:\Users\mohamud.gedi\Desktop\yelpRequestToken.json" -method Post
}

function YelpCallAPI {
    $param = @{ "Authorization" = "Bearer btM-3Y6yDwTCWn1CaGC_XCGBmufPzdXKmfLwdy3sE87DOXv6n2RRcncCIQcaCdRWrUhqldqWJxZEGHEOqFKVfHk6gsrZRyMDPRFLx2QjqrzPiBZ3qj2TqbtirVlQWHYx"}
    $url = 'https://api.yelp.com/v3/businesses/search?location=30033'
    Invoke-WebRequest $url -Headers $param -OutFile "C:\Users\mohamud.gedi\Desktop\yelpReturnedData.json"
}

function slackMessage() {
	Param(
		[Parameter (Position = 0, ValueFromPipelineByPropertyName=$true)] [AllowEmptyString()] [string]$channel,
		[Parameter(Mandatory = $true)]
		[AllowEmptyString()] $inputText,
		[string]$username = "@mogedi"
	)

	$channelsListing += slackChannels

	$counter = 0;

	if ($channel -eq "")
	{
		Write-Host ""

		ForEach ($item in $channelsListing) {
			Write-Host "$($counter): $($channelsListing[$counter])"
			$counter++
		}

		Write-Host ""

		$targetChannel = Read-Host "Who do you wish to send the message to?"

		$channel = $channelsListing[$targetChannel]
	}

	if ($targetChannel -eq "")
		{
			$channel = "@mogedi"
		}
	if ($inputText -eq "")
		{
			$text = "Hello from PowerShell"
		}

	if ($inputText -ne "")
		{
			$text = $inputText
		}

	if ($targetChannel -eq "" -and $inputText -eq "")
		{
			$channel = "@mogedi"
			$text = "You didn't specify a person or a message"

		}

	$postSlackMessage = @{token = $global:slackToken; channel = $channel; text = $text; username = $username; as_user = "true"; parse = 'full'}

	Invoke-RestMethod -Uri https://slack.com/api/chat.postMessage -Body $postSlackMessage
}

function slackChannels {
	$channelsName = @()

	$channelData = @{token = $global:slackToken; exclude_archived = 1}

	$data = Invoke-RestMethod -Uri https://slack.com/api/channels.list -Body $channelData

	ForEach($item in $data.channels + "\n") {
		if ($item.is_member -eq $true){
				$channelsName += "#"+ $item.name
		}
	}

	$groupName = @()

	$groupData = @{token = $global:slackToken; exclude_archived = 1}

	$data = Invoke-RestMethod -Uri https://slack.com/api/groups.list -Body $groupData

	ForEach($item in $data.groups + "\n") {
		if($item.is_mpim -eq $false){
			$groupName += "@" + $item.name
		}
	}

	$final = @("@mogedi", "@apages", "@davidbasarab", "@ricardo.diaz", "@abel.henry", "@jarred.blair")

	$final += $channelsName

	$final += $groupName

	return $final
}

function Shell{
	cd C:\Users\mogedi\Documents\WindowsPowerShell
}

function OpenScriptFile {
	atom "C:\Users\mogedi\Documents\WindowsPowerShell\custom_script.ps1"
}

function OpenTestingFile {
  atom "C:\Users\mogedi\Documents\WindowsPowerShell\testing.ps1"
}

function git-commit{
	param
	(
		[parameter(Mandatory=$true)]
		$comment
	)

	iex "cd C:\Shared\GitHub\PowershellModules\Scripts"

	git commit -a -m $comment

	git pull

	git push

	iex "cd ~"
}

function Background {
	Param(
		[Parameter(Position=0)] $feedback = "n",
		[Parameter(Position=1)] $cycle = "n"
	)

	if (Test-Connection 8.8.8.8 -count 1 -quiet) {
		if (Test-Connection 8.8.8.8 -count 1 -quiet) {
			$url = "https://source.unsplash.com/random/1920x1080"

			if (!(Test-Path -LiteralPath ($env:USERPROFILE + '\Pictures\BackgroundPhotos\pic.bmp'))) {
				New-Item (Join-Path $env:USERPROFILE  -ChildPath Pictures\BackgroundPhotos\) -Type Directory
				New-Item (Join-Path $env:USERPROFILE  -ChildPath Pictures\BackgroundPhotos\pic.bmp) -Type File
			} else {
				$myPictureFolder = Join-Path $env:USERNAME  -ChildPath Pictures\BackgroundPhotos\pic.bmp
			}

			$myPictureFolder = Join-Path $env:USERPROFILE  -ChildPath Pictures\BackgroundPhotos\pic.bmp

			Invoke-WebRequest $url -OutFile ('C:\Users\' + $env:USERNAME + '\Pictures\BackgroundPhotos\pic.bmp')

			Start-Sleep -s 3

			Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value ('C:\Users\' + $env:USERNAME + '\Pictures\BackgroundPhotos\pic.bmp')

			Start-Sleep -s 2

			For($i=0; $i -le 100; $i++) {
				rundll32.exe user32.dll, UpdatePerUserSystemParameters
			}

			if($feedback -eq "y") {
				Invoke-Item 'C:\Users\' + $env:USERNAME + '\Pictures\BackgroundPhotos\pic.bmp'

				$reply = Read-Host "Did it work?"

				if ($reply -ne "y") {
					control.exe /name microsoft.personalization
				}

				$save = Read-Host "Do you wish to save?"

				if($save -eq "y") {
					iex "SaveBackgroundPicture"
				}
			}

			if($cycle -eq "y"){
				$repeat = Read-Host "Do you wish to repeat?"
				$save = Read-Host "Do you wish to save?"

				if($repeat -eq "y" -and $save -eq "y"){
					SaveBackgroundPicture
					Start-Sleep -s 1
					Background -feedback n -cycle y
				}
				if($repeat -eq "y"){
					Start-Sleep -s 1
					Background -feedback n -cycle y
				}
				if($save -eq "y") {
					iex "SaveBackgroundPicture"
				}
			}
		} else {
			Write-Host "There is no internet connection" -foregroundcolor red
			Start-Sleep -m 3000
		}
	} else {
		Write-Host "There is no connection" -foregroundcolor red -bold
	}
}

function SaveBackgroundPicture() {
	$incre = Get-Random

  if (!(Test-Path -LiteralPath ($env:USERPROFILE + '\Pictures\Saved\'))) {
    New-Item (Join-Path $env:USERPROFILE  -ChildPath Pictures\Saved\) -Type Directory
  } else {
    $myPictureFolder = Join-Path $env:USERNAME  -ChildPath Pictures\BackgroundPhotos\pic.bmp
  }

	$path = 'C:\Users\' + $env:USERNAME + '\Pictures\BackgroundPhotos\pic.bmp'

	$destination = 'C:\Users\' + $env:USERNAME + '\Pictures\Saved\pic' + $incre + '.bmp'

	iex 'Copy-Item -Path $path -Destination $destination'

	Write-Host $destination
}

function gmaps() {
	$directions = @('https://www.google.com/maps/dir/150+Ottley+Drive+Northeast,+Atlanta,+GA+30324-3925,+USA/3169+Cedar+Brook+Drive,+Decatur,+GA+30033,+USA/@33.8425421,-84.3498968,13z/')

	Start-Process $directions[0]
}

function task() {
	iex "Get-Date | Out-File C:\Users\mohamud.gedi\Favorites\Notes -Append"

	iex "& 'C:\Program Files (x86)\Notepad++\notepad++.exe' C:\Users\mohamud.gedi\Favorites\Notes"
}

function chrome {

	$websites = @("Trello_0", "Trello_1", "Slack", "Outlook", "Teamcity", "GitHub", "Gmail", "Pandora", "Manga", "Messenger", "Youtube")

	$urls = @("https://trello.com/b/Vr0eGTAI/0-devops-devprod-locker", "https://trello.com/b/xyKA1vXn/1-cm-dev-weekly-wip", "https://cinemassive.slack.com/messages/development/team/", "https://outlook.office365.com/owa/?realm=cinemassive.com&exsvurl=1&ll-cc=1033&modurl=0", "http://teamcity/overview.html", "https://github.com/Mogedi", "https://mail.google.com/mail/u/0/", "https://www.pandora.com/", "http://mangastream.com/", "https://www.messenger.com/", "https://www.youtube.com/feed/subscriptions")

	$counter = 0

	$websites | % {
		Write-Host "$($counter): $_"

		$counter++
		}

	$selection = Read-Host "Please make a selection"

	Start-Process $urls[$selection]
}

function file_path {
	$file_Locations = @("C:\Shared\GitHub\PowershellModules", "\\cinenas\ProductDev\EasyUpdateBuilds", "\\cinenas\ProductDev\AdminUtility\CineNetAdminUtility.exe", "\\cinenas\ProductDev", "\\Tigersclaw\Testing\Builds", "\\Enterprise", "\\WhiteStar", "\\JupiterII", "\\Normandy", "\\Galactica", "\\Serenity", "\\Voyager", "\\Starfury", "\\LobbyFX", "\\Nostromo")

	$simple_File_Names = @("PowershellModules", "EasyUpdateBuilds", "AdminUtility", "ProductDev", "Tigersclaw Builds", "Enterprise", "WhiteStar", "JupiterII", "Normandy", "Galactica", "Serenity", "Voyager", "Starfury", "LobbyFX", "Nostromo")

	$counter = 1

	$simple_File_Names | % {
		Write-Host "$($counter): $_"

		$counter++
	}

	$selection = Read-Host "Where do you want to go?"

	explorer.exe $file_Locations[$selection - 1]
}

function zoom($meetingId = "5707912294") {
  $zoomArguments = "--url=zoommtg://zoom.us/join?action=join&confid=dGlkPWIwYzdjZTZiN2I0YTU2YmNhYmE2ZmJjM2Q4ZWY5ZmQz&confno=$meetingId&zc=0&pk=&mcv=0.92.11227.0929&browser=chrome"

  Start-Process $env:ZoomLocation $zoomArguments
}

function c {
	cls
}

function Guess() {
	param (
		[Parameter (Mandatory=$true, HelpMessage = "How many times do you wish to play?")]
		$play = (Read-Host "How many times do you wish to play?")
	)
	$count = 0
	while ($count -lt $play) {
		function geoGuessingBackEnd($num) {
			$loopData = loopPhotoPoolData($num)

			$farm = $loopData[1]
			$server = $loopData[2]
			$id = $loopData[3]
			$secret = $loopData[4]
			$counter = $loopData[5]
			$print = $loopData[6]

			if($num -gt $counter) {
				return "Number to high, please choose a number between 1 and " + $counter
			}

			$geoDevination = geoCalulations

			$url = "https://farm" + $farm[$num] + ".staticflickr.com/" + $server[$num] + "/" + $id[$num] + "_" + $secret[$num] + ".jpg"

			Start-Process $url


			$country = $geoDevination.rsp.photo.location.country.'#text';

			return $country
		}
		function CallFLickr {
			$url = 'https://api.flickr.com/services/rest/?method=flickr.groups.pools.getPhotos&api_key=' + $global:FlickrToken + '&group_id=94823070@N00&extras=geo'

			Invoke-WebRequest -Uri $url -OutFile 'C:\Users\mohamud.gedi\Desktop\data.txt' -PassThru

			[xml]$xmldata = Get-Content 'C:\Users\mohamud.gedi\Desktop\data.txt'

			return $xmldata
		}
		function loopPhotoPoolData( $num, $xmldata ) {
			$xmldata = CallFLickr
			$xmldata.rsp.photos.photo[$num]
			$counter = 0

			Clear-Content 'C:\Users\mohamud.gedi\Desktop\xmldata.txt'
			Clear-Content 'C:\Users\mohamud.gedi\Desktop\xmldata2.txt'

			for( $i = 0; $i -lt $xmldata.rsp.photos.photo.length; $i++) {
				if($xmldata.rsp.photos.photo[$i].longitude -ne 0) {
					$farm += @($xmldata.rsp.photos.photo[$i].farm)

					$server += @($xmldata.rsp.photos.photo[$i].server)

					$id += @($xmldata.rsp.photos.photo[$i].id)

					$secret += @($xmldata.rsp.photos.photo[$i].secret)

					$xmldata.rsp.photos.photo[$i] >> 'C:\Users\mohamud.gedi\Desktop\xmldata.txt'

					if($num -eq $counter) {
						$xmldata.rsp.photos.photo[$i] >> 'C:\Users\mohamud.gedi\Desktop\xmldata2.txt'
						$print =  $xmldata.rsp.photos.photo[$i]
					}

					$counter++
				}
			}
			return @($farm, $server, $id, $secret, $counter, $print)
		}
		function geoCalulations {

			[xml]$xmldata = Get-Content 'C:\Users\mohamud.gedi\Desktop\data.txt'

			$geoLatitude = $xmldata.rsp.photos.photo | foreach {If ($_.longitude -ne "0") {
				return ($_.latitude + ', ' +  $_.longitude)
			}}

			$geoUrls2 = 'https://api.flickr.com/services/rest/?method=flickr.photos.geo.getLocation&api_key=' + $global:FlickrToken + '&photo_id=' + $xmldata.rsp.photos.photo[$num].id

			$geoUrls = 'https://maps.googleapis.com/maps/api/geocode/xml?key=' + $global:GoogleGeoMapToken + '&latlng=' + $geoLatitude[$num]
			Invoke-WebRequest -Uri $geoUrls2 -OutFile 'C:\Users\mohamud.gedi\Desktop\country.txt' -PassThru
			[xml]$xmlLocation = Get-Content 'C:\Users\mohamud.gedi\Desktop\country.txt'

			return $xmlLocation
		}

		$picNum = get-random -maximum 100
		$country = geoGuessingBackEnd($picNum)

		[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

		$title = 'Guess the country'
		$msg   = 'Enter your guess:'

		$text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)

		$i = 0
		$cutoff = 1
		$win = $true

		while($text -ne $country -and $i -lt $cutoff)
		{
			 $title = 'Guess the country'
			 $msg   = 'NOPE, Try Again:'
			 $text = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
			 $i++
			 if($i -eq $cutoff) {
				Add-Type -AssemblyName PresentationCore, PresentationFramework

			 	$ButtonType = [System.Windows.MessageBoxButton]::OK

			 	$MessageboxTitle = "Failure"

			 	$Messageboxbody = "You took too many guesses, the answer was: $($country) "

			 	$MessageIcon = [System.Windows.MessageBoxImage]::Stop

			 	$Result = [System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$MessageIcon)
				$win = $false
			 }
		 }
		if ($win) {
			Add-Type -AssemblyName PresentationCore, PresentationFramework

		 	$ButtonType = [System.Windows.MessageBoxButton]::OK

		 	$MessageboxTitle = "Congragulations"

		 	$Messageboxbody = "Yes, the answer is: $($country) "

		 	$MessageIcon = [System.Windows.MessageBoxImage]::Information

		 	$Result = [System.Windows.MessageBox]::Show($Messageboxbody,$MessageboxTitle,$ButtonType,$MessageIcon)
		}
		$count++
	}
}
