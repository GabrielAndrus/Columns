.data
displayaddress:     .word       0x10008000 #Initializes the bitmap address, send everything TO bitmap.
colorsArray: .word 0xff0000, 0x00ff00, 0x0000ff, 0xFFFF00, 0xFFA500, 0x800080 #Colors contains red, blue, green, yellow, orange, purple.
#in-class demo following along

.text
lw $t0, displayaddress # $t0 = base address for display

# $t1 contains the first random number, $t3 contains the second random number, $t6 contains third random number.
# $t5, $t6, $t7 contain random colors.
# $v0, $a0, $a1 configured for random number generation as per the handout.

# Generate first random number between 0 and 5.
jal generate_random_colour


# first random color
la $t4, colorsArray
#li $t1, $a0 # Random index 0-5 in the array
sll $t2, $t1, 2 # Multiply index by 4 (bc word is size 4)
add $t2, $t4, $t2 # address of colorsArray[$ao]
lw $t5, 0($t2)

jal generate_random_colour


#li $t1, $a0 # Random index 0-5 in the array
sll $t2, $t1, 2 # Multiply index by 4 (bc word is size 4)
add $t2, $t4, $t2 # address of colorsArray[$ao]
lw $t6, 0($t2)

jal generate_random_colour


#li $t1, $a0 # Random index 0-5 in the array
sll $t2, $t1, 2 # Multiply index by 4 (bc word is size 4)
add $t2, $t4, $t2 # address of colorsArray[$ao]
lw $t7, 0($t2)


sw $t5, 0($t0) # Draw randomly colored (from colors) 
sw $t6, 4($t0) # Draw randomly colored (from colors) 
sw $t7, 8($t0) # Draw randomly colored (from colors)

li $v0, 10
syscall


##  The generate_random_colour function
##  - Draws a rectangle at a given X and Y coordinate 
#
# $t4 = array of colours
# $v0, $a0, $a1 configured for random number generation as per the handout.
generate_random_colour:
li $v0, 42
li $a0, 0
li $a1, 5
syscall
move $t1, $a0

jr $ra
