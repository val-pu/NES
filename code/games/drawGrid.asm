drawGrid:
    LDA #$21
    STA $2006
    LDA #$4B
    STA $2006
    ;LDA #$28
    ;STA $2007
    
    LDX #10 ; number of rows
    LDA #$00 
    LDY #$00 ; index in GridData
PrintGrid:
    ; save index of outer loop
    TXA
    PHA
    LDX #10 ; row index 10-X

PrintRow:
    LDA GridData, Y
    STA $2007
    INY
    DEX
    BNE PrintRow

    ; skip next 22 tiles to start a new row
    ; (grid=10 tiles wide. screen=32 and 32-10=22) 
    LDX #22
    LDA #0
BlankRemainingRow:    
    STA $2007
    DEX
    BNE BlankRemainingRow
    
    PLA
    TAX
    DEX
    BNE PrintGrid
    RTS