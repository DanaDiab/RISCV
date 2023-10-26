# TAG = lb
	.text
    lui x30,0x1000
    srli x30,x30, 12
    lb x31, (x30)



	# max_cycle 250
	# pout_start
	# 00000037    #encodage de lui
	# pout_end