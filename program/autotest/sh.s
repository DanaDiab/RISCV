# TAG = sh

	.text
    lui x3,0x1000
	srli x3,x3,12
    addi x2,x0,1000
	sh x2, (x3)
    lh x31, (x3)


	# max_cycle 50
	# pout_start
	# 000003E8
	# pout_end