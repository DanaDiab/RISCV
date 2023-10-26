# TAG = sw
	.text
    lui x3,0x1000
	srli x3,x3,12
    li x2, 0x15B3
	sw x2, (x3)
    lw x31, (x3)


	# max_cycle 50
	# pout_start
	# 000015B3
	# pout_end