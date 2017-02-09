$servers = get-adcomputer -filter 'OperatingSystem -like "*server*"' | select Name

foreach ( $server in $servers )
{
    $serverName = $server.Name
    if ( test-connection -computername $serverName -quiet -delay 1 -count 1 )
    {

        Start-Job -Name "Job-$serverName" -ArgumentList $serverName -ScriptBlock { 
        get-windowsupdate -computername $args[0] -verbose
        }

    }
}

