# TAG = add
	.text

	lui x1, 0x00005  # on pose dans le registre 1  la valeur 5 décalé de 12 bits
	lui x2, 0x00001  # on pose dans le registre 2  la valeur 1 décalé de 12 bits
	add x31, x1, x2 	# on somme x1 et x2
	
	li x1, -5  # on pose dans le registre 1  la valeur -5 
	li x2, 1  # on pose dans le registre 2  la valeur 1 
	add x31, x1, x2 	# on somme x1 et x2
	

	# max_cycle 50
	# pout_start
	# 00006000		#somme des deux reg x1 et x2
	# FFFFFFFC
	# pout_end
