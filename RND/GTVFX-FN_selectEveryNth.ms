fn selectEveryNth objArr nth:2 arr:#() =
(
	for i in 1 to objArr.count by nth do
	(
		append arr objArr[i]
	)
	select arr
)

selectEveryNth selection nth:2 