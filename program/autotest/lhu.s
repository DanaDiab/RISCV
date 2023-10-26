# TAG = lhu
	.text
    auipc t0,0x0
    li x30, -1
    sh x30, (t0)
    lhu x31, (t0)



	# max_cycle 250
	# pout_start
	# 0000FFFF    
	# pout_end