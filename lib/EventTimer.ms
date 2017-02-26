struct EventTimer
(
	caption = "Event",
	eventStart,
	eventEnd,
	
	fn Start =
	(
		eventStart = TimeStamp()
	),
	
	fn End =
	(
		if classOf eventStart == integer then
		(
			eventEnd = TimeStamp()
			
			dTime = ((eventEnd-eventStart)/1000.0)
			
			if dTime > 60 then
			(
				format "% took: %m\n" caption (dTime/60.0)
			)
			else
			(
				format "% took: %s\n" caption dTime
			)
		)
	),
	
	fn init =
	(
		Start()
	),
	__init__ = init()
)
