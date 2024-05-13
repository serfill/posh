
$NodeName = 'localhost'

if ($args[0]) {
    $NodeName = $args[0] 
}

Function Set-DSCConfiguration {
    param ([string]$NodeName)
    $Path = "D:\!Develop\powershell\dsc\Config\SRV"
    [DscLocalConfigurationManager()]Configuration LCMConfig {
    param ([string]$NodeName)
        Node $NodeName {
            Settings {
                RefreshFrequencyMins = 30;
                RefreshMode = "PULL";
                ConfigurationMode = "ApplyAndAutoCorrect";
                AllowModuleOverwrite = $true;
                RebootNodeIfNeeded = $true;
                ConfigurationModeFrequencyMins = 60;
            }

            ConfigurationRepositoryWeb S18-CM01 {
                ServerURL = 'https://S18-CM01.abakan.medved-holding.com:8080/PSDSCPullServer.svc'
                RegistrationKey = "57147cc4-cc5c-4220-8326-8fa99ff4973e"
                ConfigurationNames = @("DC_SRV", $NodeName)
            }

            PartialConfiguration DC_SRV {
                Description = "Default Configuration"
                ConfigurationSource = @("[ConfigurationRepositoryWeb]S18-CM01")
                RefreshMode = "Pull"
            }

            PartialConfiguration $NodeName {
                Description = "Personal Configuration $NodeName"
                ConfigurationSource = @("[ConfigurationRepositoryWeb]S18-CM01")
                RefreshMode = "Pull"
            }
        }
    }
    LCMConfig -NodeName $NodeName -OutputPath $Path
    Set-DscLocalConfigurationManager -ComputerName $NodeName -Path $Path
}

Set-DSCConfiguration -NodeName S18-PR03



