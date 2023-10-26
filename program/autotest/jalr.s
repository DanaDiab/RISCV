# TAG = jalr
	.text

	addi x2, x0, 1006       
    jalr x31, 1(x2) 
	addi x31, x31, 2   


	# max_cycle 250
	# pout_start
	# 00001008	
	# pout_end