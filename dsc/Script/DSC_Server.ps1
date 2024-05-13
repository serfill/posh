configuration Sample_xDscWebServiceRegistration
{
    param
    (
        [string[]]$NodeName = 'localhost',

        [ValidateNotNullOrEmpty()]
        [string] $certificateThumbPrint,

        [Parameter(HelpMessage='This should be a string with enough entropy (randomness) to protect the registration of clients to the pull server.  We will use new GUID by default.')]
        [ValidateNotNullOrEmpty()]
        [string] $RegistrationKey   # A guid that clients use to initiate conversation with pull server
    )

    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration

    Node $NodeName
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name   = "DSC-Service"
        }

        xDscWebService PSDSCPullServer
        {
            Ensure                  = "Present"
            EndpointName            = "PSDSCPullServer"
            Port                    = 8080
            PhysicalPath            = "$env:SystemDrive\inetpub\PSDSCPullServer"
            CertificateThumbPrint   = $certificateThumbPrint
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                   = "Started"
            DependsOn               = "[WindowsFeature]DSCServiceFeature"
            RegistrationKeyPath     = "$env:PROGRAMFILES\WindowsPowerShell\DscService"
            AcceptSelfSignedCertificates = $true
            UseSecurityBestPractices     = $true
            Enable32BitAppOnWin64   = $false
            SqlProvider = $true
            SqlConnectionString = "Provider=SQLOLEDB.1;Password=pAiQymD1P2r81jETEBh#;Persist Security Info=True;User ID=DSC;Initial Catalog=DSC;Data Source=S18-CM01.ABAKAN.MEDVED-HOLDING.COM"
            #SqlConnectionString = "Provider=SQLNCLI11;Data Source=(local)\MSSQLSERVER;User ID=DSC;Password=pAiQymD1P2r81jETEBh#;Initial Catalog=DSC;"
            
        }

        File RegistrationKeyFile
        {
            Ensure          = 'Present'
            Type            = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents        = $RegistrationKey
        }
    }
}


dir Cert:\LocalMachine\my
Sample_xDscWebServiceRegistration -NodeName S18-CM01.abakan.medved-holding.com -certificateThumbprint '6B60498B289AB45F42A66293BBA9FC51871E8265' -RegistrationKey '57147cc4-cc5c-4220-8326-8fa99ff4973e' -OutputPath c:\Configs\PullServer

Start-DscConfiguration -Path C:\Configs\PullServer -Wait -Verbose
