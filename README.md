# basic-risc-v-assembler
a simple RISC-V assembler that translates a small subset of the RISC-V instruction set into binary code using the correct RISC-V instruction binary encodings

# supported subset
* add rd, rs1, rs2
* sub rd, rs1, rs2
* addi rd, rs1, imm
* slli rd, rs1, imm
* lw rd, offset(rs1)
* sw rs2, offset(rs1)
* beq rs1, rs2, offset
* jal rd, offset
* auipc rd, imm

# tools
* Flex v2.6.4
* Bison v3.8.2

a windows-port is used in the project by default, found here: https://github.com/lexxmark/winflexbison/releases/tag/v2.5.25

# building
on Windows
```
./flex assembler.l
gcc -g -c lex.yy.c -o assembler.tab.o -O

./bison -dt --debug --verbose -Dparse.trace assembler.y
gcc -g -c assembler.tab.c -o assembler.tab.o -O

gcc -g assembler.tab.o lex.yy.o -o assembler -lm
```
on Linux
```
flex assembler.l
gcc -g -c lex.yy.c -o assembler.tab.o -O

bison -dt --debug --verbose -Dparse.trace assembler.y
gcc -g -c assembler.tab.c -o assembler.tab.o -O

gcc -g assembler.tab.o lex.yy.o -o assembler -lm
```

# usage
each line of input is translated to their binary encoding if possible.

```
./assembler
add x10, x8, x7
00000000011101000000010100110011 R-type
```

files can be used via input redirection.

```
./assembler < test.asm
00000000011101000000010100110011 R-type
01000000100101100000010000110011 R-type
00000010101100000000010000010011 I-type
00000001110001011001001110010011 I-type
00000100010001000010011000000011 I-type
00000000101000000010101010100011 S-type
00000000100101000000010101100011 B-type
00110011111000000000000101101111 J-type
00000000000000001011000100010111 U-type
```
