regx: 

addx-al r1, r2, r3

addx-al r10, r14, #9

addx-al r1, r2, r3, lsl r4

addx-al r1, r2, r3, lsl #4

addx-al r1, r5, #452



addx.s-al r1, r2, r3

addx.s-al r10, r14, #9

addx.s-al r1, r2, r3, lsl r4

addx.s-al r1, r2, r3, lsl #4

addx.s-al r1, r5, #452




subx-al r1, r2, r3

subx-al r10, r14, #9

subx-al r1, r2, r3, lsl r4

subx-al r1, r2, r3, lsl #4

subx-al r1, r5, #452



subx.s-al r1, r2, r3

subx.s-al r10, r14, #9

subx.s-al r1, r2, r3, lsl r4

subx.s-al r1, r2, r3, lsl #4

subx.s-al r1, r5, #452




adcx-al r1, r2, r3

adcx-al r10, r14, #9

adcx-al r1, r2, r3, lsl r4

adcx-al r1, r2, r3, lsl #4

adcx-al r1, r5, #452



adcx.s-al r1, r2, r3

adcx.s-al r10, r14, #9

adcx.s-al r1, r2, r3, lsl r4

adcx.s-al r1, r2, r3, lsl #4

adcx.s-al r1, r5, #452



sbcx-al r1, r2, r3

sbcx-al r10, r14, #9

sbcx-al r1, r2, r3, lsl r4

sbcx-al r1, r2, r3, lsl #4

sbcx-al r1, r5, #452



sbcx.s-al r1, r2, r3

sbcx.s-al r10, r14, #9

sbcx.s-al r1, r2, r3, lsl r4

sbcx.s-al r1, r2, r3, lsl #4

sbcx.s-al r1, r5, #452



mulx-eq r1, r2, r3

divx-eq r1, r2, r3


absx-al r9, r11

cmpx-al r12, r9 

cmpx-al r12, #99



notx-eq r2, r1

andx-al r3, r1, r2

andx-al r2, r1, #0x00FF

orrx-al r3, r1, r2

orrx-al r2, r1, #0x1100

xorx-al r3, r1, r2

xorx-al r2, r1, #0x0FF0





regd:

ldw-al r2, [r1, #2]

ldw-al r2, [r1, #-2]

ldw-al r2, [r1, r3]

ldb2l-al r2, [r1, #0]

stw-al r2, [r1, #2]

stw-al r2, [r1, #-2]

stw-al r2, [r1, r3]

stb2l-al r2, [r1, #0]

regb:

bx-al lr

b-al regd

subx.s-al r0, r1, r2

b-eq regb

bl-al regx