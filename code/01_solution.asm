;ca65 code/01_solution.asm -o code/01_solution.o -t nes && ld65 code/01_solution.o -o code/01_solution.nes -t ne
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
PLAYERPOSX: .byte $00 
PLAYERPOSY: .byte $00 
buttons: .res 1
.segment "STARTUP"
Reset:
    ; Disable all interrupts
    SEI 
    ; Disable decimal mode
    CLD 
    ; Initialize stack register to 256 (grows downward)
    LDX #$FF
    TXS
    ; Zero out PPU registers
    LDX #$00
    STX $2000
    STX $2001

    ; Write $3F00 (platte memory address) to PPU address register
    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006

    ; Load four colors to palette memory ($3F00)
    LDX #$00
LoadPalettes:
    ; Write colors to PPU data register
    LDA PaletteData, X
    STA $2007 ; auto inc on write of data register: $3F00, ... , $3F03
    INX
    CPX #$04  ; loop four times: write 4 values
    BNE LoadPalettes    

    ; Enable interrupts
    CLI

    LDA #%10010000 ; enable NMI change background to use second chr set of tiles ($1000)
    STA $2000
    ; Enabling sprites and background for left-most 8 pixels
    ; Enable sprites and background
    LDA #%00011110
    STA $2001

Loop:
    JMP Loop

NMI:
    RTI

PaletteData:
  .byte $16,$29,$1A,$0F ; background palette data

.segment "VECTORS"
    .word NMI
    .word Reset
    ; 
.segment "CHARS"
    .incbin "code/tilemap01.chr"