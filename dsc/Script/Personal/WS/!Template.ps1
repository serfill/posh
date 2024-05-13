cls

#Set patternt COMPUTER_NAME on real computername

$LocalPath = "D:\DSC\Config\WS\COMPUTER_NAME\" + (New-Guid)
$ServerPath = "\\S18-CM01\c$\Program Files\WindowsPowerShell\DscService\Configuration\"

Configuration COMPUTER_NAME {
    Import-DscResource –ModuleName "PSDesiredStateConfiguration"
    Import-DscResource -ModuleName "xNetworking"

    Node COMPUTER_NAME {
    }
}

COMPUTER_NAME -OutputPath $LocalPath
New-DscChecksum -Path $LocalPath -Force
Copy-Item -Path ($LocalPath + "\*") -Destination $ServerPath -Verbose