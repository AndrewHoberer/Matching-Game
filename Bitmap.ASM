.include "SysCalls.asm"
.data
	.kdata 0x10000000
	frameBuffer:	.space 8192
	numberofCards:	.word 0x00006f6e
	matchingCards:	.word 0xa7d3ec
	flippedCard: .word 0xfff7d9
	timer: .word 0x404894
.text
.globl flippingCard bitMain drawZero drawOne drawTwo drawThree drawFour drawFive drawSix drawSeven score reFlip
.globl drawF drawColon drawX drawEight drawNine drawA drawB drawC drawD drawE unmatchedCardLoop1 timerJ drawVictory
bitMain:
	la $a0, frameBuffer # initialize bitmap
	li $a1, 512
	li $a2, 256

	la $t0, frameBuffer #loop to fill bitmap in with white background
	li $t1, 2048 # loop 2048 times
	li $t2, 0xffffff # load color white into $t2
	l1:
		sw $t2, 0($t0) # store color white into $t0
		addi $t0, $t0, 4 # $t0 += 4
		addi $t1, $t1, -1 # t1 -= 1
		bnez, $t1, l1 # loop until $t1 = 0
	li $t0, 64    # $t0 = 64  
	
    	li $t4, 5 # $t4 = 5
    	la $t0, frameBuffer # $t0 = frameBuffer address
	li $t1, 64 # $t1 = 64
    	lw $t5, matchingCards # $t5 = matchingCards color
    	addi $t0, $t0, 2052 # $t0 += 2052 (address of start of first card)
    	
    	li $t7, 4 # $t7 = 4
draw_row:
        li $t6, 4  # t6 = 4
	move $s0, $t3 # $s0 = $t3
draw_col:
	addi $s0, $s0, 4 # $s0 += 4
	sw $t5, 4($t0) # Store blue color (matchingCards) into address locations of bitmaps for a row of a card
	sw $t5, 8($t0)
	sw $t5, 12($t0)
	sw $t5, 16($t0)
	sw $t5, 20($t0)
	sw $t5, 24($t0)
	sw $t5, 28($t0)
	sw $t5, 32($t0)
	sw $t5, 36($t0)
	sw $t5, 40($t0)
	sw $t5, 44($t0)
	sw $t5, 48($t0)

	addi $t0, $t0, 64 # $t0 += 64 (start of next card)
               
    	addi $t6, $t6, -1 # $t6 -= 1
    
    	bnez $t6, draw_col # $t6 != 0, jump to draw_col
    
    	addi $t3, $t3, 256 # $t3 += 256 (move down one row)
    	addi $t4, $t4, -1 # $t4 -= 1
    	bnez $t4, draw_row # $t4 != 0. jump to draw_row
    
    	addi $t7, $t7, -1 # $t7 -= 1
    	li $t4, 5 # $t4 = 5
 
    	addi $t0, $t0, 256 # $t0 += 256 (move down one row)
    	bnez $t7, draw_row # $t7 != 0, jump to draw_row
    	
    	li $t4, 0 # $t4 = 0
    	li $a2, 724 # $a2 = 724
    	addi $sp, $sp, -4 # Store $ra on the stack
    	sw $ra, ($sp)
drawCardNum:
	addi $a2, $a2, 64 # $a2 += 64
	rem $v1, $t4, 4 # v1 = rem $t4 / 4
	beqz $v1, nextRow # v1 != 0, jump to nextRow
return2:
	move $t7, $t4 # $t7 = $t4
	addi $t7, $t7, 48 # $t7 += 48
	blt $t4, 10, num # branch if $t4 is less than 10 (number doesn't need to be represented with a letter a-f)
	addi $t7, $t7, 39 # $t7 != 39
num:
	move $v1, $a2 # $v1 = $a2
	jal draw # jump to draw
	move $a2, $v1 # $a2 = $v1
	addi $t4, $t4, 1 # $t4 += 1
	bne $t4, 16, drawCardNum # $t4 != 16, jump to drawCardNum (Draw 16 cards)
	
	lw $ra, ($sp) # load $ra off the stack
	addi $sp, $sp, 4
    	jr $ra # jump to $ra
nextRow:
	beq $t4, 16, return2
	addi $a2, $a2, 1280 # if $t4 != 16, move down one row in the bitmap
	j return2 # jump to return2
score:
    	la $t0, frameBuffer # $t0 = address of frameBuffer
    	lw $t1, numberofCards # $t1 = address of numberofCards
    	li $t2, 6 # $t2 = 6
    	addi $t0, $t0, 256 # $t0 += 256 
numberofCardsLoop: # loop 6 times to draw the green box for the score in the bitmap
	sw $t1, 4($t0) # store green in each location in the bitmap
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	addi $t2, $t2, -1 # $52 -= 1
	addi $t0, $t0, 256 # $t0 += 256 (move down one row)
	
	bnez $t2, numberofCardsLoop # $t2 != 0, loop
	
	jr $ra # jump to $ra
	
timerJ:
	la $t0, frameBuffer # $t0 = address of frameBuffer
    	lw $t1, timer # t1 = color of timer background
    	li $t2, 6 # $t2 = 6
    	addi $t0, $t0, 436 # $t0 += 436
timerLoop:
	sw $t1, 4($t0) # store the blue timer background color in one row
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	sw $t1, 28($t0)
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 48($t0)
	sw $t1, 52($t0)
	sw $t1, 56($t0)
	sw $t1, 60($t0)
	sw $t1, 64($t0)
	sw $t1, 68($t0)

	addi $t2, $t2, -1 # decrement loop count: $t2 -= 1
	addi $t0, $t0, 256 # $t0 += 256 (Move down one row)
	
	bnez $t2, timerLoop # $t2 != 0, jump to timerLoop
	
	jr $ra # jump to $ra

flippingCard:
	addi $sp, $sp, -8 # store $ra and $a2 on stack
	sw $ra, ($sp)
	sw $a2, 4($sp)
	jal flipToFront # play sound for flipping card
	lw $a2, 4($sp) # load $ra and $a2 from the stack
	lw $ra, ($sp)
	addi $sp, $sp, 8
	
	la $t0, frameBuffer # $t0 = frameBuffer
	addi $t0, $t0, 2052   # $t0 += 2052
	move $s1, $t0 # $s1 = $t0
	li $t1, 0xffffff #t0 = white color
	li $t2, 5 # $t2 = 5
	li $t3, 2 # $t3 = 2

	beqz $a2, animateloop1 # a2 != 0, loop 
	
	mul $s0, $a2, 64 # $s0 = $a2 + 64
	add $t0, $t0, $s0 # $t0 += $s0
	blt $a2, 4, animateloop1 # if $a2 < 4, loop

	row2:
	addi $t0, $t0, -256 # $t0 -= 256
	bgt $a2, 7, row3 # if $a2 > 7, jump to row3

	addi $t0, $t0, 1536 # $t0 += 1536
	move $s1, $t0 # $s1 = $t0

	b animateloop1 # jump to animateloop1
	row3:
	addi $t0, $t0, -512 # $t0 -= 512
	bgt $a2, 11, row4 # if $a2 > 11, jump to row 4
	addi $t0, $t0, 3328 # $t0 += 3328
	move $s1, $t0 # $s1 = $t0
	b animateloop1 # jump to animateloop1
	row4:
	addi $t0, $t0, -768 # $t0 -= 768
	addi $t0, $t0, 5376 # $t0 += 5376
	move $s1, $t0 # $s1 = $t0
	
animateloop1:
	sw $t1, 4($t0) # store $t1 in bitmap locations
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	sw $t1, 24($t0)
	addi $t0, $t0, 256 # $t0 += 256
	addi $t2, $t2, -1 # t2 -= 1
	bnez $t2, animateloop1 # $t2 != 0, loop to animateloop1

	li $t2, 5 # $t2 = 5
	move $t0, $s1 # $t0 = $s1
	bgt $a2, 3, skip1 # $a2 > 3, jump to skip1
	beqz $a2, skip1 # $a2 != 0, jump to skip1
	add $t0, $t0, $s0 # $t0 += $s0
	skip1:
	addi $v0, $zero, 32 # v0 = 32, syscall sleep
	addi $a0, $zero, 125 # a0 = 125
	syscall # run system call
	
animateloop2:
	
	sw $t1, 28($t0) # store $t1 in bitmap locations
	sw $t1, 32($t0)
	sw $t1, 36($t0)
	sw $t1, 40($t0)
	sw $t1, 44($t0)
	sw $t1, 48($t0)

	addi $t0, $t0, 256  # $t0 != 256

	addi $t2, $t2, -1 # $t2 -= 1
	bnez $t2, animateloop2 # $t2 != 0, branch to animateloop2
		
	addi $v0, $zero, 32 # $v0 = 32, syscall sleep
	addi $a0, $zero, 50 # $v0 = 50
	syscall # run system call
		 
	addi $t3, $t3, -1 # $t3 -= 1
	lw $t1, flippedCard # $t1 = flippedCard
	li $t2, 5 # $t2 = 5
	move $t0, $s1 # $t0 = $s1
	bgt $a2, 3, skip2 # if $a2 ? 3, jump to skip2 
	beqz $a2, skip2 # if $a2 != 0, jump to skip 2
	add $t0, $t0, $s0 # $t0 += $s0
	
	skip2:
	bnez $t3, animateloop1	 # $t3 != 0, jump to animateloop1
	
	addi $v0, $zero, 32 # $v0 = 32, syscall sleep
	addi $a0, $zero, 125 # $a0 = 125
	syscall # run system call
	jr $ra # jump to $ra
	
reFlip: 
	addi $v0, $zero, 32 # $v0 = 32, syscall sleep
	addi $a0, $zero, 125 # $a0 = 125
	syscall # run system call
	addi $sp, $sp, -8 # store $ra and $a2 on the stack
	sw $ra, ($sp)
	sw $a2, 4($sp)
	jal flipToFront # play card flipping sound
	lw $a2, 4($sp) # load #ra and $a2 on the stack
	lw $ra, ($sp)
	addi $sp, $sp, 8
	li $t3, 2 # $t3 = 2
	li $t2, 5 # $t2 = 5
	la $t0, frameBuffer # $t0 = frameBuffer
	li $t1, 0xa7d3ec # $t1 = 0xa7d3ec
	addi $t0, $t0, 2056 # $t0 += 2056
	div $v0, $a2, 4 # $v0 = $a2 / 4
	mul $v0, $v0, 1536 # $v0 *= 1536
	add $t0, $t0, $v0 # $t0 += $v0
	rem $v0, $a2, 4 # $v0 = remainder $a2 / 4
	mul $v0, $v0, 64 # $v0 *= 64
	add $t0, $t0, $v0 # $t0 += $v0
	move $v0, $t0 # $v0 = $t0
	add $v1, $t0, 16 # $v1 = $t0 + 16
unmatchedCardLoop1:
	sw $t1, ($t0) # store $t1 on the bitmap locations
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)
	addi $t0, $t0, 256 # $t0 += 256   
	addi $t2, $t2, -1 # $t2 -= 1
	bnez $t2, unmatchedCardLoop1 # $t2 != 0, jump to unmatchedCardLoop1
	
	li $t2, 5 # $t2 = 5
	move $t0, $v0 # $t0 = $v0
	addi $t0, $t0, 24 # t0 += 24
	
	addi $v0, $zero, 32 # $v0 = 32, syscall sleep
	addi $a0, $zero, 125 # $a0 = 125
	syscall # run system call
unmatchedCardLoop2:
	sw $t1, 0($t0) # store $t1 on bitmap locations
	sw $t1, 4($t0)
	sw $t1, 8($t0)
	sw $t1, 12($t0)
	sw $t1, 16($t0)
	sw $t1, 20($t0)	

	addi $t0, $t0, 256 # $t0 != 256

	addi $t2, $t2, -1 # $t2 -= 1
	bnez $t2, unmatchedCardLoop2 # if $t2 != 0, jump to unmatchedCardLoop2

	
    	addi $sp, $sp, -4 # store $ra on the stack
    	sw $ra, ($sp)
	move $t7, $a2 # $t7 = $a2
	addi $t7, $t7, 48 # $t7 += 48
	blt $a2, 10, num2 # $a2 < 10, branch to num2
	addi $t7, $t7, 39 # $t7 += 39 (number is represented by a-f)
num2:
	la $t1, frameBuffer # $t1 = frameBuffer
	sub $a2, $v1, $t1 # $a2 = $v1 - $t1
	jal draw # jump to draw
	
	lw $ra, ($sp) # load $ra from the stack
	addi $sp, $sp, 4
    	jr $ra # jump to $ra
	
drawZero: # draw on the bitmap starting from $a2 the character 0
	la $t5, frameBuffer
	add $a2, $a2, $t5
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 244
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	jr $ra
drawOne: # draw on the bitmap starting from $a2 the character 1
	la $t5, frameBuffer
	add $a2, $a2, $t5
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 252
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 252
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 252
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	jr $ra
drawTwo: # draw on the bitmap starting from $a2 the character 1
	la $t5, frameBuffer
	add $a2, $a2, $t5
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 252
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 244
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 252
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	jr $ra
drawThree: # draw on the bitmap starting from $a2 the character 3
	la $t5, frameBuffer
	add $a2, $a2, $t5
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 252
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	jr $ra
drawFour: # draw on the bitmap starting from $a2 the character 4
	la $t5, frameBuffer
	add $a2, $a2, $t5
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 252
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	jr $ra
drawFive: # draw on the bitmap starting from $a2 the character 5
	la $t5, frameBuffer
	add $a2, $a2, $t5
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 244
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	add $a2, $a2, 244
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	jr $ra
drawSix: # draw on the bitmap starting from $a2 the character 6
	la $t5, frameBuffer
	add $a2, $a2, $t5
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 244
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 244
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	jr $ra
drawSeven: # draw on the bitmap starting from $a2 the character 7
	la $t5, frameBuffer
	add $a2, $a2, $t5
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	add $a2, $a2, 252
	sw $zero, ($a2)
	add $a2, $a2, 252
	sw $zero, ($a2)
	jr $ra
drawEight: # draw on the bitmap starting from $a2 the character 8
	la $t5, frameBuffer
	add $a2, $a2, $t5
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	jr $ra
drawNine: # draw on the bitmap starting from $a2 the character 9
	la $t5, frameBuffer
	add $a2, $a2, $t5
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 244
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 244
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	jr $ra
drawA: # draw on the bitmap starting from $a2 the character A
	la $t5, frameBuffer
	add $a2, $a2, $t5
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 240
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 236
	sw $zero, ($a2)
	add $a2, $a2, 20
	sw $zero, ($a2)
	jr $ra
drawB: # draw on the bitmap starting from $a2 the character B
	la $t5, frameBuffer
	add $a2, $a2, $t5
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	jr $ra
drawX:  # draw on the bitmap starting from $a2 the character X
	la $t5, frameBuffer
	add $a2, $a2, $t5
	add $a2, $a2, 256
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 252
	sw $zero, ($a2)
	add $a2, $a2, 252
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	jr $ra
drawF: # draw on the bitmap starting from $a2 the character F
	la $t5, frameBuffer
	add $a2, $a2, $t5
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 244
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 244
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	jr $ra
drawE: # draw on the bitmap starting from $a2 the character E
	la $t5, frameBuffer
	add $a2, $a2, $t5
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	jr $ra
drawD: # draw on the bitmap starting from $a2 the character D
	la $t5, frameBuffer
	add $a2, $a2, $t5
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 244
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 244
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	jr $ra
drawC: # draw on the bitmap starting from $a2 the character C
	la $t5, frameBuffer
	add $a2, $a2, $t5
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 244
	sw $zero, ($a2)
	add $a2, $a2, 256
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 248
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	jr $ra
drawColon: # draw on the bitmap starting from $a2 the character :
	la $t5, frameBuffer
	add $a2, $a2, $t5
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 512
	sw $zero, ($a2)
	jr $ra
	
drawVictory: # draw on the bitmap the text: Well Done! You finished in time taken
	la $t3, frameBuffer
	li $t1, 2048
	li $t2, 0xffffff
	l11:
		sw $t2, 0($t3)
		addi $t3, $t3, 4
		addi $t1, $t1, -1
		bnez, $t1, l11
		
	la $t5, frameBuffer
	add $a2, $t5, 524
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 32
	sw $zero, ($a2)
	
	
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 36
	sw $zero, ($a2)
	
	
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 20
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 36
	sw $zero, ($a2)
	
	
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 36
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 40
	sw $zero, ($a2)
	
	
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 20
	sw $zero, ($a2)
	add $a2, $a2, 20
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	
	
	# Next Line
	add $a2, $a2, 288
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 20
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 104
	sw $zero, ($a2)
	
	add $a2, $a2, 24
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 24
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 104
	sw $zero, ($a2)
	
	
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 104
	sw $zero, ($a2)
	
	
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 104
	sw $zero, ($a2)
	
	
	add $a2, $a2, 16
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 12
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	add $a2, $a2, 20
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 8
	sw $zero, ($a2)
	add $a2, $a2, 4
	sw $zero, ($a2)
	
	addi $sp, $sp, -4
	sw $ra, 4($sp)
	
	div $a0, $t0, 60 # divide the seconds into minutes
	rem $a1, $t0, 60
	rem $t2, $a1, 10 # get the first digit of seconds
	div $a1, $a1, 10 # get the second digit of seconds
	
	li, $a2, 3596 # $a2 = 3596
	li $t7, 48 # $t7 = 48
	jal draw # jump to draw
	
	li, $a2, 3616 # $a2 = 3616
	addi $t7, $a0, 48 # $t7 = $a0 + 48
	jal draw # jump to draw
	
	li $a2, 3888 # $a2 = 3888
	li $t7, 58 # $t7 = 58
	jal draw # jump to draw
	
	li $a2, 3644 # $a2 = 3644
	addi $t7, $a1, 48 # $t7 = $a1 + 48
	jal draw # jump to draw
	
	li $a2, 3664 # $a2 = 3664
	addi $t7, $t2, 48 # $t7 = $t2 + 48
	lw $ra, ($sp) # load the $ra from the stack
	addi $sp, $sp, 4
	lw $ra, ($sp)
	addi $sp, $sp, 4
	j draw # jump to draw
