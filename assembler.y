%{
#include <stdlib.h>
#include <stdio.h>

enum instruction_format { IF_R, IF_I, IF_UI, IF_S, IF_B, IF_J };

static struct instruction {
  enum instruction_format format;
  int funct3 : 3;
  int funct7 : 7;
  int imm : 20;
  int opcode : 7;
  int rd : 5;
  int rs1 : 5;
  int rs2 : 5;
  int shift_invalid : 1;
} instruction;

static void printbin(int val, char bits);
static int bit_range(int val, char begin, char end);
static void print_instruction(struct instruction);
int yylex();
void yyerror(char* s);
%}

%start program
%union {
  long l;
}
%token <l> REGISTER NEWLINE COMMA LEFT_PAREN RIGHT_PAREN MINUS IMMEDIATE
%token ADD SUB ADDI LW SLLI SW BEQ J AUIPC
%type <l> imm

%%
program : segments
;
segments : segments segment
| segment
;
segment : %empty
| text
;
text : text NEWLINE instruction
| instruction
;
instruction : r-type
{
  print_instruction(instruction);
}
| i-type
{
  print_instruction(instruction);
}
| s-type
{
  print_instruction(instruction);
}
| b-type
{
  print_instruction(instruction);
}
| j-type
{
  print_instruction(instruction);
}
| u-type
{
  print_instruction(instruction);
}
;
r-type : add
{
  instruction.format = IF_R;
  instruction.opcode = 0x33;
}
| sub
{
  instruction.format = IF_R;
  instruction.opcode = 0x33;
}
;
i-type : addi
{
  instruction.format = IF_I;
  instruction.opcode = 0x13;
}
| slli
{
  instruction.format = IF_I;
  instruction.opcode = 0x13;
}
| lw
{
  instruction.format = IF_I;
  instruction.opcode = 0x03;
}
;
s-type : sw
{
  instruction.format = IF_S;
  instruction.opcode = 0x23;
}
;
b-type : beq
{
  instruction.format = IF_B;
  instruction.opcode = 0x63;
}
;
j-type: j
{
  instruction.format = IF_J;
  instruction.opcode = 0x6F;
}
;
u-type: auipc
{
  instruction.format = IF_UI;
  instruction.opcode = 0x17;
}
;
add : ADD REGISTER COMMA REGISTER COMMA REGISTER // r-type: add rd, rs1, rs2
{
  instruction.funct3 = 0x0;
  instruction.funct7 = 0x0;
  instruction.rd = $2;
  instruction.rs1 = $4;
  instruction.rs2 = $6;
  instruction.shift_invalid = 0;
}
;
sub : SUB REGISTER COMMA REGISTER COMMA REGISTER // r-type: sub rd, rs1, rs2
{
  instruction.funct3 = 0x0;
  instruction.funct7 = 0x20;
  instruction.rd = $2;
  instruction.rs1 = $4;
  instruction.rs2 = $6;
  instruction.shift_invalid = 0;
}
;
addi : ADDI REGISTER COMMA REGISTER COMMA imm // i-type: addi rd, rs1, imm
{
  instruction.funct3 = 0x0;
  instruction.rd = $2;
  instruction.rs1 = $4;
  instruction.imm = $6;
  instruction.shift_invalid = 0;
}
;
slli : SLLI REGISTER COMMA REGISTER COMMA imm // i-type: slli rd, rs1, imm
{
  instruction.funct3 = 0x1;
  instruction.rd = $2;
  instruction.rs1 = $4;
  instruction.imm = $6;
  if(instruction.imm > 0x1F) instruction.shift_invalid = 1;
  else instruction.shift_invalid = 0;
}
;
lw : LW REGISTER COMMA imm LEFT_PAREN REGISTER RIGHT_PAREN // i-type: lw rd, imm(rs1)
{
  instruction.funct3 = 0x2;
  instruction.rd = $2;
  instruction.imm = $4;
  instruction.rs1 = $6;
  instruction.shift_invalid = 0;
}
;
sw : SW REGISTER COMMA imm LEFT_PAREN REGISTER RIGHT_PAREN // s-type: sw rs2, imm(rs1) 
{
  instruction.funct3 = 0x2;
  instruction.rs2 = $2;
  instruction.imm = $4;
  instruction.rs1 = $6;
  instruction.shift_invalid = 0;
}
;
beq : BEQ REGISTER COMMA REGISTER COMMA imm // b-type: beq rs1, rs2, imm
{
  instruction.funct3 = 0x0;
  instruction.rs1 = $2;
  instruction.rs2 = $4;
  instruction.imm = $6;
  instruction.shift_invalid = 0;
}
;
j : J REGISTER COMMA imm // j-type: jal rd, imm
{
  instruction.rd = $2;
  instruction.imm = $4 >> 1; // starts at bit 1
  instruction.shift_invalid = 0;
}
;
auipc : AUIPC REGISTER COMMA imm // u-type: auipc rd, imm
{
  instruction.rd = $2;
  instruction.imm = $4 >> 12; // starts at bit 12
  instruction.shift_invalid = 0;
}
;
imm : MINUS IMMEDIATE
{
$$ = -1 * $2;
}
| IMMEDIATE
{
$$ = $1;
}
;
%%
static void print_instruction(struct instruction instruction) {
  if (instruction.shift_invalid) {
    printf("Shift amount invalid\n");
    return;
  }

  switch (instruction.format) {
    case IF_R:
      printbin(instruction.funct7, 7);
      printbin(instruction.rs2, 5);
      printbin(instruction.rs1, 5);
      printbin(instruction.funct3, 3);
      printbin(instruction.rd, 5);
      printbin(instruction.opcode, 7);
      printf(" R-type");
      break;
    case IF_I:
      printbin(instruction.imm, 12);
      printbin(instruction.rs1, 5);
      printbin(instruction.funct3, 3);
      printbin(instruction.rd, 5);
      printbin(instruction.opcode, 7);
      printf(" I-type");
      break;
    case IF_UI: // imm is starting at bit 12
      printbin(instruction.imm, 20);
      printbin(instruction.rd, 5);
      printbin(instruction.opcode, 7);
      printf(" U-type");
      break;
    case IF_S:
      printbin(instruction.imm >> 5, 7);
      printbin(instruction.rs2, 5);
      printbin(instruction.rs1, 5);
      printbin(instruction.funct3, 3);
      printbin(instruction.imm, 5);
      printbin(instruction.opcode, 7);
      printf(" S-type");
      break;
    case IF_B:
      printbin(instruction.imm >> 12, 1);
      printbin(instruction.imm >> 5, 6);
      printbin(instruction.rs2, 5);
      printbin(instruction.rs1, 5);
      printbin(instruction.funct3, 3);
      printbin(instruction.imm >> 1, 4);
      printbin(instruction.imm >> 11, 1);
      printbin(instruction.opcode, 7);
      printf(" B-type");
      break;
    case IF_J: // imm is starting at bit 1
      printbin(instruction.imm >> 19, 1);
      printbin(instruction.imm, 10);
      printbin(instruction.imm >> 10, 1);
      printbin(instruction.imm >> 11, 8);
      printbin(instruction.rd, 5);
      printbin(instruction.opcode, 7);
      printf(" J-type");
      break;
    default:
      exit(-1);
  }
  printf("\n");
}
static void printbin(int val, char bits) {
  for (char i = bits - 1; i >= 0; i--) {
    if (val & (1 << i)) {
      putchar('1');
    } else {
      putchar('0');
    }
  }
}

static int bit_range(int val, char begin, char end) {
  int mask = ((1 << end) - 1) ^ ((1 << begin) - 1);
  return (val & mask) >> begin;
}

void yyerror(char *msg){
    
}

int main(){
 #ifdef YYDEBUG
 int yydebug = 1;
 #endif /* YYDEBUG */
 yyparse();
 return 0;
}
