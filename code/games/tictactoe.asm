;ca65 tictactoe.asm -o t.o -t nes && ld65 t.o -o tictactoe.nes -t nes
.segment "HEADER"
.byte "NES"
.byte $1a
.byte $02 ; 2 * 16KB PRG ROM
.byte $01 ; 1 * 8KB CHR ROM
.byte %00000001 ; mapper and mirroring
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00, $00, $00, $00, $00 ; filler bytes
.segment "ZEROPAGE" ; LSB 0 - FF
CURSOR_X: .byte $00 
CURSOR_Y: .byte $00
STICKYINPUT: .byte $00 ; Only one input per click

STATE: .byte $00, $00, $00 ; 01 is X 10 is 0, 00 is nothing. 11 is undef. Only 6 Bit used per Byte. Each byte saves one Row. 
U1: .byte $00
U2: .byte $00
buttons: .res 1
.segment "STARTUP"
Reset:
    SEI ; Disables all interrupts
    CLD ; disable decimal mode

     ; Disable sound IRQ (for some reason everthing is broken without this line)
     LDX #$40
     STX $4017

     ; Initialize the stack register
     LDX #$FF
     TXS

;     ;INX ; #$FF + 1 => #$00
     LDX #$00

     ; Zero out the PPU registers
     STX $2000
     STX $2001

     STX $4010

 :
     BIT $2002 ; wait for vblank
     BPL :-

;     ;TXA
     LDA #$00

CLEARMEM:
    STA $0000, X ; $0000 => $00FF
    STA $0100, X ; $0100 => $01FF
    STA $0300, X
    STA $0400, X
    STA $0500, X
    STA $0600, X
    STA $0700, X
    LDA #$FF
    STA $0200, X ; $0200 => $02FF
    LDA #$00
    INX
    BNE CLEARMEM    
; wait for vblank
:
    BIT $2002
    BPL :-

    LDA #$02  ; high byte von sprites
    STA $4014
    NOP

    ; $3F00
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006

    LDX #$00
LoadPalettes:
    LDA PaletteData, X
    STA $2007 ; $3F00, $3F01, $3F02 => $3F1F
    INX
    CPX #$20 ; dezi 32
    BNE LoadPalettes    

    LDX #$00
LoadSprites:
    LDA SpriteData, X
    STA $0200, X
    INX
    CPX #$10
    BNE LoadSprites    

; Clear the nametables- this isn't necessary in most emulators unless
; you turn on random memory power-on mode, but on real hardware
; not doing this means that the background / nametable will have
; random garbage on screen. This clears out nametables starting at
; $2000 and continuing on to $2400 (which is fine because we have
; vertical mirroring on. If we used horizontal, we'd have to do
; this for $2000 and $2800)
    LDX #$00
    LDY #$00
    LDA $2002
    LDA #$20
    STA $2006
    LDA #$00
    STA $2006
ClearNametable:
    STA $2007
    INX
    BNE ClearNametable
    INY
    CPY #$08
    BNE ClearNametable
    
; Enable interrupts
    CLI

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

    LDA #0
    STA $2005 ; X position (this also sets the w register)
    STA $2005 ; Y position (this also clears the w register)

    ; move selector tile to first square
    LDA #$57
    STA CURSOR_Y
    LDA #$60
    STA CURSOR_X

    LDA #%10010000 ; enable NMI change background to use second chr set of tiles ($1000)
    STA $2000
    ; Enabling sprites and background for left-most 8 pixels
    ; Enable sprites and background
    LDA #%00011110
    STA $2001

    ; delete me later
    LDA #%01001000
    STA STATE

Loop:
    JMP Loop

; At the same time that we strobe bit 0, we initialize the ring counter
; so we're hitting two birds with one stone here
readjoy:
    lda #$01
    ; While the strobe bit is set, buttons will be continuously reloaded.
    ; This means that reading from $4016 will only return the state of the
    ; first button: button A.
    sta $4016
    sta buttons
    lsr a        ; now A is 0
    ; By storing 0 into $4016, the strobe bit is cleared and the reloading stops.
    ; This allows all 8 buttons (newly reloaded) to be read from $4016.
    sta $4016
loop:
    lda $4016
    lsr a        ; bit 0 -> Carry
    rol buttons  ; Carry -> bit 0; bit 7 -> Carry
    bcc loop
    rts

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



NMI:
    LDA #$02 ; copy sprite data from $0200 => PPU memory for display
    STA $4014
    
    JSR readjoy
    LDA buttons
    BEQ NoButtonHandled ; If no button pressed reset Sticky time

    LDX STICKYINPUT
    BEQ BUTTONHANDLER
    DEX
    STX STICKYINPUT
    JMP DRAW
    
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
    JMP DRAW

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
    JMP DRAW
    
ButtonHandled:
    ; Increase Sticky Time.
    LDX #$20
    STX STICKYINPUT
    

DRAW:
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

    ;LDX #3 ; Number of Rows

    LDA #$21
    STA $2006
    LDA #$6C
    STA $2006
    LDX #$00
    LDY #$00
    JSR drawCharacter

    LDA #$20
    STA $2006
    LDA #$00
    STA $2006


    RTI

PaletteData: ; maxvalue 0x36
  .byte $3F,$10,$1A,$0F,$3F,$36,$17,$0f,$3F,$30,$21,$0f,$3F,$27,$17,$0F  ;background palette data
  .byte $3F,$16,$27,$18,$3F,$1A,$30,$27,$3F,$16,$30,$27,$3F,$0F,$36,$17  ;sprite palette data

SpriteData:
  .byte $08, $01, $01, $08 ; Y,Tileindex, ATTR, X
  .byte $08, $02, $01, $10
  .byte $10, $03, $01, $08
  .byte $10, $04, $01, $10


GridData:
  .byte $39, $31, $31, $35, $31, $31, $35, $31, $31, $3A
  .byte $30, $00, $00, $30, $00, $00, $30, $00, $00, $30
  .byte $30, $00, $00, $30, $00, $00, $30, $00, $00, $30
  .byte $33, $31, $31, $32, $31, $31, $32, $31, $31, $36 
  .byte $30, $00, $00, $30, $00, $00, $30, $00, $00, $30
  .byte $30, $00, $00, $30, $00, $00, $30, $00, $00, $30
  .byte $33, $31, $31, $32, $31, $31, $32, $31, $31, $36 
  .byte $30, $00, $00, $30, $00, $00, $30, $00, $00, $30
  .byte $30, $00, $00, $30, $00, $00, $30, $00, $00, $30
  .byte $37, $31, $31, $34, $31, $31, $34, $31, $31, $38 

.segment "VECTORS"
    .word NMI
    .word Reset
    ; 
.segment "CHARS"
    .incbin "tilemap.chr"