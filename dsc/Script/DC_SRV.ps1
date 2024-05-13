Configuration DC_SRV {
    Import-DscResource –ModuleName "PSDesiredStateConfiguration"
    Import-DscResource -ModuleName "xNetworking"
    Node DC_SRV {
        File LogRes {
            Ensure = "Present"
            Type = "File"
            DestinationPath = "C:\DC_SRV.txt"
            Contents = Get-date
        }

        Package ZabbixAgent {
            Ensure = 'Present'
            Name = 'Zabbix Agent (64-bit)'
            ProductId = '{7C9E0181-3541-46B9-A7CB-A50FD6AE0925}'
            Path = '\\abakan\dfs\Soft\IT\Clients\ZABBIX\zabbix_agent-5.0.3-windows-amd64-openssl.msi'
            Arguments = "/qn SERVER=192.168.10.10 ENABLEPATH=1 ENABLEREMOTECOMMANDS=1"
        }

        File PowerShellScripts {
            Ensure = 'Present'
            Type = 'Directory'
            Recurse = $true
            SourcePath = '\\ABAKAN\dfs\Soft\IT\Config\Zabbix\Scripts'
            DestinationPath = 'C:\Scripts'
        }

        File UserParameterConfig {
            Ensure = 'Present'
            Type = 'Directory'
            Recurse = $true
            SourcePath = '\\ABAKAN\dfs\Soft\IT\Config\Zabbix\Params'
            DestinationPath = 'c:\Program Files\Zabbix Agent\zabbix_agentd.conf.d'
        }

        xFirewall AllowFromLocal {
            Ensure = "Present"
            Name = "Allow all from local"
            DisplayName = "Allow all from local"
            Action = "Allow"
            RemoteAddress = "192.168.10.0/255.255.254.0"
        }

        xNetAdapterBinding Testipv6 {
           InterfaceAlias = "*"
           ComponentId = "ms_tcpip6"
           State = 'Disabled'
        }
    }
}


$LocalPath = "D:\!Develop\powershell\dsc\Config\WS\DC_SRV\" + (New-Guid)
$ServerPath = "\\S18-CM01\c$\Program Files\WindowsPowerShell\DscService\Configuration\"

DC_WS -OutputPath $LocalPath
New-DscChecksum -Path $LocalPath -Force

Copy-Item -Path ($LocalPath + "\*") -Destination $ServerPath -Verbose