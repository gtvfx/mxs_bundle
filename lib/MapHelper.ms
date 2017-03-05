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

Constructor: MapHelper
Instantiated Global: MapHelper

Methods:
    - InstanceLoaders()
        -- Running this method will ensure all map loaders in the scene are instanced

    - Run()
        -- Use to launch a UI

__END__
*/




mxs.Using "DotNetUi"
mxs.Using "WpfProgressbar"

struct MapHelper
(
    showUi = False,
    debug = False,
    startLoaderCount,
    endLoaderCount,
    mapLoaderArr,
    mapInstancer = False,
    storedMaterial,
    
    ro_prog,
    ro,
    rcm_uiBar,
    
    
    fn CollectMaterials excludeList:#(VRaySky) =
    (
        local out = for mat in SceneMaterials where ( findItem excludeList ( classOf mat ) ) == 0 collect mat
        out
    ),
    
    fn GenPropStream obj stream:undefined =
    (
        local prps = #()
        
        if stream == undefined then stream = "" as stringstream
        try( prps = GetPropNames obj )catch()
        
        for p in prps do
        (
            try( val = GetProperty obj p )catch( val = "" )
            format "%:%\n" p val to:stream
            
            GenPropStream val stream:stream
        )
        
        stream
    ),
    
    fn GenHashForLoader mapLoader =
    (
        local str = "" as stringStream
        
        str = ( ToLower ( ( GenPropStream mapLoader ) as string ) )
        
        local out = ( GetHashValue str 0 )
        out
    ),
    
    fn CheckSumMapLoaders loaderArr =
    (
        local out = #()
        local hashArr = #()
        
        local checkSumProg = ::WpfProgressBar caption:"Comparing map loaders" steps:loaderArr.count
        checkSumProg.Start()
        
        for map in loaderArr do
        (
            if ( keyboard.escPressed ) then
            (
                checkSumProg.End()
                exit
            )
            
            checkSumProg.UpdateLabel map.name
            
            if not ( this.CheckFileName map ) then continue
            
            local hashVal = this.GenHashForLoader map
            local indx = ( finditem hashArr hashVal )
            
            case indx of
            (
                0:
                (
                    append hashArr hashVal
                    append out #( map )
                )
                default:
                (
                    append out[indx] map
                )
            )
            
            checkSumProg.Step()
        )
        
        checkSumProg.End()
        
        if this.debug then format "***** CheckSumArr: % *****\n" out
        
        out
    ),
    
    fn GetMapLoaders inst:False  =
    (
        local out = ( GetClassInstances BitMapTexture )
        
        if ( VRayHDRi != undefined ) then
        (
            out += ( GetClassInstances VRayHDRi )
        )
        
        if inst then
        (
            out = this.CheckSumMapLoaders out
        )
        
        this.mapLoaderArr = out
        
        out
    ),
    
    fn GetMapLoaderFilename mapLoader =
    (
        local out
        
        case ( classOf mapLoader ) of
        (
            (bitMapTexture):
            (
                out = mapLoader.fileName
            )
            (VRayHDRi):
            (
                out = mapLoader.HDRIMapName
            )
            default:
            (
                out = undefined
            )
        )
        
        out
    ),
	
	fn SetMapLoaderFilename mapLoader filename =
	(
		case ( classOf mapLoader ) of
        (
            (bitMapTexture):
            (
                mapLoader.filename = filename
            )
            (VRayHDRi):
            (
                mapLoader.HDRIMapName = filename
            )
            default:
            (
                format "***** Unknown loader type *****\n"
            )
        )
	),
    
    fn CheckFileName mapLoader =
    (
        if ( this.GetMapLoaderFileName mapLoader ) == undefined then
        (
            False
        )
        else
        (
            True
        )
    ),
    
    fn InstanceLoaders instArr:unsupplied =
    (
        SetCommandPanelTaskMode #create
        ::mxs.BlockUi True
        
        if instArr == unsupplied then instArr = ( this.CheckSumMapLoaders ( this.GetMapLoaders() ) )
        
        local instanceProg = ::WpfProgressBar caption:"Instancing Map Loaders" steps:instArr.count
        instanceProg.Start()
        
        for inst in instArr do
        (
            instanceProg.UpdateLabel inst[1].name
            for i = 2 to inst.count do replaceInstances inst[i] inst[1]
            instanceProg.Step()
        )
        
        ::mxs.BlockUi False
        
        instanceProg.End()
    ),
    
    fn Get_Names name a =
    (
        append a name
    ),
    
    fn CollectMissingFiles =
    (
        local out = #()
        EnumerateFiles this.Get_Names out #missing
        out
    ),
    
    fn GetMapLoaderByName mapName mapLoaderArr:unsupplied =
    (
        if mapLoaderArr == unsupplied then mapLoaderArr = ( this.GetMapLoaders() )
        
        local arr = #()
        
        for map in mapLoaderArr do
        (
            if ( MatchPattern map.name pattern:mapName ) then append arr map
        )
        
        arr
    ),
    
    fn GetMapLoadersByFileName fName mapLoaderArr:unsupplied =
    (
        if ( mapLoaderArr == unsupplied ) then mapLoaderArr = ( This.GetMapLoaders() )
        
        local arr = #()
        
        for map in mapLoaderArr do
        (
            if not ( this.CheckFileName map ) then continue
            
            case ( classOf map ) of
            (
                (VrayHDRi):
                (
                    if ( MatchPattern map.HDRIMapName pattern:fName ) then append arr map
                )
                (BitmapTex):
                (
                    if ( MatchPattern map.fileName pattern:fName ) then append arr map
                )
            )
        )
        
        arr
    ),
    
    fn GetMapLoaderFileNames mapLoaderArr:unsupplied =
    (
        if ( mapLoaderArr == unsupplied ) then mapLoaderArr = ( This.GetMapLoaders() )
        
        local arr = #()
        
        for map in mapLoaderArr do
        (
            case ( classOf map ) of
            (
                (bitMapTexture):
                (
                    appendIfUnique arr map.fileName
                )
                (VRayHDRi):
                (
                    appendIfUnique arr map.HDRIMapName
                )
            )
        )
        
        arr
    ),
    
    fn GetUsedMaps =
    (
        local arr = UsedMaps()
        arr
    ),
    
    fn CollectRefs map =
    (
        local arr = refs.dependents map
        arr
    ),
    
    fn GetTexmapRes texFileName =
    (
        if ( DoesFileExist texFileName ) then
        (
            local bMapFile = OpenBitmap texFileName
            local resStr = ( ( bMapFile.width as string )+ "x" + ( bMapFile.height as string ) )
            format "***** %: % *****\n" ( GetFileNameFile texFileName ) ( ( bMapFile.width as string ) + " x " + ( bMapFile.height as string ) )
            close bMapFile
            resStr
        )
        else
        (
            undefined
        )
    ),
    
    fn RenameMapLoadersToFileName loaderArr:unsupplied =
    (
        if ( loaderArr == undefined ) then loaderArr = ( this.GetMapLoaders inst:False )
        
        for map in loaderArr do
        (
            if not ( MatchPattern map.name pattern:"Map #*" ) then continue
            
            case ( classOf map ) of
            (
                (BitmapTexture):
                (
                    map.name = ( GetFileNameFile map.fileName )
                )
                (VrayHDRi):
                (
                    map.name = ( GetFileNameFile map.HDRIMapName )
                )
            )
        )
    ),
    
    fn ViewMap mapLoader =
    (
        local fName = undefined
        
        case (classOf mapLoader) of
        (
            (VrayHDRi):
            (
                fName = mapLoader.HDRiMapName
            )
            (BitmapTex):
            (
                fName = mapLoader.fileName
            )
        )
        
        local bm = bitmapTex fileName:fName
        
        MatEditor.Mode = #basic
        meditMaterials[24] = Standard()
        ActiveMeditSlot = 24
        MeditMaterials[24] = bm
        MatEditor.Open()
        
        bm.viewImage()
    ),
    
    fn MenuBar =
    (
        rcmenu rcm_uiBar
        (
            local self
            
            subMenu "Tools"
            (
                menuItem itm_getDups "Assess Duplicate Loaders"
                menuItem itm_instance "Instance Loaders"
                
                separator sep_mb_1a
                
                menuItem itm_removeMissing "Remove Unresolved Loaders"
                menuItem itm_mapNames "Rename Map Loaders"
            )
            
            on itm_getDups picked do
            (
                --self.ro.dNtab_show.selectedIndex = 1
                local colAr = #()
                append colAr #(#Text,"Map Name",True,#left)
                append colAr #(#Text, "Dups",True,#center)
                append colAr #(#Text, "Filename",True,#left)
                append colAr #(#Text,"Format",True,#center)
                
                ::_dotNet.initDgv self.ro.dgv_data 10 colAr
                
                if not self.mapInstancer then
                (
                    self.GetMapLoaders inst:True
                    self.mapInstancer = True
                )
                
                self.ro.drawData self.ro.dgv_data self.mapLoaderArr nested:True
                
                itm_instance.enabled = True
            )
            
            on itm_instance picked do
            (
                self.instanceLoaders data:self.mapLoaderArr
                self.GetMapLoaders inst:True
                self.ro.drawData self.ro.dgv_data self.mapLoaderArr nested:True
            )
            
            on itm_removeMissing picked do
            (
                clearListener()
                self.collectMaterials()
                for i in self.materialList do
                (
                    self.removeImageLoadersWithMissingFiles i
                )
                format "***** % files removed *****\n" self.missingFileCount
                self.ro.refreshDataGrid self.ro.dgv_data
            )
            
            on itm_mapNames picked do
            (
                if queryBox "This will rename all map loaders to the filename they are loading.\n\nContinue?" title:"Map Instancer" then
                (
                    self.RenameMapLoadersToFileName loaderArr:self.mapLoaderArr
                    self.ro.RefreshDataGrid self.ro.dgv_data
                )
            )
            
            fn _init pself =
            (
                self = pself
                itm_instance.enabled = False
            )
        )
        
        rcm_uiBar
    ),
    
    fn Ui =
    (
        rollout ro "Map Helper" width:850
        (
            local self
            local tab = 1
            local uiDic
            local initSize
            local rcm_UI
            local tHeight = 12
            local jpgClr = (dotnetClass "System.Drawing.Color").lightGreen
            local exrClr = (dotnetClass "System.Drawing.Color").SkyBlue
            local defClr = (dotnetClass "System.Drawing.Color").plum
            local missingClr = (dotnetClass "System.Drawing.Color").tomato
            local bmpClr = (dotnetClass "System.Drawing.Color").dodgerblue
            local pngClr = (dotnetClass "System.Drawing.Color").fromARGB 252 145 27
            local tgaClr = (dotnetClass "System.Drawing.Color").fromARGB 155 250 58
            local txClr = (dotnetClass "System.Drawing.Color").lime
            local psdClr = (dotnetClass "System.Drawing.Color").yellow
            
            checkBox chk_sMapName "Search By Map Name" across:2
            checkBox chk_sFileName "Search By Filename" checked:True offset:[-250,0]
            dotNetControl dNtxt_search "Textbox" height:20
            dotNetControl dNlbl_stats "Label" width:200 height:20 offset:[0,10]
            dotNetControl dgv_data "DataGridView" align:#left  height:400
            
            fn UpdatedStats =
            (
                dNlbl_stats.text = ( "Map loaders in scene:  " + ( self.mapLoaderArr.count as string ) )
            )
            
            fn DrawData dgv dataArr nested:False =
            (
                dgv.rows.clear()
                
                local drawProgress = ::WpfProgressBar caption:"Drawing Data" steps:dataArr.count
                drawProgress.Start()
                
                for a in dataArr do
                (
                    local tempRow = ( dotNetObject "System.Windows.Forms.DataGridViewRow" )
                    
                    dgv.rows.add tempRow
                    
                    local bMap = undefined
                    
                    case nested of
                    (
                        (True):
                        (
                            bMap = a[1]
                        )
                        default:
                        (
                            bMap = a
                        )
                    )
                    
                    local mFileName = ( self.GetMapLoaderFileName bMap )
                    local type = try( tolower ( GetFileNameType mFileName ) )catch( "<NA>" )
                    local exists = if type != "<NA>" then ( DoesFileExist mFileName ) else False
                    local count = ( if nested then a.count-1 else "?" )
                    
                    tempRow.SetValues #( bMap.name, count, mFileName, type, ( classOf bMap as string ) )
                        
                    if exists then
                    (
                        case type of
                        (
                            ".jpg":
                            (
                                tempRow.DefaultCellStyle.ForeColor = jpgClr
                            )
                            ".exr":
                            (
                                tempRow.DefaultCellStyle.ForeColor = exrClr
                            )
                            ".png":
                            (
                                tempRow.DefaultCellStyle.ForeColor = pngClr
                            )
                            ".bmp":
                            (
                                tempRow.DefaultCellStyle.ForeColor = bmpClr
                            )
                            ".psd":
                            (
                                tempRow.DefaultCellStyle.ForeColor = psdClr
                            )
                            ".tx":
                            (
                                tempRow.DefaultCellStyle.ForeColor = txClr
                            )
                            ".tga":
                            (
                                tempRow.DefaultCellStyle.ForeColor = tgaClr
                            )
                            default:
                            (
                                tempRow.DefaultCellStyle.ForeColor = defClr
                            )
                        )
                    )
                    else
                    (
                        tempRow.DefaultCellStyle.ForeColor = missingClr
                    )
                    
                    drawProgress.Step()
                )
                
                for c = 0 to (dgv.columns.count-1) do
                (
                    case c of
                    (
                        2:
                        (
                            dgv.columns.item[c].autoSizeMode = dgv.columns.item[c].autoSizeMode.fill
                        )
                        default:
                        (
                            dgv.columns.item[c].autoSizeMode = dgv.columns.item[c].autoSizeMode.DisplayedCells
                        )
                    )
                )
                
                dgv.sort dgv.columns.item[(dgv.columns.count-2)] (dotNetClass "System.ComponentModel.ListSortDirection").ascending
                dgv.clearSelection()
                drawProgress.End()
                UpdatedStats()
                dgv.update()
            )
            
            fn RefreshDataGrid dgv pForce:False =
            (
                local colArr = #()
                append colArr #(#Text,"Map Name",True,#left)
                append colArr #(#Text, "Dups",True,#center)
                append colArr #(#Text, "Filename",True,#left)
                append colArr #(#Text,"Format",True,#center)
                append colArr #(#Text,"Loader Type",True,#center)
                
                ::_dotNet.initDgv dgv 10 colArr
                
                if self.mapLoaderArr.count == 0 or pForce then
                (
                    self.GetMapLoaders()
                )
                
                drawData dgv self.mapLoaderArr nested:self.mapInstancer
            )
            
            fn GetDgvCellValue dgv rowIndex cellIndex =
            (
                out = dgv.rows.item[rowIndex].cells.item[cellIndex].value
                out
            )
            
            fn UiMenu =
            (
                rcmenu rcm_UI
                (
                    local self
                    
                    menuItem itm_viewSelected "View Image"
                    separator sep_1a
                    menuItem itm_putToMedit "Put To Medit"
                    separator sep_1b
                    menuItem itm_removeSel "Destroy Selected"
                    separator sep_1c
                    --menuItem itm_getStats "Show File Stats"
                    
                    on itm_viewSelected picked do
                    (
                        selRows = dgv_data.selectedRows
                        if selRows.count != 1 then return messageBox "This only works on single row selection" title:"GTVFX:"
                        fileName = selRows.item[0].cells.item[2].value
                        if doesFileExist fileName then
                        (
                            bMap = (self.GetMapLoadersByFileName fileName)[1]
                            if bMap != undefined then
                            (
                                self.ViewMap bMap
                            )
                            else
                            (
                                messageBox "Could not find map loader..." title:"GTVFX:"
                            )
                        )
                        else
                        (
                            messageBox "File does not exist..." title:"GTVFX:"
                        )
                    )
                    
                    on itm_putToMedit picked do
                    (
                        selRows = dgv_data.selectedRows
                        if selRows.count != 1 then return messageBox "This only works on single row selection" title:"GTVFX:"
                        mapName = selRows.item[0].cells.item[0].value
                        bMap = (self.getMapLoaderByName mapName)[1]
                        if bMap != undefined then
                        (
                            meditMaterials[activeMeditSlot] = bMap
                        )
                        else
                        (
                            messageBox "Could not find map loader..." title:"GTVFX:"
                        )
                    )
                    
                    on itm_removeSel picked do
                    (
                        selRows = dgv_data.selectedRows
                        progressStart "Removing maps:"
                        perc = (100.0 / (selRows.count))
                        percentu = perc
                        for i = 0 to (selRows.count-1) do
                        (
                            loaderName = selRows.item[i].cells.item[0].value
                            bMaps = self.getMapLoaderByName loaderName
                            for bMap in bMaps do
                            (
                                self.removeBitmapSubs bMap
                            )
                            progressUpdate percentu
                            percentu += perc
                        )
                        progressEnd()
                        self.ro.refreshDataGrid self.ro.dgv_data pForce:True
                    )
                    
                    fn _init pself =
                    (
                        self = pself
                    )
                )
                
                rcm_UI
            )
            
            fn _init pself =
            (
                self = pself
                ::_dotNet.initTxtBx dNtxt_search "Search" 12 tooltip:"Filter rows\nDouble-Click to clear contents"
                ::_dotNet.initDnetLbl dNlbl_stats "Map loaders in scene:" 9 fontStyle:#regular foreColor:( ( dotnetClass "System.Drawing.Color" ).fromARGB 255 127.5 0 )
                
                if ( self.mapLoaderArr == undefined ) then self.mapLoaderArr = self.GetMapLoaders()
                
                RefreshDataGrid dgv_data
            )
            
            fn ResizeUI val =
            (
                local dif = ( val - initSize )
                local offMult = 1
                local c = undefined
                
                c = ::_dotNet.GetControlByName ro "dNtxt_search"
                c.width = ( uiDic.item["dNtxt_search"].item["width"] + dif.x )
                c = ::_dotNet.GetControlByName ro "dgv_data"
                c.width = ( uiDic.item["dgv_data"].item["width"] + dif.x )
                c.height = ( uiDic.item["dgv_data"].item["height"] + ( dif.y*offMult ) )
            )
            
            on chk_sMapName changed state do
            (
                chk_sFileName.state = not state
            )
            
            on chk_sFileName changed state do
            (
                chk_sMapName.state = not state
            )
            
            on dgv_data mouseDown arg do
            (
                if arg.button == dgv_data.mouseButtons.right then
                (
                    popUpMenu (uiMenu()) pos:mouse.screenPos
                    rcm_UI._init self
                )
            )
            
            on dNtxt_search keyUp arg do
            (
                local indx = 2
                if chk_sMapName.state then indx = 0
                ::_dotNet.FilterDataGridRows dgv_data dNtxt_search.text cellIndex:indx
            )
            
            on dNtxt_search MouseDoubleClick arg do
            (
                dNtxt_search.text = ""
                for i in 0 to dgv_data.rows.count-1 do
                (
                    dgv_data.rows.item[i].visible = true
                )
            )
            
            on dNtxt_search MouseClick arg do
            (
                if dNtxt_search.text == "Search" then dNtxt_search.text = ""
            )
            
            on ro open do
            (
                initSize = [ro.width,ro.height]
                uiDic = ::_dotNet.GetUiControlDic ro
            )
            
            on ro close do
            (
                if self.storedMaterial != undefined then meditMaterials[24] = self.storedMaterial
            )
            
            on ro help do
            (
                format "***** Coming Soon *****\n"
            )
            
            on ro resized val do
            (
                resizeUI val
            )
        )
        
        createDialog this.ro menu:(this.menuBar()) style:#(#style_titlebar, #style_resizing, #style_sunkenedge, #style_sysmenu, #style_minimizebox, #style_maximizebox)
        this.ro._init this
        this.rcm_uiBar._init this
    ),
    
    fn Run =
    (
        this.Ui()
    ),
    
    fn GetModule =
    (
        ( GetThisScriptFileName() )
    ),
    
    fn Help =
    (
        ::mxs.GetScriptHelp ( GetThisScriptFileName() )
    ),
    
    private fn __init__ =
    (
        if this.showUi then
        (
            this.Run()
        )
    ),
    
    init = __init__()
)

MapHelper = MapHelper()
