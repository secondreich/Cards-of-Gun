extends Panel

class_name turnCheck

func checkResult(PlayerCards , playerAmmo, OppoentCards, oppoentAmmo) -> Array:
	var playerDamage = 0
	var oppoentDamage = 0
	var playerLoad = 0
	var oppoentLoad = 0
	var playerType = PlayerCards[0].cardLabel
	var oppoentType = OppoentCards[0].cardLabel
	
	for c in PlayerCards:
		if c.cardLabels.find("volley") != -1 :
			playerDamage = playerAmmo
			playerLoad -= playerAmmo
			break
		elif c.cardLabels.find("attack") != -1 && oppoentType.find("volley") == -1:
			playerDamage += 1
			playerLoad -= 1
		elif c.cardLabels.find("load") != -1 && oppoentType.find("attack") == -1:
			playerLoad += 1
		elif c.cardLabels.find("avoid") != -1 && oppoentType.find("volley") == -1:
			oppoentDamage = 0
			
	for c in OppoentCards:
		if c.cardLabels.find("volley") != -1 :
			oppoentDamage = oppoentAmmo
			oppoentLoad -= oppoentAmmo
			break
		elif c.cardLabels.find("attack") != -1 && playerType.find("volley") == -1:
			oppoentDamage += 1
			oppoentLoad -= 1
		elif c.cardLabels.find("load") != -1 && playerType.find("attack") == -1:
			oppoentLoad += 1
		elif c.cardLabels.find("avoid") != -1 && playerType.find("volley") == -1:
			playerDamage = 0
			
	return [ max(playerDamage,0), max(oppoentDamage,0), playerLoad, oppoentLoad ]
