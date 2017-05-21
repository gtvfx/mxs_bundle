import os

try:
    from PySide import QtCore, QtGui
except:
    from PySide2 import QtCore, QtWidgets
    
#from mxs.lib.loadUiType import *
import MaxPlus


base,form = MaxPlus.LoadUiType(os.path.join(os.path.dirname(__file__),'ui','progress_bar.ui'))

class ProgressBar(base, form):
    def __init__(self,parent=None, title='Progress', maximum=100):
        super(self.__class__, self).__init__(parent)
        self.setupUi(self)
        self.setWindowTitle(title)
        
        try: # PySide
            QtGui.QApplication.setStyle(QtGui.QStyleFactory.create('Plastique'))
        except: # PySide2
            QtWidgets.QApplication.setStyle(QtWidgets.QStyleFactory.create('Plastique'))
            
        
        self.set_total(maximum)
        
    def clear(self):
        self.progressBar_main.reset()
        
    def set_value(self, val):
        self.progressBar_main.value = val
        
    def set_total(self, total):
        self.progressBar_main.setMaximum(total-1) # Since the indexing starts at 0 our maximum needs to be 1 less than our total items
        self.update_total(total)
        
    def step(self):
        val = self.progressBar_main.value() + 1
        self.progressBar_main.setValue(val)
        self.update_iter(val + 1) # the value iteration starts at 0, but we want to visually start from 1.
        
    def update_label(self, text):
        self.label_itemName.setText(text)
        self.update_labels()
        
    def update_total(self, total):
        self.label_itemTotal.setText(str(total))
        self.update_labels()
        
    def update_iter(self, iter):
        self.label_iterItem.setText(str(iter))
        self.update_labels()
        
    def update_labels(self):
        self.label_iterItem.adjustSize()
        self.label_itemTotal.adjustSize()
        self.label_itemName.adjustSize()
        self.label_divider.adjustSize()

    
def Run(title='Progress', maximum=100):
    try: # PySide
        tool = ProgressBar(MaxPlus.GetQMaxWindow(), title=title, maximum=maximum)
        print "Running with PySide"
    except: # PySide2
        tool = ProgressBar(MaxPlus.GetQMaxMainWindow(), title=title, maximum=maximum)
        print "Running with PySide2"
        
    tool.clear()
    tool.setFixedSize(tool.geometry().width(),tool.geometry().height())
    tool.show()
    
    return tool