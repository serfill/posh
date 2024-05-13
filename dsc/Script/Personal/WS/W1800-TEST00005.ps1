Configuration W1800-TEST00005 {
    Import-DscResource –ModuleName "PSDesiredStateConfiguration"
    Import-DscResource -ModuleName "xNetworking"

    Node W1800-TEST00005 {
        xNetAdapterBinding Testipv6 {
           InterfaceAlias = "*"
           ComponentId = "ms_tcpip6"
           State = 'Disabled'
        }
    }
}


$LocalPath = "D:\DSC\Config\WS\W1800-TEST00005\" + (New-Guid)
$ServerPath = "\\S18-CM01\c$\Program Files\WindowsPowerShell\DscService\Configuration\"

W1800-TEST00005 -OutputPath $LocalPath
New-DscChecksum -Path $LocalPath -Force

Copy-Item -Path ($LocalPath + "\*") -Destination $ServerPath -Verbose