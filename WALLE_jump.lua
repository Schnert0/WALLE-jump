print("WALL-E jump lua script")
print("created by Schnert0")
print("---")
print("jump with the select button")

-- global variables
input = nil
prevInput = nil
x, y = nil, nil

xVel, yVel, zVel = nil, nil, nil
state = nil
driveX, driveY = nil, nil

canJump = true
cantJump = false

while(true) do
	-- gets the addresses of all the memory variables
	xVel = memory.readdword(0x021D4CB4)+0x90
	yVel = xVel + 4
	zVel = xVel + 8
	
	zPos = memory.readdword(0x021D4CB4)+0x30

	state = memory.readdword(0x021D4CB4) + 0x54
	onSlope = memory.readdword(0x21D4CB4) + 0xCC
	slopeTestX = memory.readdword(0x21D4CB4) + 0x90
	slopeTestY = memory.readdword(0x21D4CB4) + 0x94
	driveX = memory.readdword(0x021D4CB8) + 0x50
	driveY = memory.readdword(0x021D4CB8) + 0x54
	
	-- sets current input to previous input and refreshes current input
	prevInput = input
	input = joypad.get()
	
	slope = memory.readbyte(onSlope)
	testX = memory.readword(slopeTestX)
	testY = memory.readword(slopeTestY)
	
	dX = memory.readword(driveX)
	dY = memory.readword(driveY)
	
	if(input.select and not prevInput.select)then -- has the player pressed the jump button?
		if((memory.readdword(zVel) == 0 and slope == 1) or slope == 2)then
			canJump = true
		end
		
		
		
		if(cantJump and memory.readdword(zVel) == 0)then
			cantJump = false
		end
		
		
		if(canJump and not cantJump)then
			canJump = false
			
			-- turns s16 int s32
			x = memory.readword(driveX)*2
			y = memory.readword(driveY)*2
			
			if(slope > 1 and testX ==0 and testY == 0)then
				cantJump = true
			end
			
			if(bit.band(x, 0x10000) == 0x10000) then
				x = bit.bor(x, 0xfffe0000)
			end
			
			if(bit.band(y, 0x10000) == 0x10000) then
				y = bit.bor(y, 0xfffe0000)
			end
			
			-- writes the modified values into memory
			memory.writedword(xVel, x)
			memory.writedword(yVel, y)
			memory.writebyte(state, 16) -- makes the jump animation
			
			-- sets jump velocity
			memory.writedword(zVel, 0x8000)
		end
	end
	emu.frameadvance()
end