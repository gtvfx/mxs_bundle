try(destroyDialog _cso.ro)catch()
struct customSampleObjects
(
	self,
	ro,
	_sourceDir,
	maxIni = getMaxIniFile(),
	iniSec = "Material Editor",
	secKey = "SampleObject",
	-- "LoadSampleCamLts=1"
	--"CustomBackground='path to image file'"
	
	fn setSampleObject mFile =
	(
		setIniSetting maxIni iniSec "SampleObject" mFile
		setIniSetting maxIni iniSec "LoadSampleCamLts" "1"
		
	),
	
	fn setCustomBg bgImage =
	(
		setIniSetting maxIni iniSec "CustomBackground" bgImage
	),



	
	
	fn ui =
	(
		rollout ro "Custom Sample Objects by GTVFX" width:300
		(
			local self
			
			dotNetControl dgv_cams "DataGridView" align:#left width:(ro.width-25) --height:(ro.height-135)
			dotNetControl dNbtn_convert "button" width:(ro.width-25) height:40 
			
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
			fn setDotNetWidget dNobj caption fontSize =
			(
				dNobj.text = caption
				dNobj.forecolor = dNobj.forecolor.FromArgb clrText.x clrText.y clrText.z
				dNobj.backColor = dNobj.backcolor.FromArgb ClrBackGround.x ClrBackGround.y ClrBackGround.z
				dNobj.Font = dotNetObject "System.Drawing.Font" "Segoe UI" fontSize ((dotNetClass "System.Drawing.FontStyle").bold)
			)
			fn initDnetBtn dNbtn caption fontSize style:#popup tooltip:"" = 
			(
				case style of
				(
					#flat:(dNbtn.flatStyle = dNbtn.flatStyle.flat)
					#popup:(dNbtn.flatStyle = dNbtn.flatStyle.popup)
					#system:(dNbtn.flatStyle = dNbtn.flatStyle.system)
				)
				setDotNetWidget dNbtn caption fontSize
				initToolTip dNbtn tooltip
			)
			fn setDataGridColor dNObj fontSize =
			(
				dNObj.forecolor = dNObj.forecolor.FromArgb clrText.x clrText.y clrText.z
				dNObj.BackgroundColor = dNObj.BackgroundColor.FromArgb clrWindow.x clrWindow.y clrWindow.z
				dNObj.DefaultCellStyle.BackColor = dNObj.backcolor.FromArgb clrWindow.x clrWindow.y clrWindow.z
				dNObj.Font = dotNetObject "System.Drawing.Font" "Calibri" fontSize ((dotNetClass "System.Drawing.FontStyle").regular)
			)
			fn drawData dgv dataArr =
			(
				dgv.rows.clear()
				
				for a in dataArr do
				(
					tempRow = dotNetObject "System.Windows.Forms.DataGridViewRow"
					dgv.rows.add tempRow
					tempRow.SetValues #(a)
				)
			)
			fn initDgv dgv fontsize tooltip:"" =
			(
				dgv.MultiSelect = true
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
				append colAr #(#text,"Camera:",True,#left)
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
				for i in 0 to dgv.columns.count-1 do
				(
					dgv.Columns.item[i].SortMode = (dotNetClass "System.Windows.Forms.DataGridViewColumnSortMode").NotSortable
				)
				setDataGridColor dgv fontSize
				dgv.AlternatingRowsDefaultCellStyle.BackColor = dgv.AlternatingRowsDefaultCellStyle.BackColor.FromArgb (clrWindow.x-15) (clrWindow.y-15) (clrWindow.z-15)
				initToolTip dgv tooltip
			)
			fn initTabs dNtab =
			(
				dNtab.controls.clear()
				setDotNetWidget dNtab "" 11 colorOffsetInt:10
				tabArr = #("Max to VRay:","VRay to Max:")
				for r in tabArr do
				(
					tP = dotNetObject "System.Windows.Forms.TabPage"
					setDotNetWidget tP r 10 colorOffsetInt:10
					dNtab.controls.add tP
				)
			)
			fn refreshDataGrid dgv tabIndex: =
			(
				case tabIndex of
				(
					0:
					(
						chk_fov.enabled = True
						chk_focal.enabled = True
						drawData dgv_cams (self.collectCamNames vrayCam:False)
					)
					1:
					(
						chk_fov.enabled = False
						chk_focal.enabled = False
						drawData dgv_cams (self.collectCamNames vrayCam:True)
					)
				)
			)
			fn _init pself =
			(
				self = pself
				--initTabs dNtab_switch
				initDgv dgv_cams 12 tooltip:"Select cameras to bake out"
				refreshDataGrid dgv_cams tabIndex:dNtab_switch.selectedIndex
				initDnetBtn dNbtn_convert "Convert selected cameras" 11 style:#flat
			)
		)
		createDialog ro
		ro._init self
	),
	fn _init =
	(
		self = this
		ui()
	),
	init = _init()
)

_cso = customSampleObjects()
