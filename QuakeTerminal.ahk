#Requires AutoHotkey v2

#SingleInstance Force

; Settings
terminalExe := "powershell"
hideTitleBar := true

; Data
terminalPID := 0

#!Space:: {
    global terminalPID
    global terminalExe
    global hideTitleBar

    if (terminalPID && ProcessExist(terminalPID)) {
        if (WinActive("ahk_pid " terminalPID)) {
            ; Window is visible - hide it
            WinHide("ahk_pid " terminalPID)
        } else {
            ; Window is hidden - show it
            WinShow("ahk_pid " terminalPID)
            WinActivate("ahk_pid " terminalPID)
        }
    } else {
        ; No running terminal - create a new one

        ; Get primary monitor dimensions
        MonitorGetWorkArea(, &left, &top, &right, &bottom)
        screenWidth := right - left
        screenHeight := bottom - top

        terminalWidth := screenWidth
        terminalHeight := screenHeight // 2

        ; Start PowerShell and get the PID
        Run(terminalExe, , , &terminalPID)

        ; Wait for the window to be created
        maxWaitTime := 10000  ; 10 seconds in milliseconds
        elapsedTime := 0
        while (!WinExist("ahk_pid " terminalPID)) {
            if (elapsedTime > maxWaitTime) {
                throw "Cannot find the created terminal window with PID" terminalPID
            }
            Sleep(100)
            elapsedTime += 100
        }

        ; Move and resize the window
        WinMove(left, top, terminalWidth, terminalHeight, "ahk_pid " terminalPID)

        if (hideTitleBar) {
            ; Remove title bar but keep resizable borders
            WinSetStyle("-0xC00000", "ahk_pid " terminalPID)  ; Remove WS_CAPTION (title bar)
        }
    }
}
