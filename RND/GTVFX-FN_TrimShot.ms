fn TrimShot head:False tail:False =
(
	if head then
	(
		animationRange = interval currentTime animationRange.end
	)
	else if tail then
	(
		animationRange = interval animationRange.start currentTime
	)
)

/*
TrimShot head:True

TrimShot tail:True
*/