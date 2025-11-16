local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- Your local Node API base and shared secret key
local API_BASE = "http://localhost:3000"
local API_KEY = "102191309gadea"

-- Calls your Node API, gets basic list of asset ids from the web catalog
local function basicSearchCatalog(keyword: string, limit: number)
	limit = limit or 10

	local url = string.format(
		"%s/catalog?keyword=%s&limit=%d",
		API_BASE,
		HttpService:UrlEncode(keyword),
		limit
	)

	local headers = {
		["X-Api-Key"] = API_KEY,
	}

	local response = HttpService:GetAsync(url, false, headers)
	local data = HttpService:JSONDecode(response)

	return data.items or {}
end

-- Use MarketplaceService to enrich each item with full Roblox catalog details
local function enrichItemsWithDetails(items: { any })
	for _, item in ipairs(items) do
		local assetId = item.id
		if typeof(assetId) == "number" then
			local ok, info = pcall(function()
				return MarketplaceService:GetProductInfo(assetId, Enum.InfoType.Asset)
			end)

			if ok and info then
				local creator = info.Creator or {}

				item.name = info.Name
				item.description = info.Description
				item.price = info.PriceInRobux
				item.isForSale = info.IsForSale
				item.isLimited = info.IsLimited
				item.isLimitedUnique = info.IsLimitedUnique
				item.productId = info.ProductId
				item.assetTypeId = info.AssetTypeId

				item.creatorName = creator.Name
				item.creatorId = creator.Id
				item.creatorType = creator.CreatorType  -- "User" or "Group"
			else
				item.name = item.name or "Unknown"
			end
		end
	end
end

-- Public function: call Node, then enrich with MarketplaceService data
local function searchCatalog(keyword: string, limit: number)
	local items = basicSearchCatalog(keyword, limit or 10)
	enrichItemsWithDetails(items)
	return items
end

-- RemoteFunction so clients can request catalog data from the server
local searchRemote = Instance.new("RemoteFunction")
searchRemote.Name = "SearchCatalog"
searchRemote.Parent = ReplicatedStorage

searchRemote.OnServerInvoke = function(player, keyword: string?, limit: number?)
	keyword = keyword or "y2k"
	return searchCatalog(keyword, limit or 20)
end

-- Test block: runs on server start so you can see data in Output
task.spawn(function()
	print("[CatalogApi] Test search starting...")
	local ok, result = pcall(function()
		return searchCatalog("y2k", 10)
	end)

	if not ok then
		warn("[CatalogApi] Test search failed:", result)
		return
	end

	for _, item in ipairs(result) do
		print(
			"[CatalogApi] item:",
			item.id,
			item.name,
			item.price,
			item.creatorName,
			item.creatorType
		)
	end
end)
