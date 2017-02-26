try(destroyDialog ro_rndrElmnts)catch()
rollout ro_rndrElmnts "Copy / Paste Render Elements By GTVFX" width:550 height:550
(
	local elmntMgr = maxOps.GetCurRenderElementMgr()
	local numElmnts
	local elmntNameArr
	local elmntArr
	local copyElmntArr
	local dnTooltip
	local clrWindow = ((colorMan.getColor #window)*255)
	local clrText = ((colorMan.getColor #text)*255)
	local ClrBackGround = ((colorMan.getColor #background)*255)
	
	dotNetControl dgv_elmntList "System.Windows.Forms.DataGridView" align:#left width:(ro_rndrElmnts.width/2-30) height:(ro_rndrElmnts.height-120) across:2
	dotNetControl dgv_copy "System.Windows.Forms.DataGridView" align:#right width:(ro_rndrElmnts.width/2-30) height:(ro_rndrElmnts.height-120)
	dotNetControl dNbtn_copy "system.windows.forms.button" width:25 height:25 pos:[(ro_rndrElmnts.width/2-12),120]
	dotNetControl dNbtn_del "system.windows.forms.button" width:25 height:25 pos:[(ro_rndrElmnts.width/2-12),(dNbtn_copy.pos.y+50)]
	dotNetControl dNbtn_execute "system.windows.forms.button" width:(ro_rndrElmnts.width-40) height:40 pos:[(ro_rndrElmnts.width/2-ro_rndrElmnts.width/2+20),(ro_rndrElmnts.height-100)]
	dotNetControl dNbtn_paste "system.windows.forms.button" width:(ro_rndrElmnts.width-40) height:40 pos:[(ro_rndrElmnts.width/2-ro_rndrElmnts.width/2+20),(ro_rndrElmnts.height-50)]
	
	fn initToolTip dNetObj caption =
	(
		if dnTooltip == undefined then
		(
			dnToolTip = dotnetobject "ToolTip"
			dnToolTip.AutoPopDelay = 5000
			dnToolTip.InitialDelay = 300
			dnToolTip.ReshowDelay = 300
			dnToolTip.ShowAlways = true
			dnToolTip.IsBalloon = true
		)
		dnToolTip.SetToolTip dNetObj caption
	)
	fn setDotNetWidget dNobj caption fontSize colorOffsetInt:0 =
	(
		dNobj.text = caption
		dNobj.forecolor = dNobj.forecolor.FromArgb clrText.x clrText.y clrText.z
		dNobj.backColor = dNobj.backcolor.FromArgb (ClrBackGround.x+colorOffsetInt) (ClrBackGround.y+colorOffsetInt) (ClrBackGround.z+colorOffsetInt)
		dNobj.Font = dotNetObject "System.Drawing.Font" "Tahoma" fontSize ((dotNetClass "System.Drawing.FontStyle").bold)
	)
	fn initDnetChk dNchk caption fontsize tooltip:"" =
	(
		setDotNetWidget dNchk caption fontSize
		initToolTip dNchk tooltip
	)
	fn initDnetBtn dNbtn caption fontSize style:#popup colorOffsetInt:0 tooltip:"" = 
	(
		case style of
		(
			#flat:(dNbtn.flatStyle = dNbtn.flatStyle.flat)
			#popup:(dNbtn.flatStyle = dNbtn.flatStyle.popup)
			#system:(dNbtn.flatStyle = dNbtn.flatStyle.system)
		)
		setDotNetWidget dNbtn caption fontSize colorOffsetInt:colorOffsetInt
		initToolTip dNbtn tooltip
	)
	fn setDataGridColor dNObj fontSize =
	(
		dNObj.forecolor = dNObj.forecolor.FromArgb clrText.x clrText.y clrText.z
		dNObj.BackgroundColor = dNObj.BackgroundColor.FromArgb clrWindow.x clrWindow.y clrWindow.z
		dNObj.DefaultCellStyle.BackColor = dNObj.backcolor.FromArgb clrWindow.x clrWindow.y clrWindow.z
		dNObj.Font = dotNetObject "System.Drawing.Font" "Calibri" fontSize ((dotNetClass "System.Drawing.FontStyle").bold)
	)
	fn drawData dgv =
	(
		dgv.rows.clear()
		for a in elmntArr do
		(
			tempRow = dotNetObject "System.Windows.Forms.DataGridViewRow"
			dgv.rows.add tempRow
			classTxt = ((classOf a) as string)
			tempRow.SetValues #(a.elementName,classTxt)
			case classTxt of
			(
				"VRayLightSelect":
				(
					tempRow.DefaultCellStyle.ForeColor = (dotnetClass "System.Drawing.Color").fromARGB 237 244 89
				)
				"VRayExtraTex":
				(
					tempRow.DefaultCellStyle.ForeColor = (dotnetClass "System.Drawing.Color").paleturquoise
				)
				"MultiMatteElement":
				(
					tempRow.DefaultCellStyle.ForeColor = (dotnetClass "System.Drawing.Color").dodgerBlue
				)
				"VRaySamplerInfo":
				(
					tempRow.DefaultCellStyle.ForeColor = (dotnetClass "System.Drawing.Color").fromARGB 244 163 51
				)
			)
		)
	)
	fn collectElementData =
	(
		numElements = elmntMgr.numRenderElements()
		elmntArr = for i in 0 to numElements-1 collect (elmntMgr.GetRenderElement i)
		elmntNameArr = for i in elmntArr collect i.elementName
	)
	fn initDgv dgv caption =
	(
		--dgv.multiSelect = false
		dgv.AllowUserToAddRows = off
		dgv.AutoSize = on
		dgv.AutoSizeColumnsMode = dgv.AutoSizeColumnsMode.Fill
		dgv.ShowEditingIcon = dgv.RowHeadersVisible = off
		dnSelectionMode = dotNetClass "System.Windows.Forms.DataGridViewSelectionMode"
		dgv.SelectionMode = dnSelectionMode.FullRowSelect 
		dgv.AllowUserToResizeRows = false
		dgv.AllowUserToOrderColumns = false
		dgv.AllowUserToResizeColumns = false
		dgv.ColumnHeadersHeightSizeMode = dgv.ColumnHeadersHeightSizeMode.DisableResizing
		
		colAr = #()
		append colAr #(#text,caption,True,#left)
		--append colAr #(#text,"Class:",True,#left)
		
		for col in colAr do
		(
			dnNewColumn
			case col[1] of
			(
				(#Text):dnNewColumn = dotNetObject "System.Windows.Forms.DataGridViewTextBoxColumn"
				(#Bool):dnNewColumn = dotNetObject "System.Windows.Forms.DataGridViewCheckBoxColumn"
				default:dnNewColumn = dotNetObject "System.Windows.Forms.DataGridViewComboBoxColumn"
			)
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
		dgv.columns.item[0].width = dgv.width
		for i in 0 to dgv.columns.count-1 do
		(
			dgv.Columns.item[i].SortMode = (dotNetClass "System.Windows.Forms.DataGridViewColumnSortMode").NotSortable
		)
		setDataGridColor dgv 11
		dgv.AlternatingRowsDefaultCellStyle.BackColor = dgv.AlternatingRowsDefaultCellStyle.BackColor.FromArgb (clrWindow.x-15) (clrWindow.y-15) (clrWindow.z-15)
	)
	fn _init pself =
	(
		this = pself
		
		collectElementData()
		initDgv dgv_elmntList "Current Render Elements:"
		initDgv dgv_copy "Elements to Store:"
		initDnetBtn dNbtn_copy ">" 8
		initDnetBtn dNbtn_del "<" 8
		initDnetBtn dNbtn_execute "Copy Listed Elements" 8
		initDnetBtn dNbtn_paste "Paste Listed Elements" 8 
		drawData dgv_elmntList
	)
	
	
	on dNbtn_copy mouseClick do
	(
		selRows = dgv_elmntList.SelectedRows
		storedElmnts = #()
		for i in 0 to dgv_copy.rows.count-1 do
		(
			appendIfUnique storedElmnts dgv_copy.rows.item[i].cells.item[0].value
		)
		for i in 0 to selRows.count-1 do
		(
			elmntName = selRows.item[i].cells.item[0].value
			if findItem storedElmnts elmntName == 0 then
			(
				tempRow = selRows.item[i].clone()
				ro_rndrElmnts.dgv_copy.rows.add tempRow
				tempRow.SetValues #(elmntName)
			)
			else
			(
				format "***** Element % is already in the list *****\n" elmntName
			)
		)
	)
	
	on dNbtn_del mouseClick do
	(
		if dgv_copy.rows.count != 0 then
		(
			selRows = dgv_copy.SelectedRows
			for i in 0 to selRows.count-1 do
			(
				indx = selRows.item[i].index
				dgv_copy.rows.removeAt indx
			)
		)
		else
		(
			format "***** Nothing to remove *****\n"
		)
	)
	 on dNbtn_execute mouseClick arg do
	 (
		 format "***** Rows: % *****\n" dgv_copy.rows
		storedElmnts = #()
		 for i in 0 to dgv_copy.rows.count-1 do
		(
			appendIfUnique storedElmnts dgv_copy.rows.item[i].cells.item[0].value
		)
		format "***** Element List % *****\n" storedElmnts
		copyElmntArr = #()
		for i in elmntArr where findItem storedElmnts i.elementName != 0 do append copyElmntArr (copy i)
		format "***** Copying elements % *****\n" copyElmntArr
		
	 )
	 
	 
	 on dNbtn_paste mouseClick arg do
	 (
		for i in copyElmntArr do
		(
			elmntMgr.addrenderelement i
		)

	 )
)
createDialog ro_rndrElmnts
ro_rndrElmnts._init this

