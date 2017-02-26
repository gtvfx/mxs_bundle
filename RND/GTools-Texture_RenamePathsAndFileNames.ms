/***************************************************************************************************
__MXSDOC__
[TITLE]
Texture_RenamePathsAndFileNames

[DESCRIPTION]
Does a find and replace function with the given text strings.

[USAGE]
- Will replace any occurence of the first string with the supplied second string. No asterisks (*).

[CREATION INFO]
by: Gavyn Thompson

[KEYWORDS]
Find, Replace, Strings, Rename, Texture

[VERSION HISTORY]
01/12/2011 - creation



__END__
***************************************************************************************************/


clearlistener ()
	
try(destroyDialog ro_ChangeString)catch()
rollout ro_ChangeString "Replace String: Texture Paths and File Names"
	(
		editText txt_ostr "Replace:" labelOnTop: true
		editText txt_rstr "With:" labelOnTop: true
		button btn_rplStr "Replace String" width:240 height:40 pos: [30,90]
		
		local thbmp	= ()
		local ostr 		= ""
		local rstr 		= ""
		
		fn tokenString str token =
			(
				local idx 		= 0
				local start 		= 1
				local end 		= 0
				local strings 	= #()
				while (idx != undefined) do
					(
						idx = findString str token
						
						if idx == undefined then
							( 
								append strings str 
								continue
							)
						end 		= idx-1
						newStr 	= subString str start end
						
						if newStr.count > 0 then
						append strings newStr
						str 		= replace str start (end+token.count) ""
					)
				return strings
			)
			
		fn replaceString str replaceStr withStr =
			(
				 local theStr 			= " " + str
				 local splitNames 	= tokenString theStr replaceStr
				 local newStr 			= str
				 if (splitNames.count >= 1) then
					(
						  newStr = ""
						  
						  for s = 1 to splitNames.count do
							  (
								   newStr += splitNames[s]
								   if s == splitNames.count do exit
								   newStr += withStr
							  )
						  newStr = replace newStr 1 1 ""
					)
			 return newStr
			)
			
		on txt_ostr entered txt do
			(
				ostr = txt
			)
			
		on txt_rstr entered txt do
			(
				rstr = txt
			)
			
		on btn_rplStr pressed do
			(
				thbmp	= getclassinstances bitmaptexture
				thbmp 	= for i in thbmp where i.filename != undefined collect i
				for t in thbmp where findstring t.filename ostr != undefined  do
					(
						fpath  = t.filename
						nfpath = replaceString fpath ostr rstr
						t.filename = nfpath
					)
			)
			
	)
	
createdialog ro_ChangeString width:300 height:140
	
	
