Set objShell = CreateObject("WScript.Shell")

Do
    ' This command launches the Chrome application
    objShell.Run "chrome.exe"
    
    ' Wait 3 seconds before trying again
    WScript.Sleep 100
Loop