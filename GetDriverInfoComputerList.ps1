﻿$Computers = @("Mobile-pc","Mobile-pc")
$Database=@()

foreach ($Computer in $Computers) {

    write-host "gathering info from $Computer"

    if (!(Test-Connection -Quiet -Count 1 -ComputerName $Computers)) {
        Write-Host "$Computer is offline, skipping"
        continue
    }

    $Model = Get-WmiObject -Class win32_computersystem -ComputerName $Computer| Select-Object -ExpandProperty Model
    $OSInstall = Get-WmiObject -Class win32_operatingsystem -ComputerName $Computer| Select-Object -ExpandProperty InstallDate
    $OSInstall = ([System.Management.ManagementDateTimeConverter]::ToDateTime($OSInstall)).ToString("d")

    $Records = Get-WmiObject -Class win32_pnpsigneddriver -ComputerName $Computer | Where-Object {(($_.Manufacturer -ne "Microsoft") -and ($_.DeviceClass -in "HDC","NET","DISPLAY","MEDIA"))} 
    $Records = $Records | Sort-Object -Property DeviceClass

    foreach ($Record in $Records) {
        $CustomEvent = New-Object -TypeName PSObject
        $CustomEvent | Add-member -Type NoteProperty -Name 'Computer' -Value $Computer
        $CustomEvent | Add-member -Type NoteProperty -Name 'Model' -Value $Model
        $CustomEvent | Add-member -Type NoteProperty -Name 'OSInstallDate' -Value $OSInstall
        $CustomEvent | Add-member -Type NoteProperty -Name 'DeviceClass' -Value $Record.DeviceClass
        $CustomEvent | Add-member -Type NoteProperty -Name 'Manufacturer' -Value $Record.Manufacturer
        $CustomEvent | Add-member -Type NoteProperty -Name 'DeviceName' -Value $Record.DeviceName
        $CustomEvent | Add-member -Type NoteProperty -Name 'DriverVersion' -Value $Record.DriverVersion

        $DriverDate = ([System.Management.ManagementDateTimeConverter]::ToDateTime($Record.DriverDate)).ToString("d")
        $CustomEvent | Add-member -Type NoteProperty -Name 'DriverDate' -Value $DriverDate

        $CustomEvent | Add-member -Type NoteProperty -Name 'DeviceID' -Value $Record.DeviceID

        $Database += $CustomEvent 

    }
}

$Database | Out-GridView