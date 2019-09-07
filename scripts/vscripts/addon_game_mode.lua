require("_loader")
-- Generated from template

if GameModeClass == nil then
	_G.GameModeClass = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	PrecacheUnitByNameAsync("npc_dota_hero_legion_commander",function () end)
	PrecacheUnitByNameAsync("npc_dota_hero_abaddon",function () end)
	PrecacheUnitByNameAsync("npc_dota_hero_tusk",function () end)
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dragon_knight.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_axe.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_nevermore.vsndevts", context )
end
-- Create the game mode when we activate
function Activate()
	GameRules.GameMode = GameModeClass()
	GameRules.GameMode:InitGameMode()
end

function GameModeClass:InitGameMode()
	local gamemode = GameRules:GetGameModeEntity()
	
	gamemode:SetThink( "OnThink", self, "GlobalThink", 2 )
	gamemode:SetFogOfWarDisabled(true) 
	--gamemode:SetCustomGameForceHero("npc_dota_hero_legion_commander")
    gamemode:SetUseCustomHeroLevels(true)
	gamemode:SetCustomHeroMaxLevel(#selfKV.required_exp)
  	gamemode:SetCustomXPRequiredToReachNextLevel(selfKV.required_exp)

	self:InitGameTime()
	self:ListToGameEvent()
	self:RegisterFilter()
end

function GameModeClass:InitGameTime()
	--GameRules:SetHeroSelectionTime(5)
    --GameRules:SetPreGameTime(0)
    --GameRules:SetShowcaseTime(0)
    --GameRules:SetStrategyTime(0)
    --GameRules:SetCustomGameSetupTimeout(0)
end

function GameModeClass:ListToGameEvent()
	ListenToGameEvent("player_chat", Dynamic_Wrap(GameModeClass,"Player_Chat"), self)
	ListenToGameEvent('dota_player_gained_level',Dynamic_Wrap(GameModeClass,"OnGainedLevel"),self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(GameModeClass, "OnNPCSpawned"), self)
	ListenToGameEvent("tree_cut", Dynamic_Wrap(GameModeClass, "OnTreeCut"), self)
	ListenToGameEvent("dota_player_used_ability", Dynamic_Wrap(GameModeClass, "OnPlayerUsedAbility"), self)
	
end

function GameModeClass:RegisterFilter()
	print('register()')
    --local gamemode = GameRules:GetGameModeEntity()
	--gamemode:SetModifyExperienceFilter(Dynamic_Wrap(GameModeClass, 'ModifierExpFilter'),self)
end

function GameModeClass:OnNPCSpawned(keys)
	for k , v in pairs(keys) do
		print('k',k)
	end
	local entindex = keys.entindex
	local entity = EntIndexToHScript(entindex)
	if entity:IsHero() and entity:GetPlayerID() >= 0 then
		if entity:GetLevel() > 1 then
			print('HideWearables')
			entity:SetContextThink("HideWearables", function()
				HideWearables(entity)
			end, 0.1)
		end

		if entity:GetLevel() == 1 and entity.initmode == nil then
			ChangeModel(entity,entity:GetLevel())
			AddSeflBatrider(entity)
			entity.initmode = true
		end
	end

end


function GameModeClass:OnGainedLevel(keys)
	--升级变模型
	local player = EntIndexToHScript(keys.player)
    local level = keys.level
	local hero = player:GetAssignedHero()
	ChangeModel(hero,level)
end

function GameModeClass:OnTreeCut(keys)
	print('treeCut')
	for k , v in pairs(keys) do
		print('k',k)
	end
end

function GameModeClass:Player_Chat(keys)
	GameRules.GM:parse(keys)
end

function GameModeClass:OnPlayerUsedAbility(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if keys.abilityname == "breathe_fire" then
		caster:EmitSound('Hero_DragonKnight.BreathFire') 
		print('--')
		local entities = Entities:FindAllByClassname('ent_dota_tree')
		local pos = caster:GetAbsOrigin()
		local forward = caster:GetForwardVector()
		local angle1 = VectorToAngles(forward).y

		for _ , tree in pairs(entities) do
			local tree_pos = tree:GetAbsOrigin()
			if #(tree_pos-pos) < 800 then
				local diff = tree_pos - pos 
				local angle2 = VectorToAngles(diff).y
				
				if AngleDiff(angle1,angle2) < 30 and forward.Dot(forward,diff) > 0 then
					print('forward.Dot(forward,diff)',forward.Dot(forward,diff))
					print('AngleDiff(angle1,angle2)',AngleDiff(angle1,angle2))
					if tree.phoenix_spirit == nil then
						CreatePhoenixSpirit(caster,tree)
					end
				end
			end
		end
	end
end

-- Evaluate the state of the game
function GameModeClass:OnThink()
	-- if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	-- elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
	-- 	return nil
	-- end
	return 1
end