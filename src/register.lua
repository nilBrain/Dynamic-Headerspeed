--
-- register
--
-- @autor   nilBrain @VertexDezign
-- @date    26/01/2021
-- @node    register for Dynamic Header Speed
-- Copyright (C) nilBrain, Confidential, All Rights Reserved.
DynamicHeaderSpeedRegister = {}

local modName = g_currentModName;
local modDir = g_currentModDirectory;

DynamicHeaderSpeedRegister.MOD_NAME = modName;
DynamicHeaderSpeedRegister.MOD_DIR = modDir;

local specializationRegister = function(specializationName, specializationClassName, specializationFilename, searchedSpecializations, blockSpecializations)
	local neddedSpec = 0;
    local hasForNeed = 0;
	local specializationObject = g_specializationManager:getSpecializationObjectByName(modName .. "."..specializationName);
    --if specializationObject == nil then
		g_specializationManager:addSpecialization(specializationName, specializationClassName, specializationFilename, nil);
		specializationObject = g_specializationManager:getSpecializationObjectByName(modName .. "."..specializationName);
        --return;
    --end;
    for typeName, vehicleType in pairs(g_vehicleTypeManager:getTypes()) do
        if searchedSpecializations ~= nil then
            neddedSpec = #searchedSpecializations;
            for _, search in pairs(searchedSpecializations) do
                local specObject = g_specializationManager:getSpecializationObjectByName(search);
                if SpecializationUtil.hasSpecialization(specObject, vehicleType.specializations) then
                    hasForNeed = hasForNeed + 1;
                end;
            end;
        end;
        if specializationObject.prerequisitesPresent(vehicleType.specializations) then
            if neddedSpec <= hasForNeed then
                g_vehicleTypeManager:addSpecialization(typeName, modName .. "." .. specializationName);
            end;
        end;
    end;
end;

local loadspecializationsFromXML = function()
    local modDesc = loadXMLFile("modDesc", modDir .. "modDesc.xml");
    local key = "modDesc.registerSpecializations.specialization"
    local count = 0;
    while true do
        local key = string.format("%s(%d)", key, count);
        if not hasXMLProperty(modDesc, key) then
            break;
        end;
        local name = getXMLString(modDesc, key .. "#name");
        local className = getXMLString(modDesc, key .. "#className");
        local filename = Utils.getFilename(getXMLString(modDesc, key .. "#filename"), modDir);
        local searchedSpecializations = string.split(getXMLString(modDesc, key .. "#searchedSpecializations")," ");
        local blockSpecializations = string.split(getXMLString(modDesc, key .. "#blockSpecializations", " "));
        specializationRegister(name, className, filename, searchedSpecializations, blockSpecializations);
        count = count + 1;
    end;
    delete(modDesc);
end;

TypeManager.validateTypes = Utils.appendedFunction(TypeManager.validateTypes, function(typeManager)
    if typeManager.typeName == "vehicle" then
        loadspecializationsFromXML();
    end;
end);