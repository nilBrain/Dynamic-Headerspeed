--
-- DynamicHeaderSpeedSettingEvent
--
-- @autor	nilBrain @VertxDezign
-- @date	26/01/2023
-- @node	MP Event to sync Header rotation speed,
-- Copyright (C) nilBrain, Confidential, All Rights Reserved.

DynamicHeaderSpeedSettingEvent = {};
local DynamicHeaderSpeedSettingEvent_mt = Class(DynamicHeaderSpeedSettingEvent, Event);

InitEventClass(DynamicHeaderSpeedSettingEvent, "DynamicHeaderSpeedSettingEvent")

function DynamicHeaderSpeedSettingEvent.emptyNew()
	return Event.new(DynamicHeaderSpeedSettingEvent_mt);
end;

function DynamicHeaderSpeedSettingEvent.new(vehicle, settingIndex)
	local self = DynamicHeaderSpeedSettingEvent.emptyNew();
	self.vehicle = vehicle;
	self.settingIndex = settingIndex;

	return self;
end;

function DynamicHeaderSpeedSettingEvent:readStream(streamId, connection)
	local vehicle = NetworkUtil.readNodeObject(streamId);
	local settingIndex = streamReadUInt8(streamId);

	vehicle:setHeaderSpeedScale(settingIndex, true);
end;

function DynamicHeaderSpeedSettingEvent:writeStream(streamId, connection)
	NetworkUtil.writeNodeObject(streamId, self.vehicle);
	streamWriteUInt8(streamId, self.settingIndex);
end;

function DynamicHeaderSpeedSettingEvent:run(connection)
end;