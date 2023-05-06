local MonUtils = {}

function MonUtils.resetMonitor(monitor, backColor, textColor)
    
    monitor.setTextScale(0.5)
    monitor.setBackgroundColor(backColor or colors.black)   
    monitor.setTextColor(textColor or colors.white)
    monitor.clear()
    monitor.setCursorPos(1,1)
end




return MonUtils