 # TAG = bne
	.text

	addi x1, x0, 5       # on ajoute 5 a 0
	addi x2, x0, 10      # on ajoute 10 à 0
    bne x1, x2, ll    # on passe au label 'll'
	bne x2, x1, jump2
	addi x31, x1, 1
jump2:
    addi x31,x2, 1     
ll: 
    addi x31,x1,2 # on mets  x31 a 7

    
	# max_cycle 250
	# pout_start
    # 00000007
	# pout_end