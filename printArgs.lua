local args = {...}
print("Printing all arguments:")
for k,v in pairs(args) do
    print(k,v)
end

print("First argument(key 1)")
print(args[1])
