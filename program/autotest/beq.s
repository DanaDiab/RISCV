# TAG = beq
	.text

	addi x1, x0, 5       # on ajoute 5 a 0
	addi x2, x0, 5    # on ajoute 5 à 0
	addi x3,x0,7
    beq x1, x2, jump    # on passe au label 'jump'
	addi x31,x1,4
jump: addi x31, x1, 2
	li x1, 7
	beq x31,x3,jump		# x31=7  donc jump , deuxieme tour =9

	# max_cycle 250
	# pout_start
	# 00000007			#resultat = 7
	# 00000009			#resultat = 9
	# pout_end
