'''
Created on Apr 19, 2014

@author: gavyn.thompson
3dsmax, Vray
Create Light Select Elements By Layer
'''

import webbrowser
from PySide import QtCore, QtGui
from gen.lib.loadUiType import *
import os,sys
import MaxPlus
import pymxs
mxs = pymxs.runtime


base,form = loadUiType(os.path.join(os.path.dirname(__file__),'ui','CLSEBL.ui'))

# print "MaxPlus Method"
# base,form = MaxPlus.loadUiType(os.path.join(os.path.dirname(__file__),'ui','CLSEBL.ui'))



class CreateLightSelects(base, form):
    nameTag = 'lgt_'
    elmntMgr = mxs.maxOps.GetCurRenderElementMgr()

    def __init__(self,parent=None):
        super(CreateLightSelects, self).__init__(parent)
        self.setupUi(self)
        
        QtGui.QApplication.setStyle(QtGui.QStyleFactory.create('Plastique'))            
        
        #pyside_uiloader.loadUi(UI, self)
        
        self.drawTableData()
        self.connectWidgets()
        
    #-- connect event handlers
    def connectWidgets(self):
        self.pushButton_delete.clicked.connect(self.deleteButton)
        self.pushButton_create.clicked.connect(self.createButton_pressed)
        self.connect(self.act_gtvfx, QtCore.SIGNAL('triggered()'),self.gtvfx)
        
    def gtvfx(self):
        #pass
        url = "www.gtvfx.com"
        webbrowser.open(url,new=2)

    def drawTableData(self):
        for i in self.getLgtLayerNames():self.listWidget_layers.addItem(i)
            
    def collectNamesFromListItems(self):
        arr = []
        for i in self.listWidget_layers.selectedItems():
            arr.append(i.text())
        return arr
        
    def getLgtLayerNames(self):
        arr = []
        for i in range(mxs.layerManager.count):
            layerName = (mxs.layerManager.getLayer(i)).name
            if self.nameTag in layerName.lower():
                arr.append(layerName)
        arr.sort()
        return arr
            
    def clearLightSelectElements(self):
        arr = []
        numElements = self.elmntMgr.NumRenderElements()
        for i in range(numElements):
            elementEach = self.elmntMgr.GetRenderElement(i)
            if self.nameTag in elementEach.elementName.lower():
                arr.append(elementEach)
        if len(arr) != 0:
            for e in arr:
                print '***** Removing Element: %s *****' %e.elementName
                self.elmntMgr.RemoveRenderElement(e)
        mxs.renderSceneDialog.update()
        return True

    def createLightSelectElemtentsByLayer(self,nameArr):
        if len(nameArr) != 0:
            for i in nameArr:
                if not (mxs.LayerManager.getLayerFromName(i)) is None:
                    lgtLayer = mxs.layerManager.getLayerFromName(i)
                    lgtLayerNodes = mxs.refs.dependents(lgtLayer.layerAsRefTarg)
                    lgtArr = []
                    for each in lgtLayerNodes:
                        if mxs.superClassOf(each) == mxs.Light:lgtArr.append(each)
                    layerNameArr = i.split("_")
                    elementName = ((self.nameTag.split("_"))[0])
                    for n in layerNameArr:
                        if n != '###' and n != elementName:
                            elementName += ('_'+n)
                    self.elmntMgr.addRenderElement(mxs.VRayLightSelect(elementname=elementName,vrayVFB=True,color_mapping=False,multiplier=1.0,lights=lgtArr,lightsExcludeType=1))
            mxs.renderSceneDialog.update()
        else:
            QtGui.QMessageBox.about(self,'','No LGT layers found')

    def deleteButton(self):
        self.clearLightSelectElements()

    def createButton_pressed(self):
        self.createLightSelectElemtentsByLayer(nameArr=self.collectNamesFromListItems())

    

    
def Run():
    print "updated"
    app = QtGui.QApplication.instance()
    if not app:
        app = QtGui.QApplication([])
        
    tool = CreateLightSelects(MaxPlus.GetQMaxWindow())
    MaxPlus.MakeQWidgetDockable(tool, 12), #Make dockable on Left, Right and Bottom 
    #tool.move(800,400)
    tool.show()
    

if __name__ == '__main__':
    pass
