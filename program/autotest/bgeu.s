# TAG = bgeu
	.text

	addi x1, x0, -5       # on ajoute -5 a 0
	addi x2, x0, 2      # on ajoute 2 à 0
    bgeu x1, x2, ll    # on passe au label 'jump'
	addi x1, x0, 3
	addi x2, x0, 7
	bgeu x1, x2, jump2
	addi x31, x1, 1
jump2:
    addi x2,x2, 1     
ll: 
    addi x31,x1,12 # on mets  x31 a 7

    
	# max_cycle 250
	# pout_start
    # 00000007
	# pout_end


	