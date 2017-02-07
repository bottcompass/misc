$servers = get-adcomputer -filter * -Properties * | ? { $_.OperatingSystem -like '*server*' }

foreach ( $server in $servers )
{
    $serverName = $server.DNSHostName
    Start-Job -ArgumentList $serverName -ScriptBlock {
    $test = Test-Connection -Quiet -count 1 -Delay 1 -ComputerName $args[0]
        if($test)
        {
            $disks = Get-WmiObject win32_logicaldisk -ComputerName $args[0] | select DeviceID, @{Name="DiskFreePercent";Expression={$_.FreeSpace / $_.Size * 100 }}
        }
        New-Object PSObject -Property @{Name=$args[0];Result=$test;Disks=$disks}
    }
}

#Get-WmiObject win32_logicaldisk -ComputerName atra-exch-01 | select DeviceID, @{Name="DiskFreePercent";Expression={$_.FreeSpace / $_.Size * 100 }} | ft -AutoSize

While ( get-job ) {
    $j = get-job | wait-job -any
    Receive-Job $j
    Remove-Job $j
}