# TAG = slt
	.text

	addi x1, x0, -5     # on met -5 dans x1
	addi x2, x0, 2    # on initialise x2 
	slt x31, x1, x2	 # on test si x1 < x2.
	li x2,-7
    slt x31, x1,x2

	# max_cycle 250
	# pout_start
	# 00000001
	# 00000000
	# pout_end