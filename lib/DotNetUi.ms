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

Constructor: DotNetUi
Instantiated Global: DotNetUi

Methods:



__END__
*/



struct DotNetUi
(
public
	
	dnTooltip,
    ----------------------------
	clrWindow = ( ( colorMan.getColor #window )*255 ),
	clrText = ( ( colorMan.getColor #text )*255 ),
	clrBackground = ( ( colorMan.getColor #background )*255 ),
    
    clrWindow_dnet,
    clrText_dnet,
    clrBackground_dnet,
    ----------------------------
	clr_skyblue = ( dotnetClass "System.Drawing.Color" ).SkyBlue,
	
    fn NormalizeRGB val =
	(
		if val < 0 then val = 0 else if val > 255 then val = 255
		val
	),
    
    fn RgbToDnetColor rgbColor =
    (
        try
        (
            rgbColor = rgbColor as color
        )
        catch
        (
            return ( format "***** Undable to convert % to color *****\n" )
        )
        
        (dotNetClass "System.Drawing.Color").fromARGB ( this.NormalizeRGB rgbColor.a ) ( this.NormalizeRGB rgbColor.r ) ( this.NormalizeRGB rgbColor.g) ( this.NormalizeRGB rgbColor.b )
    ),
    
    fn OffsetDnetColorValue dnetColor offsetVal =
    (
        local p3 = [dnetColor.r, dnetColor.g, dnetColor.b]
        
        this.RgbToDnetColor ( p3 + offsetVal )
    ),
	
	fn InitToolTip dNetObj caption =
	(
        try( this.dnTooltip.Dispose() )catch()
        		
        this.dnToolTip = dotnetobject "ToolTip"
        this.dnToolTip.AutoPopDelay = 5000
        this.dnToolTip.InitialDelay = 300
        this.dnToolTip.ReshowDelay = 300
        this.dnToolTip.ShowAlways = true
        this.dnToolTip.IsBalloon = true
		
		this.dnToolTip.SetToolTip dNetObj caption
	),
	
	fn DestroyToolTip =
	(
		if this.dnToolTip != undefined then
		(
			this.dnToolTip.RemoveAll()
			this.dnToolTip.Dispose()
			this.dnToolTip = Undefined
		)
	),
	
	fn SetDotNetWidget dNobj caption fontSize colorOffsetInt:0 fontStyle:#bold foreColor:unsupplied =
	(
        if foreColor != unsupplied and ( ClassOf foreColor ) == Color then
        (
            foreColor = this.RgbToDnetColor foreColor
        )
        
		local fStyle = case fontStyle of
		(
			(#bold):
			(
				( ( dotNetClass "System.Drawing.FontStyle" ).bold )
			)
			(#italic):
			(
				( ( dotNetClass "System.Drawing.FontStyle" ).italic )
			)
			(#regular):
			(
				( ( dotNetClass "System.Drawing.FontStyle" ).regular )
			)
		)
		dNobj.text = caption
		if foreColor == unsupplied then dNobj.forecolor = this.clrText_dnet else dNobj.forecolor = foreColor
		--dNobj.backColor = dNobj.backcolor.FromArgb ( this.NormalizeRGB ( this.clrBackground.x + colorOffsetInt ) ) ( this.NormalizeRGB ( this.clrBackground.y + colorOffsetInt ) ) ( this.NormalizeRGB ( this.clrBackground.z + colorOffsetInt ) )
		dNobj.backColor = ( this.OffsetDnetColorValue this.clrBackground_dnet colorOffsetInt )
        
        dNobj.Font = ( dotNetObject "System.Drawing.Font" "Tahoma" fontSize fStyle )
		dNobj.update()
	),
	
	fn ChangeTxtBoxColor txtBox newcolor =
	(
        if ( ClassOf newcolor ) == Color then
        (
            newcolor = this.RgbToDnetColor newcolor
        )
        
		txtBox.forecolor = newcolor
	),
	
	fn SetDataGridColor dgv fontSize _forecolor:  =
	(
		if _forecolor != unsupplied and ( ClassOf _forecolor == Color ) then
		(
			_foreColor = this.RgbToDnetColor _foreColor
		)
		
        if _foreColor == unsupplied then
		(
			_foreColor = this.clrText_dnet
		)
        
        try( dgv.forecolor = _foreColor )catch()
        try( dgv.BackgroundColor = this.clrWindow_dnet )catch()
		try( dgv.DefaultCellStyle.BackColor = this.clrWindow_dnet )catch()
		try( dgv.AlternatingRowsDefaultCellStyle.BackColor = ( this.OffsetDnetColorValue this.clrWindow_dnet -15 ) )catch()
        try( dgv.Font = dotNetObject "System.Drawing.Font" "Calibri" fontSize ( (dotNetClass "System.Drawing.FontStyle" ).bold ) )catch()
	),
	
	fn InitTabs dNtab tabArr =
	(
		dNtab.controls.clear()
		this.SetDotNetWidget dNtab "" 11 colorOffsetInt:10
		for tab in tabArr do
		(
			local tP = dotNetObject "System.Windows.Forms.TabPage"
            tP.name = tab
			this.SetDotNetWidget tP tab 11 colorOffsetInt:10
			dNtab.controls.add tP
		)
		dNtab.update()
	),
	
	fn initDnetRdo dNrdo caption fontsize useAsButton:false tooltip:"" =
	(
		if useAsButton then
		(
			dNrdo.appearance = dNrdo.appearance.button
			dNrdo.flatstyle = dNrdo.flatstyle.Flat
			dNrdo.textAlign = ( dotNetClass "System.Drawing.ContentAlignment" ).middleCenter
			dNrdo.FlatAppearance.CheckedBackColor = ( dotnetClass "System.Drawing.Color" ).dodgerBlue
			--dNrdo.FlatAppearance.MouseOverBackColor = (dotnetClass "System.Drawing.Color").red
		)
		else
		(
			dNrdo.appearance = dNrdo.appearance.normal
		)
        
		this.SetDotNetWidget dNrdo caption fontSize
		dNrdo.tag = tooltip
		dNrdo.Update()
	),
	
	fn InitDnetBtn dNbtn caption fontSize style:#popup colorOffsetInt:0 tooltip:"" =
	(
		case style of
		(
			#flat:(dNbtn.flatStyle = dNbtn.flatStyle.flat)
			#popup:(dNbtn.flatStyle = dNbtn.flatStyle.popup)
			#system:(dNbtn.flatStyle = dNbtn.flatStyle.system)
		)
        
		this.SetDotNetWidget dNbtn caption fontSize colorOffsetInt:colorOffsetInt
		dNbtn.tag = tooltip
		dNbtn.Update()
	),
	
	fn InitTxtBx tbx caption fontSize tooltip:"" =
	(
		tbx.backcolor = this.clrWindow_dnet
		tbx.forecolor = this.clrText_dnet
		tbx.text = caption
		tbx.Font = dotNetObject "System.Drawing.Font" "Calibri" fontSize ( ( dotNetClass "System.Drawing.FontStyle" ).bold )
		tbx.BorderStyle = ( dotNetClass "System.Windows.Forms.BorderStyle" ).FixedSingle
		tbx.MultiLine = false
		tbx.AcceptsReturn = false
		tbx.AcceptsTab = false
		tbx.WordWrap = false
		tbx.tag = tooltip
		tbx.update()
	),
	
	fn InitDnetLbl lbl caption fontsize fontStyle:#bold foreColor:unsupplied =
	(
		this.SetDotNetWidget lbl caption fontSize fontStyle:fontStyle foreColor:foreColor
	),
	
	fn ChangeDgvCellColor dgvCell _color =
	(
        if ( ClassOf _color ) == Color or ( ClassOf _color ) == Point3 then
        (
            _color = this.RgbToDnetColor _color
        )
        
		local newStyle = dotNetObject "System.Windows.Forms.DataGridViewCellStyle"
		newStyle.foreColor = _color
		dgvCell.Style = newStyle
	),
	
	fn UpdateDgvOpt dgvCell dataArr setItem: =
	(
		dgvCell.items.clear()
        
		for i in dataArr do dgvCell.items.add i
            
		dgvCell.value = dataArr[1]
        
		if setItem != unsupplied then
		(
            if ( ClassOf setItem != Array ) then setItem = #( setItem )
            
            for item in setItem do
            (
                if ( findItem dataArr item ) != 0 then
                (
                    dgvCell.value = item
                    exit
                )
            )
		)
	),
	
	fn ToggleDgvRowDisplay dgv visible:True =
	(
		for i = 0 to dgv.rows.count-1 do
		(
			dgv.rows.item[i].visible = visible
		)
	),
	
	fn FilterDataGridRows dgv filterTxt cellIndex:1 = -- function for the search feature
	(
		if filterTxt == "" or filterTxt == "Search" then
		(
			for i = 0 to dgv.rows.count-1 do
			(
				dgv.rows.item[i].visible = true
			)
		)
		else
		(
			for i = 0 to dgv.rows.count-1 do
			(
				if not matchPattern dgv.rows.item[i].cells.item[cellIndex].value pattern:("*"+filterTxt+"*") then
				(
					dgv.rows.item[i].visible = false
				)
				else
				(
					dgv.rows.item[i].visible = true
				)
			)
		)
	),
    
    fn ResizeImage DotNetBitmap width: height: =
    (
        if width == unsupplied or height == unsupplied then
        (
            throw "ResizeImage requires valid integer values for the 'width' and 'height' parameters."
        )
        
        --local imgBits = DotNetBitmap.PixelFormat
        
        local outImg = ( dotnetobject "System.Drawing.Bitmap" width height ) --imgBits
        local graphic =  ( dotnetclass "System.Drawing.Graphics" ).fromImage outImg
        
        graphic.CompositingQuality = graphic.CompositingQuality.HighQuality
        graphic.SmoothingMode = graphic.SmoothingMode.HighQuality
        graphic.InterpolationMode = graphic.InterpolationMode.HighQualityBicubic	
        
        local rect = dotnetobject "System.Drawing.Rectangle" 0 0 width height
        graphic.DrawImage DotNetBitmap rect
        
        local out = Copy outImg
        
        outImg.Dispose()
        graphic.Dispose()
        DotNetBitmap.Dispose()
        GC quiet:True
        
        out
    ),
    
    fn DisplayImage filePath =
    (
        local image = ( dotNetClass "System.Drawing.Bitmap" ).fromFile filePath
        
        --local pformat = image.PixelFormat
        local width = image.Width
        local height = image.Height
        
        local dest = dotnetobject "System.Drawing.Bitmap" width height --pformat
        local graphic = (dotnetclass "System.Drawing.Graphics").fromImage dest
        
        graphic.CompositingQuality = graphic.CompositingQuality.HighQuality
        graphic.SmoothingMode = graphic.SmoothingMode.HighQuality
        graphic.InterpolationMode = graphic.InterpolationMode.HighQualityBicubic
        
        local rect = dotnetobject "System.Drawing.Rectangle" 0 0 width height
        graphic.DrawImage image rect
        
        local clipboard = dotnetclass "Clipboard"
        clipboard.SetImage dest
        
        image.Dispose()
        dest.Dispose()
        graphic.Dispose()
        
        local cBitmap = GetclipboardBitmap()
        
        if cBitmap != undefined then
        (
            Display cBitmap
        )
    ),
	
	fn InitDgv dgv fontsize colAr multiSelct:True _forecolor: AllowUserToAddRows:False =
	(
        -- Example Col:
        -- #(#Icon,"OPT:",True,#center,optIcon)
        
		dgv.Columns.Clear()
        dgv.ShowCellToolTips = False
		dgv.MultiSelect = multiSelct
		dgv.AllowUserToAddRows = AllowUserToAddRows
		dgv.AutoSize = True
		dgv.AutoSizeColumnsMode = dgv.AutoSizeColumnsMode.Fill
		dgv.ShowEditingIcon = dgv.RowHeadersVisible = False
		local dnSelectionMode = dotNetClass "System.Windows.Forms.DataGridViewSelectionMode"
		dgv.SelectionMode = dnSelectionMode.FullRowSelect
		dgv.AllowUserToResizeRows = False
		dgv.AllowUserToOrderColumns = False
		dgv.AllowUserToResizeColumns = True
		dgv.ColumnHeadersHeightSizeMode = dgv.ColumnHeadersHeightSizeMode.DisableResizing
		
		for col in colAr do
		(
			local dnNewColumn
            
			case col[1] of
			(
				(#Text):dnNewColumn = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
				(#Bool):dnNewColumn = dotNetObject "System.Windows.Forms.DataGridViewCheckBoxColumn"
				(#Icon):
				(
					dnNewColumn = dotNetObject "System.Windows.Forms.DataGridViewImageColumn"
					-- Need to pass an image
					if  col[5] != undefined and (DoesFileExist col[5]) then
					(
                        local sourceImg = (dotNetClass "System.Drawing.Bitmap").fromFile col[5]
                        
						dnNewColumn.image = ( this.ResizeImage sourceImg width:48 height:48 )
					)
				)
				(#Combo):dnNewColumn = dotNetObject "System.Windows.Forms.DataGridViewComboBoxColumn"
			)
			
			dnNewColumn.name = col[2]
			dnNewColumn.HeaderText = col[2]
			dnNewColumn.ReadOnly = col[3]
			local dnAlignment = dotNetClass "System.Windows.Forms.DataGridViewContentAlignment"
			
			case col[4] of
			(
				#Right:		dnNewColumn.DefaultCellStyle.Alignment = dnAlignment.MiddleRight
				#Center:	dnNewColumn.DefaultCellStyle.Alignment = dnAlignment.MiddleCenter
				#Left:		dnNewColumn.DefaultCellStyle.Alignment = dnAlignment.MiddleLeft
				default:	dnNewColumn.DefaultCellStyle.Alignment = dnAlignment.MiddleLeft
			)
			dgv.columns.add dnNewColumn
		)
		
		this.SetDataGridColor dgv fontSize _forecolor:_forecolor
		
		for c = 0 to (colAr.count-1) do
		(
			dgv.columns.item[c].sortMode = (dotNetClass "System.Windows.Forms.DataGridViewColumnSortMode").automatic
		)
		
		dgv.update()
	),
	
	fn initTreeview trv fontsize:10 forecolor:( this.RgbToDnetColor this.clrText ) =
	(
		-- looking into this tv ops struct? not sure if its a maxsript lib that autodesk uses for their tool dev...
		
		::tvops.InitTreeView trv pFullRowSel:true pAllowDrop:true
	
		-- tvops.InitImageList tv imgFiles pSize:16 pTransparentColor:transparency 
		-----------------------------------------
		--trv.drawMode = trv.drawmode.OwnerDrawText
		--trv.imageList = IL
		trv.showLines = true
		trv.showPlusMinus = true
		trv.scrollable = true
		trv.sorted = false
		trv.labelEdit = false
		trv.hideSelection = false
		trv.fullRowSelect = true
		--------------
		trv.checkBoxes = true
		trv.backcolor = this.RgbToDnetColor this.clrWindow
		trv.forecolor = forecolor
		
		trv.font = dotnetobject "System.Drawing.Font" "Tahoma" fontsize (dotnetclass"System.Drawing.FontStyle").bold
		
		trv.update()
	),
    
    fn GetComboBoxItems dgvCell =
    (
        local out = #()
        if ( isProperty dgvCell #items ) then
        (
            for i = 0 to ( dgvCell.items.count-1 ) do
            (
                append out dgvCell.items.item[i]
            )
        )
        out
    ),
	
	fn GetColIndex dgv _name =
	( -- Requires the name property of the column to be set during dgv_init
		-- Putting into a TryCatch to ensure that it returns a logical value instead of crashing
		try(dgv.columns.item[_name].index)catch(undefined)
	),
    
    fn GetTabIndex tab _name =
    ( -- Requires the name property of the tab to be set during InitTabs
        -- Putting into a TryCatch to ensure that it returns a logical value instead of crashing
        try(tab.tabPages.item[_name].TabIndex)catch(undefined)
    ),
		
	fn GetUiControlName uiControl = 
	(
		local str = ( uiControl as string )
		local nameArr = (filterString str ":")
		local uiName = nameArr[2]
		if matchPattern nameArr[1] pattern:"Group*Control" then
		(
			local subName = SubstituteString nameArr[1] "Group" ""
			subName = SubstituteString subName "Control" ""
			
			uiName = ("Group_" + nameArr[2] + "_" + subName)
		)
		
		uiName
	),
	
	fn GetControlByName ui controlName =
	(
		local strPattern = ( "*:"+controlName+"*" )
		if matchPattern controlName pattern:"Group_*" then
		(
			local nameArr = filterString controlName "_"
			
			strPattern = ( "*"+nameArr[1]+nameArr[3]+"Control:"+nameArr[2]+"*" )
		)
		
		local out = (for i in ui.controls where matchPattern (i as string) pattern:strPattern collect i)[1]
		out
	),
	
	fn GetUiControlDic ui =
	(
		local dic = dotNetObject "System.Collections.Hashtable"
		local subDic = dotNetObject "System.Collections.Hashtable"
		subDic.add "width" ui.width
		subDic.add "height" ui.height
		dic.add "ui" subDic
		
		for c in ui.controls do
		(
			subDic = dotNetObject "System.Collections.Hashtable"
			if isproperty c #width then subDic.add "width" c.width
			if isproperty c #height then subDic.add "height" c.height
			subDic.add "pos.x" c.pos.x
			subDic.add "pos.y" c.pos.y
			dic.add (this.GetUiControlName c) subDic
		)
		dic
	),
    
    fn DicFromDataGrid dgv keyCellIndex:0 valueCellIndex:1 =
    (
        local dic = dotNetObject "System.Collections.Hashtable"
        
        for i = 0 to dgv.rows.count-1 do
        (
            if ( dgv.rows.item[i].cells.item[keyCellIndex].value != undefined ) and ( dgv.rows.item[i].cells.item[valueCellIndex].value != undefined ) then
            (
                dic.add dgv.rows.item[i].cells.item[keyCellIndex].value dgv.rows.item[i].cells.item[valueCellIndex].value
            )
        )
        
        dic
    ),
    
    fn GetModule =
    (
        ( GetThisScriptFileName() )
    ),
    
    fn Help =
    (
        ::mxs.GetScriptHelp ( GetThisScriptFileName() )
    ),
	
private
	
	fn __init__ =
	(
        this.clrWindow_dnet = this.RgbToDnetColor this.clrWindow 
        this.clrText_dnet = this.RgbToDnetColor this.clrText
        this.clrBackGround_dnet = this.RgbToDnetColor this.clrBackGround
	),

	init = __init__()
)

DotNetUi = DotNetUi()