local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
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
BlueWindow.Position = UDim2.new(0.5, -250, 0.5, -200)
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
WindowTitle.Text = "Меню серверов (перетащи)"
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

-- Кнопка обновления серверов
local RefreshButton = Instance.new("TextButton")
RefreshButton.Size = UDim2.new(0, 120, 0, 40)
RefreshButton.Position = UDim2.new(0.5, -60, 1, -100)
RefreshButton.Text = "🔄 Обновить"
RefreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
RefreshButton.BorderSizePixel = 0
RefreshButton.Font = Enum.Font.SourceSansBold
RefreshButton.TextSize = 18
RefreshButton.Parent = BlueWindow

-- Контейнер для списка серверов
local ServersContainer = Instance.new("ScrollingFrame")
ServersContainer.Size = UDim2.new(0.9, 0, 0.7, 0)
ServersContainer.Position = UDim2.new(0.05, 0, 0.15, 0)
ServersContainer.BackgroundTransparency = 1
ServersContainer.BorderSizePixel = 0
ServersContainer.ScrollBarThickness = 8
ServersContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ServersContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ServersContainer.Parent = BlueWindow

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ServersContainer

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
local MAX_SIZE = UDim2.new(0, 1200, 0, 800)

-- Переменные для перемещения
local circleDragging = false
local circleDragInput
local circleDragStart
local circleStartPos
local windowDragging = false
local windowDragInput
local windowDragStart
local windowStartPos

-- ЗАМЕНИТЕ ЭТОТ ID НА РЕАЛЬНЫЙ ID ИГРЫ "STEAL A BRAINROT"!
-- Найти ID можно в URL игры: https://www.roblox.com/games/123456789/Game-Name
local GAME_ID = 109983668079237  -- Это пример, замените на правильный!

-- Функция для получения информации о серверах
local function getServers()
    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. GAME_ID .. "/servers/Public?limit=100"
        local response = game:HttpGet(url)
        return HttpService:JSONDecode(response)
    end)
    
    if success and result and result.data then
        return result.data
    else
        warn("Ошибка получения серверов: ", result)
        return {}
    end
end

-- Функция для создания кнопки сервера
local function createServerButton(server, index)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 50)
    button.Text = ""
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 100)
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.fromRGB(100, 100, 200)
    button.AutoButtonColor = false
    
    local playersText = Instance.new("TextLabel")
    playersText.Size = UDim2.new(0.3, 0, 1, 0)
    playersText.Position = UDim2.new(0.7, 0, 0, 0)
    playersText.Text = server.playing .. "/" .. server.maxPlayers
    playersText.TextColor3 = Color3.fromRGB(255, 255, 255)
    playersText.BackgroundTransparency = 1
    playersText.Font = Enum.Font.SourceSansBold
    playersText.TextSize = 16
    playersText.TextXAlignment = Enum.TextXAlignment.Right
    playersText.Parent = button
    
    local serverText = Instance.new("TextLabel")
    serverText.Size = UDim2.new(0.6, 0, 1, 0)
    serverText.Text = "Сервер #" .. index
    serverText.TextColor3 = Color3.fromRGB(255, 255, 255)
    serverText.BackgroundTransparency = 1
    serverText.Font = Enum.Font.SourceSansBold
    serverText.TextSize = 16
    serverText.TextXAlignment = Enum.TextXAlignment.Left
    serverText.Parent = button
    
    -- Цвет в зависимости от онлайна
    if server.playing >= server.maxPlayers - 2 then
        button.BackgroundColor3 = Color3.fromRGB(100, 0, 0) -- Полный
        playersText.TextColor3 = Color3.fromRGB(255, 100, 100)
    elseif server.playing >= server.maxPlayers / 2 then
        button.BackgroundColor3 = Color3.fromRGB(100, 100, 0) -- Средний
        playersText.TextColor3 = Color3.fromRGB(255, 255, 100)
    else
        button.BackgroundColor3 = Color3.fromRGB(0, 100, 0) -- Пустой
        playersText.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
    
    -- Анимация при наведении
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = button.BackgroundColor3 + Color3.fromRGB(30, 30, 30)
    end)
    
    button.MouseLeave:Connect(function()
        if server.playing >= server.maxPlayers - 2 then
            button.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        elseif server.playing >= server.maxPlayers / 2 then
            button.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
        else
            button.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        end
    end)
    
    -- Функция телепорта
    button.MouseButton1Click:Connect(function()
        print("🚀 Телепортация на сервер #" .. index)
        TeleportService:TeleportToPlaceInstance(GAME_ID, server.id, player)
    end)
    
    return button
end

-- Функция обновления списка серверов
local function updateServerList()
    -- Очищаем контейнер
    for _, child in ipairs(ServersContainer:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    local loadingText = Instance.new("TextLabel")
    loadingText.Size = UDim2.new(1, 0, 0, 30)
    loadingText.Text = "🔄 Загрузка серверов..."
    loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadingText.BackgroundTransparency = 1
    loadingText.Font = Enum.Font.SourceSansBold
    loadingText.TextSize = 16
    loadingText.Parent = ServersContainer
    
    -- Задержка для анимации загрузки
    task.wait(0.5)
    
    local servers = getServers()
    loadingText:Destroy()
    
    if #servers == 0 then
        local noServers = Instance.new("TextLabel")
        noServers.Size = UDim2.new(1, 0, 0, 50)
        noServers.Text = "❌ Серверы не найдены\nПроверьте ID игры!"
        noServers.TextColor3 = Color3.fromRGB(255, 100, 100)
        noServers.BackgroundTransparency = 1
        noServers.Font = Enum.Font.SourceSansBold
        noServers.TextSize = 16
        noServers.TextWrapped = true
        noServers.Parent = ServersContainer
        return
    end
    
    -- Берем первые 6 серверов
    local brainrotServers = {}
    for i = 1, math.min(6, #servers) do
        table.insert(brainrotServers, servers[i])
    end
    
    -- Создаем кнопки серверов
    for i, server in ipairs(brainrotServers) do
        local button = createServerButton(server, i)
        button.Parent = ServersContainer
    end
end

-- Функция для открытия/закрытия окна
local function toggleWindow()
    if BlueWindow.Visible then
        BlueWindow.Visible = false
        CircleFrame.Visible = true
    else
        BlueWindow.Visible = true
        CircleFrame.Visible = false
        updateServerList()
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

-- Обработчик кнопки обновления
RefreshButton.MouseButton1Click:Connect(function()
    updateServerList()
    print("🔄 Список серверов обновлен!")
end)
