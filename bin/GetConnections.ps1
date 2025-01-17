﻿<#
.SYNOPSIS
   Gets a list of ESTABLISHED connections (TCP)

   Author: r00t-3xp10it
   Tested Under: Windows 10 (18363) x64 bits
   Required Dependencies: none
   Optional Dependencies: none
   PS cmdlet Dev version: v1.0.3
   
.DESCRIPTION
   Enumerates ESTABLISHED TCP connections and retrieves the
   ProcessName associated from the connection PID identifier

.Parameter GetConnections
   Accepts arguments: Enum and Verbose

.EXAMPLE
   PS C:\> Get-Help .\GetConnections.ps1 -full
   Access this cmdlet comment based help
    
.EXAMPLE
   PS C:\> .\GetConnections.ps1 -GetConnections Enum
   Enumerates All ESTABLISHED TCP connections (IPV4 only)

.EXAMPLE
   PS C:\> .\GetConnections.ps1 -GetConnections Verbose
   Retrieves process info from the connection PID (Id) identifier

.OUTPUTS
   Proto  Local Address          Foreign Address        State           Id
   -----  -------------          ---------------        -----           --
   TCP    127.0.0.1:58490        127.0.0.1:58491        ESTABLISHED     10516
   TCP    192.168.1.72:60547     40.67.254.36:443       ESTABLISHED     3344
   TCP    192.168.1.72:63492     216.239.36.21:80       ESTABLISHED     5512

   Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
   -------  ------    -----      -----     ------     --  -- -----------
   671      47        39564      28452     1,16    10516   4 firefox
   426      20        5020       21348     1,47     3344   0 svchost
   1135     77        252972     271880    30,73    5512   4 powershell
#>


[CmdletBinding(PositionalBinding=$false)] param(
   [string]$GetConnections="false"
)


## Disable Powershell Command Logging for current session.
Set-PSReadlineOption –HistorySaveStyle SaveNothing|Out-Null
If($GetConnections -ieq "Enum"){## Quick TCP enumeration

   <#
   .SYNOPSIS
      Helper - Gets a list of ESTABLISHED connections (TCP)

   .DESCRIPTION
      Quick Enumeration of ESTABLISHED TCP connections

   .EXAMPLE
      PS C:\> .\GetConnections.ps1 -GetConnections Enum
      Enumerates All ESTABLISHED TCP connections (IPV4 only)

   .OUTPUTS
      LocalAddress LocalPort RemoteAddress RemotePort OwningProcess
      ------------ --------- ------------- ---------- -------------
      192.168.1.72     64372 34.216.9.227         443         12992
      192.168.1.72     58016 51.138.106.75        443         11232
      192.168.1.72     58012 140.82.112.26        443         12992
      192.168.1.72     55274 40.67.254.36         443          3708
   #>

   Write-Host "`n`n"
   ## CmdLine To Display TCP listenning connections also!
   # $_.State -ieq "Established" -or $_.State -ieq "Listen"
   Get-NetTCPConnection | Where-Object {## Filter stdout outputs { search established and exclude IPV6 + localhost }
      $_.State -ieq "Established" -and $_.LocalAddress -NotMatch ":" -and $_.LocalAddress -NotMatch "127.0.0.1" -and $_.LocalAddress -NotMatch "0.0.0.0"
      }| Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,OwningProcess | Format-Table
}   


If($GetConnections -ieq "Verbose"){## Verbose module

   <#
   .SYNOPSIS
      Helper - Gets a list of ESTABLISHED connections (TCP)
   
   .DESCRIPTION
      Enumerates ESTABLISHED TCP connections and retrieves the
      ProcessName associated from the connection PID identifier

   .EXAMPLE
      PS C:\> .\GetConnections.ps1 -GetConnections Verbose
      Retrieves process info from the connection PID (Id) identifier

   .OUTPUTS
      Proto  Local Address          Foreign Address        State           Id
      -----  -------------          ---------------        -----           --
      TCP    127.0.0.1:58490        127.0.0.1:58491        ESTABLISHED     10516
      TCP    192.168.1.72:60547     40.67.254.36:443       ESTABLISHED     3344
      TCP    192.168.1.72:63492     216.239.36.21:80       ESTABLISHED     5512

      Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
      -------  ------    -----      -----     ------     --  -- -----------
      671      47        39564      28452     1,16    10516   4 firefox
      426      20        5020       21348     1,47     3344   0 svchost
      1135     77        252972     271880    30,73    5512   4 powershell
   #>

   Write-Host "`n`nProto  Local Address          Foreign Address        State           Id"
   Write-Host "-----  -------------          ---------------        -----           --"
   $TcpList = netstat -ano|findstr "ESTABLISHED LISTENING"|findstr /V "[ UDP 0.0.0.0:0 127.0.0.1"
   If($? -ieq $False){## fail to retrieve List of ESTABLISHED TCP connections!
      Write-Host "  [error] fail to retrieve List of ESTABLISHED TCP connections!" -ForegroundColor Red -BackgroundColor Black
      Write-Host "";Start-Sleep -Seconds 1;exit ## Exit @redpill
   }

   ## Align the Table to feat next Table outputs
   # {delete empty spaces in begging of each line}
   $parsedata = $TcpList -replace '^(\s+)',''
   echo $parsedata

   Write-Host "" ## List of ProcessName + PID associated to $Tcplist
   ForEach($Item in $TcpList){## Loop truth ESTABLISHED connections
      echo $Item.split()[-1] >> test.log
   }
   $PPid = Get-Content -Path "test.log"
   Remove-Item -Path "test.log" -Force

   ## ESTABLISHED Connections PID (Id) Loop
   ForEach($Token in $PPid){
      Get-Process -PID $Token -EA SilentlyContinue
   }
}