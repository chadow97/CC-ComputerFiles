local mePeripheral = peripheral.find("meBridge")
print(mePeripheral)
for a,b in pairs(mePeripheral) do
    textutils.pagedPrint(a)
end
print("a")

