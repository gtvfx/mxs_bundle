/***************************************************************************************************
Copyright (C) 2013 - 2017  Gavyn Thompson

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. if not, see <http://www.gnu.org/licenses/>.
***************************************************************************************************/
/***************************************************************************************************
Author:				    Gavyn Thompson
Company:				GTVFX
Website:				https://github.com/gtvfx
Email:				    gftvfx@gmail.com
ScriptVersion:			
Updated:				
[Purpose]

***************************************************************************************************/
/*
__HELP__

Constructor: EventTimer
Instantiated Global: 



Methods:

    Start:
        Creates the starting base for the time measurement
    
    End:
        Calculate the time since the Start method was called. Prints the info out to the Listener.
    
    
    
The Start method is called upon instantiation. Best practice is to define the caption parameter at the time of instantiation. 
eg..
cacheTime = ::EventTimer caption:"Cacheing objects"
<pseudo code>
cacheTime.End()

__END__
*/



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
