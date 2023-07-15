# Arm_Assembly_calculator

## Let us define our customized floating point number system (called as NFP => New Floating-Point
number) in 32 bits as follows:
Sign bit: most significant bit (0 => the number is positive, 1=> the number is negative)
2’compliment exponent: next 12 bits
Mantissa: rest 19 bits
All these floating-point numbers are in normalized format.

Write Assembly Language program to Add and Multiply two NFP numbers. Also write additional code
/ data to test these functions.
Note:
a) Implementation must be modular.
b) You need to write nfpAdd and nfpMultiply as two functions.
c) Data must be taken from memory. And After computation the result has to be put into
memory.
