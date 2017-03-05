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
***************************************************************************************************/
/*
__HELP__

Constructor: MxsPyFns
Instantiated Global: MxsPyFns

[METHODS]

[DESCRIPTION]
This module can, most likely, be depcrecated once 3dsmax 2017 is fully adopted.

[USAGE]

__END__
*/


mxs.Load "PathUtils"
mxs.Load "HashTableMethods"

::PYTHON_RETURN -- Global place holder for return values from Python


struct MxsPyFns
(
public
	
	debug = False,
	
    fn BooleanToPythonString bool =
    (
        local out = ( bool as string )
        out = ( ToLower out )
        out = ( SubstituteString out out[1] ( ToUpper out[1]) )
        out
    ),
    
	fn ListToArray pyListStr =
	(
		local pyCmd = StringStream ""
		
		format "
arr = '#({0})'.format(','.join([str('\"'+str(n)+'\"') for n in %]))
MaxPlus.Core.EvalMAXScript('PYTHON_RETURN = {0}'.format(arr))
		" pyListStr to:pyCmd
		
		python.execute (pyCmd as string)

		PYTHON_RETURN
	),
	
	fn ArrayToList arr listVarStr =
	(
		/* 
		- listVarStr is a string value that will be defined as the variable in Python that holds the list value
		- This only works for arrays of string values at the moment
		- It could be possible to transfer MaxObjects from an Array to a List using the FPValue. Will need to look into it more.
		 */
		
		pyCmd = StringStream ""
		
		format "
tempList = []
tempStr = '%'
		
tempStr = tempStr.replace('#(', '')
tempStr = tempStr.replace(')', '')
tempStr = tempStr.replace('\"', '')

tempList = tempStr.split(', ')
% = tempList
		" arr listVarStr to:pyCmd
		
		python.execute (pyCmd as string)
	),
    
    fn HashTableToPythonDict hash dictVarStr =
    (
        local keys = ::_hash.GetDicKeys hash
        
        python.execute ( dictVarStr + " = dict()" )
        
        for item in keys do
        (
            python.execute ( dictVarStr+"['"+item+"']"+"='"+hash.item[item]+"'" )
        )
    ),
    
    fn IsType objValStr typeValStr =
    (
        local pyCmd = StringStream ""
        
        format "
MaxPlus.Core.EvalMAXScript('PYTHON_RETURN = {0}'.format(str(type(%) == %)))
        " objValStr typeValStr to:pyCmd
        
        format "***** pyCmd: % *****\n" ( pyCmd as string )
        
        python.execute ( pyCmd as String )
        
        ( ::PYTHON_RETURN as BooleanClass )
    ),
	
	fn IsUpper str =
	(
		local pyCmd = StringStream ""
		
		format "
MaxPlus.Core.EvalMAXScript('PYTHON_RETURN = {0}'.format('%'.isupper()))
		" str to:pyCmd
		
		python.execute (pyCmd as string)

		PYTHON_RETURN
	),
	
	fn IsLower str =
	(
		local pyCmd = StringStream ""
		
		format "
MaxPlus.Core.EvalMAXScript('PYTHON_RETURN = {0}'.format('%'.islower()))
		" str to:pyCmd
		
		python.execute (pyCmd as string)

		PYTHON_RETURN
	),
    
    fn FlatDictToHashtable _flatDictStr =
    (
        local subDict = dotNetObject "System.Collections.Hashtable"
        
        local subDictArr = this.ListToArray ( _flatDictStr + ".items()" )
        -- This returns an array of Tuple objects as string values
        -- #("('three', 'Third item')", "('two', 'Second item')", "('one', 'First item')")
        
        for i = 1 to subDictArr.count do
        (
            -- This puts a hash at the beginning of each Tuple string and replaces the single quotations form Python with double quotations. It then executes the value which creates a MaxScript array of the string values of the Tuple object.
            subDictArr[i] = ( execute ( "#" + ( SubstituteString subDictArr[i] "'" "\"" ) ) )
            -- #( #( "three", "Third item" ), #( "two", "Second item" ), #( "one", "First item" ) )
        )
        
        for item in subDictArr do
        (
            -- This forms the dictionary treating the two-part arrays as key/value pairs
            subDict.add item[1] item[2]
        )
        
        -- return the dictionary
        subDict
    ),
	
	fn GetPropDict dictVarStr masterDict:unsupplied =
	(
		if masterDict == unsupplied then 
		(
			if this.debug then format "***** Initial Run *****\n"
			masterDict = dotNetObject "System.Collections.Hashtable"
		)
		else
		(
			if this.debug then format "***** Recursive Run *****\n"
		)
		
		-- Variables passed between Python and MaxScript must be scoped globally
		global dictItemKeys = #()
		global flatItems = #()
		
		local pyCmd = StringStream ""
		
		format "
iterDict = %
debug = %

	
dictItems = [item for item in iterDict.items() if type(item[1]) == dict and item[0] != '__dict__']
flatItems = [item for item in iterDict.items() if type(item[1]) != dict]
	
if debug: print 'dictItems: {0}'.format(dictItems)
if debug: print 'flatItems: {0}'.format(flatItems)

dictItemKeys = []
if len(dictItems) != 0:	
	dictItemKeys = [item[0] for item in dictItems]
	
	arr = '#({0})'.format(','.join([str('\"'+str(n)+'\"') for n in dictItemKeys]))
	MaxPlus.Core.EvalMAXScript('dictItemKeys = {0}'.format(arr))

if len(flatItems) > 0:
	arr = '#({0})'.format(','.join([str('\"'+str(n)+'\"') for n in flatItems]))
	if debug:
		print arr
		print type(arr)
	MaxPlus.Core.EvalMAXScript('flatItems = {0}'.format(arr))
else:
	MaxPlus.Core.EvalMAXScript('flatItems = {0}'.format('#()'))
		" dictVarStr ( ::_GenPyFns.BooleanToPythonString this.debug ) to:pyCmd
		
		python.execute ( pyCmd as string )
		
		if flatItems.count != 0 then
		(
			if this.debug then format "***** flatItems: % *****\n" flatItems
			
			for i = 1 to flatItems.count do
			(
				if ( ClassOf flatItems[i] ) == Array then continue
				
				if ( MatchPattern flatItems[i] pattern:"*[*]*" ) then
				( -- Special case for Matrix and Point3 values
					-- "('local_matrix', 'matrix3 [1, 0, 0] [0, 1, 0] [0, 0, 1] [0, 0, 0] ')"
					flatItems[i] = substituteString flatItems[i] "(" ""
					flatItems[i] = substituteString flatItems[i] ")" ""
					
					local strArr = FilterString flatItems[i] "'"
					
					flatItems[i] = #(strArr[1], strArr[3])
					
					continue
				)
				
				
				if debug then format "***** start flatItmes[%]: % *****\n" i flatItems[i]
				
				flatItems[i] = substituteString flatItems[i] "(" ""
				flatItems[i] = substituteString flatItems[i] ")" ""
				flatItems[i] = substituteString flatItems[i] "'" ""
				flatItems[i] = substituteString flatItems[i] " " ""
				flatItems[i] = filterString flatItems[i] ","
				
				if flatItems[i][1] == "variations" then
				(
					local varArr = #()
					for c = 2 to flatItems[i].count do
					(
						local str = flatItems[i][c]
						str = substituteString str "#" ""
						append varArr str
					)
					
					-- Set the value to the MaxScript array
					flatItems[i] = #("variations", varArr)
				)
				
				if debug then format "***** end flatItmes[%]: % *****\n" i flatItems[i]
			)
			
			for item in flatItems do
			(
				if this.debug then format "***** item: % *****\n" item
				
				-- This forms the dictionary treating the two-part arrays as key/value pairs
				masterDict.add item[1] item[2]
			)
		)
			
	   -- Add the dictItemKeys to the top level dict as empty Hashtables
		
		if dictItemKeys.count != 0 then
		(
			if this.debug then format "***** dictItemKeys: % *****\n" dictItemKeys
			
			for item in dictItemKeys do
			(
				if this.debug then format "***** item: % *****\n" item
				
				masterDict.add item ( dotNetObject "System.Collections.Hashtable" )
				
				if this.debug then format "***** Getting subdict | dictVarStr: % | item: % *****\n" dictVarStr item
				
				local subDictStr = ( dictVarStr + "[\"" + item + "\"]" )
				
				if this.debug then format "***** subDictStr: % *****\n" subDictStr
				
				-- Recursively build the DotNet hashtable for each nested dictionary
				this.GetPropDict subDictStr masterDict:masterDict.item[item]
			)
		)
		
		-- Return the main dict
		masterDict
	),
	
	fn CopyFiles fromDir toDir =
	(
		/*********************************************************************
		Dos commands from Maxscript can't run robocopy or xcopy when given relative paths to network locations
		This is a Python implementation that recursively copies an entire directory structure from one location ot another
		Or simply a single file
		*********************************************************************/
		
		local pyCmd = StringStream ""
		
		format "
import os
import shutil
import errno
		
srcDir = r'%'
destDir = r'%'
		
def copy(src, dest):
    try:
        shutil.copytree(src, dest)
    except OSError as e:
        # If the error was caused because the source wasn't a directory
        if e.errno == errno.ENOTDIR:
            shutil.copy(src, dest)
        else:
            print ('Directory not copied. Error: {0}'.format(e))
		
copy(srcDir, destDir)
		
		" fromDir toDir to:pyCmd
		
		pyCmd = ( pyCmd as string )
		
		--print pyCmd
		
		python.execute pyCmd
	),
    
	fn RemoveDir dir =
	(
		pyCmd = StringStream ""
		
		format "
import shutil
		
shutil.rmtree(r'%')
		" dir to: pyCmd
		
		python.execute pyCmd
	),
    
    fn GetModule =
    (
        ( GetSourceFileName() )
    ),
    
    fn Help =
    (
        ::mxs.GetScriptHelp ( GetSourceFileName() )
    ),
	
private
	
	fn _init =
	(
		
	),
	
	__init__ = _init()
)

MxsPyFns = MxsPyFns()



