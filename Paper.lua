local uis = game:GetService("UserInputService")
local ts = game:GetService("TweenService")
local rs = game:GetService("RunService")

local httpservice = game:GetService("HttpService")

local mouse = game.Players.LocalPlayer:GetMouse()

local viewport = workspace.CurrentCamera.ViewportSize

local request = http_request or request or (http and http.request) or (syn and syn.request)

local Library = {}

local libraryInitialized = false
local notifHolder = nil

local dragging
local dragInput
local dragStart
local startPos

local lastMousePos
local lastGoalPos
local DRAG_SPEED = (14); -- // The speed of the UI darg.

local b64decode = (syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.decode) or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/GameAnalytics/GA-SDK-ROBLOX/master/GameAnalyticsSDK/GameAnalytics/HttpApi/HashLib/Base64.lua")).Decode

function clickEffect(component)
	ts:Create(component, TweenInfo.new(.05, Enum.EasingStyle.Back), { BackgroundColor3 = Color3.fromRGB(40,40,43) }):Play()
	task.wait(.05)
	ts:Create(component, TweenInfo.new(.05, Enum.EasingStyle.Sine), { BackgroundColor3 = Color3.fromRGB(30,30,33) }):Play()
end

local gui = nil

local function Lerp(a, b, m)
	return a + (b - a) * m
end;

local function Update(dt)
	if not (startPos) then return end;
	if not (dragging) and (lastGoalPos) then
		gui.Position = UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, lastGoalPos.X.Offset, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, lastGoalPos.Y.Offset, dt * DRAG_SPEED))
		return 
	end;

	local delta = (lastMousePos - uis:GetMouseLocation())
	local xGoal = (startPos.X.Offset - delta.X);
	local yGoal = (startPos.Y.Offset - delta.Y);
	lastGoalPos = UDim2.new(startPos.X.Scale, xGoal, startPos.Y.Scale, yGoal)
	gui.Position = UDim2.new(startPos.X.Scale, Lerp(gui.Position.X.Offset, xGoal, dt * DRAG_SPEED), startPos.Y.Scale, Lerp(gui.Position.Y.Offset, yGoal, dt * DRAG_SPEED))
end;

function Library:New(name, titleText)

	if not isfolder("PaperContent") then
		makefolder("PaperContent")
		makefolder("PaperContent\\cfg")

		repotree = game:HttpGetAsync("https://api.github.com/repos/pcunplugged/Paper/git/trees/09b1f4324c1544c042bca5bff027b241aa855897?recursive=1")
		local filelist = {}
		repotree = httpservice:JSONDecode(repotree).tree

		for i,v in next, repotree do
			filelist[#filelist + 1] = {
				path = v.path,
				type = (v.type == "tree" and "folder") or (v.type == "blob" and "file"),
				url = v.url
			}
		end
		
		for i,v in next, filelist do
			if v.type == "folder" then
				print("Creating folder: " .. v.path)
				makefolder("PaperContent\\" .. v.path)
			end

			if v.type == "file" then
				print("Writing file: " .. v.path)
				coroutine.wrap(function()
					writefile("PaperContent\\" .. v.path, b64decode(
						httpservice:JSONDecode(
							game:HttpGetAsync(v.url)
						).content:gsub("\n", "")
					))
				end)()
			end
		end
	end

	local Paper = Instance.new("ScreenGui")
	
	local main = Instance.new("Frame")
	local mainOutline = Instance.new("Frame")
	local nameLabel = Instance.new("TextLabel")
	local tabsHolder = Instance.new("Frame")
	local tabsHolderOutline = Instance.new("Frame")
	local tabsContainer = Instance.new("Frame")
	local tabsContainerLayout = Instance.new("UIListLayout")
	local tabFolder = Instance.new("Folder")
	local notificationHolder = Instance.new("Frame")
	local notificationHolderLayout = Instance.new("UIListLayout")
	local notificationHolderPadding = Instance.new("UIPadding")
	
	Paper.Name = name

	main.Name = "main"
	main.Parent = Paper
	main.AnchorPoint = Vector2.new(0, 0)
	main.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
	main.BorderColor3 = Color3.fromRGB(24, 24, 24)
	main.BorderSizePixel = 2
	main.Position = UDim2.new(0.5, 0, 0.118, 0)
	main.Size = UDim2.new(0, 541, 0, 649)
	main.ZIndex = 0

	mainOutline.Name = "mainOutline"
	mainOutline.Parent = main
	mainOutline.AnchorPoint = Vector2.new(0.5, 0.5)
	mainOutline.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
	mainOutline.BorderColor3 = Color3.fromRGB(44, 44, 44)
	mainOutline.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainOutline.Size = UDim2.new(0, 541, 0, 649)
	mainOutline.ZIndex = 0

	nameLabel.Name = "nameLabel"
	nameLabel.Parent = main
	nameLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.BackgroundTransparency = 1.000
	nameLabel.BorderSizePixel = 0
	nameLabel.Position = UDim2.new(0.0288370773, 0, 0, 0)
	nameLabel.Size = UDim2.new(0, 300, 0, 28)
	nameLabel.Font = Enum.Font.Roboto
	nameLabel.Text = titleText
	nameLabel.TextColor3 = Color3.fromRGB(232, 232, 232)
	nameLabel.TextSize = 14.000
	nameLabel.TextStrokeTransparency = 0.000
	nameLabel.TextWrapped = true
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	tabsContainerLayout.Name = "tabsContainerLayout"
	tabsContainerLayout.Parent = tabsContainer
	tabsContainerLayout.FillDirection = Enum.FillDirection.Horizontal
	tabsContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabsContainerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	tabsContainerLayout.Padding = UDim.new(0, 5)

	tabsHolder.Name = "tabsHolder"
	tabsHolder.Parent = main
	tabsHolder.AnchorPoint = Vector2.new(0.5, 0.5)
	tabsHolder.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
	tabsHolder.BorderColor3 = Color3.fromRGB(44, 44, 44)
	tabsHolder.Position = UDim2.new(0.5, 0, 0.0649999976, 0)
	tabsHolder.Size = UDim2.new(0.949999988, 0, 0.0350000001, 0)

	tabsHolderOutline.Name = "tabsHolderOutline"
	tabsHolderOutline.Parent = tabsHolder
	tabsHolderOutline.AnchorPoint = Vector2.new(0.5, 0.5)
	tabsHolderOutline.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
	tabsHolderOutline.BorderColor3 = Color3.fromRGB(24, 24, 24)
	tabsHolderOutline.BorderSizePixel = 2
	tabsHolderOutline.Position = UDim2.new(0.5, 0, 0.5, 0)
	tabsHolderOutline.Size = UDim2.new(1, 0, 1, 0)
	tabsHolderOutline.ZIndex = 0

	tabsContainer.Name = "tabsContainer"
	tabsContainer.Parent = tabsHolder
	tabsContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	tabsContainer.BackgroundTransparency = 1.000
	tabsContainer.Size = UDim2.new(1, 0, 1, 0)
	
	notificationHolder.Name = "notificationHolder"
	notificationHolder.Parent = Paper
	notificationHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	notificationHolder.BackgroundTransparency = 1.000
	notificationHolder.Size = UDim2.new(0.25, 0, 1, 0)

	notificationHolderLayout.Name = "notificationHolderLayout"
	notificationHolderLayout.Parent = notificationHolder
	notificationHolderLayout.SortOrder = Enum.SortOrder.LayoutOrder
	notificationHolderLayout.Padding = UDim.new(0, 10)

	notificationHolderPadding.Name = "notificationHolderPadding"
	notificationHolderPadding.Parent = notificationHolder
	notificationHolderPadding.PaddingBottom = UDim.new(0, 10)
	notificationHolderPadding.PaddingLeft = UDim.new(0, 10)
	notificationHolderPadding.PaddingRight = UDim.new(0, 5)
	notificationHolderPadding.PaddingTop = UDim.new(0, 10)
	
	notifHolder = notificationHolder
	
	tabFolder.Name = "Tabs"
	tabFolder.Parent = main
	
	gui = main
	
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			lastMousePos = uis:GetMouseLocation()

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	rs.Heartbeat:Connect(Update)
	
	local Tab = {}
	
	function Tab:NewTab(tabName, visible)
		local tab = Instance.new("Frame")
		local tabOutline = Instance.new("Frame")
		local tabContainer = Instance.new("ScrollingFrame")
		local tabContainerPadding = Instance.new("UIPadding")
		local tabContainerLayout = Instance.new("UIListLayout")
		
		local tabButton = Instance.new("TextButton")
		local tabButtonOutline = Instance.new("Frame")
		
		tab.Name = tabName
		tab.Parent = tabFolder
		tab.AnchorPoint = Vector2.new(0.5, 0.5)
		tab.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
		tab.BorderColor3 = Color3.fromRGB(44, 44, 44)
		tab.Position = UDim2.new(0.5, 0, 0.540000021, 0)
		tab.Size = UDim2.new(0.949999988, 0, 0.899999976, 0)
		tab.Visible = visible or false
		
		tabOutline.Name = "tabOutline"
		tabOutline.Parent = tab
		tabOutline.AnchorPoint = Vector2.new(0.5, 0.5)
		tabOutline.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
		tabOutline.BorderColor3 = Color3.fromRGB(24, 24, 24)
		tabOutline.BorderSizePixel = 2
		tabOutline.Position = UDim2.new(0.5, 0, 0.5, 0)
		tabOutline.Size = UDim2.new(1, 0, 1, 0)
		tabOutline.ZIndex = 0

		tabContainer.Name = "tabContainer"
		tabContainer.Parent = tab
		tabContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		tabContainer.BackgroundTransparency = 1.000
		tabContainer.Selectable = false
		tabContainer.Size = UDim2.new(1, 0, 1, 0)
		tabContainer.CanvasSize = UDim2.new(0, 0, 1, 0)
		tabContainer.ScrollBarThickness = 0
		tabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y

		tabContainerPadding.Name = "tabContainerPadding"
		tabContainerPadding.Parent = tabContainer
		tabContainerPadding.PaddingBottom = UDim.new(0, 10)
		tabContainerPadding.PaddingTop = UDim.new(0, 10)
		
		tabContainerLayout.Name = "tabContainerLayout"
		tabContainerLayout.Parent = tabContainer
		tabContainerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		tabContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabContainerLayout.Padding = UDim.new(0, 15)


		tabButton.Name = tabName
		tabButton.Parent = tabsContainer
		tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
		tabButton.BorderColor3 = Color3.fromRGB(44, 44, 44)
		tabButton.Size = UDim2.new(0, 50, 1, 0)
		tabButton.ZIndex = 3
		tabButton.AutoButtonColor = false
		tabButton.Font = Enum.Font.Roboto
		tabButton.Text = tabName
		tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		tabButton.TextSize = 14.000
		tabButton.TextStrokeTransparency = 0.000
		
		if visible then
			tabButton.BackgroundColor3 = Color3.fromRGB(40,40,43)
		else
			tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
		end

		tabButtonOutline.Name = "tabButtonOutline"
		tabButtonOutline.Parent = tabButton
		tabButtonOutline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		tabButtonOutline.BorderColor3 = Color3.fromRGB(24, 24, 24)
		tabButtonOutline.BorderSizePixel = 2
		tabButtonOutline.Size = UDim2.new(1, 0, 1, 0)
		tabButtonOutline.ZIndex = 2
		
		tabButton.MouseButton1Click:Connect(function()
			for	_, v in pairs(tabFolder:GetChildren()) do
				if v:IsA("UIListLayout") then continue end
				
				if v.Name ~= tabName then
					v.Visible = false
				else
					v.Visible = true
				end
			end
			
			for	_, v in pairs(tabsContainer:GetChildren()) do
				if v:IsA("UIListLayout") then continue end
				
				if v.Name ~= tabName then
					ts:Create(v, TweenInfo.new(.1, Enum.EasingStyle.Sine), { BackgroundColor3 = Color3.fromRGB(30,30,33) }):Play()
				else
					ts:Create(v, TweenInfo.new(.1, Enum.EasingStyle.Sine), { BackgroundColor3 = Color3.fromRGB(40,40,43) }):Play()
				end
			end
		end)
		
		local Section = {}
		
		function Section:NewSection(sectionText)
			local section = Instance.new("Frame")
			local sectionContainer = Instance.new("Frame")
			local sectionName = Instance.new("TextLabel")
			local sectionContainerPadding = Instance.new("UIPadding")
			local sectionOutline = Instance.new("Frame")
			local sectionContainerLayout = Instance.new("UIListLayout")
			
			section.Name = sectionText
			section.Parent = tabContainer
			section.AnchorPoint = Vector2.new(0.5, 0.5)
			section.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
			section.BorderColor3 = Color3.fromRGB(44, 44, 44)
			section.Position = UDim2.new(0, 250, 0, 0)
			section.Size = UDim2.new(0, 500, 0, 100)
			section.ZIndex = 5
			section.AutomaticSize = Enum.AutomaticSize.Y

			sectionContainer.Name = "sectionContainer"
			sectionContainer.Parent = section
			sectionContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			sectionContainer.BackgroundTransparency = 1.000
			sectionContainer.Size = UDim2.new(1, 0, 1, 0)
			sectionContainer.ZIndex = 6

			sectionName.Name = "sectionName"
			sectionName.Parent = sectionContainer
			sectionName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			sectionName.BackgroundTransparency = 1.000
			sectionName.Size = UDim2.new(0, 100, 0, 25)
			sectionName.ZIndex = 6
			sectionName.Font = Enum.Font.Roboto
			sectionName.Text = sectionText
			sectionName.TextColor3 = Color3.fromRGB(255, 255, 255)
			sectionName.TextSize = 14.000
			sectionName.TextStrokeTransparency = 0.000

			sectionContainerPadding.Name = "sectionContainerPadding"
			sectionContainerPadding.Parent = sectionContainer
			sectionContainerPadding.PaddingBottom = UDim.new(0, 5)
			sectionContainerPadding.PaddingLeft = UDim.new(0, 5)
			sectionContainerPadding.PaddingRight = UDim.new(0, 5)
			sectionContainerPadding.PaddingTop = UDim.new(0, 5)
			
			sectionOutline.Name = "sectionOutline"
			sectionOutline.Parent = section
			sectionOutline.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
			sectionOutline.BorderColor3 = Color3.fromRGB(24, 24, 24)
			sectionOutline.BorderSizePixel = 2
			sectionOutline.Size = UDim2.new(1, 0, 1, 0)
			sectionOutline.ZIndex = 4
			sectionOutline.AutomaticSize = Enum.AutomaticSize.Y
			
			sectionContainerLayout.Name = "sectionContainerLayout"
			sectionContainerLayout.Parent = sectionContainer
			sectionContainerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			sectionContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
			sectionContainerLayout.Padding = UDim.new(0, 5)
			
			local SectionTools = {}
			
			function SectionTools:NewButton(buttonText, callback)
				local button = Instance.new("TextButton")
				local buttonOutline = Instance.new("Frame")
				
				button.Name = "button"
				button.Parent = sectionContainer
				button.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
				button.BorderColor3 = Color3.fromRGB(44, 44, 44)
				button.Size = UDim2.new(1, 0, 0, 25)
				button.ZIndex = 6
				button.AutoButtonColor = false
				button.Font = Enum.Font.Roboto
				button.Text = buttonText
				button.TextColor3 = Color3.fromRGB(255, 255, 255)
				button.TextSize = 14.000
				button.TextStrokeTransparency = 0.000

				buttonOutline.Name = "buttonOutline"
				buttonOutline.Parent = button
				buttonOutline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				buttonOutline.BorderColor3 = Color3.fromRGB(24, 24, 24)
				buttonOutline.BorderSizePixel = 2
				buttonOutline.Size = UDim2.new(1, 0, 1, 0)
				buttonOutline.ZIndex = 5
				
				button.MouseButton1Click:Connect(function()
					clickEffect(button)
					
					callback()
				end)
				
				local ButtonFuncs = {}
				
				function ButtonFuncs:Hide()
					button.Visible = false
				end
				
				return ButtonFuncs
			end
			
			function SectionTools:NewToggle(toggleText, callback)
				local toggleLabel = Instance.new("TextLabel")
				local toggleButton = Instance.new("TextButton")
				local toggleButtonOutline = Instance.new("Frame")
				local UICorner = Instance.new("UICorner")
				local UICorner_2 = Instance.new("UICorner")
				local toggleButtonStroke = Instance.new("UIStroke")
				local toggleButtonOutlineStroke = Instance.new("UIStroke")
				
				local toggledButtonFrame = Instance.new("Frame")
				local toggledButtonFrameCorner = Instance.new("UICorner")
				--local toggledButtonFrameGradient = Instance.new("UIGradient")
				
				local toggled = false
				local toggleDebounce = false
				
				toggleLabel.Name = toggleText
				toggleLabel.Parent = sectionContainer
				toggleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				toggleLabel.BackgroundTransparency = 1.000
				toggleLabel.Position = UDim2.new(0.063000001, 5, 0.649999976, 0)
				toggleLabel.Size = UDim2.new(0.918367326, 0, 0, 25)
				toggleLabel.ZIndex = 6
				toggleLabel.Font = Enum.Font.Roboto
				toggleLabel.Text = toggleText
				toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				toggleLabel.TextSize = 14.000
				toggleLabel.TextStrokeTransparency = 0.000
				toggleLabel.TextXAlignment = Enum.TextXAlignment.Left

				toggleButton.Name = "toggleButton"
				toggleButton.Parent = toggleLabel
				toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
				toggleButton.BorderColor3 = Color3.fromRGB(44, 44, 44)
				toggleButton.Position = UDim2.new(0, -20, 0, 5)
				toggleButton.Size = UDim2.new(0, 15, 0, 15)
				toggleButton.ZIndex = 6
				toggleButton.AutoButtonColor = false
				toggleButton.Font = Enum.Font.Roboto
				toggleButton.Text = ""
				toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				toggleButton.TextSize = 14.000
				toggleButton.TextStrokeTransparency = 0.000

				toggleButtonOutline.Name = "toggleButtonOutline"
				toggleButtonOutline.Parent = toggleButton
				toggleButtonOutline.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
				toggleButtonOutline.BorderColor3 = Color3.fromRGB(24, 24, 24)
				toggleButtonOutline.BorderSizePixel = 2
				toggleButtonOutline.Size = UDim2.new(1, 0, 1, 0)
				toggleButtonOutline.ZIndex = 5

				UICorner.CornerRadius = UDim.new(0, 2)
				UICorner.Parent = toggleButtonOutline

				UICorner_2.CornerRadius = UDim.new(0, 2)
				UICorner_2.Parent = toggleButton
				
				toggleButtonStroke.Parent = toggleButton
				toggleButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				toggleButtonStroke.Color = Color3.fromRGB(44,44,44)
				toggleButtonStroke.Thickness = 1
				
				toggleButtonOutlineStroke.Parent = toggleButtonOutline
				toggleButtonOutlineStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				toggleButtonOutlineStroke.Color = Color3.fromRGB(24,24,24)
				toggleButtonOutlineStroke.Thickness = 2
				
				toggledButtonFrame.Name = "toggledButtonFrame"
				toggledButtonFrame.Parent = toggleButton
				toggledButtonFrame.BackgroundColor3 = Color3.fromRGB(49, 49, 59)
				toggledButtonFrame.BorderColor3 = Color3.fromRGB(24, 24, 24)
				toggledButtonFrame.BorderSizePixel = 2
				toggledButtonFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
				toggledButtonFrame.Size = UDim2.new(0, 0, 0, 0) -- full size = (0, 11, 0, 10), small size = (0,0,0,0)
				toggledButtonFrame.ZIndex = 7
				toggledButtonFrame.AnchorPoint = Vector2.new(.5,.5)
				toggledButtonFrame.Visible = false
				

				toggledButtonFrameCorner.CornerRadius = UDim.new(0, 2)
				toggledButtonFrameCorner.Name = "toggledButtonFrameCorner"
				toggledButtonFrameCorner.Parent = toggledButtonFrame

				--[[toggledButtonFrameGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(20, 20, 24)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(24, 24, 28))}
				toggledButtonFrameGradient.Rotation = -90
				toggledButtonFrameGradient.Name = "toggledButtonFrameGradient"
				toggledButtonFrameGradient.Parent = toggledButtonFrame]]
				
				toggleButton.MouseButton1Click:Connect(function()
					if toggleDebounce then return end
					
					if toggled == false then
						toggled = true
						
						toggledButtonFrame.Visible = true
						ts:Create(toggledButtonFrame, TweenInfo.new(.25, Enum.EasingStyle.Sine), { Size = UDim2.new(0, 11, 0, 11) }):Play()
					else
						toggled = false
						
						toggleDebounce = true
						
						ts:Create(toggledButtonFrame, TweenInfo.new(.25, Enum.EasingStyle.Sine), { Size = UDim2.new(0,0,0,0) }):Play()
						task.wait(.24)
						toggledButtonFrame.Visible = false
						
						toggleDebounce = false
					end
					
					callback(toggled)
				end)
			end
			
			function SectionTools:NewSlider(sliderText, min, max, default, callback)
				local sliderFrame = Instance.new("Frame")
				local sliderOutline = Instance.new("Frame")
				local sliderValue = Instance.new("TextLabel")
				local sliderName = Instance.new("TextLabel")
				local sliderHolder = Instance.new("Frame")
				local sliderHolderCorner = Instance.new("UICorner")
				local slider = Instance.new("Frame")
				local sliderCorner = Instance.new("UICorner")
				
				sliderFrame.Name = sliderName
				sliderFrame.Parent = sectionContainer
				sliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
				sliderFrame.BorderColor3 = Color3.fromRGB(44, 44, 44)
				sliderFrame.Size = UDim2.new(1, 0, 0, 35)
				sliderFrame.ZIndex = 6

				sliderOutline.Name = "sliderOutline"
				sliderOutline.Parent = sliderFrame
				sliderOutline.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
				sliderOutline.BorderColor3 = Color3.fromRGB(24, 24, 24)
				sliderOutline.BorderSizePixel = 2
				sliderOutline.Size = UDim2.new(1, 0, 1, 0)
				sliderOutline.ZIndex = 5

				sliderValue.Name = "sliderValue"
				sliderValue.Parent = sliderFrame
				sliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				sliderValue.BackgroundTransparency = 1.000
				sliderValue.Position = UDim2.new(0, 225, 0, -5)
				sliderValue.Size = UDim2.new(1, 0, 1, 0)
				sliderValue.ZIndex = 7
				sliderValue.Font = Enum.Font.Roboto
				sliderValue.Text = default
				sliderValue.TextColor3 = Color3.fromRGB(255, 255, 255)
				sliderValue.TextSize = 14.000
				sliderValue.TextStrokeTransparency = 0.000

				sliderName.Name = "sliderName"
				sliderName.Parent = sliderFrame
				sliderName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				sliderName.BackgroundTransparency = 1.000
				sliderName.Size = UDim2.new(1, 0, 1, -35)
				sliderName.ZIndex = 7
				sliderName.Font = Enum.Font.Roboto
				sliderName.Text = sliderName
				sliderName.TextColor3 = Color3.fromRGB(255, 255, 255)
				sliderName.TextSize = 14.000
				sliderName.TextStrokeTransparency = 0.000

				sliderHolder.Name = "sliderHolder"
				sliderHolder.Parent = sliderFrame
				sliderHolder.AnchorPoint = Vector2.new(0.5, 0.5)
				sliderHolder.BackgroundColor3 = Color3.fromRGB(15, 15, 16)
				sliderHolder.BorderColor3 = Color3.fromRGB(24, 24, 24)
				sliderHolder.BorderSizePixel = 0
				sliderHolder.Position = UDim2.new(0.5, 0, 0.75, 0)
				sliderHolder.Size = UDim2.new(0.949999988, 0, 0, 10)
				sliderHolder.ZIndex = 6

				sliderHolderCorner.CornerRadius = UDim.new(0, 10)
				sliderHolderCorner.Name = "sliderHolderCorner"
				sliderHolderCorner.Parent = sliderHolder

				slider.Name = "slider"
				slider.Parent = sliderHolder
				slider.BackgroundColor3 = Color3.fromRGB(41, 41, 44)
				slider.BorderColor3 = Color3.fromRGB(24, 24, 24)
				slider.BorderSizePixel = 0
				slider.Size = UDim2.new(0.5, 0, 1, 0)
				slider.ZIndex = 6

				sliderCorner.CornerRadius = UDim.new(0, 10)
				sliderCorner.Name = "sliderCorner"
				sliderCorner.Parent = slider
			end
			
			function SectionTools:NewDropdown(dropdownName, default, callback)
				local dropdownFrame = Instance.new("Frame")
				local dropdownOutline = Instance.new("Frame")
				local dropdownTitle = Instance.new("TextLabel")
				local dropdownButton = Instance.new("TextButton")
				local dropdownButtonOutline = Instance.new("Frame")
				local dropdownPadding = Instance.new("UIPadding")
				local dropdownOptions = Instance.new("ScrollingFrame")
				local dropdownOptionsPadding = Instance.new("UIPadding")
				local dropdownOptionsLayout = Instance.new("UIListLayout")
				local dropdownOptionButton = Instance.new("TextButton")
				local dropdownOptionButtonOutline = Instance.new("Frame")
				
				dropdownFrame.Name = "dropdownFrame"
				dropdownFrame.Parent = sectionContainer
				dropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
				dropdownFrame.BorderColor3 = Color3.fromRGB(44, 44, 44)
				dropdownFrame.Position = UDim2.new(0.0100000612, 0, 0.476873726, 0)
				dropdownFrame.Size = UDim2.new(0.999999881, 0, 0.341259956, 50)
				dropdownFrame.ZIndex = 7

				dropdownOutline.Name = "dropdownOutline"
				dropdownOutline.Parent = dropdownFrame
				dropdownOutline.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
				dropdownOutline.BorderColor3 = Color3.fromRGB(24, 24, 24)
				dropdownOutline.BorderSizePixel = 2
				dropdownOutline.Size = UDim2.new(1, 0, 1, 0)
				dropdownOutline.ZIndex = 6

				dropdownTitle.Name = "dropdownTitle"
				dropdownTitle.Parent = dropdownFrame
				dropdownTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				dropdownTitle.BackgroundTransparency = 1.000
				dropdownTitle.Size = UDim2.new(1, 0, 0, 25)
				dropdownTitle.ZIndex = 10
				dropdownTitle.Font = Enum.Font.Roboto
				dropdownTitle.Text = "Dropdown"
				dropdownTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
				dropdownTitle.TextSize = 14.000
				dropdownTitle.TextStrokeTransparency = 0.000

				dropdownButton.Name = "dropdownButton"
				dropdownButton.Parent = dropdownFrame
				dropdownButton.AnchorPoint = Vector2.new(0.5, 0.5)
				dropdownButton.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
				dropdownButton.BorderColor3 = Color3.fromRGB(44, 44, 44)
				dropdownButton.Position = UDim2.new(0, 245, 0, 51)
				dropdownButton.Size = UDim2.new(0, 100, 0, 20)
				dropdownButton.ZIndex = 8
				dropdownButton.AutoButtonColor = false
				dropdownButton.Font = Enum.Font.Roboto
				dropdownButton.Text = "Dropdown Menu Option #1"
				dropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				dropdownButton.TextSize = 14.000
				dropdownButton.TextStrokeTransparency = 0.000

				dropdownButtonOutline.Name = "dropdownButtonOutline"
				dropdownButtonOutline.Parent = dropdownButton
				dropdownButtonOutline.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
				dropdownButtonOutline.BorderColor3 = Color3.fromRGB(24, 24, 24)
				dropdownButtonOutline.BorderSizePixel = 2
				dropdownButtonOutline.Size = UDim2.new(1, 0, 1, 0)
				dropdownButtonOutline.ZIndex = 7

				dropdownPadding.Name = "dropdownPadding"
				dropdownPadding.Parent = dropdownFrame
				dropdownPadding.PaddingBottom = UDim.new(0, 5)

				dropdownOptions.Name = "dropdownOptions"
				dropdownOptions.Parent = dropdownFrame
				dropdownOptions.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
				dropdownOptions.BorderColor3 = Color3.fromRGB(44, 44, 44)
				dropdownOptions.Position = UDim2.new(0, 145, 0, 70)
				dropdownOptions.Selectable = false
				dropdownOptions.Size = UDim2.new(0, 200, 0, 65)
				dropdownOptions.ZIndex = 8
				dropdownOptions.CanvasSize = UDim2.new(0, 0, 1, 0)
				dropdownOptions.ScrollBarThickness = 0

				dropdownOptionsPadding.Name = "dropdownOptionsPadding"
				dropdownOptionsPadding.Parent = dropdownOptions
				dropdownOptionsPadding.PaddingBottom = UDim.new(0, 5)
				dropdownOptionsPadding.PaddingTop = UDim.new(0, 5)

				dropdownOptionsLayout.Name = "dropdownOptionsLayout"
				dropdownOptionsLayout.Parent = dropdownOptions
				dropdownOptionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				dropdownOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
				dropdownOptionsLayout.Padding = UDim.new(0, 5)

				dropdownOptionButton.Name = "dropdownOptionButton"
				dropdownOptionButton.Parent = dropdownOptions
				dropdownOptionButton.AnchorPoint = Vector2.new(0.5, 0.5)
				dropdownOptionButton.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
				dropdownOptionButton.BorderColor3 = Color3.fromRGB(44, 44, 44)
				dropdownOptionButton.Position = UDim2.new(0, 100, 0, 15)
				dropdownOptionButton.Size = UDim2.new(0, 100, 0, 20)
				dropdownOptionButton.ZIndex = 9
				dropdownOptionButton.AutoButtonColor = false
				dropdownOptionButton.Font = Enum.Font.Roboto
				dropdownOptionButton.Text = "Dropdown Menu Option #1"
				dropdownOptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
				dropdownOptionButton.TextSize = 14.000
				dropdownOptionButton.TextStrokeTransparency = 0.000

				dropdownOptionButtonOutline.Name = "dropdownOptionButtonOutline"
				dropdownOptionButtonOutline.Parent = dropdownOptionButton
				dropdownOptionButtonOutline.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
				dropdownOptionButtonOutline.BorderColor3 = Color3.fromRGB(24, 24, 24)
				dropdownOptionButtonOutline.BorderSizePixel = 2
				dropdownOptionButtonOutline.Size = UDim2.new(1, 0, 1, 0)
				dropdownOptionButtonOutline.ZIndex = 8
			end
			
			return SectionTools
		end
		
		return Section
	end
	
	if syn then
		syn.protect_gui(Paper)
		
		Paper.Parent = game.CoreGui
	end
	
	libraryInitialized = true --// idk if this works
	
	return Tab
end

function Library:Notify(title, text, limit, soundID)
	if not libraryInitialized or notifHolder == nil then warn("Paper isn't initialized! Notifications can't be used until you have a main ui!") return end
	
	local notification = Instance.new("Frame")
	local notificationOutline = Instance.new("Frame")
	local notificationOutlineCorner = Instance.new("UICorner")
	local notificationCorner = Instance.new("UICorner")
	local notificationContainer = Instance.new("Frame")
	local notificationTitle = Instance.new("TextLabel")
	local notificationContainerPadding = Instance.new("UIPadding")
	local notificationText = Instance.new("TextLabel")
	local timeLimitFrame = Instance.new("Frame")
	local timeLimitFrameCorner = Instance.new("UICorner")
	local timeLimit = Instance.new("Frame")
	local timeLimitCorner = Instance.new("UICorner")
	
	local sound = Instance.new("Sound")
	
	limit = limit or 5
	
	soundID = getsynasset(soundID) or ""


	
	notification.Name = "notification"
	notification.Parent = notifHolder
	notification.BackgroundColor3 = Color3.fromRGB(30, 30, 33)
	notification.Position = UDim2.new(-3.38423491, 0, 0.478015631, 0)
	notification.Size = UDim2.new(1, 0, 0, 65)
	notification.AutomaticSize = Enum.AutomaticSize.Y
	notification.ZIndex = -1

	notificationOutline.Name = "notificationOutline"
	notificationOutline.Parent = notification
	notificationOutline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	notificationOutline.Size = UDim2.new(1, 0, 1, 0)
	notificationOutline.ZIndex = -2
	notificationOutline.AutomaticSize = Enum.AutomaticSize.Y

	notificationOutlineCorner.CornerRadius = UDim.new(0, 4)
	notificationOutlineCorner.Name = "notificationOutlineCorner"
	notificationOutlineCorner.Parent = notificationOutline

	notificationCorner.CornerRadius = UDim.new(0, 4)
	notificationCorner.Name = "notificationCorner"
	notificationCorner.Parent = notification

	notificationContainer.Name = "notificationContainer"
	notificationContainer.Parent = notification
	notificationContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	notificationContainer.BackgroundTransparency = 1.000
	notificationContainer.Size = UDim2.new(1, 0, 1, 0)
	notification.ZIndex = -1

	notificationTitle.Name = "notificationTitle"
	notificationTitle.Parent = notificationContainer
	notificationTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	notificationTitle.BackgroundTransparency = 1.000
	notificationTitle.Size = UDim2.new(1, 0, 0, 25)
	notificationTitle.Font = Enum.Font.Roboto
	notificationTitle.Text = title
	notificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	notificationTitle.TextSize = 14.000
	notificationTitle.TextStrokeTransparency = 0.000
	notificationTitle.TextXAlignment = Enum.TextXAlignment.Left
	notificationTitle.ZIndex = -1

	notificationContainerPadding.Name = "notificationContainerPadding"
	notificationContainerPadding.Parent = notificationContainer
	notificationContainerPadding.PaddingBottom = UDim.new(0, 15)
	notificationContainerPadding.PaddingLeft = UDim.new(0, 5)
	notificationContainerPadding.PaddingRight = UDim.new(0, 5)

	notificationText.Name = "notificationText"
	notificationText.Parent = notificationContainer
	notificationText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	notificationText.BackgroundTransparency = 1.000
	notificationText.Position = UDim2.new(0, 0, 0, 25)
	notificationText.Size = UDim2.new(1, 0, 0, 25)
	notificationText.Font = Enum.Font.Roboto
	notificationText.Text = text
	notificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
	notificationText.TextSize = 14.000
	notificationText.TextStrokeTransparency = 0.000
	notificationText.TextWrapped = true
	notificationText.TextXAlignment = Enum.TextXAlignment.Left
	notificationText.AutomaticSize = Enum.AutomaticSize.Y
	notificationText.ZIndex = -1

	timeLimitFrame.Name = "timeLimitFrame"
	timeLimitFrame.Parent = notificationContainer
	timeLimitFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
	timeLimitFrame.Position = UDim2.new(0, 0, 1, 5)
	timeLimitFrame.Size = UDim2.new(0.929, 0, 0.077, 0)
	timeLimitFrame.ZIndex = -1

	timeLimitFrameCorner.Name = "timeLimitFrameCorner"
	timeLimitFrameCorner.Parent = timeLimitFrame

	timeLimit.Name = "timeLimit"
	timeLimit.Parent = timeLimitFrame
	timeLimit.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
	timeLimit.Size = UDim2.new(1, 0, 1, 0)
	timeLimit.ZIndex = -1

	timeLimitCorner.Name = "timeLimitCorner"
	timeLimitCorner.Parent = timeLimit
	
	sound.Volume = 1
	sound.SoundId = soundID
	sound.Parent = timeLimit
	
	sound.PlayOnRemove = true
	
	sound:Destroy() --// aka sound:Play(), i need to remember this.
	
	ts:Create(timeLimit, TweenInfo.new(limit, Enum.EasingStyle.Quad), { Size = UDim2.new(0,0,1,0) }):Play()
	
	task.wait(limit)
	
	notification:Destroy()
end

return Library
