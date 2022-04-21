--see Info/LICENSE for license and copyright info

--wrapper logging function for this file
local function Log(...)
    FF.Funcs.LogMessage(CurrentModDef.title, "HydrolysisReactor", ...)
end

--class def
DefineClass.HydrolysisReactor = {
    __parents = { "OutsideBuildingWithShifts", "WaterProducer", "AirProducer", "ElectricityProducer", "ResourceProducer", "DustGenerator", "BuildingDepositExploiterComponent",
                  "SubsurfaceDepositConstructionRevealer", },
    subsurface_deposit_class = "SubsurfaceDepositWater",

    building_update_time = const.HourDuration,
    track_multiple_hit_moments_in_work_state = true,

    stockpile_spots1 = { "Resourcepile" },
    additional_stockpile_params1 = {
        apply_to_grids = false,
        has_platform = true,
        snap_to_grid = false,
        priority = 2,
        additional_supply_flags = const.rfSpecialDemandPairing
    },

    anim_moments_thread = false,
    water_production = 2000,
    air_production = 2000,
    electricity_production = 0,
}

function HydrolysisReactor:GetEntityNameForPipeConnections(grid_skin_name)
    return grid_skin_name ~= "Default" and "Moxie" .. grid_skin_name or "Moxie"
end

function HydrolysisReactor:CreateElectricityElement()
    ElectricityProducer.CreateElectricityElement(self)
end

function HydrolysisReactor:CreateLifeSupportElements()
    AirProducer.CreateLifeSupportElements(self)
    WaterProducer.CreateLifeSupportElements(self)
end

function HydrolysisReactor:SetPriority(priority)
    OutsideBuildingWithShifts.SetPriority(self, priority)
    AirProducer.SetPriority(self, priority)
end

function HydrolysisReactor:ShouldShowNotConnectedToLifeSupportGridSign()
    return AirProducer.ShouldShowNotConnectedToLifeSupportGridSign(self)
end

function HydrolysisReactor:BuildingUpdate()
    if self.working then
        self:ProduceSupply("water", self.air_production)
    end
    RebuildInfopanel(self)
end

function HydrolysisReactor:DroneLoadResource(drone, request, resource, amount)
    TaskRequester.DroneLoadResource(self, drone, request, resource, amount)

    if not self.working then
        self:UpdateWorking()
    end
end

function HydrolysisReactor:GameInit()
    self:DepositChanged()
end

function HydrolysisReactor:OnDepositsLoaded()
    self:DepositChanged()
    self:UpdateConsumption()
    self:UpdateWorking()
end

function HydrolysisReactor:ProduceSupply(resource, amount)
    if resource == "water" and self.nearby_deposits[1] then
        local deposit_grade = self.nearby_deposits[1].grade --ExtractResource may kill this

        if self:DoesHaveUpgradeConsumption() then
            amount = self:Consume_Upgrades_Production(amount, 100)
        end

        amount = self:ExtractResource(amount)
        if self:ProduceWasteRock(amount, deposit_grade) then
            self:UpdateWorking(false)
        end
    end
end

function HydrolysisReactor:DepositChanged()
    local deposit_multiplier = self:GetCurrentDepositQualityMultiplier()
    local amount = MulDivRound(self:GetClassValue("water_production"), deposit_multiplier, 100)
    self:SetBase("water_production", amount)
    self:SetBase("oxygen_production", amount)
    self:UpdateWorking()
end

function HydrolysisReactor:OnChangeActiveDeposit()
    BuildingDepositExploiterComponent.OnChangeActiveDeposit(self)
    self:DepositChanged()
end

function HydrolysisReactor:OnDepositDepleted(deposit)
    BuildingDepositExploiterComponent.OnDepositDepleted(self, deposit)
    self:DepositChanged()
end

function HydrolysisReactor:UpdateElectricityProduction()
    --if type(self.upgrades_built) == "table" then -- to avoid error in self:HasUpgrade >=(
    if self:HasUpgrade("HydrolysisReactor_AdvancedReactions") and self:IsUpgradeOn("HydrolysisReactor_AdvancedReactions") then
        self:SetBase("electricity_production", 2 * self.air_production)
    else
        self:SetBase("electricity_production", 0)
    end
    --end
end

function HydrolysisReactor:OnSetWorking(working)
    Building.OnSetWorking(self, working)
    AirProducer.OnSetWorking(self, working)
    ElectricityProducer.OnSetWorking(self, working)

    local production = working and self.water_production or 0
    if self.water then
        self.water:SetProduction(production, production)
    end

    self:UpdateElectricityProduction()
end

function HydrolysisReactor:IsIdle()
    return self.ui_working and not self:CanExploit() and not self.city.colony:IsTechResearched("NanoRefinement")
end

function HydrolysisReactor:SetUIWorking(working)
    Building.SetUIWorking(self, working)
    BuildingDepositExploiterComponent.UpdateIdleExtractorNotification(self)
end

function HydrolysisReactor:UpdateAttachedSigns()
    if self.electricity then
        self:AttachSign(self:ShouldShowNotConnectedToPowerGridSign(), "SignNoPowerProducer")
    end
end

function HydrolysisReactor:OnUpgradeToggled()
    self:UpdateElectricityProduction()
end

function HydrolysisReactor:OnModifiableValueChanged(prop)
    Log("prop = ", prop)
    if prop == "water_production" and self.water then
        local production = self.working and self.water_production or 0
        self.water:SetProduction(production, production)
        Log("val = ", self.water_production)
    end
    if prop == "air_production" and self.air then
        self.air:SetProduction(self.working and self.air_production or 0)
        Log("val = ", self.air_production)

        self:UpdateElectricityProduction()
    end
    if (prop == "electricity_production" or prop == "performance") and self.electricity then
        Log("val = ", self.electricity_production)
        self.electricity:SetProduction(self.working and self:GetPerformanceModifiedElectricityProduction() or 0)
    end
end