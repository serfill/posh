Configuration DC_WS {
    Import-DscResource –ModuleName "PSDesiredStateConfiguration"
    Import-DscResource -ModuleName "xNetworking"
    Import-DscResource -ModuleName "xWindowsUpdate"
    Node DC_WS {
        # Запись лога о последнем исполнении
        File File1 {
            Ensure = "Present"
            Type = "File"
            DestinationPath = "C:\DC_WS.txt"
            Contents = (get-date)
        }
        # Установка рабочей копии 1с
<#      
        Package Lib1 {
            Ensure = 'Present'
            Name = 'Microsoft Visual C++ 2017 x86 Minimum Runtime - 14.14.26405'
            ProductId = '{644544A0-318A-344C-964C-4DBE2FB5F864}'
            Path = ('\\abakan.medved-holding.com\dfs\Soft\IT\Clients\1c\8.3.15.1830\vc_redist.x86.exe')
            Arguments = '/install /quiet'
        }
#>
        Package Client1cWork {
            Ensure = 'Present'
            Name = '1C:Enterprise 8'
            ProductId = '{68078560-1146-433D-BC90-5AD7D741860E}'
            path = ('\\abakan.medved-holding.com\dfs\Soft\IT\Clients\1c\8.3.15.1830\1CEnterprise 8.msi')
            Arguments = '/qn'
        }
        # Установка 1с SPD
        Package Client1cSPD {
            Ensure = "Present"
            Name = "1C:Enterprise 8 Thin client"
            ProductId = "{96D3A7D1-F9B6-4B82-9886-438A7B31D65F}"
            Path = "\\abakan.medved-holding.com\dfs\Soft\IT\Clients\1c\8.3.10.2772\1CEnterprise 8 Thin client.msi"
            Arguments = '/qn'
        }
        # Установка 1с СУДА
        Package Client1cSUDA {
            Ensure = "Present"
            Name = "1C:Enterprise 8 Thin client"
            ProductId = "{658B1B34-30B8-457D-AE0E-28D22453C46A}"
            Path = "\\abakan.medved-holding.com\dfs\Soft\IT\Clients\1c\8.3.15.1958\1CEnterprise 8 Thin client.msi"
            Arguments = "/qn"
        }
        # Установка Adobe Reader
        Package AdobeReader {
            Ensure = 'Present'
            Name = 'Adobe Acrobat Reader DC - Russian'
            ProductId = '{AC76BA86-7AD7-1049-7B44-AC0F074E4100}'
            Path = '\\abakan.medved-holding.com\dfs\Soft\IT\layouts\AcroRdrDC1900820071_ru_RU.exe'
            Arguments = '/sAll /rs /sl 1049'
        }
        # Установка 7zip
        Package 7zip {
            Ensure = 'Present'
            Name = '7-Zip 19.00 (x64 edition)'
            ProductId = '{23170F69-40C1-2702-1900-000001000000}'
            Path = '\\abakan.medved-holding.com\dfs\Soft\it\utils\arc\7z1900-x64.msi'
            Arguments = '/quiet /norestart'
        }
        # Установка FAR
        Package FarManager {
            Ensure = 'Present'
            Name = 'Far Manager 3 x64'
            ProductId = '{AEF3F1EF-FB40-45F1-A462-48B359C2A27E}'
            Path = '\\abakan\dfs\Soft\IT\utils\FileManager\Far30b5700.x64.20201112.msi'
            Arguments = '/quiet /norestart'
        }
        # Установка ESET
        Package ESET {
            Ensure = 'Present'
            Name = 'ESET Endpoint Antivirus'
            ProductId = '{BC6E0C11-EAF4-4171-A7C2-3E7B81F4616B}'
            Path = '\\abakan\dfs\Soft\IT\Antivirus\eea_nt64_rus.msi'
            Arguments = '/qn'
        }

        # Включение компонентов Windows
        WindowsOptionalFeature TelNet-Client {
            Name = "TelnetClient"
            Ensure = 'Enable'
        }
        WindowsOptionalFeature NetFx3 {
            Name = "NetFx3"
            Ensure = "Enable"

        }
        xFirewall AllowFromLocal {
            Ensure = "Present"
            Name = "Allow all from local"
            DisplayName = "Allow all from local"
            Action = "Allow"
            RemoteAddress = "192.168.10.0/255.255.254.0"
        }

        xFirewall AllowFromHolding {
            Ensure = "Present"
            Name = "Allow all from Holding"
            Action = "Allow"
            RemoteAddress = "192.168.0.0/255.255.0.0"
        }
        
        xNetAdapterBinding Testipv6 {
           InterfaceAlias = "*"
           ComponentId = "ms_tcpip6"
           State = 'Disabled'
        }
        Registry 1сCompatibility {
            Ensure = "Present"
            Key = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
            ValueName = "C:\Program Files (x86)\1cv8\common\1cestart.exe"
            ValueData = "~ WIN7RTM"
            ValueType = "String"
        }
<#
        # Установка обновления приостановлено, т.к. вышла более свежая версия накопительного обновления.
        xHotfix KB5001567{
            Ensure = "Present"
            Id = "KB5001567"
            Path = "\\abakan.medved-holding.com\dfs\Soft\IT\Updates\WIndows 10\PrintBSOD\KB5001567.msu"
        }
#>
    }
}

$LocalPath = "D:\!Develop\powershell\dsc\Config\WS\DC_WS\" + (New-Guid)
$ServerPath = "\\S18-CM01\c$\Program Files\WindowsPowerShell\DscService\Configuration\"

DC_WS -OutputPath $LocalPath
New-DscChecksum -Path $LocalPath -Force

Copy-Item -Path ($LocalPath + "\*") -Destination $ServerPath -Verbose