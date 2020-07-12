----------------------------
----- BadgerStockMarket ----
-- DOCWEIRD#6666 VRP EDIT --
----------------------------

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "vrp_stocks")

vRPstockS = {}
Tunnel.bindInterface("vrp_stocks", vRPstockS)
STOCKclient = Tunnel.getInterface("vrp_stocks", "vrp_stocks")

RegisterNetEvent("BadgerStocks:Buy")
AddEventHandler("BadgerStocks:Buy", function(data, cb)
    -- This is the buy stock thing 
    local src = source
	local player = src
    local xPlayer = vRP.getUserId({player})
    local stockAbbrev = data.stock
    local costPer = (data.cost)*100
	if vRP.tryPayment({xPlayer, costPer}) then
	print("user id: "..xPlayer.." paid: "..costPer.." unit cost: "..data.cost)
   -- if (xPlayer.getMoney() >= costPer) then 
        -- They can buy it 
        if (GetStockCount(xPlayer) < GetAllowedCount(src)) then 
            -- They can buy another one of it 
            BuyStock(xPlayer, stockAbbrev, 100, costPer)
            --xPlayer.setMoney( (xPlayer.getMoney() - costPer) );
            --TriggerClientEvent("BadgerStocks:SendNotif", src, "<span class='buy'>SUCCESS: Purchased a stock of " .. stockAbbrev .. "</span>")
			TriggerClientEvent("pNotify:SendNotification", src, {text = "You bought ".. stockAbbrev .. " and you paid: "..costPer.."$", type = "success", timeout = 3000, layout = "bottomCenter"})
            TriggerEvent("BadgerStocks:SetupDataID", xPlayer)
            --cb('ok');
        else 
            -- They already have the max number of stocks they are allowed 
            --TriggerClientEvent("BadgerStocks:SendNotif", src, "<span class='error'>ERROR: You already have the max number of stocks you " .. "are allowed to own...</span>")
			TriggerClientEvent("pNotify:SendNotification", src, {text = "Max stocks allowed!", type = "error", timeout = 3000, layout = "bottomCenter"})
        end
    else 
        -- They do not have enough money to afford this 
        --TriggerClientEvent("BadgerStocks:SendNotif", src, "<span class='error'>ERROR: You do not have enough money to afford this...</span>")
		TriggerClientEvent("pNotify:SendNotification", src, {text = "Not enough money!", type = "error", timeout = 3000, layout = "bottomCenter"})
    end
end)

function GetAllowedCount(src) 
	local player = src
    local user_id = vRP.getUserId({player})
    local curCount = 0
    for key, value in pairs(Config.maxStocksOwned) do 
        if value > curCount then 
            -- Check if they have access 
            --if IsPlayerAceAllowed(src, key) then
			if vRP.hasPermission({user_id,key}) then
                curCount = value
            end
        end
    end
    return curCount
end

RegisterNetEvent("BadgerStocks:SetupData")
AddEventHandler("BadgerStocks:SetupData", function()
	local src = source
    local xPlayer = vRP.getUserId({src})
    local data = GetStockPurchaseData(xPlayer)
    TriggerClientEvent("BadgerStocks:SendData", src, data)
end)

RegisterNetEvent("BadgerStocks:SetupDataID")
AddEventHandler("BadgerStocks:SetupDataID", function(src)
    --local src = source
    local xPlayer = vRP.getUserId({src})
    local data = GetStockPurchaseData(xPlayer)
    TriggerClientEvent("BadgerStocks:SendData", src, data)
end)

RegisterNetEvent("BadgerStocks:Sell")
AddEventHandler("BadgerStocks:Sell", function(data, cb)
    -- This is the sell stock thing 
    local src = source
	local player = src
    local xPlayer = vRP.getUserId({player})
    local stockAbbrev = data.stock
    local costPer = (data.cost)*100
    if HasStockOwned(xPlayer, stockAbbrev, 100) then 
        -- They own it, sell it 
        SellStock(xPlayer, stockAbbrev, 100, costPer)
		vRP.giveMoney({xPlayer, costPer})
       -- xPlayer.setMoney(xPlayer.getMoney() + costPer)
	   TriggerClientEvent("pNotify:SendNotification", src, {text = "You sold 100 of your ".. stockAbbrev .. " stocks at the value of: "..costPer.."$", type = "success", timeout = 3000, layout = "bottomCenter"})
        --TriggerClientEvent("BadgerStocks:SendNotif", src, "<span class='sell'>SUCCESS: Sold a stock of " .. stockAbbrev .. "</span>")
        TriggerEvent("BadgerStocks:SetupDataID", src)
        --cb('ok');
    else 
        -- They do not own this stock 
        TriggerClientEvent("pNotify:SendNotification", src, {text = "You don t have any of ".. stockAbbrev .. " stocks!", type = "error", timeout = 3000, layout = "bottomCenter"})
    end 
end)


function BuyStock(src, stockAbbrev, amount, pricePer)
    --local src = source
	--local player = src
	local player = vRP.getUserSource({src})
    local steam = src
	print("USER HA COMPRATO: "..steam)
	if (HasStockOwned(steam, stockAbbrev, 100)) then 
		-- They own, increase their own count
		local  sql = "UPDATE `user_stock_data` SET ownCount = (ownCount + @amt) WHERE `identifier` = @steam AND `stockAbbrev` = @stock"
		MySQL.Async.execute(sql, {['@amt'] = amount, ['@steam'] = steam, ['@stock'] = stockAbbrev})
	else
		-- They don't have an owned stock of this, insert 
		local  sql = "INSERT INTO `user_stock_data` VALUES (0, @steam, @stock, @amt)"
		MySQL.Async.execute(sql, {['@amt'] = amount, ['@steam'] = steam, ['@stock'] = stockAbbrev})
	end
	i = 0
	while i < amount do 
		MySQL.Async.execute("INSERT INTO `stock_purchase_data` VALUES (0, @steam, @purch, @stock, 1)", {
			['@steam'] = steam,
			['@purch'] = pricePer,
			['@stock'] = stockAbbrev
		})
		i = i + 1
	end 
	TriggerEvent("BadgerStocks:SetupDataID", player)
end 

function SellStock(src, stockAbbrev, amount, pricePer)
    --local src = source
	--local player = src
    local steam = src
	if (HasStockOwned(src, stockAbbrev, amount)) then 
		-- They have enough of this stock, sell it
		local sql = "SELECT ownCount FROM user_stock_data WHERE identifier = @steam AND stockAbbrev = @abbrev"
		local countSQL = MySQL.Sync.fetchAll(sql, {['@steam'] = steam, ['@abbrev'] = stockAbbrev})
		local count = countSQL[1].ownCount
		if count == amount then 
			MySQL.Async.execute("DELETE FROM `user_stock_data` WHERE `identifier` = @steam AND `stockAbbrev` = @stock", {
				['@steam'] = steam,
				['@stock'] = stockAbbrev
			})
			MySQL.Async.execute("UPDATE `stock_purchase_data` SET isOwned = 0 WHERE `identifier` = @steam AND `stockAbbrev` = @stock", {
				['@steam'] = steam,
				['@stock'] = stockAbbrev
			})
		else 
			-- Execute async, update their isOwned data for the stock_purchase_data that has least price:
			local row = MySQL.Sync.fetchAll("SELECT `id` FROM `stock_purchase_data` WHERE `isOwned` = 1 AND `identifier` = @steam AND stockAbbrev = @stock ORDER BY `purchasedPrice` DESC", {
				['@steam'] = steam,
				['@stock'] = stockAbbrev
			})
			local updated = 0
			for i = 1, #row do 
				local id = row[i].id
				if (updated < amount) then 
					-- Set it as not owned any more 
					MySQL.Sync.execute("UPDATE `stock_purchase_data` SET `isOwned` = 0 WHERE `id` = @id", {
						['@id'] = id
					})
					updated = updated + 1
				end
			end
		end 
		-- Update it, they have more than amount
		MySQL.Async.execute("UPDATE `user_stock_data` SET `ownCount` = @own WHERE stockAbbrev = @stock AND identifier = @steam", {
			['@own'] = (count - amount),
			['@steam'] = steam,
			['@stock'] = stockAbbrev
		})
	else
		-- They do not have enough of this stock to sell 
	end
end 

function HasStockOwned(src, stockAbbrev, amount) 
    --local src = source
	--local player = src
    local steam = src
	local sql = "SELECT COUNT(*) FROM user_stock_data WHERE identifier = @steam AND stockAbbrev = @abbrev"
	local count = MySQL.Sync.fetchScalar(sql, {['@steam'] = steam, ['@abbrev'] = stockAbbrev})
	if count > 0 then 
		return true
	end
	return false
end

function GetStockCount(src)
    --local src = source
	--local player = src
    local steam = src
	local sql = "SELECT stockAbbrev, ownCount FROM user_stock_data WHERE identifier = @steam AND ownCount > 0"
	local stocks = MySQL.Sync.fetchAll(sql, {['@steam'] = steam})
	local count = 0
	for i = 1, #stocks do 
		local abbrev = stocks[i].stockAbbrev
		local owns = stocks[i].ownCount
		count = count + owns
	end
	return count
end
function GetStocks(src)
    local src = source
	local player = src
    local steam = vRP.getUserId({source})
	local sql = "SELECT stockAbbrev, ownCount FROM user_stock_data WHERE identifier = @steam AND ownCount > 0"
	local stocks = MySQL.Sync.fetchAll(sql, {['@steam'] = steam})
	local stockData = {}
	for i = 1, #stocks do 
		local abbrev = stocks[i].stockAbbrev
		local owns = stocks[i].ownCount
		if stockData[abbrev] == nil then 
			stockData[abbrev] = owns
		else
			stockData[abbrev] = stockData[abbrev] + owns
		end 
	end
	return stockData
end
function GetStockPurchaseData(src)
    --local src = source
	--local player = src
    local steam = src
	local sql = "SELECT id, stockAbbrev, purchasedPrice FROM stock_purchase_data WHERE identifier = @steam AND isOwned = 1 ORDER BY "
	.. "`id` DESC"
	local stockData = {}
	local stockDatas = MySQL.Sync.fetchAll(sql, {['@steam'] = steam})
	for i = 1, #stockDatas do 
		local id = stockDatas[i].id
		local abbrev = stockDatas[i].stockAbbrev
		local pricePurch = stockDatas[i].purchasedPrice
		table.insert(stockData, {id, abbrev, pricePurch})
	end
	local data = {}
	local sorter = {}
	for i = 1, #stockData do 
		if (data[stockData[i][2] .. "-" .. stockData[i][3]] == nil) then 
			-- Set it up 
			local count = 1
			for j = 1, #stockData do 
				if (j ~= i) and (stockData[j][2] == stockData[i][2]) and (stockData[j][3] == stockData[j][3]) then 
					-- They are another of this type, increase the count 
					count = count + 1
				end
			end 
			data[stockData[i][2] .. "-" .. stockData[i][3]] = {stockData[i][1], stockData[i][2], stockData[i][3], count}
			table.insert(sorter, stockData[i][2] .. "-" .. stockData[i][3])
		end
	end 
	return {data, sorter}
end

RegisterNetEvent('BadgerStockMarket:Server:GetMaxStocks')
AddEventHandler('BadgerStockMarket:Server:GetMaxStocks', function()
	--local player = src
    local user_id = vRP.getUserId({source})
	local curAmt = 0
	for permission, amount in pairs(Config.maxStocksOwned) do 
		--if IsPlayerAceAllowed(src, permission) then
		print("MAX STOCKS: "..permission)
		print("MAX STOCKS: "..amount)
		if vRP.hasPermission({user_id,permission}) then
			if amount >= curAmt then 
				curAmt = amount
			end
		end
	end
	TriggerClientEvent('BadgerStockMarket:Client:SetMaxStocksOwned', source, curAmt)
end)

function GetAllowedCount(src) 
	local player = src
    local user_id = vRP.getUserId({player})
    local curCount = 0
    for key, value in pairs(Config.maxStocksOwned) do 
        if value > curCount then 
            -- Check if they have access 
            --if IsPlayerAceAllowed(src, key) then
			--local permesso = 
			print("CONSENTITO: "..key)
			print("CONSENTITO: "..value)
			if vRP.hasPermission({user_id,key}) then
                curCount = value
			else
            end
        end
    end
    return curCount
end

RegisterNetEvent('BadgerStockMarket:Server:GetStockHTML')
AddEventHandler('BadgerStockMarket:Server:GetStockHTML', function()
	local stockData = {}
	local src = source
	for stockName, stockInfo in pairs(Config.stocks) do
		local stockLink = stockInfo['link']
		local stockTags = stockInfo['tags']
		local data = nil
		PerformHttpRequest(tostring(stockLink), function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
		end)
		while data == nil do 
		Wait(0)
		end
		if data.data ~= nil then 
			stockData[stockName] = {
				data = data.data,
				link = stockLink,
				tags = stockTags,
			}
		end
	end
	TriggerClientEvent('BadgerStockMarket:Client:GetStockData', src, stockData)
end)