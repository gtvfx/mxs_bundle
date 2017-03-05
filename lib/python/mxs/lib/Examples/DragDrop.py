from PySide import QtCore, QtGui
import os, sys
from gen.lib import pyside_uiloader


class DragDrop(QtGui.QMainWindow):

    def __init__(self, parent=None):
        super(self.__class__, self).__init__(parent)
        pyside_uiloader.loadUi(self.getUiFile(), self)
        
    def getUiFile(self):
        '''
        Assumes:
        The UI file is in a subdirectory of the current files directory and that subdirectory is named 'ui'
        The name of the UI file is the same as the class
        '''
        UI = r"{0}\\ui\\{1}.ui".format(os.path.dirname(__file__), self.__class__.__name__)
        print UI
        return UI
        
    def dragEnterEvent(self, event):
        print 'dragEnterEvent'
        if event.mimeData().hasUrls():
            event.accept()
        else:
            event.ignore()
            
    def dragMoveEvent(self, event):
        print 'dragMoveEvent'
        if event.mimeData().hasUrls():
            event.accept()
        else:
            event.ignore()
    
    def dropEvent(self, event):
        print 'dropEvent'
    
        if event.mimeData().hasUrls:
            hoverWidget = self.childAt(event.pos())
            print 'Drop Child: {0}'.format(hoverWidget)
            
            event.setDropAction(QtCore.Qt.CopyAction)
            event.accept()

            fname = event.mimeData().urls()[0].toLocalFile()
            
            hoverWidget.setText(fname)
        else:
            event.ignore()
               


def Run():
    import MaxPlus
    ex = DragDrop(parent=MaxPlus.GetQMaxWindow())
    ex.move(800,400)
    ex.show()
    print 'Drag and drop appropriate files into corresponding slots'
            
            
if __name__ == "__main__":
    print 'Drag and drop appropriate files into corresponding slots'
    app = QtGui.QApplication(sys.argv)
    tool = DragDrop()
    tool.show()
    sys.exit(app.exec_())