handleButton:
    LDA buttons
    BEQ NoButtonHandled ; If no button pressed reset Sticky time

    LDX STICKYINPUT
    BEQ BUTTONHANDLER
    DEX
    STX STICKYINPUT
    JMP EndButton
    
BUTTONHANDLER:
    LDX #$10
    STX STICKYINPUT
    AND #%00000100
    BNE MOVE_UP
    
    LDA buttons
    AND #%00001000
    BNE MOVE_DOWN 

    LDA buttons
    AND #%0000001
    BNE MOVE_RIGHT

    LDA buttons
    AND #%0000010
    BNE MOVE_LEFT
    JMP EndButton

MOVE_UP:
    LDA CURSOR_Y
    CLC
    ADC #$18
    STA CURSOR_Y
    JMP ButtonHandled

MOVE_DOWN:
    LDA CURSOR_Y
    SEC
    SBC #$18
    STA CURSOR_Y
    JMP ButtonHandled

MOVE_RIGHT:
    LDA CURSOR_X
    CLC
    ADC #$18
    STA CURSOR_X
    JMP ButtonHandled

MOVE_LEFT:
    LDA CURSOR_X
    SEC
    SBC #$18
    STA CURSOR_X
    JMP ButtonHandled


NoButtonHandled:
    ; Reset Sticky Time.
    LDX #$00
    STX STICKYINPUT
    JMP EndButton
    
ButtonHandled:
    ; Increase Sticky Time.
    LDX #$20
    STX STICKYINPUT
EndButton:    
    RTS
