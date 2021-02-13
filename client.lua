local sw,sh = guiGetScreenSize()
local font = dxCreateFont("font.ttf",40)

local dvdScreen = {} --//DVD class defenition

--// Fields
dvdScreen.x = 0
dvdScreen.y = 0
dvdScreen.width = sw/2
dvdScreen.height = sh
dvdScreen.color = tocolor(0,0,0)

dvdScreen.logo = {} --// Logo defenitions

dvdScreen.logo.text = "DVD"
dvdScreen.logo.scale = {1,1}
dvdScreen.logo.font = font
dvdScreen.logo.color = tocolor(255,255,255)
dvdScreen.logo.x,dvdScreen.logo.y = 0,0
dvdScreen.xStep = 1
dvdScreen.yStep = 1

--// Methods
function dvdScreen.create(x,y,w,h,step)
	local newScreen = {}
	setmetatable(newScreen,{__index = dvdScreen})

	newScreen.logo = {}
	newScreen.logo.x = newScreen.x
	newScreen.logo.y = newScreen.y
	newScreen.logo.scale = dvdScreen.logo.scale
	newScreen.logo.color = dvdScreen.logo.color
	newScreen.logo.text = dvdScreen.logo.text
	newScreen.logo.font = dvdScreen.logo.font

	if x then
		newScreen.x = x
		newScreen.logo.x = x
	end
	if y then 
		newScreen.y = y
		newScreen.logo.y = y
	end
	if w then newScreen.w = w end
	if h then newScreen.h = h end
	if step then 
		newScreen.xStep = step
		newScreen.yStep = step
	end
	return newScreen
end

-- check that logo is out of DVD screen background
function dvdScreen:logoIsOverlapping()
	local lw,lh = dxGetTextSize(self.logo.text,0,self.logo.scale[1],self.logo.scale[2],self.logo.font)
	return ( self.logo.x + lw >= self.x + self.width or self.logo.x < self.x),(self.logo.y + lh >= self.y + self.height or self.logo.y < self.y)
end

-- change logo color to random
function dvdScreen:logoChangeColor()
	local r,g,b,a = bitExtract ( self.color, 16, 8 ),bitExtract ( self.color, 8, 8 ),bitExtract ( self.color, 0, 8 ),bitExtract ( self.color, 24, 8 )
	local rL,gL,bL = math.random(0,255),math.random(0,255),math.random(0,255)
	--// IF new color merge with background
	if a >= 230 and rL == r and gL == g and bL == b then
		function minusOrPlus()
			if math.random(1,2) == 1 then 
				return math.random(255)
			else 
				return -math.random(255)
			end
		end
		function toRange(x)
			if x < 0 then 
				return 0
			elseif x > 255 then
				return 255
			else
				return x
			end
		end
		rL = toRange(rL + minusOrPlus())
		gL = toRange(rL + minusOrPlus())
		bL = toRange(rL + minusOrPlus())
		--outputChatBox("Сливается, задний фон - "..r.." "..g.." "..b.."; Цвет текста: "..rL.." "..gL.." "..bL)
	else
		rL,gL,bL = math.random(0,255),math.random(0,255),math.random(0,255)
	end
	self.logo.color = tocolor(rL,gL,bL)
end

function dvdScreen:render()
	dxDrawRectangle(self.x,self.y,self.width,self.height,self.color)
	dxDrawText(self.logo.text,self.logo.x,self.logo.y,nil,nil,self.logo.color,self.logo.scale[1],self.logo.scale[2],self.logo.font)

	--If logo is collapsing then inverse moving about collapsed axis
	local overlappedAxis = {self:logoIsOverlapping()}
	if overlappedAxis[1] or overlappedAxis[2] then
		if(overlappedAxis[1]) then
			self.xStep = -self.xStep
		end
		if(overlappedAxis[2]) then
			self.yStep = -self.yStep
		end
		self:logoChangeColor()
	end

	self.logo.x = self.logo.x + self.xStep
	self.logo.y = self.logo.y + self.yStep
end

local dvdScreens = {}
dvdScreens[1] = dvdScreen.create()
dvdScreens[2] = dvdScreen.create(sw/2)

function renderDvdScreens()
	dvdScreens[1]:render()
	dvdScreens[2]:render()
end
addEventHandler("onClientRender",root,renderDvdScreens)

clearChatBox()