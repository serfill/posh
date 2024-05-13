Configuration M1800-MNG000003 {

    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "M1800-MNG000003" {
        Package Zoom {
            Ensure    = "Present"
            Path      = "\\abakan\dfs\Soft\IT\Clients\ZoomInstallerFull.msi"
            Arguments = "/qn"
            Name      = "Zoom"
            ProductId = "{B73AF550-CC30-41D8-8C24-4D61B087EFB7}"
        }

        Package Domination {
            Ensure    = "Present"
            Path      = "\\abakan\dfs\Soft\IT\video\Domination_Client_Installer_2.6.2.msi"
            Arguments = "/qn"
            Name      = "Domination Client"
            ProductId = "{D9BB90EC-9AF5-C7A1-D5AA-588992391A62}"
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

$LocalPath = "D:\!Develop\powershell\DSC\Config\WS\M1800-MNG000003\" + (New-Guid)
$ServerPath = "\\S18-CM01\c$\Program Files\WindowsPowerShell\DscService\Configuration\"

M1800-CLIENT001 -OutputPath $LocalPath
New-DscChecksum -Path $LocalPath -Force

Copy-Item -Path ($LocalPath + "\*") -Destination $ServerPath -Verbose