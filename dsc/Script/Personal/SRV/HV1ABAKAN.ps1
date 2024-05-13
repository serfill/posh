Configuration HV1ABAKAN {

    Import-DscResource –ModuleName "PSDesiredStateConfiguration"
    Import-DscResource -ModuleName "xNetworking"

    node HV1ABAKAN {
        WindowsFeature addRole_HyperV {
            Name = "Hyper-V"
            Ensure = "Present"
            IncludeAllSubFeature = $true
        }

        Registry HyperV_DataRoot {
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization"
            ValueName = "DefaultExternalDataRoot"
            ValueData = "S:\Hyper-V\"
            Ensure = "Present"
        }

        Registry HyperV_HDDPath {
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Virtualization"
            ValueName = "DefaultVirtualHardDiskPath"
            ValueData = "S:\Hyper-V\"
            Ensure = "Present"           
        }

        Package ESET {
            Ensure = "Present"
            Name = "ESET File Security"
            ProductId = "{76D1B563-BA5E-414C-B9DA-2DE6C738543A}"
            Path = "\\abakan\dfs\Soft\IT\Antivirus\efsw_nt64_rus.msi"
            Arguments = "/qn"
        }

        xNetworkTeam {
            
        }

    }
}

$ServerPath = "\\S18-AP04\c$\Program Files\WindowsPowerShell\DscService\Configuration\"

HV1ABAKAN -OutputPath $ServerPath
New-DscChecksum -Path $ServerPath -Force