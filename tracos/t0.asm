
.text
.globl main

main:
    addi $t0, $zero, 5
    addi $t1, $zero, 10
    addi $t2, $zero, 3
    addi $t3, $zero, 7

    add  $s0, $zero, $zero
    sub  $s1, $zero, $zero
    and  $s2, $zero, $zero
    or   $s3, $zero, $zero
    slt  $s4, $zero, $zero

    sw   $zero, 0($zero)
    lw   $s5, 0($zero)

    addi $t4, $zero, 2
    addi $t5, $zero, 4
    addi $t6, $zero, 6
    addi $t7, $zero, 8

    add  $s6, $zero, $zero
    sub  $s7, $zero, $zero
    and  $t8, $zero, $zero
    or   $t9, $zero, $zero
    slt  $k0, $zero, $zero

    addi $v0, $zero, 1
    addi $v1, $zero, 2
    addi $a0, $zero, 3
    addi $a1, $zero, 4
    addi $a2, $zero, 5
    addi $a3, $zero, 6

    add  $a1, $zero, $zero
    sub  $a2, $zero, $zero

    beq  $t0, $t1, 1

    addi $t0, $zero, 9
    addi $t1, $zero, 11

    break
