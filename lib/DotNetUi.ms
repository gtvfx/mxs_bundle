

struct DotNetUi
(
	dnTooltip,
	clrWindow = ( ( colorMan.getColor #window )*255 ),
	clrText = ( ( colorMan.getColor #text )*255 ),
	ClrBackGround = ( ( colorMan.getColor #background )*255 ),
	clr_skyblue = ( dotnetClass "System.Drawing.Color" ).SkyBlue,
	
	fn NormalizeRGB val =
	(
		if val < 0 then val = 0 else if val > 255 then val = 255
		val
	),
	
	fn InitToolTip dNetObj caption =
	(
		if this.dnTooltip == undefined then
		(
			this.dnToolTip = dotnetobject "ToolTip"
			this.dnToolTip.AutoPopDelay = 5000
			this.dnToolTip.InitialDelay = 300
			this.dnToolTip.ReshowDelay = 300
			this.dnToolTip.ShowAlways = true
			this.dnToolTip.IsBalloon = true
		)
		this.dnToolTip.SetToolTip dNetObj caption
	),
	
	fn DestroyToolTip =
	(
		this.dnToolTip
		if this.dnToolTip != undefined then
		(
			this.dnToolTip.RemoveAll()
			this.dnToolTip.Dispose()
			this.dnToolTip = undefined
		)
		True
	),
	
	fn SetDotNetWidget dNobj caption fontSize colorOffsetInt:0 fontStyle:#bold foreColor:unsupplied =
	(
		local fStyle = case fontStyle of
		(
			(#bold):
			(
				((dotNetClass "System.Drawing.FontStyle").bold)
			)
			(#italic):
			(
				((dotNetClass "System.Drawing.FontStyle").italic)
			)
			(#regular):
			(
				((dotNetClass "System.Drawing.FontStyle").regular)
			)
		)
		dNobj.text = caption
		if foreColor == unsupplied then dNobj.forecolor = dNobj.forecolor.FromArgb clrText.x clrText.y clrText.z else dNobj.forecolor = foreColor
		dNobj.backColor = dNobj.backcolor.FromArgb (this.NormalizeRGB (ClrBackGround.x+colorOffsetInt)) (this.NormalizeRGB (ClrBackGround.y+colorOffsetInt)) (this.NormalizeRGB (ClrBackGround.z+colorOffsetInt))
		dNobj.Font = dotNetObject "System.Drawing.Font" "Tahoma" fontSize fStyle
		dNobj.update()
	),
	
	fn ChangeTxtBoxColor txtBox newcolor =
	(
		txtBox.forecolor = ( this.NormalizeRGB newcolor )
	),
	
	fn SetDataGridColor dgv fontSize _forecolor:  =
	(
		if _forecolor == unsupplied or not ( ClassOf _forecolor == dotNetObject ) then
		(
			dgv.forecolor = dgv.forecolor.FromArgb clrText.x clrText.y clrText.z
		)
		else
		(
			dgv.forecolor = _forecolor
		)
		
		dgv.BackgroundColor = dgv.BackgroundColor.FromArgb this.clrWindow.x this.clrWindow.y this.clrWindow.z
		dgv.DefaultCellStyle.BackColor = dgv.backcolor.FromArgb this.clrWindow.x this.clrWindow.y this.clrWindow.z
		dgv.Font = dotNetObject "System.Drawing.Font" "Calibri" fontSize ((dotNetClass "System.Drawing.FontStyle").bold)
		try(dgv.AlternatingRowsDefaultCellStyle.BackColor = dgv.AlternatingRowsDefaultCellStyle.BackColor.FromArgb (this.clrWindow.x-15) (this.clrWindow.y-15) (this.clrWindow.z-15))catch()
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
		this.setDotNetWidget dNrdo caption fontSize
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
		tbx.backcolor = tbx.backcolor.FromArgb clrWindow.x clrWindow.y clrWindow.z
		tbx.forecolor = tbx.forecolor.FromArgb clrText.x clrText.y clrText.z
		tbx.text = caption
		tbx.Font = dotNetObject "System.Drawing.Font" "Calibri" fontSize ((dotNetClass "System.Drawing.FontStyle").bold)
		tbx.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle
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
	
	fn ChangeDgvCellColor dgvCell color =
	(
		local newStyle = dotNetObject "System.Windows.Forms.DataGridViewCellStyle"
		newStyle.foreColor = color
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
	
	fn FilterDataGridRows dgv filterTxt cellIndex:0 = -- function for the search feature
	(
		if filterTxt == "" or filterTxt == "Search" then
		(
			for i in 0 to dgv.rows.count-1 do
			(
				dgv.rows.item[i].visible = true
			)
		)
		else
		(
			for i in 0 to dgv.rows.count-1 do
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
	
	fn InitDgv dgv fontsize colAr multiSelct:True _forecolor: =
	(
		dgv.Columns.Clear()
		dgv.MultiSelect = multiSelct
		dgv.AllowUserToAddRows = off
		dgv.AutoSize = on
		dgv.AutoSizeColumnsMode = dgv.AutoSizeColumnsMode.Fill
		dgv.ShowEditingIcon = dgv.RowHeadersVisible = off
		dnSelectionMode = dotNetClass "System.Windows.Forms.DataGridViewSelectionMode"
		dgv.SelectionMode = dnSelectionMode.FullRowSelect
		dgv.AllowUserToResizeRows = False
		dgv.AllowUserToOrderColumns = False
		dgv.AllowUserToResizeColumns = True
		dgv.ColumnHeadersHeightSizeMode = dgv.ColumnHeadersHeightSizeMode.DisableResizing
		
		for col in colAr do
		(
			dnNewColumn
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
						dnNewColumn.image = (dotNetClass "System.Drawing.Bitmap").fromFile col[5]
					)
				)
				(#Combo):dnNewColumn = dotNetObject "System.Windows.Forms.DataGridViewComboBoxColumn"
			)
			
			dnNewColumn.name = col[2]
			dnNewColumn.HeaderText = col[2]
			dnNewColumn.ReadOnly = col[3]
			dnAlignment = dotNetClass "System.Windows.Forms.DataGridViewContentAlignment"
			
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
	
	
	private fn _init =
	(
		format "
---------------
CLASS USAGE: DotNetUi

instantiated global: _dotNet
---------------\n"
	),

	__init__ = _init()
)

_dotNet = DotNetUi()