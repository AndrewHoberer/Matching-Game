.data
sound_file: .asciiz "sound1.wav"

.text
.globl flipToBack flipToFront victory
flipToBack:
    	li $a0, 70	    # Pitch 70
    	li $a1, 750         # Duration (750 ms)
    	li $a2, 122	    # Instument seashore
    	li $a3, 127         # Volume
    	li $v0, 31	    # Service call 31: MIDI Out
    	syscall		    # run system call
    	li $a0, 60	    # pitch 60
    	li $a1, 750         # Duration (750 ms)
    	li $v0, 31	    # Service call 31: MIDI Out
    	syscall		    # run system call
    	jr $ra	 	    # jump to $ra

flipToFront:
    	li $a0, 80	    # Pitch 80
    	li $a1, 800         # Duration (800 ms)
    	li $a2, 122	    # Instrument seashore
    	li $a3, 127         # Volume
    	li $v0, 31	    # Service call 31: MIDI Out
    	syscall		    # run system call
    	li $a0, 60
    	li $a1, 750         # Duration (750 ms)
    	li $a3, 70	    # Volume
    	li $v0, 31	    # Service call 31: MIDI Out
    	syscall		    # run system call
    	jr $ra		    # jump to $ra
victory:
   	li $a0, 60          # Pitch
   	li $a1, 2000        # Duration (2 seconds)
   	li $a2, 126	    # Instrument Applause
    	li $a3, 100         # Volume
    	li $v0, 31	    # Service call 31: MIDI Out
	syscall		    # run system call
	jr $ra		    # jump to #ra
