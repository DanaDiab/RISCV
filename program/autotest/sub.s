# TAG = sub
	.text

	lui x1, 0x00005  # on pose dans le registre 1  la valeur 5 décalé de 12 bits
	lui x2, 0x00001  # on pose dans le registre 2  la valeur 1 décalé de 12 bits
	sub x31, x1, x2 	# on soustrait x1 et x2
	li x1,3
	li x2,-4
	sub x31,x1,x2
	
	
	

	# max_cycle 50
	# pout_start
	# 00004000		#soub des deux reg x1 et x2
	# 00000007
	# pout_end
