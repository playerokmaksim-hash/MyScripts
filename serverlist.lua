local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаем GUI
local ScreenGui = Instance.new("ScreenGui")
local CircleFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")

-- Настраиваем GUI
ScreenGui.Parent = playerGui
ScreenGui.Name = "CircleToWindowGUI"
ScreenGui.ResetOnSpawn = false

-- Настраиваем круг
CircleFrame.Size = UDim2.new(0, 70, 0, 70)
CircleFrame.Position = UDim2.new(0, 100, 0, 100)
CircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
CircleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CircleFrame.BorderSizePixel = 0
CircleFrame.Parent = ScreenGui

-- Делаем круг
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = CircleFrame
CircleFrame.BackgroundTransparency = 0

-- Добавляем текст на круг
local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, 0, 1, 0)
Label.Text = "Открыть"
Label.TextColor3 = Color3.fromRGB(0, 0, 0)
Label.BackgroundTransparency = 1
Label.TextScaled = true
Label.Font = Enum.Font.SourceSansBold
Label.Parent = CircleFrame

-- Создаем синее окно (изначально скрыто)
local BlueWindow = Instance.new("Frame")
BlueWindow.Size = UDim2.new(0, 500, 0, 400)
BlueWindow.Position = UDim2.new(0.5, -150, 0.5, -100)
BlueWindow.AnchorPoint = Vector2.new(0.5, 0.5)
BlueWindow.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
BlueWindow.BackgroundTransparency = 0.7
BlueWindow.BorderSizePixel = 2
BlueWindow.BorderColor3 = Color3.fromRGB(0, 0, 150)
BlueWindow.Visible = false
BlueWindow.Parent = ScreenGui

-- Добавляем заголовок окну с возможностью перемещения
local WindowTitle = Instance.new("TextLabel")
WindowTitle.Size = UDim2.new(1, 0, 0, 40)
WindowTitle.Text = "Меню"
WindowTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
WindowTitle.BackgroundColor3 = Color3.fromRGB(0, 0, 100)
WindowTitle.BorderSizePixel = 0
WindowTitle.Font = Enum.Font.SourceSansBold
WindowTitle.TextSize = 20
WindowTitle.Parent = BlueWindow

-- Кнопка закрытия окна
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 120, 0, 40)
CloseButton.Position = UDim2.new(0.5, -60, 1, -50)
CloseButton.Text = "Закрыть"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
CloseButton.BorderSizePixel = 0
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.Parent = BlueWindow

-- Квадратик для изменения размера
local ResizeButton = Instance.new("TextButton")
ResizeButton.Size = UDim2.new(0, 20, 0, 20)
ResizeButton.Position = UDim2.new(1, -25, 1, -25)
ResizeButton.Text = "↔️"
ResizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ResizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
ResizeButton.BorderSizePixel = 1
ResizeButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
ResizeButton.TextSize = 12
ResizeButton.ZIndex = 2
ResizeButton.Parent = BlueWindow

-- Переменные для изменения размера
local resizing = false
local startSize
local startPosition

-- Размеры окна
local MIN_SIZE = UDim2.new(0, 400, 0, 300)
local MAX_SIZE = UDim2.new(0, 1000, 0, 700)

-- Переменные для перемещения
local circleDragging = false
local circleDragInput
local circleDragStart
local circleStartPos
local windowDragging = false
local windowDragInput
local windowDragStart
local windowStartPos

-- Функция для открытия/закрытия окна
local function toggleWindow()
    if BlueWindow.Visible then
        BlueWindow.Visible = false
        CircleFrame.Visible = true
    else
        BlueWindow.Visible = true
        CircleFrame.Visible = false
    end
end

-- Функция обновления позиции круга
local function updateCirclePosition(input)
    local delta = input.Position - circleDragStart
    CircleFrame.Position = UDim2.new(
        circleStartPos.X.Scale, 
        circleStartPos.X.Offset + delta.X,
        circleStartPos.Y.Scale, 
        circleStartPos.Y.Offset + delta.Y
    )
end

-- Функция обновления позиции окна
local function updateWindowPosition(input)
    local delta = input.Position - windowDragStart
    BlueWindow.Position = UDim2.new(
        windowStartPos.X.Scale, 
        windowStartPos.X.Offset + delta.X,
        windowStartPos.Y.Scale, 
        windowStartPos.Y.Offset + delta.Y
    )
end

-- Функция для изменения размера окна
local function updateWindowSize(input)
    if not resizing then return end
    
    local mousePos = input.Position
    local delta = mousePos - startPosition
    
    local newWidth = math.clamp(startSize.X.Offset + delta.X, MIN_SIZE.X.Offset, MAX_SIZE.X.Offset)
    local newHeight = math.clamp(startSize.Y.Offset + delta.Y, MIN_SIZE.Y.Offset, MAX_SIZE.Y.Offset)
    
    BlueWindow.Size = UDim2.new(0, newWidth, 0, newHeight)
end

-- Обработчики для изменения размера
ResizeButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        startPosition = input.Position
        startSize = BlueWindow.Size
        ResizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 200)
    end
end)

ResizeButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
        ResizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and resizing then
        updateWindowSize(input)
    end
end)

-- Обработчики для круга
CircleFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if not circleDragging then
            task.wait(0.2)
            if not circleDragging then
                toggleWindow()
            end
        end
    end
end)

CircleFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        circleDragInput = input
    end
end)

-- Обработчики для перемещения круга
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = input.Position
        local circlePos = CircleFrame.AbsolutePosition
        local circleSize = CircleFrame.AbsoluteSize
        
        if mousePos.X >= circlePos.X and mousePos.X <= circlePos.X + circleSize.X and
           mousePos.Y >= circlePos.Y and mousePos.Y <= circlePos.Y + circleSize.Y then
           
            circleDragging = true
            circleDragStart = input.Position
            circleStartPos = CircleFrame.Position
            CircleFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        circleDragging = false
        CircleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == circleDragInput and circleDragging then
        updateCirclePosition(input)
    end
end)

-- Обработчики для перемещения окна
WindowTitle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        windowDragging = true
        windowDragStart = input.Position
        windowStartPos = BlueWindow.Position
    end
end)

WindowTitle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        windowDragInput = input
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        windowDragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == windowDragInput and windowDragging then
        updateWindowPosition(input)
    end
end)

-- Обработчик клика по кнопке закрытия
CloseButton.MouseButton1Click:Connect(function()
    toggleWindow()
end)

print("✅ Меню загружено! Используйте круг для открытия/перемещения")
