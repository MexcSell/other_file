# SSH tunnel with automatic reconnection after network interruptions.
# Save as UTF-8 and run in Windows PowerShell 5.1 or PowerShell 7+.

$ErrorActionPreference = "Continue"

$SshHost = "65.108.79.94"
$SshUser = "root"
$LocalPort = 8765
$RemoteHost = "127.0.0.1"
$RemotePort = 8765
$RetryDelaySeconds = 5

while ($true) {
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Starting SSH tunnel..." -ForegroundColor Cyan

    # Each attempt is a fresh ssh process. If Wi-Fi/network drops, SSH exits
    # after keepalive failures and the loop retries when connectivity returns.
    & ssh `
        -N `
        -o "ServerAliveInterval=15" `
        -o "ServerAliveCountMax=3" `
        -o "ConnectTimeout=15" `
        -o "ExitOnForwardFailure=yes" `
        -L "${LocalPort}:${RemoteHost}:${RemotePort}" `
        "${SshUser}@${SshHost}"

    $sshExitCode = $LASTEXITCODE
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] SSH exited (code $sshExitCode). Retrying in $RetryDelaySeconds seconds..." -ForegroundColor Yellow
    Start-Sleep -Seconds $RetryDelaySeconds
}
