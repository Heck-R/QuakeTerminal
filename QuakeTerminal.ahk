#Requires AutoHotkey v2

#SingleInstance Force

; Settings
terminalExe := "powershell"
terminalWorkingDir := "D:/"
hideTitleBar := true

; Data
terminalPID := 0

#!Space:: {
    global terminalPID
    global terminalExe
    global hideTitleBar

    if (terminalPID && ProcessExist(terminalPID)) {
        if (WinExist("ahk_pid " terminalPID)) {
            WinHide("ahk_pid " terminalPID)
        } else {
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

        Run(terminalExe, terminalWorkingDir, , &terminalPID)

        ; Wait for the window to be created
        maxWaitTime := 10000  ; milliseconds
        elapsedTime := 0
        while (!WinExist("ahk_pid " terminalPID)) {
            if (elapsedTime > maxWaitTime) {
                throw "Cannot find the created terminal window with PID" terminalPID
            }
            Sleep(100)
            elapsedTime += 100
        }

        WinMove(left, top, terminalWidth, terminalHeight, "ahk_pid " terminalPID)

        if (hideTitleBar) {
            ; Remove WS_CAPTION (title bar)
            WinSetStyle("-0xC00000", "ahk_pid " terminalPID)
        }

        WinSetAlwaysOnTop(1, "ahk_pid " terminalPID)
    }
}
