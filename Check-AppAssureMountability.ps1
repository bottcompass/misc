#Requires -Modules RapidRecoveryPowerShellModule
<#
.help [string]protectedserver
The protected server(s) to run the mountability check on.
#>
function Start-AppAssureMountability {
[cmdletbinding()]
param(
    [Parameter(Mandatory=$True,
    ValueFromPipeline=$True)]
    [string[]]$protectedserver,
    [string]$core="localhost"
    )
    BEGIN {

    }
    PROCESS {
            ForEach ( $server in $protectedserver )
            {
                $jobName = "Job-$server"
                $jobScriptBlock = { 
                                    param ( $core,$server ) 
                                    Start-MountabilityCheck -Core $core -ProtectedServer $server
                                  }
                $newJob = Start-Job -Name $jobName -ScriptBlock (& $jobScriptBlock -core $core -server $server)

                Wait-Job -Job $newJob

                # checking if job completed successfully in the core logs


            }
    }
    END {}
}

Invoke-Command -ComputerName CH-BACK-02-NEW.citihosts.local -ScriptBlock { Start-AppAssureMountability -protectedserver MM-EX-01 }