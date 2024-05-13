Configuration PR {

    Import-DscResource –ModuleName "PSDesiredStateConfiguration"
    Import-DscResource -ModuleName "xPrinterManagement"

    node PR {
    # Установка ролей
    WindowsFeature PrintService {
        Name = "Print-Services"
        Ensure = "Present"
        IncludeAllSubFeature = $true
    }

    #Добавление драйверов
    xPrinterDriver Kyocera {
        Ensure = "Present"
        DriverName = "Kyocera Classic Universaldriver PCL6"
        InfPath = "\\ABAKAN\dfs\Soft\IT\Driver\Kyocera\KyoClassicUniversalPCL6_v3.3\OEMsetup.inf"
        Environment = 'x64'
    }
    xPrinterDriver Brother {
        Ensure = "Present"
        DriverName = "Brother MFC-L5750DW XML Paper"
        InfPath = "\\ABAKAN\dfs\Soft\IT\Driver\Brother\Install\xmlpaper\BRXM15A.INF"
        Environment = "x64"
    }
    xPrinterDriver HP {
        Ensure = "Present"
        DriverName = "HP LaserJet Pro MFP M426f-M427f PCL 6"
        InfPath = "\\ABAKAN\dfs\Soft\IT\Driver\HP\hpma5a2a_x64.inf"
        Environment = "x64"
    }


    # P18-000001
    xPrinterPort port_192.168.10.40 {
        Ensure = 'Present'
        Name = '192.168.10.40'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.40'
    }
    xPrinter P18-000001 {
        Ensure = 'Present'
        Name = 'P18-000001'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.40'
        Comment = 'Склад Медведь'
        Location = 'Склад Медведь'
        Published = $True
        ShareName = 'P18-000001'
        DependsOn = '[xPrinterPort]port_192.168.10.40'
    }
    
    # P18-000002
    xPrinterPort port_192.168.11.5 {
        Ensure = 'Present'
        Name = '192.168.11.5'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.11.5'
    }
    xPrinter P18-000002 {
        Ensure = 'Present'
        Name = 'P18-000002'
        DriverName = 'Brother MFC-L5750DW XML Paper'
        PortName = '192.168.11.5'
        Comment = 'Бухгалтерия'
        Location = 'Бухгалтерия'
        Published = $true
        ShareName = 'P18-000002'
        DependsOn = '[xPrinterPort]port_192.168.11.5'
    }

    # P18-000003
    xPrinterPort port_192.168.10.101 {
        Ensure = 'Present'
        Name = '192.168.10.101'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.101'
    }
    xPrinter P18-000003 {
        Ensure = 'Present'
        Name = 'P18-000003'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.101'
        Comment = 'Мастер цеха'
        Location = 'Мастер цеха'
        Published = $True
        ShareName = 'P18-000003'
        DependsOn = '[xPrinterPort]port_192.168.10.101'
    }
    
    # P18-000004
    xPrinterPort port_192.168.10.54 {
        Ensure = 'Present'
        Name = '192.168.10.54'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.54'
    }
    xPrinter P18-000004 {
        Ensure = 'Present'
        Name = 'P18-000004'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.54'
        Comment = 'Сервис VW'
        Location = 'Сервис VW'
        Published = $True
        ShareName = 'P18-000004'
        DependsOn = '[xPrinterPort]port_192.168.10.54'
    }
    
    # P18-000005
    xPrinterPort port_192.168.10.42 {
        Ensure = 'Present'
        Name = '192.168.10.42'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.42'
    }
    xPrinter P18-000005 {
        Ensure = 'Present'
        Name = 'P18-000005'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.42'
        Comment = 'Сервис Mitsubishi'
        Location = 'Сервис Mitsubishi'
        Published = $True
        ShareName = 'P18-000005'
        DependsOn = '[xPrinterPort]port_192.168.10.42'
    }
    
    # P18-000006
    xPrinterPort port_192.168.10.111 {
        Ensure = 'Present'
        Name = '192.168.10.111'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.111'
    }
    xPrinter P18-000006 {
        Ensure = 'Present'
        Name = 'P18-000006'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.111'
        Comment = 'Сервис Hyundai'
        Location = 'Сервис Hyundai'
        Published = $True
        ShareName = 'P18-000006'
        DependsOn = '[xPrinterPort]port_192.168.10.111'
    }
    
    # P18-000007
    xPrinterPort port_192.168.10.112 {
        Ensure = 'Present'
        Name = '192.168.10.112'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.112'
    }
    xPrinter P18-000007 {
        Ensure = 'Present'
        Name = 'P18-000007'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.112'
        Comment = 'Сервис BMW'
        Location = 'Сервис BMW'
        Published = $True
        ShareName = 'P18-000007'
        DependsOn = '[xPrinterPort]port_192.168.10.112'
    }
    
    # P18-000008
    xPrinterPort port_192.168.11.253 {
        Ensure = 'Present'
        Name = '192.168.11.253'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.11.253'
    }
    xPrinter P18-000008 {
        Ensure = 'Present'
        Name = 'P18-000008'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.11.253'
        Comment = 'Ресепшн Hyundai'
        Location = 'Ресепшн Hyundai'
        Published = $True
        ShareName = 'P18-000008'
        DependsOn = '[xPrinterPort]port_192.168.11.253'
    }
    
    # P18-000009
    xPrinterPort port_192.168.10.114 {
        Ensure = 'Present'
        Name = '192.168.10.114'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.114'
    }
    xPrinter P18-000009 {
        Ensure = 'Present'
        Name = 'P18-000009'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.114'
        Comment = 'Приемная'
        Location = 'Приемная'
        Published = $True
        ShareName = 'P18-000009'
        DependsOn = '[xPrinterPort]port_192.168.10.114'
    }
    
    # P18-000010
    xPrinterPort port_192.168.10.251 {
        Ensure = 'Present'
        Name = '192.168.10.251'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.251'
    }
    xPrinter P18-000010 {
        Ensure = "Present"
        Name = "P18-000010"
        DriverName = 'HP LaserJet Pro MFP M426f-M427f PCL 6'
        PortName = "192.168.10.251"
        Comment = "Отдел продаж Hyundai"
        Location = "Отдел продаж Hyundai"
        Published = $True
        ShareName = "P18-000010"
        DependsOn = "[xPrinterPort]port_192.168.10.251"
    }

    # P18-000011
    xPrinterPort port_192.168.10.24 {
        Ensure = 'Present'
        Name = '192.168.10.24'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.24'
    }
    xPrinter P18-000011 {
        Ensure = 'Present'
        Name = 'P18-000011'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.24'
        Comment = 'ОПА VW'
        Location = 'ОПА VW'
        Published = $True
        ShareName = 'P18-000011'
        DependsOn = '[xPrinterPort]port_192.168.10.24'
    }
    
    # P18-000012
    xPrinterPort port_192.168.10.44 {
        Ensure = 'Present'
        Name = '192.168.10.44'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.44'
    }
    xPrinter P18-000012 {
        Ensure = 'Present'
        Name = 'P18-000012'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.44'
        Comment = 'ОПА Skoda'
        Location = 'ОПА Skoda'
        Published = $True
        ShareName = 'P18-000012'
        DependsOn = '[xPrinterPort]port_192.168.10.44'
    }
    
    # P18-000013
    xPrinterPort port_192.168.10.116 {
        Ensure = 'Present'
        Name = '192.168.10.116'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.116'
    }
    xPrinter P18-000013 {
        Ensure = 'Present'
        Name = 'P18-000013'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.116'
        Comment = 'МКЦ'
        Location = 'МКЦ'
        Published = $True
        ShareName = 'P18-000013'
        DependsOn = '[xPrinterPort]port_192.168.10.116'
    }
    
    # P18-000014
    xPrinterPort port_192.168.11.251 {
        Ensure = 'Present'
        Name = '192.168.11.251'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.11.251'
    }
    xPrinter P18-000014 {
        Ensure = 'Present'
        Name = 'P18-000014'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.11.251'
        Comment = 'Клиентская служба'
        Location = 'Клиентская служба'
        Published = $True
        ShareName = 'P18-000014'
        DependsOn = '[xPrinterPort]port_192.168.11.251'
    }
    
    # P18-000015
    xPrinterPort port_192.168.10.119 {
        Ensure = 'Present'
        Name = '192.168.10.119'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.119'
    }
    xPrinter P18-000015 {
        Ensure = 'Present'
        Name = 'P18-000015'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.119'
        Comment = 'Кадры'
        Location = 'Кадры'
        Published = $True
        ShareName = 'P18-000015'
        DependsOn = '[xPrinterPort]port_192.168.10.119'
    }
    
    # P18-000016
    xPrinterPort port_192.168.10.90 {
        Ensure = 'Present'
        Name = '192.168.10.90'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.90'
    }
    xPrinter P18-000016 {
        Ensure = 'Present'
        Name = 'P18-000016'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.90'
        Comment = 'Бухгалтерия 2'
        Location = 'Бухгалтерия 2'
        Published = $True
        ShareName = 'P18-000016'
        DependsOn = '[xPrinterPort]port_192.168.10.90'
    }
    
    # P18-000017
    xPrinterPort port_192.168.10.95 {
        Ensure = 'Present'
        Name = '192.168.10.95'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.95'
    }
    xPrinter P18-000017 {
        Ensure = 'Present'
        Name = 'P18-000017'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.95'
        Comment = 'Бухгалтерия'
        Location = 'Бухгалтерия'
        Published = $True
        ShareName = 'P18-000017'
        DependsOn = '[xPrinterPort]port_192.168.10.95'
    }
    
    # P18-000018
    xPrinterPort port_192.168.10.239 {
        Ensure = 'Present'
        Name = '192.168.10.239'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.239'
    }
    xPrinter P18-000018 {
        Ensure = 'Present'
        Name = 'P18-000018'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.239'
        Comment = 'VW Цех'
        Location = 'VW Цех'
        Published = $True
        ShareName = 'P18-000018'
        DependsOn = '[xPrinterPort]port_192.168.10.239'
    }
    
    # P18-000019
    xPrinterPort port_192.168.10.25 {
        Ensure = 'Present'
        Name = '192.168.10.25'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.25'
    }
    xPrinter P18-000019 {
        Ensure = 'Present'
        Name = 'P18-000019'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.25'
        Comment = 'VW'
        Location = 'VW'
        Published = $True
        ShareName = 'P18-000019'
        DependsOn = '[xPrinterPort]port_192.168.10.25'
    }
    
    # P18-000020
    xPrinterPort port_192.168.10.102 {
        Ensure = 'Present'
        Name = '192.168.10.102'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.102'
    }
    xPrinter P18-000020 {
        Ensure = 'Present'
        Name = 'P18-000020'
        DriverName = 'Brother MFC-L5750DW XML Paper'
        PortName = '192.168.10.102'
        Comment = 'Hyundai кредитный'
        Location = 'Hyundai кредитный'
        Published = $True
        ShareName = 'P18-000020'
        DependsOn = '[xPrinterPort]port_192.168.10.102'
    }

    # P18-000021
    xPrinterPort port_192.168.10.113 {
        Ensure = 'Present'
        Name = '192.168.10.113'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.113'
    }
    xPrinter P18-000021 {
        Ensure = 'Present'
        Name = 'P18-000021'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.113'
        Comment = 'Hyundai'
        Location = 'Hyundai'
        Published = $True
        ShareName = 'P18-000021'
        DependsOn = '[xPrinterPort]port_192.168.10.113'
    }
    
    # P18-000022
    xPrinterPort port_192.168.10.91 {
        Ensure = 'Present'
        Name = '192.168.10.91'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.10.91'
    }
    xPrinter P18-000022 {
        Ensure = 'Present'
        Name = 'P18-000022'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.10.91'
        Comment = 'Касса Hyundai'
        Location = 'Касса Hyundai'
        Published = $True
        ShareName = 'P18-000022'
        DependsOn = '[xPrinterPort]port_192.168.10.91'
    }
    
    # P18-000023
    xPrinterPort port_192.168.11.98 {
        Ensure = 'Present'
        Name = '192.168.11.98'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.11.98'
    }
    xPrinter P18-000023 {
        Ensure = 'Present'
        Name = 'P18-000023'
        DriverName = 'Kyocera Classic Universaldriver PCL6'
        PortName = '192.168.11.98'
        Comment = 'Будка'
        Location = 'Будка'
        Published = $True
        ShareName = 'P18-000023'
        DependsOn = '[xPrinterPort]port_192.168.11.98'
    }

    # P18-000024
    xPrinterPort port_192.168.11.34 {
        Ensure = 'Present'
        Name = '192.168.11.34'
        Type = 'TCP/IP'
        PrinterHostAddress = '192.168.11.34'
    }
    xPrinter P18-000024 {
        Ensure = 'Present'
        Name = 'P18-000024'
        DriverName = 'Brother MFC-L5750DW XML Paper'
        PortName = '192.168.11.34'
        Comment = 'Hyundai кредитный'
        Location = 'Hyundai кредитный'
        Published = $True
        ShareName = 'P18-000024'
        DependsOn = '[xPrinterPort]port_192.168.11.34'
    }
    }
}
    
$ServerPath = "\\S18-AP04\c$\Program Files\WindowsPowerShell\DscService\Configuration\"
PR -OutputPath $ServerPath
New-DscChecksum -Path $ServerPath -Force