local isVisible = false
local hideAt = 0
local currentRadius = 0.0
local currentModeLabel = ""

local circleOffsets = {}
local cachedSegments = 0

local function buildCircleOffsets(segments)
    if segments == cachedSegments and #circleOffsets > 0 then
        return
    end

    circleOffsets = {}
    local step = (2 * math.pi) / segments
    for i = 0, segments do
        local angle = step * i
        circleOffsets[#circleOffsets + 1] = {
            x = math.cos(angle),
            y = math.sin(angle),
        }
    end
    cachedSegments = segments
end

local function showVoiceRadius(distance, modeLabel)
    if type(distance) ~= "number" or distance <= 0 then return end

    currentRadius = distance
    currentModeLabel = Config.TextUppercase and string.upper(modeLabel or "CUSTOM") or (modeLabel or "Custom")

    isVisible = true
    hideAt = GetGameTimer() + Config.DisplayDuration

    buildCircleOffsets(Config.CircleSegments)
end

CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(250)
    end

    local playerServerId = GetPlayerServerId(PlayerId())
    local bagName = ("player:%s"):format(playerServerId)
    local initialized = false

    AddStateBagChangeHandler("proximity", bagName, function(_, _, value)
        if type(value) ~= "table" or not value.distance then return end

        if not initialized then
            initialized = true
            if not Config.ShowOnInitialConnect then
                return
            end
        end

        showVoiceRadius(value.distance, value.mode)
    end)
end)

CreateThread(function()
    while true do
        local waitTime = 500

        if isVisible then
            if GetGameTimer() >= hideAt then
                isVisible = false
            else
                waitTime = 0

                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local groundZ = coords.z + Config.GroundZOffset
                local col = Config.CircleColor

                if Config.DrawFill then
                    DrawMarker(
                        1,
                        coords.x, coords.y, groundZ - 0.03,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        currentRadius * 2.0, currentRadius * 2.0, 0.03,
                        col.r, col.g, col.b, Config.FillAlpha,
                        false, false, 2, false, nil, nil, false
                    )
                end

                for layer = 0, Config.OutlineThickness - 1 do
                    local r = currentRadius + (layer * Config.OutlineThicknessOffset)
                    local prevX, prevY = nil, nil

                    for i = 1, #circleOffsets do
                        local off = circleOffsets[i]
                        local px = coords.x + (off.x * r)
                        local py = coords.y + (off.y * r)

                        if prevX then
                            DrawLine(prevX, prevY, groundZ, px, py, groundZ, col.r, col.g, col.b, Config.OutlineAlpha)
                        end

                        prevX, prevY = px, py
                    end
                end

                if Config.ShowText then
                    local textZ = coords.z + Config.TextZOffset
                    local displayDistance = math.floor(currentRadius + 0.5)
                    local label = string.format(Config.TextFormat, currentModeLabel, displayDistance)
                    local tc = Config.TextColor

                    SetTextScale(Config.TextScale, Config.TextScale)
                    SetTextFont(Config.TextFont)
                    SetTextColour(tc.r, tc.g, tc.b, tc.a)
                    SetTextOutline()
                    SetTextCentre(true)
                    SetTextEntry("STRING")
                    AddTextComponentString(label)
                    SetDrawOrigin(coords.x, coords.y, textZ, 0)
                    DrawText(0.0, 0.0)
                    ClearDrawOrigin()
                end
            end
        end

        Wait(waitTime)
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    isVisible = false
end)
