.include "SysCalls.asm"
.data
	sound1:		.asciiz "sound1.wav"
	sound2:		.asciiz "sound2.wav"
	cardsRemaining:	.word	16
	lastFlipped:	.word	0
	lastFlippedNum:	.word	0
	isFlipped:	.space	64
.text
.globl main draw
main:
	jal numGenStart # generate 16 random numbers with some being in num x num format
	move $s4, $s2 # s4 holds the array of random numbers from RandomNumGen
	jal bitMain # initialize the bitmap
	
	# intializing registers which will remain on the same address for the remainder of the program
	li $t0, 0 # t0 holds the time
	la $s0, cardsRemaining # s0 holds how many cards are not matched yet
	la $s2, isFlipped # s2 holds 16 words which hold either a 1 or 0 for each card indicating if it is flipped or not respectively
	la $s3, lastFlipped # s3 holds the value of the last card flipped
	la $s5, lastFlippedNum # s4 holds the number of the last card flipped 1 - 16
	li $s6, 0xFFFF0000 # s6 holds the keyboard MMIO simulator value of whether a new key press has been entered or not
	li $s7, 0xFFFF0004 # s7 holds the keyboard MMIO simulator value of the ascii value of the last key press
	
	li $t5, 16 # load the initial score of 16 unflipped cards remaining into the bitmap
	j updateScore # push to bitmap
gameUpdateLoop:
	lw $t2, ($s0) # load number of unflipped cards
	beqz $t2, gameOver # if every card is flipped, go to gameOver
	jal updateTime # update the timer on the bitmap
	addi $t0, $t0, 1 # add 1 to the time
	lw $t1, ($s6) # check for new key press 
	beqz $t1, wait # if no new key press, wait one second then loop again
	lw $t1, ($s7) #  get ascii value of key press
	bgt $t1, 102, wait # if key press is over 102 (a bigger ascii value than f) wait a second then loop
	blt $t1, 48, wait # if key press is less than 48 (a smaller ascii value than 0) wait a second then loop
	bgt $t1, 57, checkValue # if key press is larger than 9 check that it isnt less than a
	j flipCard
wait:
	li $v0, 32 # system call: sleep
	li $a0, 1000 # wait one second
	syscall # run service call
	j gameUpdateLoop
checkValue:
	blt $t1, 97, wait # if key press is larger than 9 and less then a, wait a second and loop
	j flipCard # if not, flip the card
	
flipCard:
	blt $t1, 96, j1 # check if key press is a letter
	add $t2, $t1, -87 # if key press is a letter, subtract 87 to get value of 9-15 (cards 10 - 16)
	j j2 
j1:
	add $t2, $t1, -48 # if key press is a number, subtract 48 to get a value of 0 - 8 (cards 1 - 9)
j2:
	move $a2, $t2 #argument for flippingCard jump later
	sll $t2, $t2, 2 # multiply card number by 4 to get amount of bytes to move
	move $t3, $t2 # $t3 = $t2
	add $t3, $t3, $s2 # add address of isFlipped to t3 to see if card to be flipped is already flipped
	lw $t4, ($t3) # get value of 1 (flipped) or 0 (not flipped)
	beq $t4, 1, wait # if card is already flipped, it can't be flipped again, wait a second and loop again
	addi $sp, $sp, -20 # flip card and store all registers which are changed in flippingCard method
	sw $t0, ($sp)
	sw $t2, 4($sp)
	sw $t3, 8($sp)
	sw $s0, 12($sp)
	sw $s1, 16($sp)
	jal flippingCard # call flippingCard method
	lw $t0, ($sp)
	lw $t2, 4($sp)
	lw $t3, 8($sp)
	lw $s0, 12($sp)
	lw $s1, 16($sp)
	addi $sp, $sp, 20 #reset all registers
	jal updateNum # put the number on the card on the now flipped card
	li $t4, 1 # $t4 = 1
	la $ra, gameUpdateLoop # $ra = gameUpdateLoop
	sw $t4, ($t3) # store one in isFlipped to indicate the card is now flipped
	lw $t4, ($s3) # load the value of the last flipped card
	bnez $t4 checkMatch # if $t4 = 0, then there is not another flipped card, therefore, there is no card to compare to
	addi $v0, $zero, 32 # if there is no card to compare to, wait .5 seeconds
	addi $a0, $zero, 500
	syscall
oneDigit: # numbers are all in one of three formats: one digit number: Num.. , two digit number: NumNum. or , Number x Number
	div $t4, $t2, 4 # get card number 0-15
	mul $t4, $t4, 3 # multiple card number by 3 to find start of number in array of numbers s4
	add $t4, $s4, $t4 # add t4 to address of array of numbers
	lb $t3, 1($t4) # if the second byte is a period. it is a one digit number
	bne $t3, 46, twoDigit # if the second byte is not a period, jump to two digit number
	lb $t3, ($t4) # load first byte of num
	addi $t3, $t3, -48 # subtract 48 to get actual value from ascii value
	sw $t3, ($s3) # store value in s3 to indicate it is the value of last flipped card
	la $t6, gameUpdateLoop # only store which card was flipped if there is no comparison to be made to another card
	beq $t6, $ra, swapLastMatch # if there is no card to compare to, jump
	jr $ra # jump to main loop or return
twoDigit:
	lb $t3, 2($t4) # if third byte is a period, it is a two digit number
	bne $t3, 46, numXnum # else, it is a numXnum format number
	lb $t3, ($t4) # load first byte of number
	addi $t3, $t3, -48 # get actual value from ascii value
	mul $t3, $t3, 10 # first digit is the 10's place so multiply by 10
	lb $t5, 1($t4) # load the second byte of number
	addi $t5, $t5, -48 # get actual value from ascii value
	add $t3, $t5, $t3 # add both numbers together to get final value
	sw $t3, ($s3) # store in last flipped number s3
	la $t6, gameUpdateLoop # only store which card was flipped if there is no comparison to be made to another card
	beq $t6, $ra, swapLastMatch # if there is no card to compare to, jump
	jr $ra # jump to main loop or return
numXnum:
	lb $t3, 2($t4) # load third byte (second multiplicand)
	addi $t3, $t3, -48 # get actual value from ascii value
	lb $t5, ($t4) # load first byte (first multiplicand)
	addi $t5, $t5, -48 # get actual value from ascii value
	mul $t3, $t3, $t5 # multply numbers to get actual value
	sw $t3, ($s3) # store in last flipped number s3
	la $t6, gameUpdateLoop # only store which card was flipped if there is no comparison to be made to another card
	beq $t6, $ra, swapLastMatch # if there is no card to compare to, jump
	jr $ra # jump to return
swapLastMatch:
	sw $t2, ($s5) # store card flipped 1-15 in s5
	jr $ra # return to main loop
checkMatch:
	la $ra return # load return into $ra
	lw $t7, ($s3) # load the value of the last flipped number
	j oneDigit # get value of current flipped number
return:
	bne $t3, $t7, reflip # if the values are not the same, flip both cards back over
	sw $zero, ($s5) # if values are the same, reset s3 and s5 to zero
	sw $zero, ($s3)
	lw $t5, ($s0) # load number of cards not flipped
	addi $t5, $t5, -2 # $t5 -= 2
	sw $t5, ($s0) # reduce cards remaining by two
	li $v0, 32 # system call: sleep
	li $a0, 250 # wait .25 seconds
	syscall # run service call
	jal updateScore

reflip:
	add $t7, $s2, $t2 # $t7 = isFlipped plus card number
	sw $zero, ($t7) # load 0 into $t7 indicating the card is flipped back over
	addi $sp, $sp, -8 # store $t0 and $t2 on the stack
	sw $t0, 4($sp)
	sw $t2, ($sp)
	lw $a2, ($s5) # load the value of the most recently flipped card
	add $t7, $s2, $a2 # $t7 = isFlipped plus card number
	sw $zero, ($t7) # load 0 into $t7 indicating the other card is flipped back over
	div $a2, $a2, 4 # divide a2 by 4 to get card number 1-15 instead of byte number
	jal reFlip # jump to reFlip
	lw $t2, ($sp) # get $t2 back from the stack
	addi $sp, $sp, 4
	div $a2, $t2, 4 # divide $t2 by 4 to get card number 1-15 instead of byte number
	jal reFlip # jump to reFlip
	lw $t0, ($sp) # get $t0 back from the stack
	addi $sp, $sp, 4
	sw $zero, ($s5) # reset s3 and s5 back to zero
	sw $zero, ($s3)
	j gameUpdateLoop # jump to main loop
	
	
	
updateNum:
	addi $sp, $sp, -4 # store ra on stack
	sw $ra, ($sp)
	div $t4, $t2, 4 # divide $t2 by 4 to get card number from byte number 
	mul $t4, $t4, 3 # multiply $t4 by 3 to get the number in the number array s4
	add $t4, $s4, $t4 # $t4 += $s4
	lb $t7, ($t4) # load the first byte from the array
	li $a2, 2056 # add bitmap address of the first card
	div $v0, $t2, 16 # divide t2 by 16 to find which row of the bitmap the card is one 1-4
	mul $v0, $v0, 1536 # mutiply v0 by 1536 to get amount needed to move to be in the right row
	add $a2, $a2, $v0 # $a2 += #v0
	div $v0, $t2, 4 # divide t2 by 4 to get card number from byte number
	rem $v0, $v0, 4 # get remainder of v0 divided by 4 to find column number 1-4
	mul $v0, $v0, 64 # multiply v0 by 64 to get amount needed to move to be in right column
	add $a2, $a2, $v0 # $a2 += #v0
	move $fp, $a2 # store $a2 in $fp
	jal draw # jump to draw
	addi $t4, $t4, 1 # $t4 += 1
	lb $t7, ($t4) # load the second byte
	addi $fp, $fp, 20 # move over 5 pixels to start of second number
	beq $t7, 46, j3 # if the second byte is a period, then stop drawing
	move $a2, $fp # else, draw byte two
	jal draw # jump to draw
	addi $t4, $t4, 1 # $t4 += 1
	lb $t7, ($t4) # load third byte
	addi $fp, $fp, 12 # move 3 pixels over to start of third number
	beq $t7, 46, j3 # if third byte is a period, then stop drwaing
	move $a2, $fp  # else, draw byte three
	lw $ra, ($sp) # get $ra from stack
	addi $sp, $sp, 4
	j draw # jump to draw
j3:	
	lw $ra, ($sp) # get $ra from stack
	addi $sp, $sp, 4
	jr $ra # jump to $ra
updateScore:
	addi $sp, $sp, -8  # store $t0 and $t5 on the stack
	sw $t0, ($sp)
	sw $t5, 4($sp)
	jal score # jump to score
	lw $t0, ($sp) # get $t0 back from the stack
	addi $sp, $sp, 4
	blt $t5, 10, oneDigitScore # if the value of $t5 is less than 10, the number is one digit big, else it is two digits big
	li $t7, 49 # if the score is two digits, the first digit must be one (ascii value 49)
	li $a2, 264 # load bitmap location 264
	jal draw # jump to draw
	lw $t5, ($sp) # load $t5 from the stack
	addi $sp, $sp, 4
	rem $t7, $t5, 10 # the second digit is obtained from the remainder of $t5 divided by 10
	addi $t7, $t7, 48 # add $t7 with 48 to obtain ascii value of second digit
	li $a2, 288 # load bitmap location of 288
	la $ra, gameUpdateLoop # load return address of gameUpdateLoop
	j draw # jump to draw
oneDigitScore:
	addi $t7, $t5, 48 # add 48 to digit value to obtain ascii value
	li $a2, 276 # load bitmap location of 276
	la $ra, gameUpdateLoop # load return address of gameUpdateLoop
	j draw # jump to draw
	
updateTime:
	addi $sp, $sp, -8 # store $ra and $t0 on the stack
	sw $ra, 4($sp)
	sw $t0, ($sp)
	jal timerJ # jump to timerJ (draw timer background color)
	lw $t0, ($sp) # load $t0 from the stack
	addi $sp, $sp, 4
	
	div $a0, $t0, 60 # divide time by 60 to find amount of minutes that have passed
	rem $a1, $t0, 60 # get remainder of time divided by 60
	rem $t2, $a1, 10 # get remainder of seconds divided by 10 to find first digit of time
	div $a1, $a1, 10 # divide number of seconds by 10 to find second digit of time
	
	li, $a2, 444 # load bitmap location of 444
	addi $t7, $a0, 48 # add 48 to number of minutes to get ascii value
	jal draw # jump to draw
	
	li $a2, 460 # load bitmap location of 460
	li $t7, 58 # load immediate 58 to draw a colon after the minutes 
	jal draw # jump to draw
	
	li $a2, 472 # load bitmap location of 472
	addi $t7, $a1, 48 # add 48 to second digit of seconds to get ascii value
	jal draw # jump to draw
	
	li $a2, 492 # load bitmap location of 492
	addi $t7, $t2, 48 # add 48 to first digit of seconds to get ascii value
	lw $ra, ($sp) # load $ra from stack
	addi $sp, $sp, 4
	j draw # jump to draw

draw: # based upon the ascii value stored in $t7, draw various different characters
	beq $t7, 58, drawColon
	beq $t7, 120, drawX
	beq $t7, 48, drawZero
	beq $t7, 49, drawOne
	beq $t7, 50, drawTwo
	beq $t7, 51, drawThree
	beq $t7, 52, drawFour
	beq $t7, 53, drawFive
	beq $t7, 54, drawSix
	beq $t7, 55, drawSeven
	beq $t7, 56, drawEight
	beq $t7, 57, drawNine
	beq $t7, 97, drawA
	beq $t7, 98, drawB
	beq $t7, 99, drawC
	beq $t7, 100, drawD
	beq $t7, 101, drawE
	beq $t7, 102, drawF

gameOver:
	li $v0, 32 # system call: sleep
	li $a0, 3000 # after final card is flipped, wait 3 seconds before displaying victory screen
	syscall # run service call
	jal victory # play victory sound
	jal drawVictory # display victory screen
	li $v0, SysExit # service call: exit
	syscall # run system call
