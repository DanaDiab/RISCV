# TAG = sb

	.text
    lui x3,0x1000
	srli x3,x3,12
    addi x2,x0,555
	sb x2, (x3)
    lb x31, (x3)


	# max_cycle 50
	# pout_start
	# 0000002B
	# pout_end