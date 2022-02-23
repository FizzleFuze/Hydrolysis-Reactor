--see Info/LICENSE for license and copyright info

--wrapper logging function for this file
local function Log(...)
    FF.Funcs.LogMessage("Code", ...)
end

--unlock upgrade
local function UnlockUpgrade(Upgrade)
    if UIColony then
        UIColony:UnlockUpgrade(Upgrade)
    end
end

--setup options and config
local function UpdateOptions()
    local DisableMOXIE = CurrentModOptions:GetProperty("DisableMOXIE")
    local Entity
    Log("BEGIN UpdateOptions()")

    if IsDlcAccessible("picard") then
        Entity = "Electrolyzer"
    elseif IsDlcAccessible("contentpack3") then
        Entity = WaterExtractorCP3
    end

    if Entity and ClassTemplates.Building.FFHydrolysisReactor then
        Log("Updating Class Template...")
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

    if DisableMOXIE then
        LockBuilding("MOXIE", "disable", FF.Funcs.Translate("Replaced by Hydrolysis Reactor"))
    else
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