.segment "ZEROPAGE"

METATILE_W: .byte $00
METATILE_H: .byte $00

.segment "STARTUP"

; Registers X and Y have X and Y positions the metatile should appear at. A contains start tile index.
; Uses ZP-Variables U1, U2

DrawMetatile:
    
    ; Save A while saving X,Y
    STA U1
    ; Save X and Y on Stack for caller
    TXA
    PHA
    TYA
    PHA

    LDA U1
    PHA; Save A for caller

    PHA ; Save Tile index 
    LDA #$20
    STA U1
    LDA #$00
    STA U2

; Calculate POS= Y * 0x20 into U1...U2 Big Endian
DrawMetatile_LoopYPos:    
    CLC
    ADC #$20    
    BCS DrawMetatile_LoopYPosCarryToNextByte
    STA U2
    JMP DrawMetatile_LoopYPosEnd
DrawMetatile_LoopYPosCarryToNextByte:
    INC U1
    STA U2
DrawMetatile_LoopYPosEnd:

    DEY
    BNE DrawMetatile_LoopYPos

    ; Add X to POS, may cause overflow in lower byte. Then add carry to high byte

    LDY U1 ; Save value U1. It will be used as second operand with X
    STX U1

    CLC
    ADC U1 ; U2 + X
    BCC DrawMetatile_NoXCarry

    INY ; Account for possible carry

DrawMetatile_NoXCarry:
    STY U1
    sta U2

    STY $2006
    LDX U2
    STX $2006

    PLA ; Pull tile index.
    LDX METATILE_H
DrawMetatile_TileSetLoopHeight:
    LDY METATILE_W
DrawMetatile_TileSetLoopWidth:
    
    STA $2007
    CLC
    ADC #1
    DEY
    BNE DrawMetatile_TileSetLoopWidth

    JMP DrawMetatile_NextLine
DrawMetatile_NextLineContinue:
    DEX
    BNE DrawMetatile_TileSetLoopHeight
    
    ; restore state for caller
    ;load A
    PLA 
    STA U1
    ; load Y
    PLA
    TAY
    ; load X
    PLA
    TAX

    LDA U1
    
    ; Clean up 2006
    PHA
    LDA #$20
    STA U1
    LDA #$00
    STA U2
    LDA U1
    STA $2006
    LDA U2
    STA $2006

    PLA

    RTS


DrawMetatile_NextLine:
    PHA
    LDA U2
    CLC
    ADC #$20
    BCC DrawMetatile_NextLineEnd
    INC U1
DrawMetatile_NextLineEnd:
    STA U2
    LDA U1
    STA $2006
    LDA U2
    STA $2006
    
    

    JMP DrawMetatile_NextLineContinue