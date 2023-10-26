# TAG = addi
	.text

	addi x1, x0, 5       # on ajoute 5 a 0
	addi x31, x1 , 11    # on ajoute 11 a 5
	addi x31, x31, -17       # on ajoute -17 a 16

	# max_cycle 250
	# pout_start
	# 00000010			#resultat = 16
	# FFFFFFFF
	# pout_end
