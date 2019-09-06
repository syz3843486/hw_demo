techies_suicide1_modifier = class({})

local MOVE_JUMP_SPEED = 500
local MOVE_SPEED = 1200
-- W
function techies_suicide1_modifier:GetBehavior()
	if not IsServer() then return end

end

function techies_suicide1_modifier:OnCreated(kv)
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
	local curPos = self:GetParent():GetAbsOrigin()
	self.curPos = curPos
	self.targetpos = self:GetAbility():GetCursorPosition()
	print('self.targetpos',self.targetpos)
	self.dir = (self.targetpos - curPos )
	self.distance = #self.dir
	self.dir = self.dir:Normalized()
	print('curPos ',curPos , 'targetPos', self.targetpos)
	self.upTime = self.distance / MOVE_SPEED * 0.5
	self.downTime = self.upTime
	self.downSpeed = ((self.upTime*MOVE_JUMP_SPEED)+curPos.z - self.targetpos.z)/self.downTime
	print('upTime',self.upTime,'downTime',self.downTime,'downSpeed',self.downSpeed)
	--self:GetParent():SetForwardVector(self.dir)
	print('----')
end


function techies_suicide1_modifier:UpdateHorizontalMotion( me, dt )
	if IsServer() then
		if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
			self:Destroy()
			return
		end
		local vOldPos = self:GetParent():GetOrigin()
		local moveDis = MOVE_SPEED * dt
		self.distance = self.distance - moveDis
		if self.distance <= 0 then
			me:SetAbsOrigin(self.targetpos)
			self:Destroy()
			return 
		end
		local pos = vOldPos + self.dir * MOVE_SPEED * dt
		me:SetOrigin(pos)
	end
end

function techies_suicide1_modifier:UpdateVerticalMotion( me, dt )
	if IsServer() then
		if self:ApplyHorizontalMotionController() == false or self:ApplyVerticalMotionController() == false then 
			self:Destroy()
			return
		end
		self.upTime = self.upTime - dt
		local pos = self:GetParent():GetAbsOrigin()
		if self.upTime > 0 then
			pos.z = pos.z + MOVE_JUMP_SPEED*dt
		else
			pos.z = pos.z - self.downSpeed*dt
		end
		me:SetAbsOrigin(pos)
	end
end


function techies_suicide1_modifier:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController( self )
		self:GetParent():RemoveVerticalMotionController( self )
		self:GetParent():SetForwardVector(self.dir)
		InnerFire(self:GetParent())
		local ability = self:GetAbility()
		local radius = ability:GetSpecialValueFor("radius")
		local damage = ability:GetSpecialValueFor("damage")
		local hp_cost = ability:GetSpecialValueFor("hp_cost")

		local caster = self:GetParent()
		local hp = caster:GetHealth()
		print('hp - hp_cost',hp - hp_cost)
		caster:SetHealth(hp - hp_cost)

		local teamID = caster:GetTeamNumber()
		local pos = caster:GetOrigin()
		local teamFilter = DOTA_UNIT_TARGET_TEAM_ENEMY
		local typeFilter = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
		local flags = DOTA_UNIT_TARGET_FLAG_NONE
		local targets = FindUnitsInRadius(teamID,pos,caster,radius,teamFilter,typeFilter,flags,FIND_CLOSEST,true)
    
		for _ , target in pairs(targets) do
			--print('target',target:GetUnitName(),damage)
			local data = {
				attacker = caster,
				victim = target,
				damage = damage,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_UNIT_TARGET_FLAG_NONE,
				ability = ability,
			}
			ApplyDamage(data)
		end
		FireTree(caster,pos,radius)
	end
end

function techies_suicide1_modifier:GetModifierDisableTurning()
	return true
end