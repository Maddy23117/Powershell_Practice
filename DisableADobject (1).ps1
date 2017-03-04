
<#
.Synopsis
   Disable Users in AD And Exchange

.DESCRIPTION

   it will disable AD users and remove form groups,Disable mailbox in Exchange

.EXAMPLE

   for multiple users

   .\DisableADobject.ps1 -connectionuri Ex.http://myserver.mydomain/PowerShell/ (Exchnage powershell URL)  | get-content -path <filename>.txt


   for Single user

   .\DisableADobject.ps1 -Samaccountnames (Email address / Samaccountname) -connectionuri Ex.http://myserver.mydomain/PowerShell/ 

#>


param ([Parameter(Mandatory=$true,                   ValueFromPipeline=$true)][alias("Samaccountname")]$Samaccountnames,[Parameter(Mandatory=$true,helpmessage="http://myserver.mydomain/PowerShell/")]$connectionuri)

$ErrorActionPreference = "Slientlycontinue"

#Enter your servername at the -ConnectionURI
Import-PSSession $(New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $connectionuri -Authentication Kerberos)

#importing Activedirectoy module

if (! (Get-Module ActiveDirectory) ) 
                 {
                   Import-Module ActiveDirectory -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                   Write-Host "`t` [INFO] ('ActiveDirectory Powershell Module Loaded')"
                   Write-Verbose -Message "Active directory Module import successfully"
                   
   
                 }
             else 
                 { 
                  Write-Host "`t` [INFO] ('ActiveDirectory Powershell Module Already Loaded')"
                  Write-Verbose -Message "ActiveDirectory Powershell Module Already Loaded"
                }

    Get-PSSnapin -Registered | Add-PSSnapin | Out-Null
    Write-Verbose "Being Process"
    Write-Host -ForegroundColor Green "`t` [INFO] Checking User"
     Foreach ($Samaccountname in $Samaccountnames)
       {
      try
        {
        $user = Get-ADUser -Filter {mail -eq $Samaccountname -or samaccountname -eq $samaccountname } -Properties *
        if ($user -ne $null)
         {
         $userssamaccountname = $user.samaccountname
         $userdis = $user.distinguishedname
         $userEmail = $user.emailaddress
         $username = $user.name
         ###################################################
         #remoiving Groups
         ###################################################
         try
           {
             Write-Verbose "Removing Users from group"
             $groupremove = Get-ADPrincipalGroupMembership -Identity $userssamaccountname | % {if ($_.name -eq "Domain users"){$null}else{Remove-ADPrincipalGroupMembership -Identity $userssamaccountname -MemberOf $_ -Confirm:$false}} 
             Write-Host -ForegroundColor green "`t`[Info]:- $username Removed from the group"
            }
         Catch
           {
             $ErrorMessage = $_.Exception.Message
             Write-Host -ForegroundColor Red "`t`[ERROR]:- $ErrorMessage"
            }
         ###################################################
         #Disable for mailbox
         ###################################################
         try
           {
             Write-Verbose "Disablign Mailbox"
             $disableMailbox = disable-mailbox -identity $userssamaccountname -confirm:$false
             Write-Host -ForegroundColor Green "`t`[INFO]:- $username Mailbox has been disable"
            }
         Catch
           {
             $ErrorMessage = $_.Exception.Message
             Write-Host -ForegroundColor Red "`t`[ERROR]:- $ErrorMessage"
            }
         ###################################################
         #Disabling Ad object
         ###################################################
         try
           {
             Write-Verbose "Disable AdAccount"
             $addisable = Disable-ADAccount -Identity $userssamaccountname -Confirm:$false
             Write-Host -ForegroundColor Green "`t`[Info]:- $username Account has been disable"
            }
         Catch
           {
             $ErrorMessage = $_.Exception.Message
             Write-Host -ForegroundColor Red "`t`[ERROR]:- $ErrorMessage"
            }
         <###################################################
         #Moving Ad object
         ###################################################
         try
           {
             Write-Verbose "Moving to OU"
             $moveUser = Get-ADUser -Identity $userssamaccountname | Move-ADObject  -TargetPath $DeleteOU -Confirm:$false
             Write-Host -ForegroundColor Green "`t`[INFO] :- $username Account has been move to OU"
            }
         Catch
           {
             $ErrorMessage = $_.Exception.Message
             Write-Host -ForegroundColor Red "`t`[ERROR]:- $ErrorMessage"
            }#>
         
         }
        else
          {
         Write-Host -ForegroundColor Red "`t`[Error]:- $Samaccountname User Not Found"
         continue
        }
        }
      catch
        {
        $ErrorMessage = $_.Exception.Message
        Write-Host -ForegroundColor Red "`t`[ERROR]:- $ErrorMessage"
        }
        }
   