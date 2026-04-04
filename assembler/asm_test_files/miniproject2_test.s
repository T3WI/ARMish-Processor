addx-al r1, r0, r0

addx-al r2, r0, #8

addx-al r3, r0, #24

addx-al r7, r0, #0

loop:

addx-al r4, r2, #40

addx-al r5, r3, #100

addx-al r2, r2, #16

addx-al r3, r3, #20

ldb2l-al r6, [r7, #0]

addx-al r7, r7, #1

b-al loop