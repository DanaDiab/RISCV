# TAG = srl
	.text

	lui x1, 0x00001  # on pose dans le registre 1  la valeur 1 qui se décale de 12 bits vers la gauche
	addi x2, x0, 12    # on initialise x2 
	srl x31, x1, x2	 # on décale de 12 bits vers la droite

	# max_cycle 250
	# pout_start
	# 00000001
	# pout_end