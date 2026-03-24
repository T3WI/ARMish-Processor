dot_product: 
    addx-al r1, r0, r0

loop:
    cmpx-al r7, r0
    b-eq done
    ldw-al r2, [r3, #0]
    ldw-al r4, [r5, #0]
    mulx-al r2, r2, r4 
    addx-al r1, r1, r2 
    addx-al r3, r3, #4
    addx-al r5, r5, #4
    subx-al r7, r7, #1
    b-al loop
done: 
    bx-al lr