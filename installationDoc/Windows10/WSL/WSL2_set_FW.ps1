<#
# updated by ...: Loreto Notarantonio
# Version ......: 24-10-2020 12.51.47

Tutorial: https://www.guru99.com/powershell-tutorial.html

Get-ExecutionPolicy command.
    Restricted    — No scripts are allowed. This is the default setting, so it will display first time when you run the command.
    AllSigned     — You can run scripts signed by a trusted developer. With the help of this setting, a script will ask for confirmation that you want to run it before executing.
    RemoteSigned  — You can run your or scripts signed by a trusted developer.
    Unrestricted  — You can run any script which you wants to run

  Set-ExecutionPolicy RemoteSigned
    ...oppure ...
  Set-ExecutionPolicy Unrestricted
 ... oppure:
  Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
#>

# WSL2 network port forwarding script v1
#   To enable script:
#      'Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser' in Powershell,
# params:
#   list:   show ports
#   delete: for deleting exist rules and ports
# written by Daehyuk Ahn, Aug-1-2020

# Display all portproxy information
If ($Args[0] -eq "list") {
    netsh interface portproxy show v4tov4;
    exit;
}

# If elevation needed, start new process
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path),"$Args runas" -Verb RunAs
  exit
}

# You should modify '$Ports' for your applications
# $Ports = (22,80,443,8080)
$Ports = (2222)

# Check WSL ip address
wsl hostname -I | Set-Variable -Name "WSL"
$found = $WSL -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';
if (-not $found) {
  echo "WSL2 cannot be found. Terminate script.";
  exit;
}

# Remove and Create NetFireWallRule
Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock';
if ($Args[0] -ne "delete") {
  New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort $Ports -Action Allow -Protocol TCP;
  New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort $Ports -Action Allow -Protocol TCP;
}

# Add each port into portproxy
$Addr = "0.0.0.0"
$Addr = "127.0.0.1"
Foreach ($Port in $Ports) {
    iex "netsh interface portproxy delete v4tov4 listenaddress=$Addr listenport=$Port | Out-Null";
    if ($Args[0] -ne "delete") {
        iex "netsh interface portproxy add v4tov4 listenaddress=$Addr listenport=$Port connectaddress=$WSL connectport=$Port | Out-Null";
    }
}

# Display all portproxy information
netsh interface portproxy show v4tov4;

# Give user to chance to see above list when relaunched start
If ($Args[0] -eq "runas" -Or $Args[1] -eq "runas") {
  Write-Host -NoNewLine 'Press any key to close! ';
  $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}