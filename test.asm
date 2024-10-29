add x10, x8, x7
sub x8, x12, x9
addi x8, x0, 43
slli x7, x11, 28
lw x12, 0104(x8)
sw x10, 0x15(x0)
beq x8, x9, 0b1010
jal x2, 0x33F
auipc x2, 0xB8C2