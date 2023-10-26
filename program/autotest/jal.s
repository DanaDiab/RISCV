# TAG = jal
	.text

	addi x1, x0, 1       # on ajoute 1 a 0
    jal x31, jump2    # on passe au label 'jump1'
jump1: addi x31, x1, 2
jump2: addi x31, x1, 3

	# max_cycle 250
	# pout_start
	# 00001008			#resultat = pc+4 = 1004 +4
    # 00000004          #resultat = 4
	# pout_end