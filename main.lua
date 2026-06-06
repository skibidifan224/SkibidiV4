repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

if identifyexecutor then
	if table.find({'Wave', 'Seliware', 'Volt'}, ({identifyexecutor()})[1]) then
		getgenv().setthreadidentity = nil
	end
end

local args = ...
if type(args) == "table" and args.Username then
	shared.ValidatedUsername = args.Username
end

if type(args) == "table" and args.Closet then
	getgenv().Closet = true
else
	if getgenv().Closet == nil then
		getgenv().Closet = false
	end
end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService('HttpService'))

local function downloadFile(path, func)
	if not isfile(path) then
		local res
		local success = false
		for attempt = 1, 3 do
			local suc, result = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/R12sa/R12SAVapeV4/' .. readfile('newvape/profiles/commit.txt') .. '/' .. select(1, path:gsub('newvape/', '')), true)
			end)
			if suc and result ~= '404: Not Found' then
				res = result
				success = true
				break
			end
			task.wait(1)
		end
		if not success then
			error('Failed to download ' .. path .. ' after 3 attempts')
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n' .. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

--[[ ===== CLOSET MODE SYSTEM ===== ]]
local closetMode = {}
closetMode.enabled = getgenv().Closet or false
closetMode.modulesCache = {}

-- Closet preset configuration: Legitimate looking but competitive
closetMode.closetConfig = {
	-- Aimbot settings (uses existing ProjectileAimbot module)
	ProjectileAimbot = {
		Enabled = true,
		Part = 'Head',
		FOV = 25, -- Small FOV looks natural
	},
	
	-- Aim assist for hitscan weapons
	AimAssist = {
		Enabled = true,
		Part = 'Head',
		FOV = 20,
		Speed = 3.5, -- Slower = more natural
	},
	
	-- Silent aim (subtle)
	SilentAim = {
		Enabled = true,
		Range = 40, -- Slightly extended reach
		HitChance = 85, -- Not 100% = looks human
		HeadshotChance = 60,
	},
	
	-- Combat modules
	TriggerBot = {
		Enabled = false, -- Too obvious for closet
	},
	
	KillAura = {
		Enabled = false, -- Way too obvious
	},
	
	Reach = {
		Enabled = false, -- Handle via SilentAim range instead
	},
	
	-- Visuals (disabled for legitimacy)
	ESP = {
		Enabled = false,
	},
	
	Wallhack = {
		Enabled = false,
	},
	
	Tracers = {
		Enabled = false,
	},
	
	HealthBars = {
		Enabled = false,
	},
	
	Nametags = {
		Enabled = false,
	},
	
	-- Movement (subtle)
	Speed = {
		Enabled = false,
	},
	
	NoFall = {
		Enabled = false,
	},
	
	Flight = {
		Enabled = false,
	},
	
	-- Spider (useful for bedwars, not obvious)
	Spider = {
		Enabled = false,
	},
	
	-- Anti-knockback (subtle advantage)
	Disabler = {
		Enabled = false, -- Can be detected
	},
}

-- Blatant preset: Full power mode
closetMode.blatantConfig = {
	ProjectileAimbot = { Enabled = true, Part = 'Head', FOV = 180 },
	AimAssist = { Enabled = true, Part = 'Head', FOV = 180, Speed = 20 },
	SilentAim = { Enabled = true, Range = 100, HitChance = 100, HeadshotChance = 100 },
	TriggerBot = { Enabled = true },
	KillAura = { Enabled = true },
	Reach = { Enabled = true },
	ESP = { Enabled = true },
	Wallhack = { Enabled = true },
	Tracers = { Enabled = true },
	HealthBars = { Enabled = true },
	Nametags = { Enabled = true },
	Speed = { Enabled = true },
	NoFall = { Enabled = true },
	Flight = { Enabled = true },
	Spider = { Enabled = true },
	Disabler = { Enabled = true },
}

function closetMode.findModule(moduleName)
	if not shared.vape or not shared.vape.Modules then
		return nil
	end
	
	for _, module in ipairs(shared.vape.Modules) do
		if module.Name == moduleName then
			return module
		end
	end
	return nil
end

function closetMode.applyPreset(preset)
	if not shared.vape then
		warn('[R12SA V4] Vape not loaded yet')
		return false
	end
	
	task.wait(0.5) -- Wait for modules to load
	
	for moduleName, config in pairs(preset) do
		local module = closetMode.findModule(moduleName)
		
		if module then
			-- Store original state
			if not closetMode.modulesCache[moduleName] then
				closetMode.modulesCache[moduleName] = {
					enabled = module.Enabled,
					options = {}
				}
			end
			
			-- Apply enabled state
			if config.Enabled ~= nil then
				if module.Enabled ~= config.Enabled then
					module:Toggle()
				end
			end
			
			-- Apply options
			if module.Options then
				for optionName, optionValue in pairs(config) do
					if optionName ~= 'Enabled' then
						local option = module.Options[optionName]
						if option then
							-- Store original
							if not closetMode.modulesCache[moduleName].options[optionName] then
								if option.Value then
									closetMode.modulesCache[moduleName].options[optionName] = option.Value
								elseif option.Enabled ~= nil then
									closetMode.modulesCache[moduleName].options[optionName] = option.Enabled
								end
							end
							
							-- Apply new value
							if option.Value ~= nil then
								option.Value = optionValue
							elseif option.Enabled ~= nil then
								option.Enabled = optionValue
							end
						end
					end
				end
			end
		end
	end
	
	closetMode.enabled = (preset == closetMode.closetConfig)
	return true
end

function closetMode.toggle()
	if closetMode.enabled then
		closetMode.applyPreset(closetMode.blatantConfig)
		vape:CreateNotification('[R12SA V4] Closet Mode', 'Switched to BLATANT mode', 5, 'info')
		return 'Closet mode disabled - Blatant mode enabled'
	else
		closetMode.applyPreset(closetMode.closetConfig)
		vape:CreateNotification('[R12SA V4] Closet Mode', 'Switched to CLOSET mode', 5, 'info')
		return 'Closet mode enabled - Legitimacy mode active'
	end
end

function closetMode.getStatus()
	return {
		enabled = closetMode.enabled,
		currentMode = closetMode.enabled and 'closet' or 'blatant',
	}
end

-- Apply closet mode on startup if enabled
if getgenv().Closet then
	task.spawn(function()
		task.wait(2) -- Wait for full initialization
		closetMode.applyPreset(closetMode.closetConfig)
	end)
end

getgenv().closetMode = closetMode
shared.closetMode = closetMode

local function finishLoading()
	vape.Init = nil
	if not vape.Load then
		warn('[R12SA V4] vape.Load is nil skipping load')
		return
	end
	vape:Load()
	vape:Clean(task.spawn(function()
		repeat
			pcall(vape.Save, vape)
			task.wait(10)
		until vape.Loaded == nil
	end))

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				repeat task.wait() until game:IsLoaded()
				if getgenv and not getgenv().shared then getgenv().shared = {} end
				shared.vapereload = true
				loadstring(game:HttpGet('https://raw.githubusercontent.com/R12sa/R12SAVapeV4/'..readfile('newvape/profiles/commit.txt')..'/loader.lua', true), 'loader')()
			]]
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n' .. teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "' .. shared.VapeCustomProfile .. '"\n' .. teleportScript
			end
			if shared.ValidatedUsername then
				teleportScript = 'shared.ValidatedUsername = "' .. shared.ValidatedUsername .. '"\n' .. teleportScript
			end
			if getgenv().Closet then
				teleportScript = 'getgenv().Closet = true\n' .. teleportScript
			end
			local _ok, _err = pcall(function() vape:Save() end)
			if not _ok then warn('[R12SA V4] save failed before teleport: ' .. tostring(_err)) end
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			local name = shared.ValidatedUsername and ('wsg, ' .. shared.ValidatedUsername .. ' :D ') or 'welcome '
			local closetStatus = getgenv().Closet and ' [CLOSET MODE]' or ''
			task.spawn(function()
				local deadline = tick() + 15
				while tick() < deadline do
					task.wait(0.5)
				end
				vape:CreateNotification('[R12SA V4] Finished Loading' .. closetStatus, name .. (vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press F5 to open GUI'), 10)
			end)
		end
	end
end

if not isfile('newvape/profiles/gui.txt') then
	writefile('newvape/profiles/gui.txt', 'new')
end
local gui = readfile('newvape/profiles/gui.txt')

if not isfolder('newvape/assets/' .. gui) then
	makefolder('newvape/assets/' .. gui)
end

local guiSource = downloadFile('newvape/guis/' .. gui .. '.lua')
local guiFunc, guiErr = loadstring(guiSource, 'gui')
if not guiFunc then
	local errMsg = tostring(guiErr)
	local lineNum = errMsg:match(':(%d+):')
	local context = ''
	if lineNum then
		local n = tonumber(lineNum)
		local lines = guiSource:split('\n')
		local from = math.max(1, n - 2)
		local to   = math.min(#lines, n + 2)
		local parts = {}
		for i = from, to do
			local marker = i == n and '>>> ' or '    '
			table.insert(parts, marker .. i .. ': ' .. (lines[i] or ''))
		end
		context = '\n\nContext:\n' .. table.concat(parts, '\n')
	end
	error('[R12SA V4] syntax error in ' .. gui .. '.lua' .. '\n' .. errMsg .. context)
end
vape = guiFunc()
if not vape then
	error('[R12SA V4] GUI returned nil file may be corrupted try deleting newvape/guis/' .. gui .. '.lua and reinjecting.')
end
if not vape.Load then
	if delfile then pcall(function() delfile('newvape/guis/' .. gui .. '.lua') end) end
	error('[R12SA V4] gui file corrupted (missing load) reinject..')
end
if not vape.Init and not vape.Load then
	error('[R12SA V4] failed to initialize properly reinject to fix this bs')
end
shared.vape = vape
task.wait(0.1)

if not shared.VapeIndependent then
	loadstring(downloadFile('newvape/games/universal.lua'), 'universal')()
	local gameFileId = game.PlaceId
	if isfile('newvape/games/' .. gameFileId .. '.lua') then
		loadstring(downloadFile('newvape/games/' .. gameFileId .. '.lua'), tostring(gameFileId))(...)
	else
		if not shared.VapeDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/R12sa/R12SAVapeV4/' .. readfile('newvape/profiles/commit.txt') .. '/games/' .. gameFileId .. '.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('newvape/games/' .. gameFileId .. '.lua'), tostring(gameFileId))(...)
			end
		end
	end
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
