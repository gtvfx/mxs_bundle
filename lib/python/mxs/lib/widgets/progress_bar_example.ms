-- We can aggregate the Python module to Maxscript by using the python.import method
if ( ::progress_bar == undefined ) and ( ( MaxVersion() )[1] > 18000 ) then ::progress_bar = python.import "mxs.lib.widgets.progress_bar"


-- in order to use the reload() method to get changes to the python module, we'll first need to load the module into the Python instance
-- even though we've already imported the module through aggregation into Maxscript.
python.execute "from mxs.lib.widgets import progress_bar"
-- We can then call the reload method on the module
python.execute "reload(progress_bar)"



dataArr = for i = 1 to 100 collect i

drawProgress = ::progress_bar.Run title:"Looping Example" maximum:dataArr.count


for i = 1 to dataArr.count do
(
	drawProgress.update_label ( "Processing " + ( i as string ))
	
	drawProgress.step()
		
	sleep .03
)

drawProgress.close()