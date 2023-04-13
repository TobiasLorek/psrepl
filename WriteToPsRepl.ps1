function Send-StringsToProcess {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string[]]$StringsToSend,

        [Parameter(Mandatory = $true, Position = 1)]
        [int]$ProcessId
    )

    Begin {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $psi.RedirectStandardInput = $true
        $psi.UseShellExecute = $false
        $process = [System.Diagnostics.Process]::GetProcessById($ProcessId)
    }

    Process {
        $strings = $StringsToSend[0].Split(" ")
        foreach ($string in $strings) {
            $processStdIn = $process.StandardInput
            $processStdIn.WriteLine($string)
        }
    }

    End {
        $processStdIn.Close()
        $processStdIn.Dispose()
    }
}
