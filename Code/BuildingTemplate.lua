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

--wrapper logging function for this file
local function Log(...)
        Fizzle_FuzeLogMessage("BuildingTemplate", ...)
end

--translation strings
local Translate = { ID = {}, Text = {} }

Translate.Text['display_name'] = "Hydrolysis Reactor"
Translate.Text['display_name_pl'] = "Hydrolysis Reactors"
Translate.Text['description'] = "Extracts Oxygen from Water.<newline><newline>All extractors raise dust resulting in more frequent maintenance for buildings in the grey area."
Translate.Text['upgrade2_display_name'] = "Advanced Reactions"
Translate.Text['upgrade2_description'] = "Advanced Reactions allow excess energy from hydrogen atoms to be used in the power grid."
Translate.Text['upgrade3_display_name'] = "Moisture Farming"
Translate.Text['upgrade3_description'] = "Allows reactors to take moisture from the atmosphere to produce more oxygen and power."
Translate.Text['encyclopedia_text'] = "Uses the power of science to extract oxygen from water."

--get every string a unique ID
for k, _ in pairs(Translate.Text) do
        Translate.ID[k] = RandomLocId()
        if not Translate.ID[k] then
                Log("ERROR", "Could not find valid translation ID for '", k, "'!")
        end
end

function OnMsg.ClassesPostprocess()
        Log("Adding BT")

        PlaceObj('BuildingTemplate', {
                'comment', "Hydrolysis Reactor",
                'Group', "Life-Support",
                'Id', "FFHydrolysisReactor",
                'template_class', "HydrolysisReactor",
                'pin_rollover_context', "air",
                'pin_rollover_hint', T(471070805886, --[[ModItemBuildingTemplate FF-Hydrolysis-Reactor pin_rollover_hint]] "<image UI/Infopanel/left_click.tga 1400> Select"),
                'pin_rollover_hint_xbox', T(488123886351, --[[ModItemBuildingTemplate FF-Hydrolysis-Reactor pin_rollover_hint_xbox]] "<image UI/PS4/Cross.tga> View"),
                'construction_cost_Concrete', 5000,
                'construction_cost_Metals', 4000,
                'construction_cost_Electronics', 1000,
                'construction_cost_MachineParts', 2000,
                'build_points', 1500,
                'is_tall', true,
                'dome_forbidden', false,
                'upgrade1_id', "MOXIE_MagneticFiltering",
                'upgrade1_display_name', T(396174688820, --[[ModItemBuildingTemplate FF-Hydrolysis-Reactor upgrade1_display_name]] "Magnetic Filtering"),
                'upgrade1_description', T(936522085574, --[[ModItemBuildingTemplate FF-Hydrolysis-Reactor upgrade1_description]] "+<upgrade1_mul_value_1>% Production."),
                'upgrade1_icon', CurrentModPath.."/UI/Icons/amplify_01.png",
                'upgrade1_mod_label_1', "MOXIE",
                'upgrade1_mod_prop_id_1', "air_production",
                'upgrade1_mul_value_1', 50,
                'upgrade1_upgrade_cost_Concrete', 2000,
                'upgrade1_upgrade_cost_Polymers', 5000,
                'upgrade2_id', "HydrolysisReactor_AdvancedReactions",
                'upgrade2_display_name', T(Translate.ID['upgrade2_display_name'], Translate.Text['upgrade2_display_name']),
                'upgrade2_description', T(Translate.ID['upgrade2_description'], Translate.Text['upgrade2_description']),
                'upgrade2_icon', CurrentModPath.."/UI/Icons/eternal_fusion_01.png",
                'upgrade2_mod_prop_id_1', "electricity_production",
                'upgrade2_add_value_1', 0,
                'upgrade2_upgrade_cost_Electronics', 2000,
                'upgrade2_upgrade_cost_PreciousMetals', 1000,
                'upgrade3_id', "HydrolysisReactor_MoistureFarming",
                'upgrade3_display_name', T(Translate.ID['upgrade3_display_name'], Translate.Text['upgrade3_display_name']),
                'upgrade3_description', T(Translate.ID['upgrade3_description'], Translate.Text['upgrade3_description']),
                'upgrade3_icon', CurrentModPath.."/UI/Icons/hygroscopic_coating_01.png",
                'upgrade3_mod_prop_id_1', "air_production",
                'upgrade3_mul_value_1', 50,
                'upgrade3_upgrade_cost_Metals', 2000,
                'upgrade3_upgrade_cost_Polymers', 5000,
                'maintenance_resource_type', "MachineParts",
                'maintenance_resource_amount', 2000,
                'maintenance_threshold_base', 150000,
                'sight_category', "Additional Buildings",
                'sight_satisfaction', 5,
                'display_name', T(Translate.ID['display_name'], Translate.Text['display_name']),
                'display_name_pl', T(Translate.ID['display_name_pl'], Translate.Text['display_name_pl']),
                'description', T(Translate.ID['description'], Translate.Text['description']),
                'build_category', "Life-Support",
                'display_icon', CurrentModPath.."/UI/Icons/electrolyzer.png",
                'build_pos', 5,
                'entity', "Moxie",
                'show_range', true,
                'encyclopedia_id', "HydrolysisReactor",
                'encyclopedia_text', T(Translate.ID['encyclopedia_text'], Translate.Text['encyclopedia_text']),
                'encyclopedia_image', "UI/Encyclopedia/Electrolyzer.tga",
                'label1', "OutsideBuildings",
                'label2', "OutsideBuildingsTargets",
                'palette_color1', "outside_accent_1",
                'palette_color2', "outside_metal",
                'palette_color3', "life_base",
                'demolish_sinking', range(1, 5),
                'demolish_debris', 85,
                'disabled_in_environment1', "Asteroid",
                'air_production', 3000,
                'water_production', 2000,
                'exploitation_resource', "Water",
        })
end