local GMClass = class{}

function GMClass:parse(keys)
	local str = keys.text
	if string.find(str,'-') == 1 then
		print('str ',str)
		str = string.sub(str,2,-1)
	end

	if str == nil then
		return
	end
	print('str[1]',str)

	local args = string.split(str,' ')
	if #args == 0 then
		return
	end

	local funcName = args[1]
	local funcArgs = {}
	for i=2 , #args do
		table.insert(funcArgs,args[i])
	end
	print('gm parse ',funcName)
	
	local player = PlayerInstanceFromIndex(keys.userid)

	if self[funcName] then
		self[funcName](self,player,funcArgs)
	else
		print("[GM]: not find ",funcName)
	end
end

function GMClass:rs(player,args)
	SendToConsole("script_reload")
	if args[1] == '1' then
		return
	end
	GameRules:Playtesting_UpdateAddOnKeyValues()
end

function GMClass:cl(player,args)
	SendToConsole("clear")
end

function GMClass:cm(player,args)
	local hero = player:GetAssignedHero()
	ChangeModel(hero,tonumber(args[1]))
end

function GMClass:addexp(player,args)
	local hero = player:GetAssignedHero()
	print('pre xp',hero:GetCurrentXP())
	hero:AddExperience(tonumber(args[1]), DOTA_ModifyXP_Unspecified, false, false)
	print('later xp',hero:GetCurrentXP())
	print('---')
end

function GMClass:test(player,args)
	print('---test')
	local hero = player:GetAssignedHero()
	local url = "particles/exort_test1.vpcf"
	local p = ParticleManager:CreateParticle(url, PATTACH_ABSORIGIN_FOLLOW, hero)
	--ParticleManager:SetParticleControl(p,3,Vector(0,0,10))
	print('p',p)
	ParticleManager:SetParticleControlEnt(p, 3, hero, PATTACH_POINT_FOLLOW, "attach_orb1", Vector(100,100,100), true )
	ParticleManager:SetParticleControl(p,0,Vector(100,100,100))
	--ParticleManager:SetParticleControlOrientation(p,1,Vector(1,0,0),Vector(1,0,0),Vector(0,0,10))
	--hero:AddNewModifier(hero, nil,'modifier_invoker_exort_instance' , {})
end

function GMClass:p(player,args)
	local hero = player:GetAssignedHero()
	local url = "particles/econ/items/juggernaut/jugg_ti8_sword/juggernaut_blade_fury_abyssal.vpcf"
	local p = ParticleManager:CreateParticle(url, PATTACH_ABSORIGIN_FOLLOW, hero)
	ParticleManager:SetParticleControlEnt(p, 0, hero, PATTACH_ABSORIGIN_FOLLOW, "", Vector(500,500,500), true )
end

function GMClass:addnpc(player,args)
	local hero = player:GetAssignedHero()
	local pos = hero:GetAbsOrigin()

	local name = args[1] and args[1] or 'npc_dota_hero_elder_titan'
	local newhero = CreateUnitByName(name,pos,true,nil,nil,DOTA_TEAM_NEUTRALS)
	newhero:SetControllableByPlayer(player:GetPlayerID(),true)
	newhero:SetBaseIntellect(100)
	for i=1,25 do
		newhero:HeroLevelUp(true)
	end
end

function GMClass:pmod(player,args)
	local herolist = HeroList:GetAllHeroes()
	for _ , hero in pairs(herolist) do
		local modCount = hero:GetModifierCount()
		print('hero',hero:GetName(),modCount)
		for idx=0 , modCount-1 do
			local modName = hero:GetModifierNameByIndex(idx)
			print('modName',modName)
		end
		hero:AddNewModifier(hero,nil,'modifier_nevermore_necromastery',{})
	end
end

function GMClass:scale(player,args)
	local hero = player:GetAssignedHero()
	hero:SetModelScale(tonumber(args[1]))
end

function GMClass:kill(player,args)
	local hero = player:GetAssignedHero()
	hero:ForceKill(true)
end

function GMClass:fake(player,args)
	local hero = player:GetAssignedHero()
	local pos = hero:GetAbsOrigin()
	local name = "phoenix_spirit"
	local unit = CreateUnitByName(name,pos,true,nil,nil,hero:GetTeam())
	--local url = "particles/self_batrider.vpcf"
	--local p = ParticleManager:CreateParticle(url, PATTACH_ABSORIGIN_FOLLOW, unit)
	--ParticleManager:SetParticleControlEnt(p, 0, unit, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true )
end

function GMClass:pt(player,args)
	local hero = player:GetAssignedHero()
	local caster = hero
    local teamID = caster:GetTeamNumber()
	local origin = caster:GetOrigin()
	local name = "ent_dota_tree"
	local entities = Entities:FindAllByClassname(name)

	for _ , entity in pairs(entities) do
		--DeepPrintTable(entity)
		local max = entity:GetBoundingMaxs()
		local min = entity:GetBoundingMins()
		local center = entity:GetCenter()
		local pos = entity:GetAbsOrigin()
		print(max)
		print(min)
		print(center)
		print(pos)
		entity:SetRenderColor(255, 00, 0)
		break
	end
end

function GMClass:ac(player,args)
	local hero = player:GetAssignedHero()
	InnerFire(hero)
end

function GMClass:pos(player,args)
	local hero = player:GetAssignedHero()
	local origin = hero:GetAbsOrigin()
	origin.z = 300
	hero:SetAbsOrigin(origin)
end

function GMClass:sound(player,args)
	local hero = player:GetAssignedHero()
	
	hero:EmitSound("juggernaut_jug_win_01") 
	hero:EmitSound('Hero_DragonKnight.BreathFire') 
end

GameRules.GM = GMClass()