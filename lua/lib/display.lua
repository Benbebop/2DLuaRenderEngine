local ini = require( "lib/ini" )

local settings = ini.load( "settings.ini" )

local library = {}

local colorFormat = "[38;5;%dm"

library.send = function( filename )
	
	os.execute("bin\\ffplay frames\\ppm\\" .. filename .. ".ppm")
end

library.run = function( filename, leadingZero )
	if (leadingZero > 9 or leadingZero < 0) or (math.floor(leadingZero) ~= leadingZero) then
		error("leadingZero must be a positive integer and less then 10")
	end
	if settings.render.frames > 0 then
		os.execute("bin\\ffplay -noborder -loop 0 frames\\ppm\\" .. filename .. "%0" .. leadingZero .. "d.ppm")
	end
end

library.save = function( pMatrix, name, toClose )
	os.execute("rmdir /s frames")
	os.execute("mkdir /s frames\\ppm")
	local file, prevlineindex = io.open("frames\\ppm\\" .. name .. ".ppm", "w+"), 1
	file:write("P3\n" .. settings.render.xres .. " " .. settings.render.yres .. "\n255\n")
	local prevCursor = {}
	for i,v in pMatrix.itterate do
		local r, g, b = 0, 0, 0
		if v then
			r, g, b = v:get255()
		end
		local append = " "
		if i.x == settings.render.xres then
			append = "\n"
		end
		file:write(string.format("% 4d% 4d% 4d", math.max( r, 0 ), math.max( g, 0 ), math.max( b, 0 )) .. append)
		prevCursor = i
	end
	
	local filetmp = io.open("bin\\ffmpeg","rb")
	
	if filetmp then
		os.execute("bin\\ffmpeg -hide_banner -loglevel error -y -i frames\\ppm\\" .. name .. ".ppm frames\\" .. name .. ".png")
	end
	
	filetmp:close()
end

return setmetatable( library, {
	__metatable = "the metatable is locked"
})
