fn GenKey digitCount letterCountMax: letterArr:#("C","K","X") integerArr:#("3","4","7") =
(
	if letterCountMax == unsupplied then letterCountMax = digitCount
	
	letterCount = 0

	str = ""
	for i = 1 to digitCount do
	(
		whichArr = random 1 2
		if letterCount >= letterCountMax then whichArr = 2
		case whichArr of
		(
			(1):
			(
				str += letterArr[(random 1 3)]
				letterCount += 1
			)
			(2):
			(
				str += integerArr[(random 1 3)]
			)
		)
	)
	str
)


newStr = GenKey 8 letterCountMax:2
