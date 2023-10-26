# TAG = auipc
	.text
        
	auipc x31, 0x00004
	
	# max_cycle 50
	# pout_start
	# 00005000			#PC est initialisé à 0x1000 et 0x00004 est décalé de 12 bits vers la gauche
	# pout_end
