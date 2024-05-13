Configuration W1800-SKLAD0005 {

    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "W1800-SKLAD0005" {
        Package Zoom {
            Ensure    = "Absent"
            Path      = "\\abakan\dfs\Soft\IT\Clients\ZoomInstallerFull.msi"
            Arguments = "/qn"
            Name      = "Zoom"
            ProductId = "{B73AF550-CC30-41D8-8C24-4D61B087EFB7}"
        }

        Package Cisco {
            Ensure    = "Present"
            Path      = "\\abakan\dfs\Soft\IT\Clients\anyconnect-win-3.1.13015-pre-deploy-k9.msi"
            Arguments = "/qn"
            Name      = "Cisco AnyConnect Secure Mobility Client"
            ProductId = "{EDEB4A62-FE20-4F95-8B90-26BB74CEB6A9}"
        }
    }
}

$LocalPath = "D:\!Develop\powershell\DSC\Config\WS\W1800-SKLAD0005\" + (New-Guid)
$ServerPath = "\\S18-CM01\c$\Program Files\WindowsPowerShell\DscService\Configuration\"

W1800-SKLAD0005 -OutputPath $LocalPath
New-DscChecksum -Path $LocalPath -Force

Copy-Item -Path ($LocalPath + "\*") -Destination $ServerPath -Verbose