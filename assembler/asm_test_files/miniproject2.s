dot_product: 
    addx-al r1, r0, r0
    addx-al r3, r0, #0
    addx-al r5, r0, #9
    addx-al r7, r0, #9

loop:
    cmpx-al r7, r0
    b-eq done
    ldb2l-al r2, [r3, #0]
    ldb2l-al r4, [r5, #0]
    mulx-al r2, r2, r4 
    addx-al r1, r1, r2 
    addx-al r3, r3, #1
    addx-al r5, r5, #1
    subx-al r7, r7, #1
    b-al loop
done: 
    bx-al lr