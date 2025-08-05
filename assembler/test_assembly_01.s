regx: 

addx-al r1, r2, r3

addx-al r1, #9

addx-al r1, r2, r3, lsl #2

addx-al r1, #9, lsl #2

subx-al r1, r2, r3

subx-al r1, #9

subx-al r1, r2, r3, lsl #2

subx-al r1, #9, lsl #2

addx.s-al r1, r2, r3

addx.s-al r1, #9

subx.s-al r1, r2, r3

subx.s-al r1, #9

mulx-eq r1, r2, r3

mulx-eq r1, r2, #9

divx-eq r1, r2, r3

divx-eq r1, r2, #9

notx-eq r2, r1

andx-al r3, r1, r2

andx-al r2, r1, #9

orrx-al r3, r1, r2

orrx-al r2, r1, #9

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

b-al label

subx.s-al r0, r1, r2

b-eq label

bl-al label