# TAG = sll
	.text

	lui x1, 0x00001  # on pose dans le registre 1  la valeur 1 qui se décale de 12 bits vers la gauche
	addi x2, x0, 2    # on initialise x2 
	sll x31, x1, x2	 # on décale de 2 bits vers la gauche

	# max_cycle 250
	# pout_start
	# 00004000
	# pout_end
