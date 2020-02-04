<#
Author: Timothee Frily, Samuel Malherbe
Purpose: Install and config Active Directory
Warning : NTP command in this script don't work with vmware workstation
#>

#--------------Variables----------------------------------------------------------------------------------------------------------------#
$ComputerName = "SRV-DC-01"


#----OUNames----#
$OUNameTeam = "Team3"
$OUNameUsers = "Users"
$OUNameComputer = "Computers"

#----DCNames----#
$DCNameTeam = "team3"

#----NetBiosName----#
$NetBiosName = "TEAM3"


#----Passwords----#
$DomainPassword = ConvertTo-SecureString 'Pa$$w0rd' -AsPlainText -Force

#----SetUsers----#
$UsersPassword  = ConvertTo-SecureString 'Pa$$w0rd' -AsPlainText -Force

#--------------Functions-----------------------------------------------------------------------------------------------------------------#
function Rename-Computers {
    Write-Host "Un redémarrage de la machine est nécessaire a la fin de cette action"
    Rename-Computer -NewName $ComputerName 
    shutdown.exe -r /t 0
} # ---> ok
function Install-AD {
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools # OK
    Import-Module ADDSDeployment #OK
    Install-ADDSForest -DomainName "$DCNameTeam.local" -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "7" -DomainNetbiosName $NetBiosName -ForestMode "7" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$True -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword $DomainPassword
    Write-Host "La machine rebootera dans 5 secondes"
    shutdown.exe -r /t 5
} # ----> ok

function Set-OU {
    New-ADOrganizationalUnit -Name $OUNameTeam -Path "DC=$DCNameTeam,DC=local"
    New-ADOrganizationalUnit -Name $OUNameUsers -Path "OU=$OUNameTeam,DC=$DCNameTeam,DC=local"
    New-ADOrganizationalUnit -Name $OUNameComputer -Path "OU=$OUNameTeam,DC=$DCNameTeam,DC=local"
    
}
function Set-Users {
    New-ADUser -Name "user_1" -GivenName "user1" -Surname "user1" -SamAccountName "user_1" -UserPrincipalName "user_1@$DCNameTeam.local" -Path "OU=$OUNameUsers,OU=$OUNameTeam,DC=$DCNameTeam,DC=local" -AccountPassword $UsersPassword -Enabled $true
    New-ADUser -Name "user_2" -GivenName "user2" -Surname "user2" -SamAccountName "user_2" -UserPrincipalName "user_2@$DCNameTeam.local" -Path "OU=$OUNameUsers,OU=$OUNameTeam,DC=$DCNameTeam,DC=local" -AccountPassword $UsersPassword -Enabled $true
}

# Ces commandes ne fonctionne pas sur VMWARE workstation.
function Install-NTP {
    Stop-Service W32Time
    w32tm.exe /config /syncfromflags:MANUAL /manualpeerlist:time-a-g.nist.gov,time-b-g.nist.gov,time-c-g.nist.gov,time-d-g.nist.gov /reliable:YES
    Start-Service W32Time
    w32tm.exe /resync /rediscover
}


#--------------Main-----------------------------------------------------------------------------------------------------------------#
#----Check Computer Name----#
if (!($env:COMPUTERNAME -eq $ComputerName)) {
    Rename-Computers
}

#---Check AD---#
if (!((Get-WindowsFeature -Name "AD-Domain-services").InstallState) -eq "Installed") {
    Install-AD
}

#---Check OU---#
if (!(Get-ADOrganizationalUnit -filter *).name -match $OUNameTeam -and $OUNameUsers -and $OUNameComputer) {
    Set-OU
    
}

#---Check Users---#
if (!(Get-Aduser -filter *).name -match "user_1" -and "user_2") {
     Set-Users
}

#---Check NTP---#
Install-NTP
w32tm.exe /query /source
Write-Host "Here the NTP server check if this is the right name"