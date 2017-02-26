/* 
Maxscript functions for building a ZshotFile using the sgshotfile module in Python

Not the most elegant, but this does provide a programatic method of constructing the Zshot file 
*/

::_GenZshot

Struct GenZshot
(
	fn init_sgshotfile zshotFile =
	(
		local pyCmd = StringStream ""
		format "
import sgshotfile

zFile = open(r'%','w')
zFile.close()

#print zFile.name

sf = sgshotfile.readFile(zFile.name)
		" zshotFile to:pyCmd
		
		python.execute (pyCmd as string)
	),

--( Maketake Functions
	
	fn MergePackageClassFromAtlas assetName =
	(
		/* 
		The code here for versions and version will only allow us to maketake the latest version of the set
		
		I need to explore a method to retrieve a preferred version from Unity.
		We have a wrapper function for this in ilmUnity, but I need to explore how to return that version in Python and pass it along here.
		 */
		local pyCmd = StringStream ""
		
		format "
AI = atlastools.getAtlasIndex()
setName = '%'
versions = AI.getAssetVersions(setName,'primary')
version = versions[-1]

sfCont = AI.getAssetShotfile(setName,version = version.version_num, track = 'primary')
pkgClass = sfCont.findSubcontainer(setName)

sgshotfile.mergeElements(pkgClass, sf)
		" assetName to:pyCmd
		
		python.execute (pyCmd as string)
	),
	
	fn AppendAssetToZshotFile assetNode abcFile: =
	(
		local pyCmd = StringStream ""
		
		format "
pkg = sf.newSubcontainer('package', '%')
pkgClass = sf.findSubcontainer('%')
pkg.setInheritsFrom(pkgClass)
		" assetNode.name assetNode.Asset_Fullname  to:pyCmd
		
		if abcFile != unsupplied then
		(
			format "
app_alembic = pkg.newSubcontainer('application', 'alembic')
app_alembic_tag = app_alembic.newSubcontainer('tag', 'genTag')
app_alembic_tag_group = app_alembic_tag.newSubcontainer('group', 'geom')

abcFile = app_alembic_tag_group.newAttribute('file','default')
abcFile.setValue('%')
			" (_ilmPathUtils.LinuxifyPath abcFile) to:pyCmd
		)
		
		python.execute (pyCmd as string)
	),
	
--)	

--( Checkin Functions
	
	fn AppendPackageClassToZshot nameStr =
	(
		pyCmd = StringStream ""

		format "
pkgClass = sf.newSubcontainer('packageClass', '%')
		" (tolower nameStr) to:pyCmd
		
		python.execute (pyCmd as string)
	),

	fn AppendApplicationToPackageClass pkgClassName appName =
	(
		pyCmd = StringStream ""

		format "
pkgClass = sf.findSubcontainer('%')
app = pkgClass.newSubcontainer('application', '%')
		" (tolower pkgClassName) (tolower appName) to:pyCmd
		
		python.execute (pyCmd as string)
	),

	fn AppendTagToApplication pkgClassName appName tagName =
	(
		pyCmd = StringStream ""

		format "
pkgClass = sf.findSubcontainer('%')
app = pkgClass.findSubcontainer('%')
tag = app.newSubcontainer('tag', '%')
		" (tolower pkgClassName) (tolower appName) tagName to:pyCmd
		
		python.execute (pyCmd as string)
	),

	fn AppendGroupToTag pkgClassName appName tagName groupName =
	(
		pyCmd = StringStream ""

		format "
pkgClass = sf.findSubcontainer('%')
app = pkgClass.findSubcontainer('%')
tag = app.findSubcontainer('%')
group = tag.newSubcontainer('group', '%')
		" (tolower pkgClassName) (tolower appName) tagName groupName to:pyCmd
		
		python.execute (pyCmd as string)
	),

	fn AppendAttributeToTag pkgClassName appName tagName attrName attrValue =
	(
		pyCmd = StringStream ""

		format "
pkgClass = sf.findSubcontainer('%')
app = pkgClass.findSubcontainer('%')
tag = app.findSubcontainer('%')
file = tag.newAttribute('file','%')
file.setValue('%')
		" (tolower pkgClassName) (tolower appName) tagName (tolower attrName) (tolower attrValue) to:pyCmd
		
		python.execute (pyCmd as string)
	),

	fn AppendAttributeToGroup pkgClassName appName tagName groupName attrName attrValue =
	(
		pyCmd = StringStream ""

		format "
pkgClass = sf.findSubcontainer('%')
app = pkgClass.findSubcontainer('%')
tag = app.findSubcontainer('%')
group = tag.findSubcontainer('%')
file = group.newAttribute('file','%')
file.setValue('%')
		" (tolower pkgClassName) (tolower appName) tagName groupName (tolower attrName) (tolower attrValue) to:pyCmd
		
		python.execute (pyCmd as string)
	),
	
--) End Checkin Functions
	
--( MakeTake Functions
	
	fn GetPackageClassFromPrimary assetNode =
	(
		/* 
		The code here for versions and version will only allow us to maketake the latest version of the set
		
		I need to explore a method to retrieve a preferred version from Unity.
		We have a wrapper function for this in ilmUnity, but I need to explore how to return that version in Python and pass it along here.
		 */
		local pyCmd = StringStream ""
		
		format "
import atlastools
AI = atlastools.getAtlasIndex()
assetName = '%'
versions = AI.getAssetVersions(assetName,'primary')
version = versions[-1]

sfCont = AI.getAssetShotfile(assetName,version = version.version_num, track = 'primary')
pkgClass = sfCont.findSubcontainer(assetName)

sgshotfile.mergeElements(pkgClass, sf)
		" assetNode.Asset_Fullname to:pyCmd
		
		python.execute (pyCmd as string)
	),
	
	fn AppendAssetToZshotFile assetNode abcFile: =
	(
		local pyCmd = StringStream ""
		
		format "
pkg = sf.newSubcontainer('package', '%')
pkgClass = sf.findSubcontainer('%')
pkg.setInheritsFrom(pkgClass)
		" assetNode.name assetNode.Asset_Fullname  to:pyCmd
		
		if abcFile != unsupplied then
		(
			format "
app_alembic = pkg.newSubcontainer('application', 'alembic')
app_alembic_tag = app_alembic.newSubcontainer('tag', 'genTag')
app_alembic_tag_group = app_alembic_tag.newSubcontainer('group', 'geom')

abcFile = app_alembic_tag_group.newAttribute('file','default')
abcFile.setValue('%')
			" (_ilmPathUtils.LinuxifyPath abcFile) to:pyCmd
		)
		
		python.execute (pyCmd as string)
	),
	
--) End MakeTake Functions

	fn WriteZshot zshotFile =
	(
		local pyCmd = StringStream ""
		
		format "
sf.writeFile(r'%')
		" zshotFile to:pyCmd
		
		python.execute (pyCmd as string)
	),
	
	private fn _init =
	(
		format "
---------------
CLASS USAGE:
		
Constructor = GenZshot
Instantiated Global = _GenZshot 
--
--
Begin with <init_sgshotfile zshotFile> to initiate the sgshotfile object in Python
--
Once you've added all the components to the sgshotfile object use <WriteZshot zshotFile> to write the file to disk
---------------\n"
	),
	
	__init__ = _init()
)

_GenZshot = GenZshot()



