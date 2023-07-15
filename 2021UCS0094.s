.section .data
@d1: .word 0x00010000,0x00010000        
@d1: .word 0x0028e000,0x00010000
@d1: .word 0x92345678,0x92341234

@d1: .word 0x8000d000,0x7ff68000 
@d1: .word 0x7fec0000,0x7fe40000  
@d1: .word 0x800ed000,0xfff68000
@d1: .word 0x00260000,0x80330000
d1:.word 0x00330000,0xfff60000

d3: .word 0,0,0
d4: .word 0,0,0
d5: .word 0x7fffffff,0x8007ffff,0xfff80000,0x40000000,0x7ff80000,0x00080000,0xffffffff
d6: .word 0,0


.section .text
.global _start

@nfpform: it is function which is used to extract the sign bit,exponent bits and mantisaa bits into 3 different numbers
@d3: it will store all bits extracted from 1st number 1st num is sign bits,2nd exponent bits and 3rd mantisaa bits
@d4: it will contain same results but for 2nd number
@d6: 1st number will contain result of multiplication and 2nd contain result of addition
@nfpmultiply: function which multiply two numbers

@RESULT OF MULTIPLICATION IS STORED IN D6 AND RESULT OF ADDITION IS STORED IN D6+4

nfpform:
  stmfd sp!,{r0,r2,r3,r4,r5,r6,r7,r8,r9,lr}
  ldr r1,=d1
  ldr r8,=d3
  ldr r9,=d4
  ldr r5,=d5
 
 @@@@@@@@@@@@@@@@@@@ EXTRACTING SIGN BIT OF NUMBER
  ldr r2,[r5]
  ldr r6,[r1]
  add r1,r1,#4
  ldr r7,[r1]
  bic r3,r6,r2
  bic r4,r7,r2
  str r3,[r8]
  str r4,[r9]

  add r5,r5,#4
  ldr r2,[r5]

@@@@@@@@@@@@@@@@@@@@@@ EXTRACTING EXPONENT BITS
  bic r3,r6,r2
  
  bic r4,r7,r2
  
  
  add r8,r8,#4
  add r9,r9,#4
  str r3,[r8]
  str r4,[r9]

@@@@@@@@@@@@@@@@@@@ EXTRACTING MANTISSA BITS
  add r5,r5,#4
  ldr r2,[r5]
  bic r3,r6,r2
  bic r4,r7,r2
  add r8,r8,#4
  add r9,r9,#4
  
  str r3,[r8]
  str r4,[r9]

  ldmfd sp!,{r0,r2,r3,r4,r5,r6,r7,r8,r9,pc}



nfpmultiply:
   stmfd sp!,{r0,r2,r3,r4,r5,r6,r7,r8,r9,lr}
   ldr r0,=d3
   ldr r2,=d4
   add r0,r0,#4
   add r2,r2,#4

   ldr r3,[r0]
   ldr r4,[r2]
   
   @@@@@@@@@@@@@@@@@ ADDITION OF EXPONRNTS
   add r5,r3,r4
   lsl r5,r5,#1
   lsr r5,r5,#1
      
   add r0,r0,#4
   add r2,r2,#4

   @@@@@@@@@@@@@@@@MULTIPLICATION OF MANTISSA
   ldr r3,[r0]
   ldr r4,[r2]  
   mov r9,#1
   lsl r9,r9,#19

   add r3,r3,r9
   add r4,r4,r9
   @lsr r3,r3,#4
   @lsr r4,r4,#4
   umull r7,r6,r3,r4
   
   
   lsl r6,r6,#24
   lsr r7,r7,#8
   add r6,r6,r7

   lsr r8,r6,#31
   
   cmp r8,#0
   beq j
   add r5,r5,r9
   lsr r6,r6,#1
    
   
   j:lsr r6,r6,#11
   
   @@@ REMOVING SIGNIFICAND THAT WE HAVE ADDED PREVIOUSLY 
   sub r6,r6,r9

  
    
     
   
   @@@@@@@@@@@@@@@@@@@@@ FINAL SIGN OF MULTIPLICATION
   ldr r0,=d3
   ldr r2,=d4
   ldr r3,[r0]
   ldr r4,[r2]
   eor r7,r3,r4
   cmp r7,#1
   mov r8,#0
   adc r8,r8,#0
   lsl r8,r8,#31

   @@@@@@@@@@@@@@@@@@@@@@FINAL RESULT OF MULTIPLICATION IN R2 REGISTER
   add r2,r8,r5
   add r2,r2,r6

   @@@@@@@@@@@@@@@@@@@@@@@@@@@STORAGE OF RESULT OF MULTIPLICATION IN d6
   ldr r1,=d6
   str r2,[r1]
      
   ldmfd sp!,{r0,r2,r3,r4,r5,r6,r7,r8,r9,pc}



nfpadd:
  stmfd sp!,{r0,r2,r3,r4,r5,r6,r7,r8,r9,lr}
  ldr r0,=d3
  ldr r2,=d4
  ldr r5,=d5

  ldr r6,[r0,#4]!                @@@ IN R6 EXPONENT OF 1ST NUMBER IS STORED 
                                 
  ldr r8,[r2,#4]!                @@@ IN R8 EXPONENT OF 2ND NUMBER
         
  ldr r3,[r0,#4]!                @@@ IN R3 MANTISA OF 1ND NUMBER
  ldr r4,[r2,#4]!                @@@ IN R4 MANTISA OF 2ND NUMBER
  mov r9,#1
  lsl r9,r9,#19
  add r4,r4,r9                   @@@ SIGNIFICANT 1 IN FRONT OF BOTH OF MANTISSA
  add r3,r3,r9
  mov r2,#0


  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ COMPARISON OF EXPONENTS IFF SIGN ARE NOT SAME 
  lsr r5,r6,#30
  lsr r1,r8,#30
  
  cmp r5,r1        
  beq r                           @@@ IF SIGN OF BOTH EXPONENT ARE SAME BRANCH TO 'r'
  cmp r5,#1                           
  beq e
  ldr r5,=d5
  ldr r1,[r5,#16]!
  bic r8,r1,r8
  add r8,r8,r9
  mov r7,#0
  add r7,r6,r8
  lsr r7,r7,#19
  lsr r4,r4,r7
  
  add r2,r2,r6
  b s


  e:ldr r5,=d5
    ldr r2,[r5,#16]!
    bic r6,r2,r6
    add r6,r6,r9
    mov r7,#0
    add r7,r6,r8
    lsr r7,r7,#19
    lsr r3,r3,r7
   
    add r2,r2,r8
    b s                          @@@ S IS JUST A NOP INSTRUCTION TO PASS AWAY OTHER CONDITION (CAN SAY IF/ELSE)
   
  

  

  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  COMPARE TWO EXPONENTS IF SIGN OF BOTH EXPONENT ARE SAME
  



r:cmp r6,r8
  bgt p
  sub r7,r8,r6
  add r2,r2,r8
  lsr r7,r7,#19
  lsr r3,r3,r7 
  cmp r2,r8
  beq y
  
  

  p: sub r7,r6,r8
     add r2,r2,r6
     lsr r7,r7,#19 
     lsr r4,r4,r7
  
  y:nop
 
  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ ADDITION/SUBTRACTION OF MANTISSA
  s:nop
  
  mov r7,#0
  ldr r0,=d3
  ldr r6,=d4
  ldr r8,[r0]
  ldr r5,[r6]

  cmp r8,r5
  beq g                        @@@ IF SIGN OF BOTH NUMBER IS SAME GO TO g(ADDITION)
  cmp r3,r4
  bgt h
  sub r0,r4,r3
  add r7,r7,r5
  cmp r7,r5
  beq u

  h:sub r0,r3,r4
    add r7,r7,r8
  
 u:mov r9,#1
   lsl r9,r9,#19
   mov r6,#1
   lsl r6,r6,#20
   lsl r0,r0,#1
   sub r2,r2,r9
   cmp r6,r0
   bgt u
   lsr r0,r0,#1
   sub r0,r0,r9
   add r2,r2,r9
   cmp r6,r6
   beq t
   



 g:add r0,r3,r4
   mov r7,#0
   add r7,r7,r8
   mov r9,#1
   lsl r9,r9,#20
   
   cmp r0,r9
   bgt q
   beq q
   lsr r9,r9,#1  
   b m

 q: 
   lsr r0,r0,#1
   add r2,r2,r9

 m:sub r0,r0,r9   
   

t:nop

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ RENORMALISATION

    
     
lsr r4,r2,#31        @@@@@ IF POWER IS NEGATIVE OF ANSWER REMOVE 1 FROM OVERALL SIGN BIT
  cmp r4,#0
  beq w
  mov r5,#1
  lsl r5,r5,#31
  sub r2,r2,r5


w:nop 


mov r3,#0
add r3,r3,r7
add r3,r3,r2
add r3,r3,r0



ldr r1,=d6
str r3,[r1,#4]!                     @@@ RESULT IS STORED IN 'D6+4'
ldr r1,=d6

ldmfd sp!,{r0,r2,r3,r4,r5,r6,r7,r8,r9,pc}



_start:
bl nfpform
mov r0, #0
bl nfpmultiply
mov r4,#0
bl nfpadd
mov r5,#0

























