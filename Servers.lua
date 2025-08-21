return function()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    
    -- ID игры Steal a Brainrot
    local GAME_ID = 109983668079237
    
    -- Функция для получения списка серверов
    local function getServers()
        local success, result = pcall(function()
            local url = "https://games.roblox.com/v1/games/" .. GAME_ID .. "/servers/Public?limit=50"
            local response = game:HttpGet(url)
            return HttpService:JSONDecode(response)
        end)
        
        if success and result and result.data then
            return result.data
        else
            warn("Ошибка получения серверов")
            return {}
        end
    end
    
    -- Функция для создания кнопки сервера
    local function createServerButton(server, index, parentFrame)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.9, 0, 0, 60)
        button.Position = UDim2.new(0.05, 0, 0, (index-1)*70 + 50)
        button.Text = ""
        button.BackgroundColor3 = Color3.fromRGB(30, 30, 100)
        button.BorderSizePixel = 1
        button.BorderColor3 = Color3.fromRGB(100, 100, 200)
        button.AutoButtonColor = false
        button.Parent = parentFrame
        
        local playersText = Instance.new("TextLabel")
        playersText.Size = UDim2.new(0.3, 0, 1, 0)
        playersText.Position = UDim2.new(0.65, 0, 0, 0)
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
        if server.playing >= 6 then
            button.BackgroundColor3 = Color3.fromRGB(100, 0, 0) -- Красный (6+ игроков)
        elseif server.playing >= 4 then
            button.BackgroundColor3 = Color3.fromRGB(150, 50, 0) -- Оранжевый (4-5 игроков)
        elseif server.playing >= 2 then
            button.BackgroundColor3 = Color3.fromRGB(100, 100, 0) -- Желтый (2-3 игрока)
        else
            button.BackgroundColor3 = Color3.fromRGB(0, 100, 0) -- Зеленый (0-1 игрок)
        end
        
        -- Функция телепорта
        button.MouseButton1Click:Connect(function()
            print("🚀 Телепортация на сервер #" .. index)
            TeleportService:TeleportToPlaceInstance(GAME_ID, server.id)
        end)
        
        return button
    end
    
    -- Функция отображения списка серверов
    local function showServerList()
        -- Находим BlueWindow по имени
        local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
        local screenGui = playerGui:FindFirstChild("CircleToWindowGUI")
        if not screenGui then
            warn("Не найден CircleToWindowGUI")
            return
        end
        
        local blueWindow = screenGui:FindFirstChild("BlueWindow")
        if not blueWindow then
            warn("Не найден BlueWindow")
            return
        end
        
        -- Очищаем старые элементы (кроме заголовка и кнопок)
        for _, child in ipairs(blueWindow:GetChildren()) do
            if child.Name ~= "WindowTitle" and child.Name ~= "CloseButton" and child.Name ~= "ResizeButton" then
                child:Destroy()
            end
        end
        
        -- Создаем контейнер для серверов
        local serversContainer = Instance.new("Frame")
        serversContainer.Size = UDim2.new(0.9, 0, 0.7, 0)
        serversContainer.Position = UDim2.new(0.05, 0, 0.15, 0)
        serversContainer.BackgroundTransparency = 1
        serversContainer.Name = "ServersContainer"
        serversContainer.Parent = blueWindow
        
        -- Заголовок
        local loadingText = Instance.new("TextLabel")
        loadingText.Size = UDim2.new(1, 0, 0, 30)
        loadingText.Text = "🔄 Поиск серверов..."
        loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
        loadingText.BackgroundTransparency = 1
        loadingText.Font = Enum.Font.SourceSansBold
        loadingText.TextSize = 16
        loadingText.Parent = serversContainer
        
        -- Задержка для анимации
        task.wait(0.5)
        
        -- Получаем серверы
        local servers = getServers()
        loadingText:Destroy()
        
        if #servers == 0 then
            local noServers = Instance.new("TextLabel")
            noServers.Size = UDim2.new(1, 0, 0, 50)
            noServers.Text = "❌ Серверы не найдены"
            noServers.TextColor3 = Color3.from极速赛车开奖结果记录RGB(255, 100, 100)
            noServers.BackgroundTransparency = 1
            noServers.Font = Enum.Font.SourceSansBold
            noServers.TextSize = 16
            noServers.Parent = serversContainer
            return
        end
        
        -- Фильтруем серверы (не более 6 игроков)
        local filteredServers = {}
        for _, server in ipairs(servers) do
            if server.playing <= 6 then -- ТОЛЬКО СЕРВЕРЫ С НЕ БОЛЕЕ 6 ИГРОКАМИ
                table.insert(filteredServers, server)
            end
        end
        
        if #filteredServers == 0 then
            local noAvailable = Instance.new("TextLabel")
            noAvailable.Size = UDim2.new(1, 0, 0, 80)
            noAvailable.Text = "😢 Нет свободных серверов\n(все серверы имеют более 6 игроков)"
            noAvailable.TextColor3 = Color3.fromRGB(255, 150, 150)
            noAvailable.BackgroundTransparency = 1
            noAvailable.Font = Enum.Font.SourceSansBold
            noAvailable.TextSize = 16
            noAvailable.TextWrapped = true
            noAvailable.Parent = serversContainer
            return
        end
        
        -- Берем первые 6 подходящих серверов
        local displayServers = {}
        for i = 1, math.min(6, #filteredServers) do
            table.insert(displayServers, filteredServers[i])
        end
        
        -- Создаем кнопки серверов
        for i, server in ipairs(displayServers) do
            createServerButton(server, i, serversContainer)
        end
        
        -- Кнопка обновления
        local refreshButton = Instance.new("TextButton")
        refreshButton.Size = UDim2.new(0, 120, 0, 40)
        refreshButton.Position = UDim2.new(0.5, -60, 1, -100)
        refreshButton.Text = "🔄 Обновить"
        refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        refreshButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        refreshButton.BorderSizePixel = 0
        refreshButton.Font = Enum.Font.SourceSansBold
        refreshButton.TextSize = 18
        refreshButton.Parent = blueWindow
        
        refreshButton.MouseButton1Click:Connect(function()
            showServerList()
        end)
        
        -- Статистика
        local statsText = Instance.new("TextLabel")
        statsText.Size = UDim2.new(1, 0, 0, 30)
        statsText.Position = UDim2.new(0, 0, 0, 0)
        statsText.Text = "📊 Найдено: " .. #displayServers .. " серверов (≤6 игроков)"
        statsText.TextColor3 = Color3.fromRGB(200, 200, 255)
        statsText.BackgroundTransparency = 1
        statsText.Font = Enum.Font.SourceSans
        statsText.TextSize = 14
        statsText.Parent = serversContainer
        
        print("✅ Загружено " .. #displayServers .. " серверов с не более 6 игроками")
    end
    
    -- Запускаем отображение списка серверов
    showServerList()
end
