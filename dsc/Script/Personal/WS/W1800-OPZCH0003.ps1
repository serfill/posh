Configuration W1800-OPZCH0003 {

    Import-DscResource -ModuleName xNetworking

    Node "W1800-OPZCH0003" {
        xHostsFile eparts-dfs.cpn.vwg {
            HostName = "eparts-dfs.cpn.vwg"
            IPAddress = "10.112.198.112"
            Ensure = "Present"
        }
    }
}


$LocalPath = "D:\DSC\Config\WS\W1800-OPZCH0003\" + (New-Guid)
$ServerPath = "\\S18-CM01\c$\Program Files\WindowsPowerShell\DscService\Configuration\"

W1800-OPZCH0003 -OutputPath $LocalPath
New-DscChecksum -Path $LocalPath -Force

Copy-Item -Path ($LocalPath + "\*") -Destination $ServerPath -Verbose

