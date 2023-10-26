# TAG = sltiu
	.text

	li x1, -15
	li x2, 5
    sltiu x31, x1, 5
    sltiu x31, x2, -15
    sltiu x31, x1, -20

	# max_cycle 250
	# pout_start
	# 00000000
    # 00000001
    # 00000000
	# pout_end
    