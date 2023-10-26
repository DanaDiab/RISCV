# TAG = lbu
	.text
    auipc t0,0x0
    li x30, -1
    sb x30, (t0)
    lbu x31, (t0)



	# max_cycle 250
	# pout_start
	# 000000FF    
	# pout_end