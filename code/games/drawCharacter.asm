; Draw X, O or nothing at row of register x and y
drawCharacter:

    ; Calculate Byte index für Row X. It is (X-1)
    LDA STATE, X
    LDX #$03
    TAY
DrawCharsRow:
    TYA
    AND #%01000000
    BEQ NO_X
    LDA #$28
    STA $2007
    CLC
    ADC #$01
    STA $2007
    JMP drawCharacter_END
NO_X:
    TYA
    AND #%10000000
    BEQ NO_O
    LDA #$2C
    STA $2007
    CLC
    ADC #$01
    STA $2007
    JMP drawCharacter_END
NO_O:
    LDA #$00
drawCharacter_END:
    TYA
    ASL
    ASL
    TAY 
    DEX
    BNE DrawCharsRow
    rts