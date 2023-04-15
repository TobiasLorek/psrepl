# Load the Console API from kernel32.dll
Add-Type -Name ConsoleApi -Namespace Win32 -MemberDefinition "
[DllImport(\"kernel32.dll\")]
public static extern bool AttachConsole(int dwProcessId);
[DllImport(\"kernel32.dll\", SetLastError = true, CharSet = CharSet.Auto)]
public static extern IntPtr GetStdHandle(int nStdHandle);
[DllImport(\"kernel32.dll\", SetLastError = true)]
public static extern bool WriteConsole(IntPtr hConsoleOutput, string lpBuffer, uint nNumberOfCharsToWrite, out uint lpNumberOfCharsWritten, IntPtr lpReserved);
[DllImport(\"kernel32.dll\", SetLastError = true)]
public static extern bool FreeConsole();
"

# Get the process id and array of strings from the command line arguments
$pid = [int]$args[0]
$lines = $args[1..$($args.Count-1)]

# Attach to the console of the specified process
$consoleAttached = [Win32.ConsoleApi]::AttachConsole($pid)

if ($consoleAttached) {
    try {
        # Get the handle for the console's standard input
        $hStdIn = [Win32.ConsoleApi]::GetStdHandle(-10) # -10 = STD_INPUT_HANDLE

        if ($hStdIn -ne [System.IntPtr]::Zero) {
            # Write each line to the console's standard input
            foreach ($line in $lines) {
                [uint]$written = 0
                [Win32.ConsoleApi]::WriteConsole($hStdIn, $line, $line.Length, [ref]$written, [System.IntPtr]::Zero)
            }
        }
    } finally {
        # Detach from the console and free the console resources
        [void][Win32.ConsoleApi]::FreeConsole()
    }
} else {
    Write-Error "Failed to attach to console for process with id $pid"
}
