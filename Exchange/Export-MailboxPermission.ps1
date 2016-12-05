#$env:PSModulePath
$domainName = $env:USERDOMAIN
$excludedUsers = @("NT AUTHORITY\SELF","$domainName\Domain Admins","DiscoverySearch")

$mailboxes = Get-Mailbox 

foreach($mbox in $mailboxes)
{
    $userID = $mbox.UserPrincipalName
    $mailboxGUID = $mbox.ExchangeGuid
    if($mbox.UserPrincipalName -eq $null -or $mbox.UserPrincipalName -eq "")
    {
        $userID = $mbox.Alias
        #Write-Host $upn
    }

    try
    {
        $permission = Get-MailboxPermission -Identity "$mailboxGUID" | where {$_.IsInherited -eq $false -and  $excludedUsers -notcontains $_.User -and $_.Deny -eq $false}

    }
    catch 
    {
        Write-Host "$_ : $userID "
    }


    foreach ($acl in $permission)
    {
        if ($acl.User -notlike "S-1-5-21-*")
        {
            
            $GrantedUserUPN = Get-Mailbox -Identity "$($acl.User)" -ErrorAction SilentlyContinue
            
            if($GrantedUserUPN -ne "" -and $GrantedUserUPN -ne $null)
            {
                $objAcl = @{
                    UserName = $userID  
                    Email = $mbox.PrimarySmtpAddress
                    GrantedUser = $acl.User
                    GrantedUserUPN = $GrantedUserUPN.PrimarySmtpAddress
                    AccessRight = $acl.AccessRights[0]

                }


                $obj = New-Object -TypeName PSObject -Property $objAcl
                Write-Output $obj        
            }
        }
    }

}