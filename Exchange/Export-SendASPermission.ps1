
#$env:PSModulePath
$domainName = $env:USERDOMAIN
$excludedUsers = @("NT AUTHORITY\SELF","$domainName\Domain Admins","DiscoverySearch")

$mailboxes = Get-Mailbox 

foreach($mbox in $mailboxes)
{
    $userID = $mbox.UserPrincipalName
    $SamAccountName = $mbox.SamAccountName
    $DispName = $mbox.DisplayName
    $mailboxGUID = $mbox.ExchangeGuid
    $DN = $mbox.DistinguishedName
    if($mbox.UserPrincipalName -eq $null -or $mbox.UserPrincipalName -eq "")
    {
        $userID = $mbox.Alias
        #Write-Host $upn
    }

    try
    {
#        Get-ADPermission | where {($_.ExtendedRights -like “*Send-As*”) -and ($_.IsInherited -eq $false) -and -not ($_.User -like “NT AUTHORITY\SELF”)} 
        $permission = Get-ADPermission -Identity "$DN" | where {($_.ExtendedRights -like "*Send-As*") -and $_.IsInherited -eq $false -and  $excludedUsers -notcontains $_.User}

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
