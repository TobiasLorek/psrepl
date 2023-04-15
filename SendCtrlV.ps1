Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class PInvokeHelper {
        [DllImport("user32.dll")]
        public static extern bool SendMessage(IntPtr hWnd, uint Msg, int wParam, int lParam);
    }
"@

function Send-CtrlVKeysToWindow([IntPtr]$handle)
{
    # Get the window handle
    $targetWindow = $handle

    # Activate the target window to prepare it to receive the keystroke message
    [PInvokeHelper]::SendMessage($targetWindow, 0x0100, 0x000D, 0)

    # Simulate a key down message for the Ctrl key
    [PInvokeHelper]::SendMessage($targetWindow, 0x0100, 0x0014, 0x001D0001)

    # Simulate a key down message for the V key
    [PInvokeHelper]::SendMessage($targetWindow, 0x0100, 0x0022, 0x002F0001)

    # Simulate a key up message for the V key
    [PInvokeHelper]::SendMessage($targetWindow, 0x0101, 0x0022, 0xC02F0001)

    # Simulate a key up message for the Ctrl key
    [PInvokeHelper]::SendMessage($targetWindow, 0x0101, 0x0014, 0xC01D0001)
}
