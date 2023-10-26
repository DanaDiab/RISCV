# TAG = bge
	.text

	addi x1, x0, -3       # on ajoute -3 a 0
	addi x2, x0, -3      # on ajoute -3 à 0
    bge x1, x2, jump    # on passe au label 'jump'
	addi x31,x1,4
jump: addi x31,x1,2
	addi x2,x0,-1
	bge x31,x2, jump1	# on passe au label 'jump'
    addi x31,x0,2
jump1: addi x31, x1,5

	# max_cycle 250
	# pout_start
	# FFFFFFFF
    # 00000002
	# pout_end
