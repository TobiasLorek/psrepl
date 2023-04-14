function Send-StringsToProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]]$StringsToSend,

        [Parameter(Mandatory = $true, Position = 1)]
        [int]$ProcessId
    )

    Begin {
        $process = [System.Diagnostics.Process]::GetProcessById($ProcessId)
    }

    Process {
        foreach ($stringToSend in $StringsToSend) {
            $decodedString = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($stringToSend))
            $strings = $decodedString.Split(" ")
            foreach ($string in $strings) {
                $processStdIn = $process.StandardInput
                $processStdIn.WriteLine($string)
            }
        }
    }

    End {
        $processStdIn.Close()
        $processStdIn.Dispose()
    }
}

$arguments = [System.Environment]::GetCommandLineArgs()
$arguments = $arguments[1..($arguments.Length - 1)]
Send-StringsToProcess -StringsToSend $arguments -ProcessId $pid
