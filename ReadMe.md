# NES Assembly Tutorial


# 00 Setup

- Task 1: Install the assembler and linker https://cc65.github.io
- Task 2: Install a NES emulator https://fceux.com
- Task 3: Install a tile editor https://github.com/toruzz/TileMolester
- Task 4: What computers used the 6502 micro processor? What are the registers and their purpose? Use this link: https://en.wikipedia.org/wiki/MOS_Technology_6502

# 01 Background Color

- Example: Sets the background color to blue [01_example.asm](./code/01_example.asm)

- Task 1: Assemble and link the file and create a nes file using `ca65` and `ld65`. 
  The command is at the top of the first example.

- Task 2: Look up the assembly commands in the StartUp segment and describe what they do. Ignore all memory addresses for now. Use this link: http://mimuma.pl/opcodes/ 

- Task 3: Look up every memory address (like $2000) and find the name of hardware register which is mapped at this location. Use this link: http://en.wikibooks.org/wiki/NES_Programming

- Task 4: Look up the effect of every Bit of the PPUCTRL ($2000) and PPUMASK ($2001) register. Use this link: http://nesdev.org/wiki/PPU_registers

- Task 5: Explain how the example writes to the PPU RAM using this picture: [cpu_ppu_communication](
https://bugzmanov.github.io/nes_ebook/images/ch6.1/image_2_cpu_ppu_communication.png)
- Task 6: Open the NES file with fceux. 
  Compare the numbers in `PaletteData` in the assembly file with the numbers shown in fceux `Tools->Palette Editor`.

- Exercise: Set the background color to red [01_solution.asm](./code/01_solution.asm)

![solution01.png](code/solution01.png)

