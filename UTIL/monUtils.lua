local MonUtils = {}

function MonUtils.resetMonitor(monitor)
    
    monitor.setTextScale(0.5)
    monitor.setBackgroundColor(colors.black)   
    monitor.setTextColor(colors.white)
    monitor.clear()
    monitor.setCursorPos(1,1)
end




return MonUtils