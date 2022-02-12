--Copyright
--[[
*******************************************************************************
Fizzle_Fuze's Surviving Mars Mods
Copyright (c) 2022 Fizzle Fuze Enterprises (mods@fizzlefuze.com)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

  If your software can interact with users remotely through a computer
network, you should also make sure that it provides a way for users to
get its source.  For example, if your program is a web application, its
interface could display a "Source" link that leads users to an archive
of the code.  There are many ways you could offer source, and different
solutions will be better for different programs; see section 13 for the
specific requirements.

  You should also get your employer (if you work as a programmer) or school,
if any, to sign a "copyright disclaimer" for the program, if necessary.
For more information on this, and how to apply and follow the GNU AGPL, see
<https://www.gnu.org/licenses/>.
*******************************************************************************
--]]

--mod name
local ModName = "["..CurrentModDef.title.."]"

--translation strings
local Translate = { ID = {}, Text = {} }

Translate.Text['MoxieDisable'] = "Replaced by Hydrolysis Reactor."

--get every string a unique ID
for k, _ in pairs(Translate.Text) do
    Translate.ID[k] = RandomLocId()
    if not Translate.ID[k] then
        Log("ERROR", "Could not find valid translation ID for '", k, "'!")
    end
end

--logging variables
local Debugging = false

--print log messages to console and disk
local function PrintLog()
    local MsgLog = SharedModEnv["Fizzle_FuzeLog"]

    if #MsgLog > 0 then
        --print logged messages to console and file
        for _, Msg in ipairs(MsgLog) do
            print(Msg)
        end
        FlushLogFile()

        --reset
        SharedModEnv["Fizzle_FuzeLog"] = {}
        return
    end
end

--setup cross-mod variables for log if needed
if not SharedModEnv["Fizzle_FuzeLog"] then
    SharedModEnv["Fizzle_FuzeLog"] = { ModName.." INFO: First Fizzle_Fuze mod loading!" }
end

--main logging function
function Fizzle_FuzeLogMessage(...)
    local Sev, Arg = nil, {...}
    local SevType = {"INFO", "DEBUG", "WARNING", "ERROR", "CRITICAL"}

    if #Arg == 0 then
        print(ModName,"/?.lua CRITICAL: No error message!")
        FlushLogFile()
        MsgLog[#MsgLog+1] = ModName.."/?.lua CRITICAL: No error message!"
        SharedModEnv["Fizzle_FuzeLog"] = MsgLog
        return
    end

    for _, ST in ipairs(SevType) do
        if Arg[2] == ST then --2nd arg = severity
            Arg[2] = Arg[2]..": "
            Sev = Arg[2]
            break
        end
    end

    if not Sev then
        Sev = "DEBUG: "
        Arg[2] = "DEBUG: "..Arg[2]
    end

    if (Sev == "DEBUG: " and Debugging == false) or (Sev == "INFO: " and Info == false) then
        return
    end

    local MsgLog = SharedModEnv["Fizzle_FuzeLog"]
    local Msg = ModName.."/"..Arg[1]..".lua "
    for i = 2, #Arg do
        Msg = Msg..tostring(Arg[i])
    end
    MsgLog[#MsgLog+1] = Msg
    SharedModEnv["Fizzle_FuzeLog"] = MsgLog

    if (Debugging == true or Info == true) and Sev == "WARNING" or Sev == "ERROR" or Sev == "CRITICAL" then
        PrintLog()
    end
end

--wrapper logging function for this file
local function Log(...)
    Fizzle_FuzeLogMessage("Code", ...)
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
    end

    if IsTechResearched("NuclearFusion") then
        UnlockUpgrade("HydrolysisReactor_AdvancedReactions")
    end
    if IsTechResearched("MoistureFarming") then
        UnlockUpgrade("HydrolysisReactor_MoistureFarming")
    end

    if DisableMOXIE then
        LockBuilding("MOXIE", "disable", T(Translate.ID['MoxieDisable'], Translate.Text['MoxieDisable']))
    else
        RemoveBuildingLock("MOXIE")
    end

    Log("FINISH UpdateOptions()")
end

--event handling
function OnMsg.NewHour()
    if Debugging == true then
        PrintLog()
    end
end

--event handling
function OnMsg.NewDay()
    PrintLog()
end

--event handling
function OnMsg.ApplyModOptions(id)
    if id == CurrentModId then
        UpdateOptions()
    end
end

--event handling
OnMsg.ModsReloaded = UpdateOptions
OnMsg.CityStart = UpdateOptions
OnMsg.LoadGame = UpdateOptions

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