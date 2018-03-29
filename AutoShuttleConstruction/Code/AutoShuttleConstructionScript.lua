
-- Mod configuration
-- ==========================================================================
-- See if ModConfig is installed and that notifications are enabled
function AutoShuttleConstructionConfigShowNotification()
    if rawget(_G, "ModConfig") then
        return ModConfig:Get("AutoShuttleConstruction", "Notifications")
    end
    return "all"
end

-- See if ModConfig is installed and that notifications are enabled
function AutoShuttleConstructionConfigThreshold()
    if rawget(_G, "ModConfig") then
        return ModConfig:Get("AutoShuttleConstruction", "Threshold")
    end
    return 5
end

-- ModConfig signals "ModConfigReady" when it can be manipulated
function OnMsg.ModConfigReady()

    ModConfig:RegisterMod("AutoShuttleConstruction",
        T{"AutoShuttleConstruction"},
        T{"Automatically construct Shuttles at Shuttle Hubs if there are plenty of resources and the hub is not full"}
    ) 

    ModConfig:RegisterOption("AutoShuttleConstruction", "Notifications", {
        name = T{"Notifications"},
        desc = T{"Enable/Disable notifications of the rovers in Auto mode."},
        type = "enum",
        values = {
            {value = "all", label = T{"All"}},
            {value = "problems", label = T{"Problems only"}},
            {value = "off", label = T{"Off"}}
        },
        default = "all" 
    })

    ModConfig:RegisterOption("AutoShuttleConstruction", "Threshold", {
        name = T{"Threshold"},
        desc = T{"How many times more resources are needed than the base cost of a Shuttle"},
        type = "number",
        min = 0,
        max = 50,
        default = 5 
    })

end

-- Automation Logic initialization
-- ==========================================================================
function OnMsg.GameTimeStart()
    AutoShuttleConstructionInstallThread()
end

function OnMsg.LoadGame()
    AutoShuttleConstructionInstallThread()
end

function AutoShuttleConstructionInstallThread()
    CreateGameTimeThread(function()
        while true do
            Sleep(1000)
            AutoShuttleConstructionManageHubs() 
        end
    end)
end

-- Automation Logic initialization
-- ==========================================================================
function AutoShuttleConstructionManageHubs()
    -- notifications to show
    local showNotifications = AutoShuttleConstructionConfigShowNotification()

    -- multiplier
    local threshold = AutoShuttleConstructionConfigThreshold()

    -- shuttle construction costs are local info on ShuttleHub unfortunately
    -- numbers are offset by 1000 relative to the displayed amount
    local polymerCost = 5000
    local polymerName = "Polymers"
    local electronicsCost = 3000
    local electronicsName = "Electronics"

    -- total available resources
    local totalPolymers = ResourceOverview['GetTotalStored'..polymerName](ResourceOverviewObj) or 0
    local totalElectronics = ResourceOverview['GetTotalStored'..electronicsName](ResourceOverviewObj) or 0

    local queuedShuttles = 0

    -- first find out how many shuttles are queued at the moment
    ForEach { class = "ShuttleHub",
        filter = function(hub)
            return not IsKindOf(hub, "ConstructionSite") 
                    and not tunnel.demolishing 
                    and not tunnel.destroyed 
                    and not tunnel.bulldozed
        end,
        exec = function(hub)
            queuedShuttles = queuedShuttles + hub.queued_shuttles_for_construction == 0
        end
    }

    -- deduce assigned resources from queued suttles
    totalPolymers = totalPolymers - queuedShuttles * polymerCost
    totalElectronics = totalElectronics - queuedShuttles * electronicsCost

    -- deduce threshold costs
    totalPolymers = totalPolymers - threshold * polymerCost
    totalElectronics = totalElectronics - threshold * electronicsCost

    -- loop through the hubs again and queue up construction
    ForEach { class = "ShuttleHub",
        filter = function(hub)
            return not IsKindOf(hub, "ConstructionSite") 
                    hub:CanHaveMoreShuttles()
                    and not tunnel.demolishing 
                    and not tunnel.destroyed 
                    and not tunnel.bulldozed
        end,
        exec = function(hub)
            if totalPolymers > 0 and totalElectronics > 0 then
                if not hub.shuttle_construction_time_start_ts and hub.queued_shuttles_for_construction == 0 then
                    if showNotifications == "all" then
                        AddCustomOnScreenNotification(
                            "AutoShuttleConstructionQueued", 
                            T{"Shuttle hub"}, 
                            T{"Shuttle construction queued"}, 
                            "UI/Icons/Notifications/research_2.tga",
                            false,
                            {
                                expiration = 15000
                            }
                        )
                    end
                    
                    hub:QueueConstructShuttle(1)

                    -- reduce the available amounts so that the next hub decides based on the remaining
                    -- free resources
                    totalPolymers = totalPolymers - polymerCost
                    totalElectronics = totalElectronics - electronicsCost
                end
            end
        end
    }
    
end