--see Info/LICENSE for license and copyright info
--FF.Lib.Debug = true

--wrapper logging function for this file
local function Log(...)
    FF.Funcs.LogMessage("Hydrolysis-Reactor", "Code", ...)
end

--unlock upgrade
local function UnlockUpgrade(Upgrade)
    if UIColony then
        UIColony:UnlockUpgrade(Upgrade)
    end
end

--setup options and config
local function UpdateOptions()

    -- yeah, let's just cause an engine fault by not error handling anything... gg devs
    if not Mods then return end
    if not Mods.FIZZLE7 then return end
    if not Mods.FIZZLE7.options then return end

    local DisableMOXIE = CurrentModOptions:GetProperty("DisableMOXIE")
    local HideMOXIE = Mods.FIZZLE7.options.HideMOXIE
    local Entity
    Log("BEGIN UpdateOptions()")

    if IsDlcAccessible("picard") then
        Log("Picard DLC installed")
        Entity = "Electrolyzer"
    elseif IsDlcAccessible("contentpack3") then
        Log("Content Pack 3 installed")
        Entity = "WaterExtractorCP3"
    end

    if Entity and ClassTemplates.Building.FFHydrolysisReactor then
        Log("Updating class template to: ", Entity)
        ClassTemplates.Building.FFHydrolysisReactor.entity = Entity
    end

    if UICity then
        if UICity.labels.FFHydrolysisReactor then
            Log("Updating entity of existing reactors...")
            for _, HR in ipairs(UICity.labels.FFHydrolysisReactor) do
                HR:ChangeEntity(Entity)
            end
        end

        if IsTechResearched("NuclearFusion") then
            UnlockUpgrade("HydrolysisReactor_AdvancedReactions")
        end
        if IsTechResearched("MoistureFarming") then
            UnlockUpgrade("HydrolysisReactor_MoistureFarming")
        end
    end


    --toggle lock/hidden
    if DisableMOXIE then
        LockBuilding("MOXIE", "disable", FF.Funcs.Translate("Replaced by Hydrolysis Reactor"))
    end

    if HideMOXIE then
        LockBuilding("MOXIE")
    end

    if not (DisableMOXIE or HideMOXIE) then
        RemoveBuildingLock("MOXIE")
    end

    Log("FINISH UpdateOptions()")
end

--event handling
function OnMsg.TechResearched(tech_id, _, first_time)
    Log("Tech, FirstTime = ", tech_id, ", ", first_time)
    if tech_id == "NuclearFusion" and first_time then
        UnlockUpgrade("HydrolysisReactor_AdvancedReactions")
    end
    if tech_id == "MoistureFarming" and first_time then
        UnlockUpgrade("HydrolysisReactor_MoistureFarming")
    end
end

function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        UpdateOptions()
    end
end

local Init = UpdateOptions
OnMsg.MapGenerated = Init