# TAG = xor
	.text

	addi x1, x0, 1      
	addi x2, x0, 3
    xor x31, x1, x2

	# max_cycle 250
	# pout_start
	# 00000002		#resultat = 2
	# pout_end