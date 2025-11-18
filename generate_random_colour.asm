generate_random_colour:
li $v0, 42
li $a0, 0
li $a1, 5
syscall
move $v0, $a0

jr $ra

generate_random_column_colours:
addi $sp, $sp, -4
sw   $ra, 0($sp)

la   $t8, colorsArray    # base of colour array

# top colour
jal  generate_random_colour
sll  $t1, $v0, 2         # index * 4
add  $t1, $t8, $t1
lw   $t5, 0($t1)

# middle colour
jal  generate_random_colour
sll  $t1, $v0, 2
add  $t1, $t8, $t1
lw   $t6, 0($t1)

# bottom colour
jal  generate_random_colour
sll  $t1, $v0, 2
add  $t1, $t8, $t1
lw   $t7, 0($t1)

lw   $ra, 0($sp)
addi $sp, $sp, 4
jr   $ra
