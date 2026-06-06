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
closetMode.presets = {
	-- Closet preset: Legitimate looking but competitive
	closet = {
		aimbotEnabled = true,
		aimbotFOV = 25, -- Smaller FOV looks more natural
		aimbotSmoothing = 0.8, -- High smoothing for natural movement
		aimbotPrediction = true,
		triggerbot = false, -- Too obvious
		esp = false, -- Completely disabled for legitimacy
		wallhack = false,
		speedEnabled = false, -- Too obvious
		nofall = false,
		nowater = false,
		flight = false,
		hitboxExpander = false,
		reachLimit = 3.5, -- Subtle reach increase
		killAura = false, -- Way too obvious
		nametags = false,
		tracers = false,
		healthbars = false,
		blatantSettings = false,
		recoilCompensation = 0.5, -- Subtle recoil smoothing
		mouseSensitivity = 1.0, -- Natural sensitivity
		humanoidRotation = 0.3, -- Subtle head jitter
	},
	-- Blatant preset: Full power mode
	blatant = {
		aimbotEnabled = true,
		aimbotFOV = 180,
		aimbotSmoothing = 0.2,
		aimbotPrediction = true,
		triggerbot = true,
		esp = true,
		wallhack = true,
		speedEnabled = true,
		nofall = true,
		nowater = true,
		flight = true,
		hitboxExpander = true,
		reachLimit = 10,
		killAura = true,
		nametags = true,
		tracers = true,
		healthbars = true,
		blatantSettings = true,
		recoilCompensation = 1.0,
		mouseSensitivity = 2.0,
		humanoidRotation = 1.0,
	}
}

function closetMode.applyPreset(presetName)
	if not closetMode.presets[presetName] then
		warn('[R12SA V4] Invalid closet preset: ' .. presetName)
		return false
	end
	
	local preset = closetMode.presets[presetName]
	
	-- Store original settings if not already stored
	if not shared.vapeOriginalSettings then
		shared.vapeOriginalSettings = {}
	end
	
	-- Apply preset settings to all modules
	for setting, value in pairs(preset) do
		shared.vapeOriginalSettings[setting] = shared.vapeOriginalSettings[setting] or value
		
		-- Store in global environment for access by modules
		getgenv()[setting] = value
		shared[setting] = value
	end
	
	-- Apply to vape settings if vape is loaded
	if shared.vape and shared.vape.Categories then
		pcall(function()
			-- Combat settings
			local combat = shared.vape.Categories.Combat
			if combat and combat.Options then
				if combat.Options['Aimbot'] then
					combat.Options['Aimbot'].Enabled = preset.aimbotEnabled
				end
				if combat.Options['Aimbot FOV'] then
					combat.Options['Aimbot FOV'].Value = preset.aimbotFOV
				end
				if combat.Options['Aimbot Smoothing'] then
					combat.Options['Aimbot Smoothing'].Value = preset.aimbotSmoothing
				end
				if combat.Options['Prediction'] then
					combat.Options['Prediction'].Enabled = preset.aimbotPrediction
				end
				if combat.Options['Triggerbot'] then
					combat.Options['Triggerbot'].Enabled = preset.triggerbot
				end
				if combat.Options['Reach'] then
					combat.Options['Reach'].Value = preset.reachLimit
				end
			end
			
			-- Visuals settings
			local visuals = shared.vape.Categories.Visuals
			if visuals and visuals.Options then
				if visuals.Options['ESP'] then
					visuals.Options['ESP'].Enabled = preset.esp
				end
				if visuals.Options['Wallhack'] then
					visuals.Options['Wallhack'].Enabled = preset.wallhack
				end
				if visuals.Options['Nametags'] then
					visuals.Options['Nametags'].Enabled = preset.nametags
				end
				if visuals.Options['Tracers'] then
					visuals.Options['Tracers'].Enabled = preset.tracers
				end
				if visuals.Options['Healthbars'] then
					visuals.Options['Healthbars'].Enabled = preset.healthbars
				end
			end
			
			-- Movement settings
			local movement = shared.vape.Categories.Movement
			if movement and movement.Options then
				if movement.Options['Speed'] then
					movement.Options['Speed'].Enabled = preset.speedEnabled
				end
				if movement.Options['Nofall'] then
					movement.Options['Nofall'].Enabled = preset.nofall
				end
				if movement.Options['Flight'] then
					movement.Options['Flight'].Enabled = preset.flight
				end
			end
			
			-- Performance settings
			local performance = shared.vape.Categories.Performance
			if performance and performance.Options then
				if performance.Options['Recoil Compensation'] then
					performance.Options['Recoil Compensation'].Value = preset.recoilCompensation
				end
			end
		end)
	end
	
	closetMode.enabled = (presetName == 'closet')
	return true
end

function closetMode.toggle()
	if closetMode.enabled then
		closetMode.applyPreset('blatant')
		return 'Closet mode disabled - Blatant mode enabled'
	else
		closetMode.applyPreset('closet')
		return 'Closet mode enabled - Legitimacy mode active'
	end
end

function closetMode.getStatus()
	return {
		enabled = closetMode.enabled,
		currentPreset = closetMode.enabled and 'closet' or 'blatant',
		legitimacyMode = closetMode.enabled,
	}
end

-- Apply closet mode on startup if enabled
if getgenv().Closet then
	closetMode.applyPreset('closet')
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
			local closetStatus = getgenv().Closet and ' [CLOSET MODE ACTIVE]' or ''
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
