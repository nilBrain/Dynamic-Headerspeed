--
-- DynamicHeaderSpeed
--
-- @autor	nilBrain @VertexDezign
-- @date	01.08.2022
-- Copyright (C) nilBrain, Confidential, All Rights Reserved.

DynamicHeaderSpeed = {};

--relative to km/h
DynamicHeaderSpeed.MIN_SPPED_FACTOR = 4;
DynamicHeaderSpeed.MAX_SPPED_FACTOR = 10;

local modName = DynamicHeaderSpeedRegister.MOD_NAME;


function DynamicHeaderSpeed.prerequisitesPresent(specializations)
	return SpecializationUtil.hasSpecialization(Cutter, specializations);
end;

function DynamicHeaderSpeed.initSpecialization()
    local schemaSavegame = Vehicle.xmlSchemaSavegame
    local savegamePath = string.format("vehicles.vehicle(?).%s", modName);
    schemaSavegame:register(XMLValueType.INT, savegamePath .. ".dynamicHeaderSpeed#speedIndex", "Current header speed Index");
end;

function DynamicHeaderSpeed.registerEventListeners(vehicleType)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", DynamicHeaderSpeed);
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", DynamicHeaderSpeed);
	SpecializationUtil.registerEventListener(vehicleType, "onUpdate", DynamicHeaderSpeed);
end;

function DynamicHeaderSpeed.registerFunctions(vehicleType)
	SpecializationUtil.registerFunction(vehicleType, "getHeaderSpeed", DynamicHeaderSpeed.getHeaderSpeed);
	SpecializationUtil.registerFunction(vehicleType, "setHeaderSpeedScale", DynamicHeaderSpeed.setHeaderSpeedScale);
	SpecializationUtil.registerFunction(vehicleType, "actionEventHeaderSpeedValue", DynamicHeaderSpeed.actionEventHeaderSpeedValue);
end;

function DynamicHeaderSpeed:onLoad(savegame)
	self.spec_dynamicHeaderSpeed = self[string.format("spec_%s.dynamicHeaderSpeed", modName)];
	local spec = self.spec_dynamicHeaderSpeed;

	spec.headerSpeedScale = g_dynamicHeaderSpeedSetting:getSpeedFromIndex(g_dynamicHeaderSpeedSetting:getSpeedIndex());

	if savegame ~= nil then
        local savegameKey = string.format("%s.%s.dynamicHeaderSpeed", savegame.key, modName);

		local index = savegame.xmlFile:getValue(savegameKey .. "#speedIndex");
		if index ~= nil then
			spec.headerSpeedScale = g_dynamicHeaderSpeedSetting:getSpeedFromIndex(index);
		end
	end;


	if self.isClient then
		local specCutter = self.spec_cutter;
		local newSpeedFunc = function()
			return MathUtil.clamp(self:getLastSpeed(true) / self:getRawSpeedLimit(), DynamicHeaderSpeed.MIN_SPPED_FACTOR / 10, DynamicHeaderSpeed.MAX_SPPED_FACTOR / 10) * spec.headerSpeedScale;
		end;

		if specCutter ~= nil then
			if specCutter.animationNodes ~= nil then
				for _, animation in ipairs(specCutter.animationNodes) do
					if getName(animation.node):lower():find("reel") then
						animation.speedFunc = newSpeedFunc;
					end;
				end;
			end;
		end;
	end;
end;


function DynamicHeaderSpeed:saveToXMLFile(xmlFile, key, usedModNames)
    local spec = self.spec_dynamicHeaderSpeed
	local speedIndex = g_dynamicHeaderSpeedSetting:getIndexFromSpeed(spec.headerSpeedScale);
	xmlFile:setValue(key .. "#speedIndex", speedIndex);
end

function DynamicHeaderSpeed:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    if self.isClient then
        local spec = self.spec_dynamicHeaderSpeed;

        if isActiveForInput then
            local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.DHS_AXIS_HEADERSPEED, self, DynamicHeaderSpeed.actionEventHeaderSpeedValue, false, true, false, true, nil);

			spec.lastCruiseControlActionEventId = actionEventId;

			DynamicHeaderSpeed.updateActionEventTexts(self);
			g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_NORMAL);
		end;
	end;
end;

function DynamicHeaderSpeed:onUpdate()
	if self.isClient then

		local spec = self.spec_dynamicHeaderSpeed;
		local specTurnOn = self.spec_turnOnVehicle;

		if specTurnOn ~= nil then
			for i = 1, #specTurnOn.turnedOnAnimations do

				local turnedOnAnimation = specTurnOn.turnedOnAnimations[i];
				local isTurnedOn = self:getIsTurnedOnAnimationActive(turnedOnAnimation);

				if turnedOnAnimation.name:lower():find("reel") and isTurnedOn then
					local speed = turnedOnAnimation.speedScale * MathUtil.clamp(self:getLastSpeed(true) / self:getRawSpeedLimit(), DynamicHeaderSpeed.MIN_SPPED_FACTOR / 10, DynamicHeaderSpeed.MAX_SPPED_FACTOR / 10) * spec.headerSpeedScale;
					turnedOnAnimation.currentSpeed = speed;
				end;
			end;
		end;
	end;
end;

function DynamicHeaderSpeed:getHeaderSpeed()
	return self.spec_dynamicHeaderSpeed.headerSpeedScale;
end;

function DynamicHeaderSpeed:updateActionEventTexts()
    local spec = self.spec_dynamicHeaderSpeed;

    if spec.lastCruiseControlActionEventId ~= nil then
		local text = string.format("%s [%s]", g_i18n:getText("action_changeHeaderSpeedLevel"), self:getHeaderSpeed());
		g_inputBinding:setActionEventText(spec.lastCruiseControlActionEventId, text);
	end;
end;

function DynamicHeaderSpeed:setHeaderSpeedScale(speedIndex, noEventSend)

	if speedIndex ~= nil then
		local spec = self.spec_dynamicHeaderSpeed;

		if (noEventSend == nil or noEventSend == false) and g_server == nil and g_client ~= nil then
			g_client:getServerConnection():sendEvent(VehicleSettingsChangeEvent.new(self, speedIndex));
		end

		spec.headerSpeedScale = g_dynamicHeaderSpeedSetting:getSpeedFromIndex(speedIndex);

		if self.isClient then
			DynamicHeaderSpeed.updateActionEventTexts(self);
		end;
	end;
end;


function DynamicHeaderSpeed:actionEventHeaderSpeedValue(actionName, inputValue, callbackState, isAnalog)
	local spec = self.spec_dynamicHeaderSpeed;
	local value = g_dynamicHeaderSpeedSetting:getIndexFromSpeed(spec.headerSpeedScale) + inputValue;

	self:setHeaderSpeedScale(g_dynamicHeaderSpeedSetting:getValidSpeedIndex(value));
end;