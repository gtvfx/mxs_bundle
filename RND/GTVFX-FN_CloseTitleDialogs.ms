fn CloseTitleDialogs =
(
    childWindows = Windows.GetChildrenHWND #max
    qatWindow = (for i in childWindows where i[5]=="QATHwndSource" collect i[1])[1]
    infoCenter = (for i in childWindows where i[5]=="InfoCenterHwndSource" collect i[1])[1]
    UIAccessor.CloseDialog qatWindow
    UIAccessor.CloseDialog infoCenter
)
CloseTitleDialogs()