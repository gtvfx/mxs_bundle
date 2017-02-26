

struct qc_EmptyMapLoaders
(
    aggregate,
    debug = False,
    
    fn GetAllEmptyMapLoaders =
	(
		local bitMapArr = for b in ( Getclassinstances bitmaptexture asTrackViewPick:on ) where b.anim.filename == undefined or b.anim.filename == "" collect b
		if VrayHdri != undefined then
        (
            local vrArr = for v in ( Getclassinstances VrayHdri asTrackViewPick:on ) where v.anim.HdriMapName == undefined or v.anim.HdriMapName == "" collect v
            bitMapArr += vrArr
        )
        bitMapArr
	),
	
	fn RemoveMapLoaders mapLoaderArr =
	(
		MatEditor.Close()
		for map in mapLoaderArr do
		(
			for i = 1 to map.client.numsubs do
			(
				if map.client[i] == map.anim then
				(
					map.client[i].value = undefined
					exit
				)
			)
		)
	),
	
	fn RemoveEmptyMapLoaders =
	(
		local emptyLoaderArr = this.GetAllEmptyMapLoaders()
		this.RemoveMapLoaders emptyLoaderArr
	),
	
	fn CheckEmptyBitmapTextures =
	(
		local emptyLoaderArr = GetAllEmptyMapLoaders()
        
        local msg = "There are " + ( emptyLoaderArr.count as string ) + " empty map loaders"
        format "***** % *****\n" msg
        
        if emptyLoaderArr.count != 0 then
        (
            if ( this.aggregate != undefined ) and ( isProperty this.aggregate #msgBuffer ) then
            (
                this.aggregate.msgBuffer = msg
            )
            
            False
        )
        else
        (
            True
        )
	),
    
    fn Run =
    (
        if not ( this.CheckEmptyBitmapTextures() ) then
        (
            if ( queryBox "Would you like to remove all empty bitmap loaders?" title:"?" ) then
            (
                this.RemoveEmptyMapLoaders()
            )
        )
    ),
    
    fn Help =
    (
        format "
---------------
CLASS USAGE:

Constructor = qc_EmptyMapLoaders
Instantiated Global = N/A

---------------\n"
    ),

    private fn _init =
    (
        -- Pass
    ),

    __init__ = _init()
)


