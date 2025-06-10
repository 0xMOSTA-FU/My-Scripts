Define the target machine and the range of ports to scan
$target = "192.168.1.1"  # Replace with the target machine's IP address or hostname
$startPort = 1
$endPort = 1024

function Test-Port {
    param (
        [string]$Target,
        [int]$Port
    )
    $connection = Test-NetConnection -ComputerName $Target -Port $Port
    return $connection.TcpTestSucceeded
}

foreach ($port in $startPort..$endPort) {
    if (Test-Port -Target $target -Port $port) {
        Write-Output "Port $port is open on $target"
    } else {
        Write-Output "Port $port is closed on $target"
    }
}
