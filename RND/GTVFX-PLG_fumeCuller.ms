plugin helper fumeCuller
name:"fumeCuller"
classID:#(0x31fcfbd3, 0x488710ea)
category:"GTVFX_Helpers"
extends:point
replaceUI:false
version:1.0
(
	fn camFilter obj = isKindOf obj camera
		
	fn addCustomAttrFromCamCull ctrlr =
	(
		ca = attributes "fumeCull"
		(
			parameters params 
			(
				cam type:#node 
				grids type:#nodeTab tabSizeVariable:True
				cacheFiles type:#filenameTab tabSizeVariable:True
				cacheTypes type:#stringTab tabSizeVariable:True
				on grids set args do
				(
					--format "***** Grids Set: % *****\n" grids
					cacheFiles = #()
					for i in this.grids do
					(
						if i != undefined then
						(
							cacheType = case i.SelectedCache of
							(
								0:(#Default)
								1:(#Wavelet)
								2:(#Post)
							)
							
							append cacheFiles (i.getPath cacheType)
							append cacheTypes cacheType
						)
					)
				)
			)
			fn toggleFumeCache iFGrid vis:true =
			(
				index = findItem this.grids iFGrid
				if vis then
				(
					iFGrid.setPath this.cacheFiles[index] this.cacheTypes[index]
				)
				else
				(
					iFGrid.setPath (getDir #temp) this.cacheTypes[index]
				)
			)
			fn infront cullPlanePos cullPlaneDir testObjPos =
			(
				if (dot cullPlaneDir (normalize(testObjPos-cullPlanePos)))>=0 then true else false
			)
			fn cullPlane grids cullPlanePos cullPlaneDir =
			(
				visObjs = #()
				for i in grids do
				(
					vis = false
					if this.infront cullPlanePos cullPlaneDir (i.max) then vis = true
					else if this.infront cullPlanePos cullPlaneDir (i.min) then vis = true
					else if this.infront cullPlanePos cullPlaneDir (i.center) then vis = true
					this.toggleFumeCache i vis:vis
				)
			)
			fn getCamDirs pickCam =
			(
				dirs = #()
				camTR = pickCam.objecttransform
				cullPlanePos = pickCam.transform.position  
				hFOV = pickCam.fov/2.0
				vFOV = atan(tan(hFOV)/((renderWidth as float)/renderHeight*renderPixelAspect))
				offset = 1000
				w = offset*(sin(hFOV)/sin(90-hFOV))
				h = offset*(sin(vFOV)/sin(90-vFOV))
				TL = ([-w,h,-offset]*CamTR)
				BR = ([w,-h,-offset]*CamTR)
				TR = ([w,h,-offset]*CamTR)
				BL = ([-w,-h,-offset]*CamTR) 
				dirs[1] = (pickCam.dir*-1)
				dirs[2] = cross (normalize (TL-cullPlanePos)) (normalize (TR-cullPlanePos))
				dirs[3] = cross (normalize (BR-cullPlanePos)) (normalize (BL-cullPlanePos))
				dirs[4] = cross (normalize (BL-cullPlanePos)) (normalize (TL-cullPlanePos))
				dirs[5] = cross (normalize (TR-cullPlanePos)) (normalize (BR-cullPlanePos))
				dirs
			)
		)
		custattributes.add ctrlr ca
	)
	fn scaleScript =
	(
		txt = ""
		txt += "fGrids = (this.grids as array)\n"
		txt += "camPos = this.cam.transform.position\n"
		txt += "dirArr = this.getCamDirs this.cam\n"
		txt += "for i in dirArr do this.cullPlane fGrids camPos i\n"
		txt += "messageBox \"Fume Paths Set\" title:\"GTVFX:\"\n"
		txt += "[1, 1, 1]\n"
		txt
	)
	fn genScaleCtrlr cam =
	(
		me = this.getMe()
		sclScript = scale_script()
		me.scale.controller = sclScript
		addCustomAttrFromCamCull sclScript
		sclScript.cam = cam
		sclScript.script = this.scaleScript()
	)
	fn setCtrlrGrids gridArr =
	(
		me = this.getMe()
		me.scale.controller.grids = gridArr
	)
	
	rollout ro "Fume Culler UI"
	(
		local dnTooltip
		local clrWindow = ((colorMan.getColor #window)*255)
		local clrText = ((colorMan.getColor #text)*255)
		local ClrBackGround = ((colorMan.getColor #background)*255)
		local camClr = (dotnetClass "System.Drawing.Color").lightGreen
		local animClr = (dotnetClass "System.Drawing.Color").SkyBlue
		
		group "Camera:"
		(
			dotNetControl dgv_cam "DataGridView" align:#left height:50
			pickButton pbtn_cam "Pick Camera" filter:this.camFilter  width:150 height:20
		)
		group "Fume Grids:"
		(
			dotNetControl dgv_fGrids "DataGridView" align:#left height:400
			button btn_grids "Collect Fume Grids" width:150 height:20
		)
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
		fn setDataGridColor dgv fontSize =
		(
			dgv.forecolor = dgv.forecolor.FromArgb clrText.x clrText.y clrText.z
			dgv.BackgroundColor = dgv.BackgroundColor.FromArgb clrWindow.x clrWindow.y clrWindow.z
			dgv.DefaultCellStyle.BackColor = dgv.backcolor.FromArgb clrWindow.x clrWindow.y clrWindow.z
			dgv.Font = dotNetObject "System.Drawing.Font" "Calibri" fontSize ((dotNetClass "System.Drawing.FontStyle").bold)
			dgv.AlternatingRowsDefaultCellStyle.BackColor = dgv.AlternatingRowsDefaultCellStyle.BackColor.FromArgb (clrWindow.x-15) (clrWindow.y-15) (clrWindow.z-15)
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
		fn drawGridData dgv gridArr =
		(
			dgv.DefaultCellStyle.SelectionBackColor = dgv.DefaultCellStyle.BackColor
			dgv.DefaultCellStyle.SelectionForeColor = animClr
			DGV.rows.clear()
			for d in gridArr do
			(
				tempRow = dotNetObject "System.Windows.Forms.DataGridViewRow"
				dgv.rows.add tempRow
				
				tempRow.SetValues #(d.name)
				tempRow.DefaultCellStyle.ForeColor = animClr
			)
		)
		fn drawCamData dgv cam =
		(
			dgv.DefaultCellStyle.SelectionBackColor = dgv.DefaultCellStyle.BackColor
			dgv.DefaultCellStyle.SelectionForeColor = camClr
			
			DGV.rows.clear()
			tempRow = dotNetObject "System.Windows.Forms.DataGridViewRow"
			dgv.rows.add tempRow
			
			tempRow.SetValues #(cam.name)
			tempRow.DefaultCellStyle.ForeColor = camClr
		)
		fn initDgv dgv colArr =
		(
			dgv.multiSelect = true
			dgv.AllowUserToAddRows = off
			dgv.AutoSize = on
			dgv.ShowEditingIcon = dgv.RowHeadersVisible = off
			dnSelectionMode = dotNetClass "System.Windows.Forms.DataGridViewSelectionMode"
			dgv.SelectionMode = dnSelectionMode.FullRowSelect 
			dgv.AllowUserToResizeRows = false
			dgv.AllowUserToOrderColumns = false
			dgv.AllowUserToResizeColumns = True
			dgv.ColumnHeadersHeightSizeMode = dgv.ColumnHeadersHeightSizeMode.DisableResizing
			
			for col in colArr do
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
			setDataGridColor dgv 9
			dgv.AutoResizeColumns()
			dgv.columns.item[0].autoSizeMode = dgv.columns.item[0].autoSizeMode.fill
			dgv.columns.item[0].Resizable = dgv.columns.item[0].Resizable.false
		)
		
		
		on pbtn_cam picked arg do
		(
			this.genScaleCtrlr arg
			drawCamData dgv_cam arg
		)
		on btn_grids pressed do
		(
			fGrids = #()
			for i in (getClassInstances FumeFX) do fGrids += refs.dependentNodes i
			setCtrlrGrids fGrids
			drawGridData dgv_fGrids fGrids
		)
		on ro open do
		(
			format "***** Open *****\n"
			initDgv dgv_cam #(#(#Text,"Camera",True,#Left))
			initDgv dgv_fGrids #(#(#Text,"Grid Name",True,#Left))
		)
	)
	fn getMe =
	(
		(refs.dependentNodes delegate)[1]
	)
	on clone og do
	(
		format "***** Clone Event *****\n"
	)
)