drawCursor:
   ; move the sprite up or down by updating the OAM Y Attr
    LDX #$00
    LDA CURSOR_Y
MoveSpritesY:
    STA $0200, X ; first tile at $0200 + X
    STA $0204, X ; second tile at $0204 + X
    INX
    INX
    INX
    INX
    INX
    INX
    INX
    INX          ; next tile at $0208, $020C ... 
    CLC          ; next two tiles must be drawn 8 pixels below
    ADC #$08
    CPX #$10     ; sprite is 8x8 tiles (64 pixels) but every iteration handles two
    BNE MoveSpritesY


    LDX #$00
    LDA CURSOR_X
MoveSpritesX:
    STA $0203, X
    CLC          ; every second tile is 8 pixels to the right (modify CURSOR_X by 8)
    ADC #$08
    STA $0207, X
    INX
    INX
    INX
    INX
    INX
    INX
    INX
    INX
    SEC
    SBC #$08     ; make sure the original CURSOR_X is used for the first tile
    CPX #$10
    BNE MoveSpritesX
    RTS