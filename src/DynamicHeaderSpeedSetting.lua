--
-- DynamicHeaderSpeedSetting
--
-- @autor   nilBrain @VertexDezign
-- @date    26/01/2023
-- @node register setting for Dynamic Header Speed
-- Copyright (C) nilBrain, Confidential, All Rights Reserved.

DynamicHeaderSpeedSetting = {};
local DynamicHeaderSpeedSetting_mt = Class(DynamicHeaderSpeedSetting)


function DynamicHeaderSpeedSetting.new(customMt)
	local self = setmetatable({}, customMt or DynamicHeaderSpeedSetting_mt);

    self.settings = {"0.5", "0.6", "0.7", "0.8", "0.9", "1.0", "1.1", "1.2", "1.3", "1.4", "1.5"};
    self.defaultIndex = 6;

    return self;
end;

function DynamicHeaderSpeedSetting:getSpeedIndex()
    return self.speedIndex or self.defaultIndex;
end;

function DynamicHeaderSpeedSetting:getValidSpeedIndex(value)
    local index = value;

    if MathUtil.getIsOutOfBounds(value, 1, #self.settings) then
        if value > #self.settings then
            index = 1;
        else
            index = #self.settings;
        end;
    end;

    return index;
end;


function DynamicHeaderSpeedSetting:getIndexFromSpeed(speedScale)
    for index, speed in pairs(self.settings) do
        if speed == tostring(speedScale) then
            return index;
        end;
    end;

    return self.defaultIndex;
end;

function DynamicHeaderSpeedSetting:getSpeedFromIndex(index)
    if index ~= nil and self.settings[index] ~= nil then
        return self.settings[index];
    end;
end;

function DynamicHeaderSpeedSetting.getHeader(vehicle)
    if vehicle ~= nil then
        if vehicle.spec_dynamicHeaderSpeed ~= nil then
            return vehicle;
        else

            if vehicle.getAttachedImplements ~= nil then
                for _, implement in ipairs(vehicle:getAttachedImplements()) do
                    if implement.object.spec_dynamicHeaderSpeed ~= nil then
                        return implement.object;
                    end;
                end;
            end;

        end;
    end;
end;

InGameMenuGeneralSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuGeneralSettingsFrame.onFrameOpen, function (self)

    if self.dynamicHeaderSpeed == nil then
        local title = TextElement.new();
        title:applyProfile("settingsMenuSubtitle", true);
        title:setText(g_i18n:getText("title_dynamicHeaderSpeed"));

        self.boxLayout:addElement(title);

        local headerText = TextElement.new();
        headerText:applyProfile("ingameMenuHelpRowText", true);
        headerText:setText(g_i18n:getText("text_DHS_moHeader"));

        self.boxLayout:addElement(headerText);

        local target = g_dynamicHeaderSpeedSetting;
        self.dynamicHeaderSpeed = self.checkUseEasyArmControl:clone()
        self.dynamicHeaderSpeed.target = target;
        self.dynamicHeaderSpeed.id = "dynamicHeaderSpeed";

        self.dynamicHeaderSpeed.title = title;
        self.dynamicHeaderSpeed.headerText = headerText;

        self.dynamicHeaderSpeed:setTexts(g_dynamicHeaderSpeedSetting.settings);

        self.dynamicHeaderSpeed.onClickCallback = function(_, state, optionElement)
            local header = g_dynamicHeaderSpeedSetting.getHeader(g_currentMission.controlledVehicle);
            if header ~= nil then
                header:setHeaderSpeedScale(state);
            end;
        end;

        self.dynamicHeaderSpeed:setState(g_dynamicHeaderSpeedSetting.defaultIndex);

        local settingTitle = self.dynamicHeaderSpeed.elements[4];
        local toolTip = self.dynamicHeaderSpeed.elements[6];

        settingTitle:setText(g_i18n:getText("setting_dynamicHeaderSpeed"));
        toolTip:setText(g_i18n:getText("toolTip_dynamicHeaderSpeed"));

        self.boxLayout:addElement(self.dynamicHeaderSpeed);
    end;

    local header = g_dynamicHeaderSpeedSetting.getHeader(g_currentMission.controlledVehicle);
    local isVisable = header ~= nil and header.spec_dynamicHeaderSpeed ~= nil;

    self.dynamicHeaderSpeed:setVisible(isVisable);
    self.dynamicHeaderSpeed.headerText:setVisible(not isVisable);

    if isVisable then
        self.dynamicHeaderSpeed:setState(g_dynamicHeaderSpeedSetting:getIndexFromSpeed(header:getHeaderSpeed()));
    end;

    self.boxLayout:invalidateLayout();
end);

g_dynamicHeaderSpeedSetting = DynamicHeaderSpeedSetting.new();