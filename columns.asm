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

# Registers:
  # $t0 = display address
  # $t1 = keyboard address
  # $t2 = col_x
  # $t3 = col_y
  # $t8 = keyboard key

# Commands: 
# a moves the column left
# s moves the column down
# w rotates the column
# d moves the column to the right
# q exits the program


# Ascii characters for a, w, s, and d respectively: 0x61, 0x77, 0x73, 0x64 (from Google).

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
colorsArray: .word 0xff0000, 0x00ff00, 0x0000ff, 0xFFFF00, 0xFFA500, 0x800080 #Colors contains red, blue, green, yellow, orange, purple.
order: .word 0, 1, 2 # Colors: upper pixel, middle pixel, lower pixel
col_x: .word 16 # starting value of column x coordinate
col_y: .word 0 # y coordinate of the upper pixel



##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
    .text
    .globl main

main:
    lw $t0, ADDR_DSPL
    lw $t1, ADDR_KBRD
    lw $t2, col_x
    lw $t3, col_y

game_loop:
    # 1a. Check if key has been pressed
    lw $t8, 0($t1)
    beq $t8, $zero, no_input
    lw $t8, 4($t1)  
    move $s0, $t8   

    # 1b. Check which key has been pressed
    beq $t8, 0x61, respond_to_a    # 'a'
    beq $t8, 0x77, respond_to_w    # 'w'  
    beq $t8, 0x73, respond_to_s    # 's'
    beq $t8, 0x64, respond_to_d    # 'd'

    # 2a. Check for collisions.

    # 2b. Update locations

    # 3. Draw the screen

    # 4. Sleep

    # 5. Go back to step 1
no_input:
    addi $t3, $t3, 1 # configure so column is falling
    jal clear_screen
    jal draw_column
    
    li $v0, 32
    li $a0, 500
    syscall
    
    j game_loop

# When a pushed, move column to the left (col_x - 1, col_y)
respond_to_a:
    addi $t2, $t2, -1
    j game_loop

# when d pushed, move column right (col_x + 1, col_y)
respond_to_d:
    addi $t2, $t2, 1
    j game_loop

# When s pushed, shift column down (col_x, col_y + 1)
respond_to_s:
    addi $t3, $t3, 1
    j game_loop

# please daniel be my saviour
respond_to_w: 


j game_loop # jump to game loop
# When pushed, move column to the right.

draw_column:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Draw all three pixels at current column position
    move $s1, $t3   # Save base y position
    
    # Draw top pixel (original y)
    li $t4, 0xff0000
    jal draw_pixel
    
    # Draw middle pixel (y + 1)
    addi $t3, $s1, 1
    li $t4, 0x00ff00
    jal draw_pixel
    
    # Draw bottom pixel (y + 2)  
    addi $t3, $s1, 2
    li $t4, 0x0000ff
    jal draw_pixel
    
    # Restore original y position
    move $t3, $s1
    
    # Restore and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra

draw_pixel:
    # Calculate address: (y * 256 + x) * 4 + base_address
    li $t6, 32
    mult $t3, $t6
    mflo $t7
    add $t7, $t7, $t2  # y * 256
    sll $t7, $t7, 2    # Multiply by 4
    add $t7, $t7, $t0  # Add base address
    
    sw $t4, 0($t7)     # Draw the pixel
    jr $ra

clear_screen:
    # Clear entire screen to black
    li $t5, 0x000000   # Black color
    li $t6, 16384      # 64x256 = 16384 pixels (assuming 256x256 display)
    move $t7, $t0      # Start at display address
    
clear_loop:
    sw $t5, 0($t7)     # Write black pixel for clearing
    addi $t7, $t7, 4 
    addi $t6, $t6, -1  # decrement
    bnez $t6, clear_loop
    
    jr $ra
    

