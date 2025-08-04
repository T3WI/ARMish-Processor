regx: 

add.x-al r1, r2, r3

add.x-al r1, #9

add.x-al r1, r2, r3, lsl #2

add.x-al r1, #9, lsl #2

sub.x-al r1, r2, r3

sub.x-al r1, #9

sub.x-al r1, r2, r3, lsl #2

sub.x-al r1, #9, lsl #2

adds.x-al r1, r2, r3

adds.x-al r1, #9

subs.x-al r1, r2, r3

subs.x-al r1, #9

mul.x-eq r1, r2, r3

mul.x-eq r1, r2, #9

div.x-eq r1, r2, r3

div.x-eq r1, r2, #9

mac.x-eq r1, r2, r3

sqrt.x-eq r1, r2

convf.x-eq r1, r2

cmp.x-eq r1, r2

regf:

add.f-al r1, r2, r3, #0

sub.f-al r1, r2, r3, #0

mul.f-eq r1, r2, r3, #0

div.f-eq r1, r2, r3, #0

mac.f-eq r1, r2, r3, #0

sqrt.f-eq r1, r2, #0

convx.f-eq r1, r2, #0

cmp.f-eq r1, r2

regd:

ldr r1, [r2, #8]

str r1, [r2, #8]

ldr r1, [r2, #-8]

str r1, [r2, #-8]

ldr r1, [r2, r3]

str r1, [r2, r3]

ldrb r1, [r2, #8]

strb r1, [r2, #8]

regb:

bx r1 

b regd

bl regf
