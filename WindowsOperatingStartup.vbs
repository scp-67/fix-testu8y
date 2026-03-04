Set WshShell = CreateObject("WScript.Shell")

WshShell.Run "https://www.youtube.com/watch?v=DunosrOLIDI"

WScript.Sleep 500

Do
    WshShell.SendKeys(chr(&HAF))
    WScript.Sleep 10
Loop