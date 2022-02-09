--[[ All credits go to lua-users user The Doctor for the function @http://lua-users.org/lists/lua-l/2004-09/msg00054.html
    And @https://www.rapidtables.com/convert/number/decimal-to-hex.html for the explanation and showcase
]]
do
    local baseCharacters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" -- Base 62 -- Did you know that all capital letter unicode characters are 2 bytes while lowercases starting after c are 3? micro-optimization. Unfortunately this is all ascii.
    local baseLength = #baseCharacters

	local floor = math.floor
	local abs = math.abs
	local sub = string.sub -- In luau this shouldn't be any more efficient, but I rather type sub than string.sub
    function baseEncode(x, base) -- (x : number base : number) -> string
		assert(base, "Argument 2 missing or nil")
		assert(not (base > baseLength or base < 2), "Base not in range of 2 - " .. baseLength)
		-- add assert for decimals?
		
		local returnString = ""

		local negative = x < 0
		if negative then
			x = abs(x)
		end

        local i = 0
        local remainder
        while x ~= 0 do
            i = i + 1 -- Compound this is luau
			x, remainder = floor(x / base), x % base + 1
            -- remainder = x % base + 1
            -- x = math.floor(x / base)
            returnString = sub(baseCharacters, remainder, remainder) .. returnString
        end
        return (negative and "-" or "") .. returnString
    end

	local find = string.find -- should I hash the string in a table?
	-- decodes to decimal, recode it yourself if you want to. I didn't add decode to base since it would just end up referencing the encode func.
    function baseDecode(s, encodedBase) -- (s : string, encodedBase : number) -> number
		if encodedBase <= 36 then
			s = s:upper()
		end

		local positive = true
		if sub(s, 1, 1) == "-" then
			positive = false
			s = sub(s, 2, -1)
		end

		local returnNumber = 0
		local length = #s

		for i = 1, length do -- wouldn't a while loop be faster? -- I think #s is only evalulated once, definately in luau
			local currentCharacter = sub(s, i, i) -- cache the position in a table? doesn't seem worth it with how short these strings can be.
			
			local characterValue = (find(baseCharacters, currentCharacter) - 1) * encodedBase ^ (length - i)
			returnNumber = returnNumber + characterValue
		end
		return positive and returnNumber or -returnNumber
    end

	function convertBase(s, encodedBase, newBase) -- (s : string, encodedBase : number, newBase : number)
		return baseEncode(baseDecode(s, encodedBase), newBase)
	end
end

-- twitter's 'edit button' tweet: 1370410960394067970 | 19 characters
math.randomseed(os.time())
for i = 1, 20 do math.random() end -- math.random still produces similar results for the first few calls

local function testBase(...) -- bonus function for string formating
	local args = {...}
	local longestNumber, longestEncoded = 0, 0
	
	local formatArgs = {} --table.create(#args) -- doesn't exist in lua 5.1 rip

	for i, x in next, args do -- what an ugly method of printing multiple lines with the same width.
		local encoded = baseEncode(x, 62)

		local numberLength, encodedLength = #tostring(x), #encoded
		if numberLength > longestNumber then
			longestNumber = numberLength
		end
		if encodedLength > longestEncoded then
			longestEncoded = encodedLength
		end

		local position = (i - 1) * 3 + 1
		formatArgs[position] = x
		formatArgs[position + 1] = encoded
		formatArgs[position + 2] = baseDecode(encoded, (62))

		-- print(x .. " == " .. encoded .. " == " .. encoded:fromBase(62))
		-- print(format("%-14s == %-8s == %-14s", x, encoded, encoded:fromBase(62)))
	end
	
	print(-- adds a .0 on Lua 5.3 :\
		("%-" .. longestNumber .. "s == %-" .. longestEncoded .. "s == %s\n")
		:rep(#args)
		:format(table.unpack(formatArgs))
		:sub(1, -2) -- remove the newline at the end of the string
	)
end

testBase(math.random(0, 99999999999), os.time(), 84232, 5222440, 10000, -10000)
print(convertBase("fff", 16, 16))