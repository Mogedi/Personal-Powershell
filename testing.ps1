function device_manager {
	Get-WmiObject Win32_PNPEntity | sort -Property caption | select caption,status | Where-Object {$_.status -like "Error"}
}

function power {
	powercfg.exe -l

	powercfg.exe -Change -monitor-timeout-ac 15
	powercfg.exe -Change -monitor-timeout-dc 15
	powercfg.exe -Change -standby-timeout-ac 15
	powercfg.exe -Change -standby-timeout-dc 15
	#powercfg.exe -Change -hibernate-timeout-ac 15
	#powercfg.exe -Change -hibernate-timeout-dc 15
}

function firewall {
	$private_firewall_boolean = [System.Convert]::ToBoolean((Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile).EnableFirewall)

	$domain_firewall_boolean = [System.Convert]::ToBoolean((Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile).EnableFirewall)

	$public_firewall_boolean = [System.Convert]::ToBoolean((Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile).EnableFirewall)

	if ($private_firewall_boolean -Or $public_firewall_boolean -Or $domain_firewall_boolean) {
		if (!(New-Object Security.Principal.WindowsPrincipal (
			[Security.Principal.WindowsIdentity]::GetCurrent())
			).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
				Write-Host NOT ADMIN -foregroundcolor red
			} else {
				netsh.exe advfirewall set allprofiles state off

				$private_firewall_boolean = [System.Convert]::ToBoolean((Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile).EnableFirewall)

				$domain_firewall_boolean = [System.Convert]::ToBoolean((Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile).EnableFirewall)

				$public_firewall_boolean = [System.Convert]::ToBoolean((Get-ItemProperty Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile).EnableFirewall)
			}
	}

	if ($private_firewall_boolean)
	{
		Write-Host "Private FirewallPolicy: " -nonewline
		Write-Host $private_firewall_boolean -foregroundcolor red
	}

	if (!$private_firewall_boolean)
	{
		Write-Host "Private FirewallPolicy: " $private_firewall_boolean
	}

	if ($public_firewall_boolean)
	{
		Write-Host "Private FirewallPolicy: " -nonewline
		Write-Host $public_firewall_boolean -foregroundcolor red
	}

	if (!$public_firewall_boolean)
	{
		Write-Host "Private FirewallPolicy: " $public_firewall_boolean
	}

	if ($domain_firewall_boolean)
	{
		Write-Host "Private FirewallPolicy: " -nonewline
		Write-Host $domain_firewall_boolean -foregroundcolor red
	}

	if (!$domain_firewall_boolean)
	{
		Write-Host "Private FirewallPolicy: " $domain_firewall_boolean
	}
}

function Version {
	(Get-WmiObject -class Win32_OperatingSystem).Caption
}

function test {
	Write-Host (Test-Connection 8.8.8.8 -count 1 -quiet)
}

function mini {
	$shell = New-Object -ComObject "Shell.Application"
	$shell.minimizeall()
}

function screenResolution {
	$resolution = (Get-WmiObject -Class Win32_DesktopMonitor | Select-Object ScreenWidth,ScreenHeight)

	Foreach ($item in $resolution)
	{
		$Width = [math]::floor($item.ScreenWidth / 1920)
		$Height = [math]::floor($item.ScreenHeight / 1080)

		Write-Host "Width: " $Width "Height: " $Height
	}

	Write-Host "Total Screens: `t `t" -nonewline
	Write-Host $resolution.length -foregroundcolor blue

}

function change_firewall
{
	if (!(New-Object Security.Principal.WindowsPrincipal (
		[Security.Principal.WindowsIdentity]::GetCurrent())
		).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
			Write-Host running NOT as Admin -foregroundcolor red
		} else {
			netsh.exe advfirewall set allprofiles state off
		}
}

#(New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
