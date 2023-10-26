# TAG = slti
	.text

	addi x1, x0, -5       # on ajoute 5 a 0
    slti x31, x1, 15
    slti x31, x1, -15
	# max_cycle 250
	# pout_start
	# 00000001
    # 00000000
	# pout_end
