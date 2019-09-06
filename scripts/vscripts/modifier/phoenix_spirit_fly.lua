phoenix_spirit_fly = class({})

local FLY_SPEED_XY = 1000
-- W
function phoenix_spirit_fly:GetBehavior()
	if not IsServer() then return end

end

function phoenix_spirit_fly:OnCreated(kv)
	if not IsServer() then return end
	print('IsServer() ',IsServer())
	print('self:ApplyHorizontalMotionController()',self:ApplyHorizontalMotionController())
	print('self:ApplyVerticalMotionController()',self:ApplyVerticalMotionController())
	if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
		print('---destory')
		self:Destroy()
		return
	end
    print(kv.targetpos) 
    local caster = self:GetParent()
    local curPos = caster:GetAbsOrigin()
	self.curPos = curPos
	self.targetpos = caster.targetpos
	print('self.targetpos',self.targetpos)
    self.dir = (self.targetpos - curPos )
    --caster:SetForwardVector(self.dir)
    self.distanceZ = self.dir.z
    self.dir.z = 0
    self.distanceXY = #self.dir
    self.dir = self.dir:Normalized()
    self.SpeedZ = self.distanceZ / self.distanceXY * FLY_SPEED_XY
    
	print('curPos ',curPos , 'targetPos', self.targetpos)
end


function phoenix_spirit_fly:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
			self:Destroy()
			return
        end
        local caster = self:GetParent()
		local vOldPos = caster:GetOrigin()
		local moveDis = FLY_SPEED_XY * dt
        self.distanceXY = self.distanceXY - moveDis
		if self.distanceXY <= 0 then
			me:SetAbsOrigin(self.targetpos)
			self:Destroy()
			return 
		end
		local pos = vOldPos + self.dir * FLY_SPEED_XY * dt
		me:SetOrigin(pos)
	end
end

function phoenix_spirit_fly:UpdateVerticalMotion( me, dt )
	if IsServer() then
		if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
			self:Destroy()
			return
		end
		local pos = self:GetParent():GetAbsOrigin()
		pos.z = pos.z + self.SpeedZ*dt
		me:SetAbsOrigin(pos)
	end
end

function phoenix_spirit_fly:shadowraze()
    local url = 'particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf' 
    EasyParticle(self:GetParent(),url)

    local owner = self:GetParent():GetOwner()
    local ability = owner:FindAbilityByName('spell_fire_sprite')
    local zxc_damage = ability:GetSpecialValueFor("damage")
    local buff_damage = ability:GetSpecialValueFor("buff_damage")
    local zxc_radius = ability:GetSpecialValueFor("zxc_radius")
    local teamID = owner:GetTeamNumber()
    local caster = self:GetParent()
    local pos = caster:GetOrigin()
    local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
    local typeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
    local flags = DOTA_UNIT_TARGET_FLAG_NONE
    local targets = FindUnitsInRadius(teamID,pos,caster,zxc_radius,teamFilter,typeFilter,flags,FIND_CLOSEST,true)
    
    local debuff_name = "nevermore_necromastery_debuff"

    for _ , target in pairs(targets) do
        --print('target',target:GetUnitName(),damage)
        local add_damage = 0
        local mod = target:FindModifierByName(debuff_name)
        if mod ~= nil then
            add_damage = buff_damage * mod:GetStackCount()
        end
        local damage = zxc_damage + add_damage
        print('damage',damage)
        local data = {
            attacker = caster,
            victim = target,
            damage = damage,
            damage_type = ability:GetAbilityDamageType(),
            damage_flags = DOTA_UNIT_TARGET_FLAG_NONE,
            ability = ability,
        }
        ApplyDamage(data)

        if mod == nil then
            ability:ApplyDataDrivenModifier(owner, target, debuff_name, {})
            mod = target:FindModifierByName(debuff_name)
        end

        mod:SetStackCount(mod:GetStackCount() + 1)
    end

end

function phoenix_spirit_fly:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController( self )
		self:GetParent():RemoveVerticalMotionController( self )
		self:GetParent():SetForwardVector(self.dir)
        --InnerFire(self:GetParent())
        --particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf
        
        self:shadowraze()
        local origin = self:GetParent():GetAbsOrigin()
        origin.z = -100
        local caster = self:GetParent()
        self:GetParent():SetAbsOrigin(origin)
        print('origin',origin,self:GetParent():GetAbsOrigin())
        caster:SetContextThink("killself", function()
            caster:AddNoDraw()
            print('kill')
        end, 1)
        caster:ForceKill(true)
	end
end

function phoenix_spirit_fly:GetModifierDisableTurning()
	return true
end