################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Columns.
#
# Student 1: Gabriel Andrus, 1010898762
# Student 2: Daniel Hong, 1011662504
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       TODO
# - Unit height in pixels:      TODO
# - Display width in pixels:    TODO
# - Display height in pixels:   TODO
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################
.macro push(%reg)
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw %reg, 0($sp)
.end_macro
.macro pop(%reg)
    lw %reg, 0($sp)
    addi $sp, $sp, 4
.end_macro
.macro loadcolour(%reg)
bgtz %reg, gray
lw %reg, empty_color
j colour_end_mac

gray:
lw %reg, gray

colour_end_mac:
.end_macro
.macro colour_checker(%reg, %erase)
push(%reg)
push($ra)
jal get_display_pixel
move $t9, $v0
addi $t5, $zero, 0
addi $t6, $zero, 0
jal check_positive
pop($ra)
lw %reg, 0($sp)
push($ra)
jal check_negative

j grand_return

check_positive:
push($ra)
check_positive_loop:
lw $ra, 0($sp)
addi %reg, %reg, 1
jal check_block
addi $t5, $t5, 1
bgtz %erase, positive_erase
j check_positive_loop
positive_erase:
jal erase
addi $t5, $t5, -2

j check_positive_loop



grand_return:
pop($ra)
pop(%reg)
jr $ra


return:
pop($ra)
jr $ra

check_negative:
push($ra)
check_negative_loop:
lw $ra, 0($sp)
addi %reg, %reg, -1
jal check_block
addi $t6, $t6, 1
bgtz %erase, negative_erase
j check_negative_loop
negative_erase:
jal erase
addi $t6, $t6, -2

j check_negative_loop

check_block:
push($ra)
jal get_display_pixel
pop($ra)
bne $v0, $t9, return
jr $ra


erase:
push($ra)
push($t4)
lw $t4, empty_color
jal draw_pixel
pop($t4)
j return

.end_macro
.macro rdiag_colour_checker(%erase)
push($t2)
push($t3)
push($ra)
jal get_display_pixel
move $t9, $v0
addi $t5, $zero, 0
addi $t6, $zero, 0
jal rdcheck_positive
pop($ra)
pop($t3)
pop($t2)
push($t2)
push($t3)
push($ra)
jal rdcheck_negative

j rdgrand_return

rdcheck_positive:
push($ra)
rdcheck_positive_loop:
lw $ra, 0($sp)
addi $t2, $t2, 1
addi $t3, $t3, 1
jal rdcheck_block
addi $t5, $t5, 1
bgtz %erase, rdpositive_erase
j rdcheck_positive_loop
rdpositive_erase:
jal rderase
addi $t5, $t5, -2

j rdcheck_positive_loop



rdgrand_return:
pop($ra)
pop($t3)
pop($t2)
jr $ra


rdreturn:
pop($ra)
jr $ra

rdcheck_negative:
push($ra)
rdcheck_negative_loop:
lw $ra, 0($sp)
addi $t2, $t2, -1
addi $t3, $t3, -1
jal rdcheck_block
addi $t6, $t6, 1
bgtz %erase, rdnegative_erase
j rdcheck_negative_loop
rdnegative_erase:
jal rderase
addi $t6, $t6, -2

j rdcheck_negative_loop

rdcheck_block:
push($ra)
jal get_display_pixel
pop($ra)
bne $v0, $t9, rdreturn
jr $ra


rderase:
push($ra)
push($t4)
lw $t4, empty_color
jal draw_pixel
pop($t4)
j rdreturn

.end_macro
.macro ldiag_colour_checker(%erase)
push($t2)
push($t3)
push($ra)
jal get_display_pixel
move $t9, $v0
addi $t5, $zero, 0
addi $t6, $zero, 0
jal ldcheck_positive
pop($ra)
pop($t3)
pop($t2)
push($t2)
push($t3)
push($ra)
jal ldcheck_negative

j ldgrand_return

ldcheck_positive:
push($ra)
ldcheck_positive_loop:
lw $ra, 0($sp)
addi $t2, $t2, 1
addi $t3, $t3, -1
jal ldcheck_block
addi $t5, $t5, 1
bgtz %erase, ldpositive_erase
j ldcheck_positive_loop
ldpositive_erase:
jal lderase
addi $t5, $t5, -2

j ldcheck_positive_loop



ldgrand_return:
pop($ra)
pop($t3)
pop($t2)
jr $ra


ldreturn:
pop($ra)
jr $ra

ldcheck_negative:
push($ra)
ldcheck_negative_loop:
lw $ra, 0($sp)
addi $t2, $t2, -1
addi $t3, $t3, 1
jal ldcheck_block
addi $t6, $t6, 1
bgtz %erase, ldnegative_erase
j ldcheck_negative_loop
ldnegative_erase:
jal lderase
addi $t6, $t6, -2

j ldcheck_negative_loop

ldcheck_block:
push($ra)
jal get_display_pixel
pop($ra)
bne $v0, $t9, ldreturn
jr $ra


lderase:
push($ra)
push($t4)
lw $t4, empty_color
jal draw_pixel
pop($t4)
j ldreturn

.end_macro
    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
order: .word 1, 2, 3 # Colors: upper pixel, middle pixel, lower pixel
colorsArray: .word 0xff0000, 0x00ff00, 0x0000ff, 0xFFFF00, 0xFFA500, 0x800080 #Colors contains red, blue, green, yellow, orange, purple.
grid_x: .word 3
grid_y: .word 3
grid_width: .word 20
grid_height: .word 20
empty_color: .word 0x000000
gray: .word 0x777777
##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    # Initialize the game
    li $t1, 0xff0000 # $t1 = red
    li $t2, 0x00ff00 # $t2 = green
    li $t3, 0x0000ff # $t3 = blue
    li $t4, 0x777777 # $t3 = gray
    lw $t0, ADDR_DSPL # $t0 = base address for display
    sw $t1, 0( $t0 ) # paint the first unit (i.e., top−left) red
    sw $t2, 4( $t0 ) # paint the second unit on the first row green
    sw $t3, 128( $t0 ) # paint the first unit on the second row blue
    
    lw $a0, grid_x     # set X coordinate to 19
    lw $a1, grid_y     # set Y coordinate to 16
    lw $a2, grid_width      # set rectangle width to 4
    lw $a3, grid_height     # set rectangle height to 12
    add $t5, $zero, $t4
    jal draw_grid           # call the rectangle drawing code.
    
create_new_column:
    
    la $t0, colorsArray
    
    jal generate_random_colour
    sll  $t1, $v0, 2         # index * 4
    add  $t1, $t0, $t1
    lw   $a3, 0($t1)
    
    jal generate_random_colour
    sll  $t1, $v0, 2         # index * 4
    add  $t1, $t0, $t1
    lw   $t7, 0($t1)
    
    jal generate_random_colour
    sll  $t1, $v0, 2         # index * 4
    add  $t1, $t0, $t1
    lw   $t9, 0($t1)
    
    jal side_draw
    
    lw $t0, ADDR_DSPL
    lw $t1, ADDR_KBRD
    lw $t2, grid_width  # $t2 stores the x-coord
    lw $t3, grid_x 
    srl $t2, $t2, 1
    add $t2, $t2, $t3
    lw $t3, grid_y  # $t3 stores the y-coord
    addi $t3, $t3, 1

game_loop:
    # 1a. Check if key has been pressed
    lw $t8, 0($t1)
    jal remove_column
    beq $t8, $zero, no_input
    lw $t8, 4($t1)  
    move $s0, $t8   

    # 1b. Check which key has been pressed
    beq $t8, 0x61, respond_to_a    # 'a'
    beq $t8, 0x77, respond_to_w    # 'w'  
    beq $t8, 0x73, respond_to_s    # 's'
    beq $t8, 0x64, respond_to_d    # 'd'
    beq $t8, 0x71, respond_to_q     # 'q'
    
    
    

    # 2a. Check for collisions.
    
side_draw:
    push($ra)
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw $t0, 0($sp)
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw $t1, 0($sp)
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw $t2, 0($sp)
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw $t3, 0($sp)
    
    
    lw $t0, ADDR_DSPL
    lw $t2, grid_width
    lw $t3, grid_x
    add $t2, $t2, $t3
    addi $t2, $t2, 3
    lw $t3, grid_y
    lw $t1, grid_height
    srl $t1, $t1, 1
    add $t3, $t3, $t1
    
    jal draw_column
    
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
jr $ra
    

    # 2b. Update locations

    # 3. Draw the screen

    # 4. Sleep

    # 5. Go back to step 1
    
collision:  # When collision happens, draws the column where it was
    jal draw_column 
    
    li $v0, 32
    li $a0, 100
    syscall

    

    j game_loop


# $t2: x-coord of the collided column
# $t3: y-coord of the collided column
# $t8: switch for loadcolour and horizontal_return
check_column_colours:
    push($s1)
    push($ra)
    push($t3)
    addi $t3, $t3, 2
    
check_start:
    addi $a3, $zero, 0
    addi $s1, $zero, 0
    push($t5)
    push($t6)
    
    jal get_display_pixel
    addi $t8, $zero, 1
    loadcolour($t8)
    beq $v0, $t8, check_end
    jal get_display_pixel
    addi $t8, $zero, 0
    loadcolour($t8)
    beq $v0, $t8, check_end
    
    j next
    this:
    colour_checker($t2, $a3) # check horizontal colour
    next:
    jal this
    
    add $t6, $t6, $t5
    addi $a3, $zero, 3
    addi $t6, $t6, 1
    
    bge $t6, $a3, erase_horizontal_colour
    
    back: 
    pop($t6)
    pop($t5)
    
    addi $a3, $zero, 0
    push($t5)
    push($t6)
    
    
    
    
    j vertical_next
    vertical_this:
    colour_checker($t3, $a3) # check horizontal colour
    vertical_next:
    jal vertical_this
    
    add $t6, $t6, $t5
    addi $a3, $zero, 3
    addi $t6, $t6, 1
    
    bge $t6, $a3, erase_vertical_colour
    
    vertical_back:
    pop($t6)
    pop($t5)
    push($t5)
    push($t6)
    addi $a3, $zero, 0
    
    j rdiag_next
    rdiag_this:
    rdiag_colour_checker($a3) # check horizontal colour
    rdiag_next:
    jal rdiag_this
    
    add $t6, $t6, $t5
    addi $a3, $zero, 3
    addi $t6, $t6, 1
    
    bge $t6, $a3, erase_rdiag_colour
    
    rdiag_back:
    pop($t6)
    pop($t5)
    push($t5)
    push($t6)
    addi $a3, $zero, 0
    
    j ldiag_next
    ldiag_this:
    ldiag_colour_checker($a3) # check horizontal colour
    ldiag_next:
    jal ldiag_this
    
    add $t6, $t6, $t5
    addi $a3, $zero, 3
    addi $t6, $t6, 1
    
    bge $t6, $a3, erase_rdiag_colour
    
    ldiag_back:
    pop($t6)
    pop($t5)
    
    bgtz $s1, ethis
    j enext
    ethis:
    jal erase_this_block
    enext:
    
    
    
    
    addi $t3, $t3, -1
    
    j check_start
    
    check_end:
    pop($t6)
    pop($t5)
    pop($t3)
    pop($ra)
    pop($s1)
    jr $ra

erase_horizontal_colour:
    lw $t5, 0($sp)
    addi $a3, $zero, 1
    j erase_next
    erase_this:
    addi $s1, $zero, 1
    colour_checker($t2, $a3)
    erase_next:
    jal erase_this
    j back
    
erase_vertical_colour:
    lw $t5, 0($sp)
    addi $a3, $zero, 1
    j erase_vertical_next
    erase_vertical_this:
    addi $s1, $zero, 1
    colour_checker($t3, $a3)
    erase_vertical_next:
    jal erase_vertical_this
    
    j vertical_back

erase_rdiag_colour:
    lw $t5, 0($sp)
    addi $a3, $zero, 1
    j rdiag_erase_next
    rdiag_erase_this:
    addi $s1, $zero, 1
    rdiag_colour_checker($a3)
    rdiag_erase_next:
    jal rdiag_erase_this
    j rdiag_back

erase_ldiag_colour:
    lw $t5, 0($sp)
    addi $a3, $zero, 1
    j ldiag_erase_next
    ldiag_erase_this:
    addi $s1, $zero, 1
    rdiag_colour_checker($a3)
    ldiag_erase_next:
    jal ldiag_erase_this
    j ldiag_back
    
erase_this_block:
    push($ra)
    push($t4)
    lw $t4, empty_color
    jal draw_pixel
    pop($t4)
    pop($ra)
    jr $ra

no_input:   
    lw $t8, empty_color
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw $t3, 0($sp)
    addi $t3, $t3, 3
    jal get_display_pixel
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    
    bne $v0, $t8, draw_column_and_create
    
    addi $t3, $t3, 1 # configure so column is falling
    
    jal draw_column
    
    li $v0, 32
    li $a0, 500
    syscall
    
    j game_loop


respond_to_q:
li $v0, 10
syscall

draw_column_and_create:
addi $s1, $zero, 0
jal draw_column
jal check_column_colours
j create_new_column

##  The draw_line function
##  - Draws a horizontal line from a given X and Y coordinate 
#
# $a0 = the x coordinate of the line
# $a1 = the y coordinate of the line
# $a2 = the length of the line
# $t5 = the colour for this line 
# $t0 = the top left corner of the bitmap display
# $t2 = the starting location for the line.
# $t3 = location for line drawing to stop.

# When a pushed, move column to the left (col_x - 1, col_y)
respond_to_a:
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw $t2, 0($sp)
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw $t3, 0($sp)
    addi $t3, $t3, 2
    addi $t2, $t2, -1
    jal get_display_pixel
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    
    lw $t8, empty_color
    bne $v0, $t8, collision
    
    addi $t2, $t2, -1
    j game_loop

# when d pushed, move column right (col_x + 1, col_y)
respond_to_d:
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw $t2, 0($sp)
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw $t3, 0($sp)
    addi $t3, $t3, 2
    addi $t2, $t2, 1
    jal get_display_pixel
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t8, empty_color
    bne $v0, $t8, collision
    
    addi $t2, $t2, 1
    j game_loop

# When s pushed, shift column down (col_x, col_y + 1)
respond_to_s:
    lw $t8, empty_color
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw $t3, 0($sp)
    addi $t3, $t3, 3
    jal get_display_pixel
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    
    bne $v0, $t8, draw_column_and_create
    
    addi $t3, $t3, 1 # configure so column is falling
    
    jal draw_column
    
    j game_loop

# please daniel be my saviour
respond_to_w: 
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw $a0, 0($sp)
    move $a0, $a3   # store random colour in $a3 to a temporary variable $a0
    move $a3, $t7   # store colour $t7 to $a3
    move $t7, $t9   # store colour $t9 to $t7
    move $t9, $a0   # store colour $a0($a3) to $t9
    lw $a0, 0($sp)
    addi $sp, $sp, 4
    j game_loop

j game_loop # jump to game loop
# When pushed, move column to the right.

get_display_pixel:
    lw  $t0,ADDR_DSPL
    
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw $t2, 0($sp)
    addi $sp, $sp, -4   #save variable that is temporarily used
    sw $t3, 0($sp)
    
    sll $t2,$t2,2          
    add $t2,$t0,$t2

    sll $t3,$t3,7     
    add $t2,$t2,$t3

    lw  $v0,0($t2)
    
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    jr  $ra

draw_column:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    push($s1)
    # Draw all three pixels at current column position
    move $s1, $t3   # Save base y position
    
    # Draw top pixel (original y)
    move $t4, $a3
    jal draw_pixel
    
    # Draw middle pixel (y + 1)
    addi $t3, $s1, 1
    move $t4, $t7
    jal draw_pixel
    
    # Draw bottom pixel (y + 2)  
    addi $t3, $s1, 2
    move $t4, $t9
    jal draw_pixel
    
    # Restore original y position
    move $t3, $s1
    pop($s1)
    # Restore and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra

draw_pixel:
    # Calculate address: (y * 256 + x) * 4 + base_address
    li $t6, 32
    mult $t3, $t6
    
    addi $sp, $sp, -4   #Storing t7 since we want to use more variables
    sw $t7, 0($sp)
    
    mflo $t7
    add $t7, $t7, $t2  # y * 256
    sll $t7, $t7, 2    # Multiply by 4
    add $t7, $t7, $t0  # Add base address
    
    sw $t4, 0($t7)     # Draw the pixel
    
    lw $t7, 0($sp)  #getting back $t7 a random colour
    addi $sp, $sp, 4
    jr $ra

remove_column:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Draw all three pixels at current column position
    move $s1, $t3   # Save base y position
    
    # Draw top pixel (original y)
    li $t4, 0x000000
    jal draw_pixel
    
    # Draw middle pixel (y + 1)
    addi $t3, $s1, 1
    jal draw_pixel
    
    # Draw bottom pixel (y + 2)  
    addi $t3, $s1, 2
    jal draw_pixel
    
    # Restore original y position
    move $t3, $s1
    
    # Restore and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra

    
clear_loop:
    sw $t5, 0($t7)     # Write black pixel for clearing
    addi $t7, $t7, 4 
    addi $t6, $t6, -1  # decrement
    bnez $t6, clear_loop
    
    jr $ra# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (capsules)
	# 3. Draw the screen
	# 4. Sleep

    # 5. Go back to Step 1
    j game_loop


draw_line:
sll $a0, $a0, 2         # multiply the X coordinate by 4 to get the horizontal offset
add $t2, $t0, $a0       # add this horizontal offset to $t0, store the result in $t2
sll $a1, $a1, 7         # multiply the Y coordinate by 128 to get the vertical offset
add $t2, $t2, $a1       # add this vertical offset to $t2

# Make a loop to draw a line.
sll $a2, $a2, 2         # calculate the difference between the starting value for $t2 and the end value.
add $t3, $t2, $a2       # set stopping location for $t2
line_loop_start:
beq $t2, $t3, line_loop_end  # check if $t2 has reached the final location of the line
sw $t5, 0( $t2 )        # paint the current pixel
addi $t2, $t2, 4        # move $t0 to the next pixel in the row.
j line_loop_start            # jump to the start of the loop
line_loop_end:
jr $ra      

##  The draw_rect function
##  - Draws a rectangle at a given X and Y coordinate 
#
# $a0 = the x coordinate of the line
# $a1 = the y coordinate of the line
# $a2 = the width of the rectangle
# $a3 = the height of the rectangle
draw_rect:
# no registers to initialize (use $a3 as the loop variable)
rect_loop_start:
beq $a3, $zero, rect_loop_end   # test if the stopping condition has been satisfied
addi $sp, $sp, -4               # move the stack pointer to an empty location
sw $ra, 0($sp)                  # push $ra onto the stack
addi $sp, $sp, -4               # move the stack pointer to an empty location
sw $a0, 0($sp)                  # push $a0 onto the stack
addi $sp, $sp, -4               # move the stack pointer to an empty location
sw $a1, 0($sp)                  # push $a1 onto the stack
addi $sp, $sp, -4               # move the stack pointer to an empty location
sw $a2, 0($sp)                  # push $a2 onto the stack

jal draw_line                   # call the draw_line function.

lw $a2, 0($sp)                  # pop $a2 from the stack
addi $sp, $sp, 4                # move the stack pointer to the top stack element
lw $a1, 0($sp)                  # pop $a1 from the stack
addi $sp, $sp, 4                # move the stack pointer to the top stack element
lw $a0, 0($sp)                  # pop $a0 from the stack
addi $sp, $sp, 4                # move the stack pointer to the top stack element
lw $ra, 0($sp)                  # pop $ra from the stack
addi $sp, $sp, 4                # move the stack pointer to the top stack element
addi $a1, $a1, 1                # move the Y coordinate down one row in the bitmap
addi $a3, $a3, -1               # decrement loop variable $a3 by 1
j rect_loop_start               # jump to the top of the loop.
rect_loop_end:
jr $ra                          # return to the calling program.


##  The draw_grid function
##  - Draws a grid at a given X and Y coordinate 
#
# $a0 = the x coordinate of the line
# $a1 = the y coordinate of the line
# $a2 = the width of the grid
# $a3 = the height of the grid
draw_grid:

addi $sp, $sp, -4               # move the stack pointer to an empty location
sw $ra, 0($sp)                  # push $ra onto the stack

addi $sp, $sp, -4               # move the stack pointer to an empty location
sw $a0, 0($sp)                  # push $a0 onto the stack
addi $sp, $sp, -4               # move the stack pointer to an empty location
sw $a1, 0($sp)                  # push $a1 onto the stack
addi $sp, $sp, -4               # move the stack pointer to an empty location
sw $a2, 0($sp)                  # push $a2 onto the stack
addi $sp, $sp, -4               # move the stack pointer to an empty location
sw $a3, 0($sp)                  # push $a3 onto the stack

jal draw_line
sub $a0, $t3, $t0
sub $a0, $a0, $a1
srl $a0, $a0, 2
srl $a1, $a1, 7
addi $a2, $zero, 1

jal draw_rect

lw $a3, 0($sp)                  # pop $a3 from the stack
addi $sp, $sp, 4                # move sp to the topp stack element
lw $a2, 0($sp)                  # pop $a2 from the stack
addi $sp, $sp, 4                # move the stack pointer to the top stack element
lw $a1, 0($sp)                  # pop $a1 from the stack
addi $sp, $sp, 4                # move the stack pointer to the top stack element
lw $a0, 0($sp)                  # pop $a0 from the stack
addi $sp, $sp, 4                # move the stack pointer to the top stack element

addi $sp, $sp, -4               # move the stack pointer to an empty location
sw $a2, 0($sp)                  # push $a2 onto the stack

addi $a2, $zero, 1

jal draw_rect
lw $a2, 0($sp)                  # pop $a2 from the stack
addi $sp, $sp, 4                # move the stack pointer to the top stack element
addi $a1, $a1, -1
jal draw_line

lw $ra, 0($sp)                  # pop $a0 from the stack
addi $sp, $sp, 4                # move the stack pointer to the top stack element

jr $ra

##  The generate_random_colour function
##  - Draws a rectangle at a given X and Y coordinate 
#
# $t4 = array of colours
# $v0, $a0, $a1 configured for random number generation as per the handout.
generate_random_colour:
addi $sp, $sp, -4
sw   $a0, 0($sp)
addi $sp, $sp, -4
sw   $a1, 0($sp)


li $v0, 42
li $a0, 0
li $a1, 5
syscall
move $v0, $a0

addi $sp, $sp, 4
lw   $a1, 0($sp)
addi $sp, $sp, 4
lw   $a0, 0($sp)

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
