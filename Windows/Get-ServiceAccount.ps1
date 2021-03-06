Import-Module ActiveDirectory

$targetLogonDate = (Get-Date).AddDays(-60)
$servers = Get-ADComputer -Filter * -Properties OperatingSystem,LastLogonDate  | where {$_.OperatingSystem -like "*server*" -and $_.LastLogonDate -gt $targetLogonDate}

$ExcludedAccounts = @("NT AUTHORITY\LocalService", "LocalSystem","NT AUTHORITY\NetworkService","NT AUTHORITY\NETWORK SERVICE","NT AUTHORITY\LOCAL SERVICE")

foreach($computer in $servers)
{
    try
    {    
        #Get Services
        $services = Get-WmiObject -ComputerName $computer.Name  Win32_Service -ErrorAction Stop
    
        foreach ($srv in $services)
        {
            if ($ExcludedAccounts -notcontains $srv.startname  -and $srv.startname -notlike "NT Service\*")
            {
                 $objProps = @{
                        ComputerName =  $computer.Name
                        OS = $computer.OperatingSystem
                        ServiceName = $srv.DisplayName
                        StartAccount = $srv.StartName 
                        Status = $srv.State
                 }
            
                 $obj = New-Object -TypeName PSObject -Property $objProps
                 Write-Output $obj 
                 #Write-Host $computer "," $srv.displayname "," $srv.startname
            }
        
        }
    }
    catch
    {
        Write-Host "Failed to connect to $($computer.Name) remotely!" -ForegroundColor Red
    }
}