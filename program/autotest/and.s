# TAG = and
	.text

	addi x1, x0, 3       # on ajoute 3 a 0
	addi x2, x0, 6
    and x31, x1, x2

	# max_cycle 250
	# pout_start
	# 00000002		#resultat = 2
	# pout_end