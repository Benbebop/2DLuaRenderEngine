local ini, renderScript, Matrix, Color, Frame, Display, Metaball = require( "lib/ini" ), require( "render" ), require( "lib/class/matrix" ), require( "lib/class/color" ), require( "lib/frame" ), require( "lib/display" ), require( "lib/class/metaball" )
local settings = ini.load( "settings.ini" )
local dmode = settings.misc.debug

local subMatrix = Matrix.new()

if settings.render.ssaa <= 1 then settings.render.ssaa = 1 end

Frame.onFrame(function( frame )
	local tIndex = 0
	local stamp1 = os.clock()
	for y=1,settings.render.yres do
		for x=1,settings.render.xres do
			tIndex = tIndex + 1
			subMatrix.set( Color.new( renderScript( x, y, frame, tIndex ) ), x, y )
		end
	end
	local pMatrix, res = true, settings.render.ssaa
	if res > 1 then
		pMatrix = Matrix.new()
		for y=1,settings.render.yres / res do
			for x=1,settings.render.xres / res do
				local blockColor = Color.new()
				for i=1,res do
					for l=1,res do
						blockColor = Color.new( blockColor.average( subMatrix.get( x * res + i, y * res + l ) ) )
					end
				end
				pMatrix.set( blockColor, x, y)
			end
		end
	else
		pMatrix = subMatrix
	end
	local duration = os.clock() - stamp1
	local frameIndex = string.format("frame%04d", frame)
	Display.save( pMatrix, frameIndex )
	io.write("rendered frame ", frame, " in ", math.floor( duration * 100 ), " ms\n")
end)

Frame.run( settings.render.frames, true )

Display.run( "frame", 4 )