# TAG = sltu
	.text

	li x1, -15
	li x2, 5
    li x3 , 15
    sltu x31, x1, x2
    sltu x31, x2, x1
    sltu x31, x3,x2
    sltu x31, x2,x3
	# max_cycle 250
	# pout_start
	# 00000000
    # 00000001
    # 00000000
    # 00000001
	# pout_end