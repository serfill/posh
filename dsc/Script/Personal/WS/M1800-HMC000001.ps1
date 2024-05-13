Configuration M1800-HMC000001 {

    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "M1800-HMC000001" {
        Package Zoom {
            Ensure = "Present"
            Path = "\\abakan\dfs\Soft\IT\Clients\ZoomInstallerFull.msi"
            Arguments = "/qn"
            Name = "Zoom"
            ProductId = "{B73AF550-CC30-41D8-8C24-4D61B087EFB7}"
        }
    }
}

$LocalPath = "D:\DSC\Config\WS\M1800-HMC000001\" + (New-Guid)
$ServerPath = "\\S18-CM01\c$\Program Files\WindowsPowerShell\DscService\Configuration\"

M1800-HMC000001 -OutputPath $LocalPath
New-DscChecksum -Path $LocalPath -Force

Copy-Item -Path ($LocalPath + "\*") -Destination $ServerPath -Verbose