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

Constructor: 
Instantiated Global: 

Methods:



__END__
*/


struct cln_CollapseToLogic
(
public

    aggregate,
    debug = False,
    progBar = undefined,
    objArr,
    
    deleteObjs = #(),
    classArr = #(),
    modClassArr = #(TurboSmooth, Point_Cache),
    thirdPartyModArr = #(VRayDisplacementMod),
    thirdPartyClassArr = #(RailClone_Pro),
    
    fn ValidateThirdPartyClasses =
    (
        for i in this.thirdPartyModArr do
		(
			if i != undefined then append modClassArr i
		)
		
		for i in this.thirdPartyClassArr do
		(
			if i != undefined then append classArr i
		)
    ),
    
    fn DeleteTemplateObjs =
    (
        local arr = MakeUniqueArray deleteObjs
        
        arr = ( for i in arr where ( IsValidNode i ) collect i )
        
        if arr.count != 0 then ( Delete arr )
        
        GC quiet:True
    ),
    
    fn CollectRailCloneTemplateObjects railCloneObj =
    (
        local refsObjs = for obj in railCloneObj.sobjnode collect obj
            
        refsObjs
    ),

    fn CollapseRailCloneObj obj =
    (
        this.deleteObjs += ( this.CollectRailCloneTemplateObjects obj )
        
        ConvertToMesh obj
    ),

    fn CollapseClassArrObjs classArr =
    (
        if classArr.count != 0 then
        (
            for cls in classArr do
            (
                local clsObjArr = #()
                
                for i in ( GetClassInstances cls ) do
                (
                    clsObjArr += ( refs.dependentNodes i )
                )
                
                if clsObjArr.count != 0 then
                (
                    case cls of
                    (
                        (undefined):
                        (
                            continue
                        )
                        (RailClone_Pro):
                        (
                            for obj in clsObjArr do
                            (
                                this.CollapseRailCloneObj obj
                            )
                        )
                        default:
                        (
                            for obj in clsObjArr do
                            (
                                ConvertToMesh obj
                            )
                        )
                    )
                    
                    format "***** %: Converted to mesh *****\n" obj.name
                )
            )
        )
    ),

    fn CollapseDownToMod _progressBar:this.progBar objArr:this.objArr =
    (
        /* 
                Collapses the modifiers stack of all objects
                If a turbosmooth modifier is present, then the stack is collapsed below the turbosmooth modifier
                */
        
        if objArr == undefined then
        (
            throw "CollapseDownToMod needs a valid object array to operate on.\n-- Either define this at the <objArr> class parameter\n-- or use the optional <objArr:> flag on the method."
        )
        
        if _progressBar != undefined then
        (
            _progressBar.UpdateLabel_Sub ""
            
            _progressBar.Start_Sub _steps:self.testObjects.count
        )
        
        for obj in objArr do
        (
            if _progressBar != undefined then _progressBar.UpdateLabel_Sub obj.name
            
            if not ( isDeformable obj ) or ( obj.modifiers.count == 0 ) then continue
            
            local tbIndx = 0
            
            -- We get the index of each modifier in the stack that matches one of our filtered classes
            local indexArr = for x = 1 to obj.modifiers.count where ( FindItem modClassArr ( classof obj.modifiers[x] ) ) != 0 collect x
            
            -- We get the top-most filtered mod
            tbIndx = indexArr[1]
                
            case tbIndx of
            (
                (1): -- If the top-most filtered mod is at the top of the stack we keep the modifer and collapse everything below it
                (
                    maxOps.CollapseNodeTo obj (tbIndx+1) True
                )
                default: -- if the modifier is not at the top of the stack then we collapse everything and bake it into the mesh
                (
                    if tbIndx != 0 then
                    (
                        for mod in obj.modifiers where classOf mod == TurboSmooth do
                        (
                            if mod.useRenderIterations and mod.renderIterations > mod.iterations then
                            (
                                mod.iterations = mod.renderIterations
                            )
                        )
                    )
                    
                    ConvertToMesh obj
                    
                    -- This try/catch is to catch world space modifiers.
                    if obj.modifiers.count != 0 then
                    (
                        try( maxOps.CollapseNodeTo obj 1 off )catch()
                    )
                )
            )
            
            if _progressBar != undefined then _progressBar.Step_Sub()
        )
    ),
    
    fn Run objArr:this.objArr =
    (
        this.CollapseClassArrObjs classArr
        this.CollapseDownToMod()
        this.DeleteTemplateObjs()
        
        if ( this.aggregate != undefined ) and ( IsProperty this.aggregate #RefactorObjs ) then this.aggregate.RefactorObjs()
    ),

private
    
    fn _init =
    (
        this.ValidateThirdPartyClasses()
        
        if this.aggregate != undefined and ( isProperty this.aggregate #_progressBar ) then 
        (
            this.progBar = this.aggregate._progressBar
        )
    ),

    __init__ = _init()
)


