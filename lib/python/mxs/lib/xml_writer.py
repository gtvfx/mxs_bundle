import xml.etree.cElementTree as ET

class XMLWriter:
    def __init__(self):
        pass
        
    @classmethod
    def indent(cls, elem, level=0):
        i = "\n" + level*"\t"
        if len(elem):
            if not elem.text or not elem.text.strip():
                elem.text = i + "\t"
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
            for elem in elem:
                cls.indent(elem, level+1)
            if not elem.tail or not elem.tail.strip():
                elem.tail = i
        else:
            if level and (not elem.tail or not elem.tail.strip()):
                elem.tail = i
                
    @staticmethod
    def create_root(tag, **kwargs):
        return ET.Element(tag, **kwargs)
        
    @staticmethod
    def create_subelement(element, tag, **kwargs):
        return ET.SubElement(element, tag, **kwargs)
        
    @classmethod
    def write_file(cls, root, filename):
        tree = ET.ElementTree(root)
        cls.indent(root)
        tree.write(filename)