$ip = "192.168.1.1"
$ports = 22, 80, 443

foreach ($port in $ports) {
    $conn = Test-NetConnection -ComputerName $ip -Port $port
    if ($conn.TcpTestSucceeded) {
        Write-Host "Port $port is open on $ip" -ForegroundColor Green
    } else {
        Write-Host "Port $port is closed on $ip" -ForegroundColor Red
    }
}
