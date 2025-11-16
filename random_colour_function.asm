
.data
displayaddress:     .word       0x10008000 # Initializes the bitmap address, send everything TO bitmap.
ADDR_KBRD: .word 0xffff0000 # Initialize keyboard address
col_x: .word 16 # starting x coordinate
col_y: .word 0 # y coordinate of the upper pixel
order: .word 1, 2, 3 # Colors: upper pixel, middle pixel, lower pixel
colorsArray: .word 0xff0000, 0x00ff00, 0x0000ff, 0xFFFF00, 0xFFA500, 0x800080 #Colors contains red, blue, green, yellow, orange, purple.
#in-class demo following along

# thinking of how to keep track of columns and pixels within columns.

.text
lw $t0, displayaddress # $t0 = base address for display

li $t1, 0xff0000 # $t1 = red
li $t2, 0x00ff00 # $t2 = green
li $t3, 0x0000ff # $t3 = blue

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

move $t1, $t5
move $t2, $t6
move $t3, $t7

lw $t9, ADDR_KBRD # $t9 = base address for keyboard
li $v0, 32 # Set return value 32
li $a0, 1 
syscall
lw $t4, col_x
lw $t5, col_y

# Draws a column.
draw_column:
  
jal draw_pixel # Draw upper pixel
sw $t1, 0($t8) # Set upper pixel color
addi $t5, $t5, 1 # middle pixel at (col_x, col_y + 1)
jal draw_pixel # Draw middle pixel
sw $t2, 0($t8) # Set middle pixel color
addi $t5, $t5, 1 # set lower pixel at (col_x, col_y + 2)
jal draw_pixel # Draw lower pixel
sw $t3, 0($t8) # Set lower_pixel color

li $v0, 10 # Load 10 into register $v0.
syscall # Syscall.

# Draws a pixel.
draw_pixel:
  
li $t6, 32 # load 256 into $t6.
mult $t5, $t6 # Multiply col_y and 256
mflo $t7
add $t7, $t4, $t7 # Add $t7: (col_y * 256) + col_x
sll $t7, $t7, 2 # Multiply by 4
add $t8, $t7, $t0 # Add the above offset to the displayAddress to determine where to write the pixel on the bitmap.
#sw $t1, 0($t8)
jr $ra # Return draw_pixel



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
