<#
.SYNOPSIS
    Generates Windows Security Event ID 4625 (failed logins) for SIEM testing
    
.DESCRIPTION
    Creates realistic failed authentication events to test:
    - Windows Event Logging
    - Log collection (Winlogbeat)
    - Elasticsearch ingestion
    - Kibana detection rules
    
.NOTES
    Version: 2.0
    Author: Mostafa Essam (0xMOSTA)
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$TargetUser,
    
    [Parameter(Mandatory=$true)]
    [int]$AttemptCount,
    
    [int]$DelayMs = 300,
    
    [switch]$RandomizeSource
)

# Import required assembly
Add-Type -AssemblyName System.DirectoryServices.AccountManagement

# Configuration
$IncorrectPassword = "SIEM_TestPassword123!"  # Will always fail
$eventLogSource = "Security"
$startTime = Get-Date

# Generate random IPs if enabled
$sourceIPs = @("192.168.1.10", "10.0.0.15", "172.16.5.20")
if ($RandomizeSource) {
    $sourceIPs = 1..10 | ForEach-Object { "192.168.1.$_" }
}

Write-Host @"
[ Brute Force Test Configuration ]
Target User:       $TargetUser
Attempts:          $AttemptCount
Delay Between:     ${DelayMs}ms
Randomize Sources: $($RandomizeSource.IsPresent)
Start Time:        $startTime
"@

# Main test loop
1..$AttemptCount | ForEach-Object {
    $attemptNum = $_
    $currentIP = if ($RandomizeSource) { $sourceIPs | Get-Random } else { $sourceIPs[0] }
    
    try {
        # Create authentication context
        $context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
            [System.DirectoryServices.AccountManagement.ContextType]::Machine
        )
        
        # Simulate failed login (will generate Event ID 4625)
        $null = $context.ValidateCredentials($TargetUser, $IncorrectPassword)
        
        Write-Host "[Attempt $attemptNum] Generated failed login from $currentIP" -ForegroundColor DarkGray
        
        # Optional: Add source IP to the Windows event (requires admin)
        if ($false) {  # Change to $true if you want to enrich events with source IP
            $eventMessage = "Logon attempt failed for $TargetUser from $currentIP"
            Write-EventLog -LogName $eventLogSource -Source "Microsoft Windows security auditing" `
                -EventID 4625 -EntryType FailureAudit -Message $eventMessage
        }
    }
    catch {
        Write-Warning "[Attempt $attemptNum] Error: $($_.Exception.Message)"
    }
    
    # Add delay between attempts
    if ($attemptNum -lt $AttemptCount) {
        Start-Sleep -Milliseconds $DelayMs
    }
}

Write-Host @"
`n[ Test Complete ]
Total attempts made: $AttemptCount
Start time: $startTime
End time:   $(Get-Date)
"@
