----------------------------
----- BadgerStockMarket ----
-- DOCWEIRD#6666 VRP EDIT --
----------------------------

Citizen.CreateThread(function()
	-- This is the thread for sending resource name 
	Citizen.Wait(1000)
	local rname = GetCurrentResourceName();
	SendNUIMessage({
		resourcename = rname;
	});
end)

RegisterNetEvent("BadgerStocks:SendNotif")
AddEventHandler("BadgerStocks:SendNotif", function(notif)
	SendNUIMessage({
		notification = notif;
	});
end)

RegisterNetEvent("BadgerStocks:SendData")
AddEventHandler("BadgerStocks:SendData", function(data)
	SendNUIMessage({
		theirStockData = data;
	});
end)

local puocomprare = true

RegisterNUICallback("BadgerStocks:Buy", function(data, cb)
	if puocomprare then
	TriggerServerEvent("BadgerStocks:Buy", data, function(callback) return callback end)
	puocomprare = false
	--SetNuiFocus(false, false)
	--cb('ok')
	Citizen.Wait(3000)
	puocomprare = true
	else
	TriggerEvent("pNotify:SendNotification",  {text = "Don t SPAM!", type = "error", timeout = 3000, layout = "bottomCenter"})
	end
end)

local puovendere = true

RegisterNUICallback("BadgerStocks:Sell", function(data, cb)
	if puocomprare then
	TriggerServerEvent("BadgerStocks:Sell", data, function(callback) return callback end)
	puovendere = false
	--SetNuiFocus(false, false)
	--cb('ok')
	Citizen.Wait(3000)
	puovendere = true
	else
	TriggerEvent("pNotify:SendNotification",  {text = "Don t SPAM!", type = "error", timeout = 3000, layout = "bottomCenter"})
	end
end)

maxStocksOwned = 20; -- The max stocks the user is allowed to own 

RegisterNetEvent('BadgerStockMarket:Client:SetMaxStocksOwned')
AddEventHandler('BadgerStockMarket:Client:SetMaxStocksOwned', function(maxStocks)
	maxStocksOwned = maxStocks
end)

stockData = nil;

RegisterNetEvent('BadgerStockMarket:Client:GetStockData')
AddEventHandler('BadgerStockMarket:Client:GetStockData', function(stockD)
	stockData = stockD
end)

RegisterCommand('stocks', function(source, args, rawCommand)
	-- Toggle on and off stocks phone 
	TriggerServerEvent('BadgerStockMarket:Server:GetStockHTML')
	SetNuiFocus(true, true)
	TriggerServerEvent('BadgerStockMarket:Server:GetMaxStocks')
	SendNUIMessage({
		maxStocksAllowed = maxStocksOwned;
	});
	SendNUIMessage({
		show = true;
	});
	TriggerServerEvent("BadgerStocks:SetupData")
	while stockData == nil do 
		Wait(500);
		SendNUIMessage({
			stockData = stockData;
		});
	end
	if stockData ~= nil then 
		SendNUIMessage({
			stockData = stockData;
		});
	end
end)

RegisterNUICallback('BadgerPhoneClose', function(data, cb)
	SetNuiFocus(false, false)
	if (cb) then 
		cb('ok')
	end
end)