# TAG = lw
	.text
    lui x30,0x1000
    srli x30,x30, 12
    lw x31, (x30)



	# max_cycle 250
	# pout_start
	# 01000f37    #encodage de lui
	# pout_end