<#
Author: Timothee Frily
Purpose: Install and config 
#>

#--------------Variables---------------#
$ComputerName = "SRV-DC-01"


#----OUNames----#
$OUNameTeam = "Team3"
$OUNameUsers = "Users"
$OUNameComputer = "Computers"

#----DCNames----#
$DCNameTeam = "team3"


$NetBiosName = "TEAM3"


#----Passwords----#
$DomainPassword = ConvertTo-SecureString 'Pa$$w0rd' -AsPlainText -Force
$
#--------------Functions---------------#
function Rename-Computers {
    Write-Host "Un redémarrage de la machine est nécessaire a la fin de cette action"
    Rename-Computer -NewName $ComputerName 
    shutdown.exe -r /t 0
}
function Install-AD {
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools # OK
    Import-Module ADDSDeployement #OK
    Install-ADDSForest -DomainName "$DCNameTeam.local" -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "7" -DomainNetbiosName $NetBiosName -ForestMode "7" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$True -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword $DomainPassword
    Write-Host "La machine rebootera dans 5 secondes"
    sleep 5
    shutdown.exe -r /t 0
}

function Set-OU {
    New-ADOrganizationalUnit -Name $OUNameTeam -Path "DC=$DCNameTeam,DC=local"
    New-ADOrganizationalUnit -Name $OUNameUsers -Path "OU=$OUNameTeam,DC=$DCNameTeam,DC=local"
    New-ADOrganizationalUnit -Name $OUNameComputer -Path "OU=$OUNameTeam,DC=$DCNameTeam,DC=local"
    
}
function Set-Users {
    New-ADUser -Name "user_1" -GivenName "user1" -Surname "user1" -SamAccountName "user_1" -UserPrincipalName "user_1@team1.local" -Path "OU=Users,OU=Team1,DC=Team1,DC=local" -AccountPassword(Read-Host -AsSecureString "Type Password for User") -Enabled $true
    New-ADUser -Name "user_2" -GivenName "user2" -Surname "user2" -SamAccountName "user_2" -UserPrincipalName "user_2@team1.local" -Path "OU=Users,OU=Team1,DC=Team1,DC=local" -AccountPassword(Read-Host -AsSecureString "Type Password for User") -Enabled $true
}

function Install-NTP {
     
    
}


function Check-Configuration {
   
    
}


#--------------Main---------------#
if (!($env:COMPUTERNAME -eq "SRV-DC-01")) {
    Rename-Computers
}
if (condition) {
    
}
