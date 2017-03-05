from __future__ import print_function
import alembic
import hashlib

class AlembicObject(object):
    def __init__(self, abcFile, debug=False):
        super(self.__class__,self).__init__()
        self.abcFile = abcFile
        self.objects = []
        self.objectNames = []
        
        if self.abcFile:
            self.archive = alembic.Abc.IArchive(self.abcFile)
            self.top = self.archive.getTop()
            
            self.GetAllAlembicObjects()
            self.GetAllObjectNames()
            
    def GetAllAlembicObjects(self):
        self.objects = self.GetChildrenRecursive(self.top, childList=[])
        
    def GetAllObjectNames(self):
        if self.objects:
            self.objectNames = self.GetObjectNames(self.objects)
        
    def GetChildrenRecursive(self, obj, childList=[], skipNameList=[]):
        '''
        skipNameList is expected to be a list of object names
        every object found through the recursion is tested against the names in the skipNameList
        If found the recursion ends, so that branch of the hierarchy is ignored
        '''
        if obj is None:
            print('Invalid object supplied to GetChildrenRecursive')
            return childList
        for i in xrange(0, obj.getNumChildren()):
            child = obj.getChild(i)
            
            skipCase = child.getName() in skipNameList
            
            if not skipCase:
                childList.append(child)
                self.GetChildrenRecursive(child, childList=childList, skipNameList=skipNameList)
            else:
                print('Skipping {0}'.format(child.getName()))
            
        return childList
        
    def FilterObjectList(self, objList, getShapes=True):
        if getShapes:
            return [obj for obj in objList if 'Shape' in obj.getName()]
        else:
            return [obj for obj in objList if 'Shape' not in obj.getName()]
        
    def GetObjectNames(self, objList, getShapes=True, fullName=False):
        if getShapes:
            if fullName:
                return [obj.getFullName() for obj in objList if 'Shape' in obj.getName()]
            else:
                return [obj.getName() for obj in objList if 'Shape' in obj.getName()]
        else:
            if fullName:
                return [obj.getFullName() for obj in objList if 'Shape' not in obj.getName()]
            else:
                return [obj.getName() for obj in objList if 'Shape' not in obj.getName()]
            
    def GetObjectHash(self, obj):
        objPropHash = obj.getPropertiesHash()
        objFullName = obj.getFullName()
        hash = hashlib.md5((objFullName + "|" + objPropHash)).hexdigest()
        return ( hash )
        
    def GetHashList(self, objList):
        return [self.GetObjectHash(obj) for obj in objList]
        
    def GetObjectByHash(self, hash):
        '''
        this method should only ever return a single object
        using list comprehension for performance
        '''
        obj = [obj for obj in self.objects if self.GetObjectHash(obj) == hash]
        if len(obj) != 0:
            return obj[0]
        else:
            print('No object match the supplied hash: {0}'.format(hash))
            return None
        
    def GetObjectByName(self, objName, fullName=False):
        '''
        Returns either a single object or a list of objects if multiple objects are found with the same name
        Collecting objects by fullName should never return more than a single object
        '''
        if fullName:
            # Look into using the Filter method instead and returning the first item found. Should be faster.
            objList = [obj for obj in self.objects if obj.getFullName() == objName]
        else:
            objList = [obj for obj in self.objects if obj.getName() == objName]
        
        if len(objList) != 0:
            if len(objList) > 1: 
                print('AlembicObject collected multiple objects with name {0}'.format(objName))
            else:
                objList = objList[0]
            return objList