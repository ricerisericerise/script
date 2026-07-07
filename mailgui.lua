-- Game Verification: Only run on Grow a Garden 2
if game.PlaceId ~= 97598239454123 then
    return
end

-- Read external configuration set before loadstring (fallback to blank if not set)
local targetRecipient = _G.MailRecipient or ""

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Networking = require(ReplicatedStorage.SharedModules.Networking)
local PlayerStateClient = require(ReplicatedStorage.ClientModules.PlayerStateClient)
local MailboxItemCatalog = require(LocalPlayer.PlayerScripts.Controllers.MailboxController.MailboxItemCatalog)

-- GUI Configuration
local GUI_NAME = "AutoMailDropdown"
local existingGui = PlayerGui:FindFirstChild(GUI_NAME)
if existingGui then
    existingGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 400, 0, 560)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -280)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true -- Required for visual minimizing
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(50, 50, 60)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Cover bottom corners of TitleBar
local TitleCover = Instance.new("Frame")
TitleCover.Size = UDim2.new(1, 0, 0, 10)
TitleCover.Position = UDim2.new(0, 0, 1, -10)
TitleCover.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
TitleCover.BorderSizePixel = 0
TitleCover.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -80, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Multi-Mail GUI"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 245)
TitleText.TextSize = 16
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -38, 0.5, -15)
CloseButton.BackgroundTransparency = 1
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(180, 180, 190)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TitleBar

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ADDED: Minimize Button
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -73, 0.5, -15)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Text = "—"
MinimizeButton.TextColor3 = Color3.fromRGB(180, 180, 190)
MinimizeButton.TextSize = 16
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TitleBar

-- Minimize Logic
local isMinimized = false
local originalHeight = 560

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetHeight = isMinimized and 45 or originalHeight
    
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 400, 0, targetHeight)
    }):Play()
    
    MinimizeButton.Text = isMinimized and "▢" or "—"
end)

-- Content Area ScrollFrame
local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -20, 1, -65)
Content.Position = UDim2.new(0, 10, 0, 55)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.CanvasSize = UDim2.new(0, 0, 0, 600)
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
Content.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 10)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Content

-- Utility function to create section labels
local function createSectionTitle(text, order)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = text:upper()
    label.TextColor3 = Color3.fromRGB(120, 120, 135)
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.LayoutOrder = order
    label.Parent = Content
    return label
end

-- Recipient Input Section
createSectionTitle("Recipient Details", 1)

local RecipientFrame = Instance.new("Frame")
RecipientFrame.Size = UDim2.new(1, 0, 0, 38)
RecipientFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
RecipientFrame.BorderSizePixel = 0
RecipientFrame.LayoutOrder = 2
RecipientFrame.Parent = Content

local RecipientCorner = Instance.new("UICorner")
RecipientCorner.CornerRadius = UDim.new(0, 6)
RecipientCorner.Parent = RecipientFrame

local RecipientStroke = Instance.new("UIStroke")
RecipientStroke.Color = Color3.fromRGB(45, 45, 55)
RecipientStroke.Thickness = 1
RecipientStroke.Parent = RecipientFrame

local RecipientBox = Instance.new("TextBox")
RecipientBox.Size = UDim2.new(1, -20, 1, 0)
RecipientBox.Position = UDim2.new(0, 10, 0, 0)
RecipientBox.BackgroundTransparency = 1
RecipientBox.Text = targetRecipient
RecipientBox.PlaceholderText = "Enter Recipient Username..."
RecipientBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
RecipientBox.TextColor3 = Color3.fromRGB(240, 240, 245)
RecipientBox.TextSize = 14
RecipientBox.Font = Enum.Font.Gotham
RecipientBox.TextXAlignment = Enum.TextXAlignment.Left
RecipientBox.ClearTextOnFocus = false
RecipientBox.Parent = RecipientFrame

-- Multi-Select Dropdown Accordion Section
createSectionTitle("Item Selection", 3)

local DropdownContainer = Instance.new("Frame")
DropdownContainer.Name = "DropdownContainer"
DropdownContainer.Size = UDim2.new(1, 0, 0, 36)
DropdownContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
DropdownContainer.BorderSizePixel = 0
DropdownContainer.ClipsDescendants = true
DropdownContainer.LayoutOrder = 4
DropdownContainer.Parent = Content

local DropdownCorner = Instance.new("UICorner")
DropdownCorner.CornerRadius = UDim.new(0, 6)
DropdownCorner.Parent = DropdownContainer

local DropdownStroke = Instance.new("UIStroke")
DropdownStroke.Color = Color3.fromRGB(45, 45, 55)
DropdownStroke.Thickness = 1
DropdownStroke.Parent = DropdownContainer

local DropdownListLayout = Instance.new("UIListLayout")
DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
DropdownListLayout.Parent = DropdownContainer

local DropdownButton = Instance.new("TextButton")
DropdownButton.Name = "DropdownButton"
DropdownButton.Size = UDim2.new(1, 0, 0, 36)
DropdownButton.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
DropdownButton.BorderSizePixel = 0
DropdownButton.Text = "Select Items (0 selected)  ▼"
DropdownButton.TextColor3 = Color3.fromRGB(220, 220, 230)
DropdownButton.TextSize = 13
DropdownButton.Font = Enum.Font.GothamBold
DropdownButton.LayoutOrder = 1
DropdownButton.Parent = DropdownContainer

-- Dropdown Inner Content
local DropdownContent = Instance.new("Frame")
DropdownContent.Name = "DropdownContent"
DropdownContent.Size = UDim2.new(1, 0, 0, 220)
DropdownContent.BackgroundTransparency = 1
DropdownContent.BorderSizePixel = 0
DropdownContent.LayoutOrder = 2
DropdownContent.Visible = false
DropdownContent.Parent = DropdownContainer

-- Search and Actions bar
local ToolBar = Instance.new("Frame")
ToolBar.Name = "ToolBar"
ToolBar.Size = UDim2.new(1, 0, 0, 30)
ToolBar.BackgroundTransparency = 1
ToolBar.Parent = DropdownContent

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, -130, 1, -4)
SearchBox.Position = UDim2.new(0, 10, 0, 2)
SearchBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
SearchBox.BorderSizePixel = 0
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 95)
SearchBox.TextColor3 = Color3.fromRGB(220, 220, 230)
SearchBox.TextSize = 12
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = ToolBar

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 4)
SearchCorner.Parent = SearchBox

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Color = Color3.fromRGB(40, 40, 50)
SearchStroke.Thickness = 1
SearchStroke.Parent = SearchBox

local SelectAllBtn = Instance.new("TextButton")
SelectAllBtn.Name = "SelectAllBtn"
SelectAllBtn.Size = UDim2.new(0, 55, 1, -4)
SelectAllBtn.Position = UDim2.new(1, -115, 0, 2)
SelectAllBtn.BackgroundColor3 = Color3.fromRGB(50, 120, 70)
SelectAllBtn.BorderSizePixel = 0
SelectAllBtn.Text = "All"
SelectAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectAllBtn.TextSize = 11
SelectAllBtn.Font = Enum.Font.GothamBold
SelectAllBtn.Parent = ToolBar

local SelectAllCorner = Instance.new("UICorner")
SelectAllCorner.CornerRadius = UDim.new(0, 4)
SelectAllCorner.Parent = SelectAllBtn

local ClearBtn = Instance.new("TextButton")
ClearBtn.Name = "ClearBtn"
ClearBtn.Size = UDim2.new(0, 50, 1, -4)
ClearBtn.Position = UDim2.new(1, -55, 0, 2)
ClearBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
ClearBtn.BorderSizePixel = 0
ClearBtn.Text = "Clear"
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.TextSize = 11
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.Parent = ToolBar

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 4)
ClearCorner.Parent = ClearBtn

-- Item List ScrollFrame
local ItemScroll = Instance.new("ScrollingFrame")
ItemScroll.Name = "ItemScroll"
ItemScroll.Size = UDim2.new(1, -16, 1, -36)
ItemScroll.Position = UDim2.new(0, 8, 0, 32)
ItemScroll.BackgroundTransparency = 1
ItemScroll.BorderSizePixel = 0
ItemScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ItemScroll.ScrollBarThickness = 4
ItemScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
ItemScroll.Parent = DropdownContent

local ItemListLayout = Instance.new("UIListLayout")
ItemListLayout.Padding = UDim.new(0, 3)
ItemListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ItemListLayout.Parent = ItemScroll

-- Count Input Section
createSectionTitle("Send Quantity", 5)

local QuantityFrame = Instance.new("Frame")
QuantityFrame.Name = "QuantityFrame"
QuantityFrame.Size = UDim2.new(1, 0, 0, 38)
QuantityFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
QuantityFrame.BorderSizePixel = 0
QuantityFrame.LayoutOrder = 6
QuantityFrame.Parent = Content

local QuantityCorner = Instance.new("UICorner")
QuantityCorner.CornerRadius = UDim.new(0, 6)
QuantityCorner.Parent = QuantityFrame

local QuantityStroke = Instance.new("UIStroke")
QuantityStroke.Color = Color3.fromRGB(45, 45, 55)
QuantityStroke.Thickness = 1
QuantityStroke.Parent = QuantityFrame

local CountBox = Instance.new("TextBox")
CountBox.Name = "CountBox"
CountBox.Size = UDim2.new(1, -20, 1, 0)
CountBox.Position = UDim2.new(0, 10, 0, 0)
CountBox.BackgroundTransparency = 1
CountBox.Text = "All"
CountBox.PlaceholderText = "Count to send per item (e.g. 5 or All)..."
CountBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
CountBox.TextColor3 = Color3.fromRGB(240, 240, 245)
CountBox.TextSize = 14
CountBox.Font = Enum.Font.Gotham
CountBox.TextXAlignment = Enum.TextXAlignment.Left
CountBox.ClearTextOnFocus = false
CountBox.Parent = QuantityFrame

-- Controls and Actions Section
createSectionTitle("Mailer Actions", 7)

local function createButton(text, bgCol, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = bgCol
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.LayoutOrder = order
    btn.Parent = Content
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    return btn
end

local SendSelectedBtn = createButton("Send Selected Items", Color3.fromRGB(60, 100, 220), 8)
local RefreshInvBtn = createButton("Refresh Inventory List", Color3.fromRGB(60, 60, 70), 9)

-- Inbox Section
createSectionTitle("Inbox Utilities", 10)

local ClaimToggleFrame = Instance.new("Frame")
ClaimToggleFrame.Size = UDim2.new(1, 0, 0, 42)
ClaimToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
ClaimToggleFrame.BorderSizePixel = 0
ClaimToggleFrame.LayoutOrder = 11
ClaimToggleFrame.Parent = Content

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ClaimToggleFrame

local ToggleLabel = Instance.new("TextLabel")
ToggleLabel.Size = UDim2.new(0.6, 0, 1, 0)
ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
ToggleLabel.BackgroundTransparency = 1
ToggleLabel.Text = "Auto Claim Inbox"
ToggleLabel.TextColor3 = Color3.fromRGB(210, 210, 220)
ToggleLabel.TextSize = 13
ToggleLabel.Font = Enum.Font.GothamMedium
ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
ToggleLabel.Parent = ClaimToggleFrame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 46, 0, 22)
ToggleBtn.Position = UDim2.new(1, -56, 0.5, -11)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
ToggleBtn.Text = ""
ToggleBtn.Parent = ClaimToggleFrame

local ToggleBtnCorner = Instance.new("UICorner")
ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
ToggleBtnCorner.Parent = ToggleBtn

local ToggleCircle = Instance.new("Frame")
ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
ToggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
ToggleCircle.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
ToggleCircle.Parent = ToggleBtn

local ToggleCircleCorner = Instance.new("UICorner")
ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
ToggleCircleCorner.Parent = ToggleCircle

local ClaimAllBtn = createButton("Claim All Mail Now", Color3.fromRGB(50, 130, 80), 12)

-- Cancel Send Button
local CancelSendBtn = createButton("CANCEL CURRENT TRANSACTION", Color3.fromRGB(180, 50, 50), 13)
CancelSendBtn.Visible = false

-- Status Log Box
createSectionTitle("Status Logs", 14)

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, 0, 0, 110)
LogFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
LogFrame.BorderSizePixel = 0
LogFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LogFrame.ScrollBarThickness = 4
LogFrame.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
LogFrame.LayoutOrder = 15
LogFrame.Parent = Content

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0, 6)
LogCorner.Parent = LogFrame

local LogList = Instance.new("UIListLayout")
LogList.Padding = UDim.new(0, 4)
LogList.Parent = LogFrame

local function addLog(text, color)
    color = color or Color3.fromRGB(200, 200, 210)
    
    local logLabel = Instance.new("TextLabel")
    logLabel.Size = UDim2.new(1, -10, 0, 16)
    logLabel.Position = UDim2.new(0, 5, 0, 0)
    logLabel.BackgroundTransparency = 1
    logLabel.Text = string.format("[%s] %s", os.date("%X"), text)
    logLabel.TextColor3 = color
    logLabel.TextSize = 10
    logLabel.Font = Enum.Font.Code
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.TextWrapped = true
    logLabel.Parent = LogFrame
    
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, LogList.AbsoluteContentSize.Y + 20)
    LogFrame.CanvasPosition = Vector2.new(0, LogList.AbsoluteContentSize.Y)
end

addLog("Multi-Mailer GUI initialized via loadstring.", Color3.fromRGB(120, 220, 120))

-- LOGIC, INVENTORY, AND DROPDOWN
local selectedItems = {} 
local availableItems = {} 
local dropdownOpen = false
local autoClaimEnabled = false
local claimConnection = nil
local sendCooldown = 6.0 
local isSendingActive = false
local cancelRequested = false

local rarityOrder = {
    Super = 1,
    Mythic = 2,
    Legendary = 3,
    Epic = 4,
    Rare = 5,
    Uncommon = 6,
    Common = 7
}

local function getItemRarity(category, itemKey, itemVal)
    local PetData = require(game:GetService("ReplicatedStorage").SharedData.PetData)
    local SeedData = require(game:GetService("ReplicatedStorage").SharedModules.SeedData)
    
    local rarity = "Common"
    
    if category == "Pets" then
        local petInfo = PetData[itemKey]
        if petInfo and petInfo.Rarity then
            rarity = petInfo.Rarity
        end
    elseif category == "Seeds" or category == "HarvestedFruits" then
        for _, entry in ipairs(SeedData) do
            if entry.SeedName == itemKey then
                if entry.Rarity then
                    rarity = entry.Rarity
                end
                break
            end
        end
    else
        local nameLower = string.lower(itemKey)
        if string.find(nameLower, "super") then
            rarity = "Super"
        elseif string.find(nameLower, "mythic") then
            rarity = "Mythic"
        elseif string.find(nameLower, "legendary") then
            rarity = "Legendary"
        elseif string.find(nameLower, "epic") then
            rarity = "Epic"
        elseif string.find(nameLower, "rare") then
            rarity = "Rare"
        elseif string.find(nameLower, "uncommon") then
            rarity = "Uncommon"
        end
    end
    
    return rarity
end

local function updateSelectionCount()
    local count = 0
    for _, isSel in pairs(selectedItems) do
        if isSel then
            count = count + 1
        end
    end
    DropdownButton.Text = string.format("Select Items (%d selected)  %s", count, dropdownOpen and "▲" or "▼")
end

local function renderDropdownRows()
    for _, child in ipairs(ItemScroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    
    local filterText = string.lower(SearchBox.Text)
    local groupedItems = {}
    for _, item in ipairs(availableItems) do
        local isFiltered = filterText ~= "" and not string.find(string.lower(item.DisplayName), filterText)
        if not isFiltered then
            if not groupedItems[item.Category] then
                groupedItems[item.Category] = {}
            end
            table.insert(groupedItems[item.Category], item)
        end
    end
    
    local categoriesProcessed = {}
    for catName, _ in pairs(groupedItems) do
        table.insert(categoriesProcessed, catName)
    end
    table.sort(categoriesProcessed)
    
    local layoutOrderIdx = 1
    
    for _, category in ipairs(categoriesProcessed) do
        local itemsInCat = groupedItems[category]
        if #itemsInCat > 0 then
            local HeaderFrame = Instance.new("Frame")
            HeaderFrame.Name = "CategoryHeader_" .. category
            HeaderFrame.Size = UDim2.new(1, -4, 0, 24)
            HeaderFrame.BackgroundTransparency = 1
            HeaderFrame.LayoutOrder = layoutOrderIdx
            HeaderFrame.Parent = ItemScroll
            layoutOrderIdx = layoutOrderIdx + 1
            
            local HeaderLabel = Instance.new("TextLabel")
            HeaderLabel.Size = UDim2.new(1, -65, 1, 0)
            HeaderLabel.BackgroundTransparency = 1
            HeaderLabel.Text = category:upper()
            HeaderLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
            HeaderLabel.TextSize = 11
            HeaderLabel.Font = Enum.Font.GothamBold
            HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
            HeaderLabel.Parent = HeaderFrame
            
            local CatSelectAllBtn = Instance.new("TextButton")
            CatSelectAllBtn.Size = UDim2.new(0, 55, 0, 18)
            CatSelectAllBtn.Position = UDim2.new(1, -55, 0.5, -9)
            CatSelectAllBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            CatSelectAllBtn.BorderSizePixel = 0
            CatSelectAllBtn.Text = "Toggle All"
            CatSelectAllBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
            CatSelectAllBtn.TextSize = 10
            CatSelectAllBtn.Font = Enum.Font.GothamBold
            CatSelectAllBtn.Parent = HeaderFrame
            
            local CatSelectCorner = Instance.new("UICorner")
            CatSelectCorner.CornerRadius = UDim.new(0, 4)
            CatSelectCorner.Parent = CatSelectAllBtn
            
            CatSelectAllBtn.MouseButton1Click:Connect(function()
                local allSelected = true
                for _, item in ipairs(itemsInCat) do
                    if not selectedItems[item.ItemKey] then
                        allSelected = false
                        break
                    end
                end
                
                for _, item in ipairs(itemsInCat) do
                    selectedItems[item.ItemKey] = not allSelected
                end
                
                updateSelectionCount()
                renderDropdownRows()
            end)
            
            for _, item in ipairs(itemsInCat) do
                local Row = Instance.new("Frame")
                Row.Name = item.ItemKey
                Row.Size = UDim2.new(1, -4, 0, 28)
                Row.BackgroundColor3 = selectedItems[item.ItemKey] and Color3.fromRGB(45, 45, 60) or Color3.fromRGB(24, 24, 28)
                Row.BorderSizePixel = 0
                Row.LayoutOrder = layoutOrderIdx
                Row.Parent = ItemScroll
                layoutOrderIdx = layoutOrderIdx + 1
                
                local RowCorner = Instance.new("UICorner")
                RowCorner.CornerRadius = UDim.new(0, 4)
                RowCorner.Parent = Row
                
                local CheckBox = Instance.new("TextLabel")
                CheckBox.Size = UDim2.new(0, 20, 1, 0)
                CheckBox.Position = UDim2.new(0, 8, 0, 0)
                CheckBox.BackgroundTransparency = 1
                CheckBox.Text = selectedItems[item.ItemKey] and "☑" or "☐"
                CheckBox.TextColor3 = selectedItems[item.ItemKey] and Color3.fromRGB(100, 200, 120) or Color3.fromRGB(150, 150, 160)
                CheckBox.TextSize = 16
                CheckBox.Font = Enum.Font.Gotham
                CheckBox.Parent = Row
                
                local ItemName = Instance.new("TextLabel")
                ItemName.Size = UDim2.new(1, -36, 1, 0)
                ItemName.Position = UDim2.new(0, 32, 0, 0)
                ItemName.BackgroundTransparency = 1
                ItemName.Text = string.format("%s [x%d]", item.DisplayName, item.Count)
                ItemName.TextColor3 = Color3.fromRGB(220, 220, 230)
                ItemName.TextSize = 11
                ItemName.Font = Enum.Font.GothamMedium
                ItemName.TextXAlignment = Enum.TextXAlignment.Left
                ItemName.Parent = Row
                
                local RowBtn = Instance.new("TextButton")
                RowBtn.Size = UDim2.new(1, 0, 1, 0)
                RowBtn.BackgroundTransparency = 1
                RowBtn.Text = ""
                RowBtn.Parent = Row
                
                RowBtn.MouseButton1Click:Connect(function()
                    selectedItems[item.ItemKey] = not selectedItems[item.ItemKey]
                    Row.BackgroundColor3 = selectedItems[item.ItemKey] and Color3.fromRGB(45, 45, 60) or Color3.fromRGB(24, 24, 28)
                    CheckBox.Text = selectedItems[item.ItemKey] and "☑" or "☐"
                    CheckBox.TextColor3 = selectedItems[item.ItemKey] and Color3.fromRGB(100, 200, 120) or Color3.fromRGB(150, 150, 160)
                    updateSelectionCount()
                end)
            end
        end
    end
    
    ItemScroll.CanvasSize = UDim2.new(0, 0, 0, ItemListLayout.AbsoluteContentSize.Y + 10)
end

local function scanInventory()
    local replica = PlayerStateClient:GetLocalReplica()
    if not replica or not replica.Data or not replica.Data.Inventory then
        addLog("No inventory replica found.", Color3.fromRGB(240, 100, 100))
        return
    end
    
    local inventory = replica.Data.Inventory
    availableItems = {}
    
    for _, cat in ipairs(MailboxItemCatalog.Categories) do
        if cat ~= "HarvestedFruits" then
            local catData = inventory[cat]
            if typeof(catData) == "table" then
                if cat == "Pets" then
                    for itemKey, itemVal in pairs(catData) do
                        local isGiftable = typeof(itemVal) == "table" and itemVal.Id ~= nil and itemVal.Equipped ~= true
                        
                        if isGiftable then
                            local rarity = getItemRarity(cat, itemKey, itemVal)
                            table.insert(availableItems, {
                                Category = cat,
                                ItemKey = itemKey,
                                Count = 1,
                                DisplayName = itemVal.Name or itemKey,
                                Rarity = rarity
                            })
                        end
                    end
                else
                    for itemKey, count in pairs(catData) do
                        if typeof(count) == "number" and count > 0 then
                            local rarity = getItemRarity(cat, itemKey, nil)
                            table.insert(availableItems, {
                                Category = cat,
                                ItemKey = itemKey,
                                Count = count,
                                DisplayName = itemKey,
                                Rarity = rarity
                            })
                        end
                    end
                end
            end
        end
    end
    
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    if Backpack then
        for _, child in ipairs(Backpack:GetChildren()) do
            if child:IsA("Configuration") and (child:GetAttribute("Fruit") ~= nil or child:GetAttribute("Fruits") ~= nil) then
                local itemKey = child:GetAttribute("Id") or child:GetAttribute("UUID") or child.Name
                local count = child:GetAttribute("Count") or child:GetAttribute("Amount") or 1
                local displayName = child.Name
                local rarity = getItemRarity("HarvestedFruits", displayName, nil)
                
                table.insert(availableItems, {
                    Category = "HarvestedFruits",
                    ItemKey = itemKey, 
                    Count = count,
                    DisplayName = displayName,
                    Rarity = rarity
                })
            end
        end
    end
    
    local currentKeys = {}
    for _, item in ipairs(availableItems) do
        currentKeys[item.ItemKey] = true
    end
    for key, isSel in pairs(selectedItems) do
        if isSel and not currentKeys[key] then
            selectedItems[key] = nil
        end
    end
    
    updateSelectionCount()
    renderDropdownRows()
end

local function toggleDropdown(forceState)
    if forceState ~= nil then
        dropdownOpen = forceState
    else
        dropdownOpen = not dropdownOpen
    end
    
    local targetHeight = dropdownOpen and 260 or 36
    
    TweenService:Create(DropdownContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, targetHeight)
    }):Play()
    
    DropdownContent.Visible = dropdownOpen
    updateSelectionCount()
    
    task.spawn(function()
        task.wait(0.26)
        Content.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 20)
    end)
end

DropdownButton.MouseButton1Click:Connect(function()
    toggleDropdown()
end)

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    renderDropdownRows()
end)

SelectAllBtn.MouseButton1Click:Connect(function()
    for _, item in ipairs(availableItems) do
        selectedItems[item.ItemKey] = true
    end
    updateSelectionCount()
    renderDropdownRows()
end)

ClearBtn.MouseButton1Click:Connect(function()
    table.clear(selectedItems)
    updateSelectionCount()
    renderDropdownRows()
end)

RefreshInvBtn.MouseButton1Click:Connect(function()
    scanInventory()
    addLog("Inventory list re-scanned.", Color3.fromRGB(120, 200, 240))
end)

local function updateToggleVisual()
    if autoClaimEnabled then
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 150, 80)}):Play()
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
    else
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
    end
end

local function claimAllMail()
    addLog("Fetching inbox items...", Color3.fromRGB(240, 220, 120))
    local ok, inbox = pcall(function()
        return Networking.Mailbox.OpenInbox:Fire()
    end)
    
    if not ok or typeof(inbox) ~= "table" then
        addLog("Failed to fetch inbox.", Color3.fromRGB(240, 100, 100))
        return
    end
    
    local mailCount = 0
    for id, _ in pairs(inbox) do
        mailCount = mailCount + 1
    end
    
    if mailCount == 0 then
        addLog("Inbox is empty.", Color3.fromRGB(180, 180, 190))
        return
    end
    
    addLog(string.format("Found %d mail items. Claiming...", mailCount), Color3.fromRGB(120, 200, 240))
    for id, item in pairs(inbox) do
        local success, result, errMsg = pcall(function()
            return Networking.Mailbox.Claim:Fire(id)
        end)
        
        if success and result then
            addLog(string.format("Claimed mail ID: %s", string.sub(id, 1, 8)), Color3.fromRGB(120, 240, 120))
        else
            addLog(string.format("Failed claim %s: %s", string.sub(id, 1, 8), tostring(errMsg or result)), Color3.fromRGB(240, 100, 100))
        end
        task.wait(0.01)
    end
    addLog("Claim process completed.", Color3.fromRGB(120, 240, 120))
end

-- UPDATED TOGGLE LOGIC: Incorporates Polling Fallback Loop
ToggleBtn.MouseButton1Click:Connect(function()
    autoClaimEnabled = not autoClaimEnabled
    updateToggleVisual()
    
    if autoClaimEnabled then
        addLog("Auto-Claim enabled.", Color3.fromRGB(100, 240, 100))
        task.spawn(claimAllMail)
        
        -- Fallback safety connect for event pushes
        pcall(function()
            claimConnection = Networking.Mailbox.Updated.OnClientEvent:Connect(function()
                addLog("New mail notification received! Auto-claiming...", Color3.fromRGB(240, 220, 120))
                task.spawn(claimAllMail)
            end)
        end)

        -- Background loop sweeps every 15 seconds ensuring new mail is collected
        task.spawn(function()
            while autoClaimEnabled do
                task.wait(15)
                if autoClaimEnabled then
                    addLog("Running background loop inbox sweep...", Color3.fromRGB(150, 150, 160))
                    claimAllMail()
                end
            end
        end)
    else
        addLog("Auto-Claim disabled.", Color3.fromRGB(240, 100, 100))
        if claimConnection then
            claimConnection:Disconnect()
            claimConnection = nil
        end
    end
end)

ClaimAllBtn.MouseButton1Click:Connect(function()
    task.spawn(claimAllMail)
end)

local function getUserId(username)
    if not username or username == "" then
        return nil
    end
    
    local ok, id, displayName = pcall(function()
        return Networking.Mailbox.LookupPlayer:Fire(username)
    end)
    
    if ok and id and id > 0 then
        return id, displayName
    end
    return nil
end

local function createBatches(items)
    local batches = {}
    local currentBatch = {}
    
    for _, item in ipairs(items) do
        if #currentBatch >= 20 then
            table.insert(batches, currentBatch)
            currentBatch = {}
        end
        table.insert(currentBatch, {
            Category = item.Category,
            ItemKey = item.ItemKey,
            Count = item.Count,
            DisplayName = item.DisplayName,
            Rarity = item.Rarity
        })
    end
    
    if #currentBatch > 0 then
        table.insert(batches, currentBatch)
    end
    
    return batches
end

local function executeSendMail()
    if isSendingActive then
        addLog("A transaction is already running!", Color3.fromRGB(240, 100, 100))
        return
    end
    
    local username = RecipientBox.Text
    username = string.gsub(username, "^%s*(.-)%s*$", "%1")
    
    if username == "" then
        addLog("Error: Please enter a recipient username.", Color3.fromRGB(240, 100, 100))
        return
    end
    
    local itemsToSend = {}
    local countInput = string.lower(string.gsub(CountBox.Text, "^%s*(.-)%s*$", "%1"))
    local quantityLimit = tonumber(countInput)
    
    for _, item in ipairs(availableItems) do
        if selectedItems[item.ItemKey] then
            local finalCount = item.Count
            if quantityLimit and item.Category ~= "Pets" and item.Category ~= "HarvestedFruits" then
                finalCount = math.min(quantityLimit, item.Count)
            end
            
            if finalCount > 0 then
                table.insert(itemsToSend, {
                    Category = item.Category,
                    ItemKey = item.ItemKey,
                    Count = finalCount,
                    DisplayName = item.DisplayName,
                    Rarity = item.Rarity
                })
            end
        end
    end
    
    if #itemsToSend == 0 then
        addLog("Error: No items selected or send count is 0.", Color3.fromRGB(240, 100, 100))
        return
    end
    
    isSendingActive = true
    cancelRequested = false
    CancelSendBtn.Visible = true
    
    toggleDropdown(false)
    
    addLog(string.format("Looking up player '%s'...", username), Color3.fromRGB(240, 220, 120))
    local userId, displayName = getUserId(username)
    if not userId then
        addLog("Error: Player not found or invalid.", Color3.fromRGB(240, 100, 100))
        isSendingActive = false
        CancelSendBtn.Visible = false
        return
    end
    
    addLog(string.format("Recipient: %s (ID: %d)", displayName, userId), Color3.fromRGB(120, 240, 120))
    
    table.sort(itemsToSend, function(a, b)
        local aRarityPri = rarityOrder[a.Rarity] or 7
        local bRarityPri = rarityOrder[b.Rarity] or 7
        
        if aRarityPri ~= bRarityPri then
            return aRarityPri < bRarityPri
        end
        
        return a.DisplayName < b.DisplayName
    end)
    
    local batches = createBatches(itemsToSend)
    addLog(string.format("Prepared %d selected items. Split into %d batches of 20.", #itemsToSend, #batches), Color3.fromRGB(120, 200, 240))
    
    local totalSentCount = 0
    for i, batch in ipairs(batches) do
        if cancelRequested then
            addLog("TRANSACTION CANCELLED BY USER.", Color3.fromRGB(240, 100, 100))
            break
        end
        
        local secondsLeft = (#batches - i) * sendCooldown
        addLog(string.format("Sending batch %d/%d (%d%%). Est. time remaining: %ds", i, #batches, math.floor((i-1)/#batches * 100), secondsLeft), Color3.fromRGB(240, 220, 120))
        
        local apiBatch = {}
        for _, bit in ipairs(batch) do
            apiBatch[#apiBatch + 1] = {
                Category = bit.Category,
                ItemKey = bit.ItemKey,
                Count = bit.Count
            }
        end
        
        local success, result, errMsg
        local retries = 0
        local maxRetries = 5
        
        while retries < maxRetries do
            if cancelRequested then
                break
            end
            
            success, result, errMsg = pcall(function()
                return Networking.Mailbox.SendBatch:Fire(userId, apiBatch, "Multi-Mail Delivery")
            end)
            
            if success and result then
                break
            end
            
            local errStr = typeof(errMsg) == "string" and errMsg or tostring(errMsg or result or "")
            local waitTime = tonumber(string.match(errStr, "Wait (%d+)s"))
            
            if waitTime then
                addLog(string.format("Rate limit hit. Waiting %ds to retry...", waitTime), Color3.fromRGB(240, 140, 100))
                task.wait(waitTime + 0.5)
                retries = retries + 1
            else
                addLog(string.format("Batch %d error: %s", i, errStr), Color3.fromRGB(240, 100, 100))
                break
            end
        end
        
        if success and result then
            addLog(string.format("Batch %d sent successfully!", i), Color3.fromRGB(120, 240, 120))
            for _, item in ipairs(batch) do
                addLog(string.format("  -> Sent x%d %s (%s)", item.Count, item.DisplayName, item.Rarity or "Common"), Color3.fromRGB(170, 170, 180))
                totalSentCount = totalSentCount + item.Count
            end
            
            if i < #batches then
                task.wait(sendCooldown)
            end
        else
            addLog(string.format("Batch %d permanently failed. Stopping transaction.", i), Color3.fromRGB(240, 50, 50))
            break
        end
    end
    
    addLog(string.format("Finished! Total items mailed: %d", totalSentCount), Color3.fromRGB(120, 240, 120))
    isSendingActive = false
    CancelSendBtn.Visible = false
    
    scanInventory()
end

SendSelectedBtn.MouseButton1Click:Connect(function()
    task.spawn(executeSendMail)
end)

CancelSendBtn.MouseButton1Click:Connect(function()
    if isSendingActive then
        cancelRequested = true
        addLog("Cancellation requested. Waiting for current batch to finish...", Color3.fromRGB(240, 140, 100))
    end
end)

scanInventory()
Content.CanvasSize = UDim2.new(0, 0, 0, UIList.AbsoluteContentSize.Y + 20)
