; Draw X, O or nothing at row of register x and y
drawCharacter:


    LDA #$2
    STA METATILE_H
    STA METATILE_W
    

    ;JSR DrawMetatile


    ; Calculate Byte index für Row X. It is (X-1)



    LDA #$20
    LDX #4
    LDY #8
    JSR DrawMetatile


    LDA #$20
    LDX #7
    LDY #8
    JSR DrawMetatile
    LDY #4
    JSR DrawMetatile
;
    LDY #8
    JSR DrawMetatile
;
    ;LDY #16
    ;JSR DrawMetatile
;
    ;LDX #16
    ;JSR DrawMetatile

    rts