endIt = false
reset = false
function OnEvent(event, arg)
	if (event == "MOUSE_BUTTON_RELEASED" and arg == 4) then

		-- GUARD TOGGLE TO NOT INFINITE LOOP
		if(endIt and not reset) then
			reset = true
			return
		end

		-- AFTER GUARD, RESET
		if(endIt and reset) then
			endIt = false
			reset = false
		end
		
		Sleep(1000)
		if(not endIt and not reset) then
			repeat
				
				-- random mouse movement
				local x = math.random(65535)
				local y = math.random(65535)
				MoveMouseTo(x,y)

				local moveSlightCount = math.random(5,60)

				-- random mouse jitter
				while(moveSlightCount > 0) do
					x = math.Clamp(x + math.random(-300,300), 0, 65535)
					y = math.Clamp(y + math.random(-300,300), 0, 65535)
					MoveMouseTo(x,y)
					moveSlightCount = moveSlightCount - 1
					Sleep(5)
				end

				-- random alt tab
				local chance = math.random(0,100)
				if(chance > 98) then
					OutputLogMessage("CHANCE!")
					PressKey("lalt")
					Sleep(200)
					PressKey("tab")
					Sleep(math.random(300,1300))
					ReleaseKey("lalt", "tab")
				end

				Sleep(25)

				if(IsMouseButtonPressed(4)) then
					endIt = true
				end
			until endIt
		end
	end
end

function math.Clamp(val, min, max)
    return math.min(math.max(val, min), max)
end
