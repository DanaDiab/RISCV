# TAG = blt
	.text

	addi x1, x0, -4       # on ajoute -4 a 0
	addi x2, x0, -1      # on ajoute -1 à 0
    blt x1, x2, jump    # on passe au label 'jump'
	addi x31,x1,4
jump1: addi x31, x0,5
jump: addi x31, x1, 6
	addi x2, x0, 1    # on ajoute 6 à 0
    blt x31,x2, jump1
    addi x31,x31,2


	# max_cycle 250
	# pout_start
	# 00000002
    # 00000004
	# pout_end