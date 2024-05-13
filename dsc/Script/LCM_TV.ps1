
$NodeName = 'localhost'

if ($args[0]) {
    $NodeName = $args[0] 
}

Function Set-DSCConfiguration {
    param ([string]$NodeName)
    $Path = "D:\!Develop\powershell\dsc\Config\LCM\WS"

    [DscLocalConfigurationManager()]Configuration LCMConfig {
        param ([string]$NodeName)
        Node $NodeName {
            Settings {
                RefreshFrequencyMins           = 30;
                RefreshMode                    = "PULL";
                ConfigurationMode              = "ApplyAndAutoCorrect";
                AllowModuleOverwrite           = $true;
                RebootNodeIfNeeded             = $false;
                ConfigurationModeFrequencyMins = 15;
                ActionAfterReboot              = 'ContinueConfiguration'
            }

            ConfigurationRepositoryWeb S18-CM01-Pull {
                ServerURL          = 'https://S18-CM01.abakan.medved-holding.com:8080/PSDSCPullServer.svc'
                RegistrationKey    = "57147cc4-cc5c-4220-8326-8fa99ff4973e"
                ConfigurationNames = @("DC_WS", $NodeName)
            }
            <#
            ReportServerWeb S18-CM01-Report {
                ServerURL = 'https://S18-CM01.abakan.medved-holding.com:8080/PSDSCPullServer.svc'
            }
#>
            PartialConfiguration DC_WS {
                Description         = "Default Configuration"
                ConfigurationSource = @("[ConfigurationRepositoryWeb]S18-CM01-Pull")
                RefreshMode         = "Pull"
            }

            PartialConfiguration $NodeName {
                Description         = "Personal Configuration $NodeName"
                ConfigurationSource = @("[ConfigurationRepositoryWeb]S18-CM01-Pull")
                RefreshMode         = "Pull"
            }
        }
    }
    LCMConfig -NodeName $NodeName -OutputPath $Path
    Set-DscLocalConfigurationManager -ComputerName $NodeName -Path $Path -Verbose
}

foreach ($CN in (Get-ADComputer -Filter "CN -like 'W1800-SBMW*2'")) {
    if (Test-Connection $CN.Name -Quiet -Count 1) {
        Set-DSCConfiguration -NodeName $CN.Name
    }
}