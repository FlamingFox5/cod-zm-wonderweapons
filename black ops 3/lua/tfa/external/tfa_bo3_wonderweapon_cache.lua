local nzombies = engine.ActiveGamemode() == "nzombies"
local pvp_cvar = GetConVar("sbox_playershurtplayers")
local SinglePlayer = game.SinglePlayer()

//-------------------------------------------------------------
// TFA Muzzleflash Base
//-------------------------------------------------------------

if SERVER then
	AddCSLuaFile("tfa/bo3_muzzleflash_base.lua")
end

//-------------------------------------------------------------
// TFA Ammo Types
//-------------------------------------------------------------

TFA.AddAmmo("SpecialistCharge", "Specialist Ammo")

//-------------------------------------------------------------
// Model Caching
//-------------------------------------------------------------

// Projectiles
util.PrecacheModel("models/weapons/tfa_bo3/scavenger/scavenger_projectile.mdl")
util.PrecacheModel("models/weapons/tfa_bo3/keepersword/keepersword_projectile.mdl")

// Throwables
util.PrecacheModel("models/weapons/tfa_bo3/gstrike/gstrike_prop.mdl")
util.PrecacheModel("models/weapons/tfa_bo3/monkeybomb/monkeybomb_prop.mdl")
util.PrecacheModel("models/weapons/tfa_bo3/octobomb/octobomb_arnie.mdl")
util.PrecacheModel("models/weapons/tfa_bo3/matryoshka/matryoshka_prop.mdl")
util.PrecacheModel("models/weapons/tfa_bo3/qed/w_qed.mdl")
util.PrecacheModel("models/weapons/tfa_bo3/gersch/w_gersch.mdl")

// Misc
util.PrecacheModel("models/weapons/tfa_bo3/grenade/grenade_prop.mdl")
util.PrecacheModel("models/weapons/tfa_bo3/dg4/dg4_prop.mdl")
util.PrecacheModel("models/weapons/tfa_bo3/qed/w_haymaker.mdl")
util.PrecacheModel("models/weapons/tfa_bo3/qed/w_kn44.mdl")
util.PrecacheModel("models/weapons/tfa_bo3/qed/w_maxgl.mdl")

//-------------------------------------------------------------
// Global Tables
//-------------------------------------------------------------

local WonderWeapons = TFA.WonderWeapon

// Enable entities to pass the ShouldUseRobustRadiusDamage() function in the projectile explosion code
// allowing for the explosion to 'spill over' corners and hit entities just barely out of LOS

WonderWeapons.RobustableEntity = WonderWeapons.RobustableEntity or {}
WonderWeapons.RobustableEntity["func_button"] = true
WonderWeapons.RobustableEntity["func_breakable"] = true
WonderWeapons.RobustableEntity["func_door"] = false
WonderWeapons.RobustableEntity["func_door_rotating"] = false
WonderWeapons.RobustableEntity["prop_door_rotating"] = false

// sick and tired of having to copy paste this table for doors everywhere

WonderWeapons.DoorClasses = WonderWeapons.DoorClasses or {}
WonderWeapons.DoorClasses["func_door"] = true
WonderWeapons.DoorClasses["func_door_rotating"] = true
WonderWeapons.DoorClasses["prop_door_rotating"] = true

// Used by the custom GetHeadAttachment, GetChestAttachment, & GetMouthAttachment functions for declaring model specific attachment points
// includes ['chest'], ['head'], ['mouth'], ['eyes'], ['reye'], ['leye'], ['rhand'], ['lhand']

WonderWeapons.ModelAttachmentPoints = WonderWeapons.ModelAttachmentPoints or {}
WonderWeapons.ModelAttachmentPoints["models/gunship.mdl"] = { ["chest"] = 4, ["head"] = 4 }
WonderWeapons.ModelAttachmentPoints["models/Combine_Strider.mdl"] = { ["chest"] = 14, ["head"] = 14 }
WonderWeapons.ModelAttachmentPoints["models/combine_dropship.mdl"] = { ["chest"] = 5, ["head"] = 5 }
WonderWeapons.ModelAttachmentPoints["models/scientist.mdl"] = { ["chest"] = 2, ["head"] = 1 }
WonderWeapons.ModelAttachmentPoints["models/hgrunt.mdl"] = { ["head"] = 2 }
WonderWeapons.ModelAttachmentPoints["models/garg.mdl"] = { ["rhand"] = 2, ["lhand"] = 3, ["head"] = 1 }

// Stops sound from playing entirely when affected by JGB shrink effect

WonderWeapons.NoShrinkSound = WonderWeapons.NoShrinkSound or {}

WonderWeapons.NoShrinkSound["npc/metropolice/die1.wav"] = true
WonderWeapons.NoShrinkSound["npc/metropolice/die2.wav"] = true
WonderWeapons.NoShrinkSound["npc/metropolice/die3.wav"] = true
WonderWeapons.NoShrinkSound["npc/metropolice/die4.wav"] = true

WonderWeapons.NoShrinkSound["npc/overwatch/radiovoice/die1.wav"] = true
WonderWeapons.NoShrinkSound["npc/overwatch/radiovoice/die2.wav"] = true
WonderWeapons.NoShrinkSound["npc/overwatch/radiovoice/die3.wav"] = true

// Stops pitch modification to sounds emit by entities affected by JGB shrink effect

WonderWeapons.NoShrinkSoundMod = WonderWeapons.NoShrinkSoundMod or {}

WonderWeapons.NoShrinkSoundMod["TFA_BO3_JGB.ZMB.Squish"] = true
WonderWeapons.NoShrinkSoundMod["TFA_BO3_JGB.ZMB.Kick"] = true
WonderWeapons.NoShrinkSoundMod["TFA_BO3_JGB.ZMB.Shrink"] = true
WonderWeapons.NoShrinkSoundMod["TFA_BO3_JGB.ZMB.UnShrink"] = true

WonderWeapons.NoShrinkSoundMod["npc/antlion/rumble1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/antlion/shell_impact1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/antlion/shell_impact2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/antlion/shell_impact3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/antlion/shell_impact4.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/antlion_grub/squashed.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/antlion_guard/shove1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/antlion_guard/foot_heavy1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/antlion_guard/foot_heavy2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/antlion_guard/foot_light1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/antlion_guard/foot_light2.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/attack_helicopter/aheli_charge_up.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/attack_helicopter/aheli_damaged_alarm1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/attack_helicopter/aheli_megabomb_siren1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/attack_helicopter/aheli_mine_drop1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/attack_helicopter/aheli_mine_seek_loop1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/attack_helicopter/aheli_wash_loop3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/attack_helicopter/aheli_weapon_fire_loop3.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/barnacle/barnacle_crunch2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/barnacle/barnacle_crunch3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/barnacle/barnacle_digesting1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/barnacle/barnacle_digesting2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/barnacle/neck_snap1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/barnacle/neck_snap2.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/combine_gunship/attack_start2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/combine_gunship/attack_stop2.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/combine_gunship/engine_rotor_loop1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/combine_gunship/gunship_crashing1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/combine_gunship/gunship_engine_loop3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/combine_gunship/gunship_explode2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/combine_gunship/gunship_fire_loop1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/combine_gunship/gunship_ping_search.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/combine_gunship/gunship_weapon_fire_loop6.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/combine_soldier/gear1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/combine_soldier/gear2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/combine_soldier/gear3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/combine_soldier/gear4.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/combine_soldier/gear5.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/combine_soldier/gear6.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/crow/flap2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/crow/hop1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/crow/hop2.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/dog/dog_footstep1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_footstep2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_footstep3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_footstep4.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_footstep_run1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_footstep_run2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_footstep_run3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_footstep_run4.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_footstep_run5.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_footstep_run6.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_footstep_run7.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_footstep_run8.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_idlemode_loop1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_pneumatic1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_pneumatic2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_rollover_servos1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_servo1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_servo10.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_servo12.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_servo2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_servo3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_servo5.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_servo6.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_servo7.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_servo8.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_straining1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_straining2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/dog/dog_straining3.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/fast_zombie/claw_miss1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/fast_zombie/claw_miss2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/fast_zombie/claw_strike1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/fast_zombie/claw_strike2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/fast_zombie/claw_strike3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/fast_zombie/foot1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/fast_zombie/foot2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/fast_zombie/foot3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/fast_zombie/foot4.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/footsteps/hardboot_generic1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/footsteps/hardboot_generic2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/footsteps/hardboot_generic3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/footsteps/hardboot_generic4.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/footsteps/hardboot_generic5.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/footsteps/hardboot_generic6.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/footsteps/hardboot_generic8.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/footsteps/softshoe_generic6.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/headcrab/headbite.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/headcrab/headcrab_burning_loop2.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/headcrab_poison/ph_jump1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/headcrab_poison/ph_jump2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/headcrab_poison/ph_step1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/headcrab_poison/ph_step2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/headcrab_poison/ph_step3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/headcrab_poison/ph_step4.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/headcrab_poison/ph_wallhit1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/headcrab_poison/ph_wallhit2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/ichthyosaur/snap_miss.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/manhack/bat_away.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/manhack/gib.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/manhack/grind1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/manhack/grind2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/manhack/grind3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/manhack/grind4.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/manhack/grind5.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/manhack/grind_flesh1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/manhack/grind_flesh2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/manhack/grind_flesh3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/manhack/mh_blade_loop1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/manhack/mh_blade_snick1.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/metropolice/die1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/metropolice/die2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/metropolice/die3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/metropolice/die4.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/metropolice/gear1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/metropolice/gear2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/metropolice/gear3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/metropolice/gear4.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/metropolice/gear5.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/metropolice/gear6.wav"] = true
	
WonderWeapons.NoShrinkSoundMod["npc/overwatch/radiovoice/404zone.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/overwatch/radiovoice/accomplicesoperating.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/overwatch/radiovoice/die1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/overwatch/radiovoice/die2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/overwatch/radiovoice/die3.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/roller/blade_cut.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/roller/mine/combine_mine_deploy1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/roller/mine/rmine_explode_shock1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/roller/mine/rmine_blip1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/roller/mine/rmine_blip3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/roller/mine/rmine_chirp_answer1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/roller/mine/rmine_blip1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/roller/mine/rmine_blip3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/roller/mine/rmine_movefast_loop1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/roller/mine/rmine_moveslow_loop1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/roller/mine/rmine_shockvehicle1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/roller/mine/rmine_shockvehicle2.wav"] = true
	
WonderWeapons.NoShrinkSoundMod["npc/scanner/cbot_discharge1.wav"] = true
	
WonderWeapons.NoShrinkSoundMod["npc/scanner/cbot_fly_loop.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/scanner/cbot_servochatter.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/scanner/cbot_energyexplosion1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/scanner/scanner_electric1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/scanner/scanner_electric2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/scanner/scanner_explode_crash2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/scanner/scanner_nearmiss1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/scanner/scanner_nearmiss2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/scanner/scanner_pain1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/scanner/scanner_pain2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/scanner/scanner_photo1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/scanner/scanner_siren1.wav"] = true
	
WonderWeapons.NoShrinkSoundMod["npc/sniper/echo1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/sniper/reload1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/sniper/sniper1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/stalker/laser_burn.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/stalker/laser_flesh.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/stalker/stalker_footstep_left1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/stalker/stalker_footstep_left2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/stalker/stalker_footstep_right1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/stalker/stalker_footstep_right2.wav"] = true
	
WonderWeapons.NoShrinkSoundMod["npc/strider/charging.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/strider/fire.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/strider/strider_minigun.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/strider/strider_minigun2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/strider/strider_skewer1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/strider/strider_step1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/strider/strider_step2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/strider/strider_step3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/strider/strider_step4.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/strider/strider_step5.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/strider/strider_step6.wav"] = true
	
WonderWeapons.NoShrinkSoundMod["npc/turret_floor/active.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/turret_floor/click1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/turret_floor/deploy.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/turret_floor/die.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/turret_floor/ping.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/turret_floor/retract.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/turret_floor/shoot1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/turret_floor/shoot2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/turret_floor/shoot3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/turret_wall/turret_loop1.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/vort/attack_charge.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/vort/attack_shoot.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/vort/claw_swing1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/vort/claw_swing2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/vort/foot_hit.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/vort/health_charge.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/vort/vort_foot1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/vort/vort_foot2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/vort/vort_foot3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/vort/vort_foot4.wav"] = true
	
WonderWeapons.NoShrinkSoundMod["npc/waste_scanner/grenade_fire.wav"] = true
	
WonderWeapons.NoShrinkSoundMod["npc/zombie/claw_miss1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/zombie/claw_miss2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/zombie/claw_strike1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/zombie/claw_strike2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/zombie/claw_strike3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/zombie/foot1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/zombie/foot2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/zombie/foot3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/zombie/foot_slide1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/zombie/foot_slide2.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/zombie/foot_slide3.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/zombie/zombie_hit.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/zombie/zombie_pound_door.wav"] = true

WonderWeapons.NoShrinkSoundMod["npc/zombie_poison/pz_left_foot1.wav"] = true
WonderWeapons.NoShrinkSoundMod["npc/zombie_poison/pz_right_foot1.wav"] = true

// Blood effects helper tables

WonderWeapons.ExplosionByBloodColor = WonderWeapons.ExplosionByBloodColor or {}
WonderWeapons.ExplosionByBloodColor[BLOOD_COLOR_GREEN] = "bo3_annihilator_blood_zomb"
WonderWeapons.ExplosionByBloodColor[BLOOD_COLOR_ZOMBIE] = "bo3_annihilator_blood_zomb"
WonderWeapons.ExplosionByBloodColor[BLOOD_COLOR_YELLOW] = "bo3_annihilator_blood_yellow"
WonderWeapons.ExplosionByBloodColor[BLOOD_COLOR_ANTLION] = "bo3_annihilator_blood_yellow"
WonderWeapons.ExplosionByBloodColor[BLOOD_COLOR_RED] = "bo3_annihilator_blood"

WonderWeapons.ExplosionByBloodColor[WonderWeapons.BLOOD_RED] = "bo3_annihilator_blood"
WonderWeapons.ExplosionByBloodColor[WonderWeapons.BLOOD_ZOMBIE] = "bo3_annihilator_blood_zomb"
WonderWeapons.ExplosionByBloodColor[WonderWeapons.BLOOD_ALIEN] = "bo3_annihilator_blood_yellow"
WonderWeapons.ExplosionByBloodColor[WonderWeapons.BLOOD_ACID] = "bo3_annihilator_blood_yellow"
WonderWeapons.ExplosionByBloodColor[WonderWeapons.BLOOD_CYBORG] = "bo3_annihilator_blood"
WonderWeapons.ExplosionByBloodColor[WonderWeapons.BLOOD_SYNTH] = "bo3_annihilator_blood"

WonderWeapons.ParticleByBloodColor = WonderWeapons.ParticleByBloodColor or {}
WonderWeapons.ParticleByBloodColor[BLOOD_COLOR_RED] = "blood_impact_red_01"
WonderWeapons.ParticleByBloodColor[BLOOD_COLOR_YELLOW] = "blood_impact_yellow_01"
WonderWeapons.ParticleByBloodColor[BLOOD_COLOR_GREEN] = "blood_impact_green_01"
WonderWeapons.ParticleByBloodColor[BLOOD_COLOR_ZOMBIE] = "blood_impact_zombie_01"
WonderWeapons.ParticleByBloodColor[BLOOD_COLOR_ANTLION] = "blood_impact_antlion_01"
WonderWeapons.ParticleByBloodColor[BLOOD_COLOR_ANTLION_WORKER] = "blood_impact_antlion_worker_01"

WonderWeapons.ParticleByBloodColor[WonderWeapons.BLOOD_RED] = "blood_impact_red_01"
WonderWeapons.ParticleByBloodColor[WonderWeapons.BLOOD_ZOMBIE] = "blood_impact_zombie_01"
WonderWeapons.ParticleByBloodColor[WonderWeapons.BLOOD_ALIEN] = "blood_impact_yellow_01"
WonderWeapons.ParticleByBloodColor[WonderWeapons.BLOOD_ACID] = "blood_impact_antlion_worker_01"
WonderWeapons.ParticleByBloodColor[WonderWeapons.BLOOD_CYBORG] = "blood_impact_synth_01"
WonderWeapons.ParticleByBloodColor[WonderWeapons.BLOOD_SYNTH] = "blood_impact_synth_01"

WonderWeapons.DecalByBloodColor = WonderWeapons.DecalByBloodColor or {}
WonderWeapons.DecalByBloodColor[BLOOD_COLOR_RED] = "Blood"
WonderWeapons.DecalByBloodColor[BLOOD_COLOR_YELLOW] = "YellowBlood"
WonderWeapons.DecalByBloodColor[BLOOD_COLOR_GREEN] = "YellowBlood"
WonderWeapons.DecalByBloodColor[BLOOD_COLOR_ZOMBIE] = "YellowBlood"
WonderWeapons.DecalByBloodColor[BLOOD_COLOR_ANTLION] = "YellowBlood"
WonderWeapons.DecalByBloodColor[BLOOD_COLOR_ANTLION_WORKER] = "YellowBlood"

WonderWeapons.DecalByBloodColor[WonderWeapons.BLOOD_RED] = "Blood"
WonderWeapons.DecalByBloodColor[WonderWeapons.BLOOD_ZOMBIE] = "YellowBlood"
WonderWeapons.DecalByBloodColor[WonderWeapons.BLOOD_ALIEN] = "YellowBlood"
WonderWeapons.DecalByBloodColor[WonderWeapons.BLOOD_ACID] = "YellowBlood"
WonderWeapons.DecalByBloodColor[WonderWeapons.BLOOD_SYNTH] = "BirdPoop"
WonderWeapons.DecalByBloodColor[WonderWeapons.BLOOD_MECH] = "BeerSplash"

// Campaign related

if SERVER then
	WonderWeapons.ClassifyDamageIgnore = WonderWeapons.ClassifyDamageIgnore or {}
	WonderWeapons.ClassifyDamageIgnore[CLASS_HACKED_ROLLERMINE] = true
	WonderWeapons.ClassifyDamageIgnore[CLASS_BULLSEYE] = true
end

// this is overkill
WonderWeapons.BoltImpactSoundSurfaceMats = {
	["carpet"] = {"weapons/tfa_bo3/impacts/canvas_00.wav"},
	["ceiling_tile"] = {"weapons/tfa_bo3/impacts/canvas_00.wav"},
	["paper"] = {"weapons/tfa_bo3/impacts/canvas_00.wav"},
	["papercup"] = {"weapons/tfa_bo3/impacts/canvas_00.wav"},
	["cardboard"] = {"weapons/tfa_bo3/impacts/canvas_00.wav"},
	["plastic"] = {"weapons/tfa_bo3/impacts/canvas_00.wav"},

	["dirt"] = {"weapons/tfa_bo3/impacts/dirt_00.wav"},
	["grass"] = {"weapons/tfa_bo3/impacts/dirt_00.wav"},
	["gravel"] = {"weapons/tfa_bo3/impacts/dirt_00.wav"},

	["jeeptire"] = {"weapons/tfa_bo3/impacts/flesh_02.wav", "weapons/tfa_bo3/impacts/flesh_03.wav"},
	["rubbertire"] = {"weapons/tfa_bo3/impacts/flesh_02.wav", "weapons/tfa_bo3/impacts/flesh_03.wav"},
	["rubber"] = {"weapons/tfa_bo3/impacts/flesh_02.wav", "weapons/tfa_bo3/impacts/flesh_03.wav"},
	["plastic_barel"] = {"weapons/tfa_bo3/impacts/flesh_02.wav", "weapons/tfa_bo3/impacts/flesh_03.wav"},
	["plastic_barrel_buoyant"] = {"weapons/tfa_bo3/impacts/flesh_02.wav", "weapons/tfa_bo3/impacts/flesh_03.wav"},
	["plastic_box"] = {"weapons/tfa_bo3/impacts/flesh_02.wav", "weapons/tfa_bo3/impacts/flesh_03.wav"},
	["watermelon"] = {"weapons/tfa_bo3/impacts/flesh_02.wav", "weapons/tfa_bo3/impacts/flesh_03.wav"},
	["flesh"] = {"weapons/tfa_bo3/impacts/flesh_02.wav", "weapons/tfa_bo3/impacts/flesh_03.wav"},
	["bloodyflesh"] = {"weapons/tfa_bo3/impacts/flesh_02.wav", "weapons/tfa_bo3/impacts/flesh_03.wav"},
	["alienflesh"] = {"weapons/tfa_bo3/impacts/flesh_02.wav", "weapons/tfa_bo3/impacts/flesh_03.wav"},

	["foliage"] = {"weapons/tfa_bo3/impacts/foliage_00.wav"},

	["glass"] = {"weapons/tfa_bo3/impacts/glass_00.wav"},
	["glassbottle"] = {"weapons/tfa_bo3/impacts/glass_00.wav"},
	["computer"] = {"weapons/tfa_bo3/impacts/glass_00.wav"},
	["porcelain"] = {"weapons/tfa_bo3/impacts/glass_00.wav"},

	["ice"] = {"weapons/tfa_bo3/impacts/ice_00.wav"},

	["armorflesh"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["weapon"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["solidmetal"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["slipperymetal"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["roller"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["popcan"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["paintcan"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["metalvent"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["metalpanel"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["metalgrate"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["metal_box"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["metal_bouncy"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["floating_metal_barrel"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["metal_barrel"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["metal"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["chainlink"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["chain"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["canister"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["item"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	["ladder"] = {"weapons/tfa_bo3/impacts/metal_00.wav"},

	["mud"] = {"weapons/tfa_bo3/impacts/mud_01.wav"},
	["quicksand"] = {"weapons/tfa_bo3/impacts/mud_01.wav"},
	["slime"] = {"weapons/tfa_bo3/impacts/mud_01.wav"},
	["slipperyslime"] = {"weapons/tfa_bo3/impacts/mud_01.wav"},

	["tile"] = {"weapons/tfa_bo3/impacts/rock_00.wav"},
	["pottery"] = {"weapons/tfa_bo3/impacts/rock_00.wav"},
	["rock"] = {"weapons/tfa_bo3/impacts/rock_00.wav"},
	["concrete_block"] = {"weapons/tfa_bo3/impacts/rock_00.wav"},
	["concrete"] = {"weapons/tfa_bo3/impacts/rock_00.wav"},
	["brick"] = {"weapons/tfa_bo3/impacts/rock_00.wav"},
	["boulder"] = {"weapons/tfa_bo3/impacts/rock_00.wav"},

	["sand"] = {"weapons/tfa_bo3/impacts/sand_03.wav"},

	["snow"] = {"weapons/tfa_bo3/impacts/snow_01.wav"},

	["wade"] = {"weapons/tfa_bo3/impacts/water_00.wav"},
	["water"] = {"weapons/tfa_bo3/impacts/water_00.wav"},

	["plaster"] = {"weapons/tfa_bo3/impacts/wood_01.wav"},
	["wood_solid"] = {"weapons/tfa_bo3/impacts/wood_01.wav"},
	["wood_panel"] = {"weapons/tfa_bo3/impacts/wood_01.wav"},
	["wood_plank"] = {"weapons/tfa_bo3/impacts/wood_01.wav"},
	["wood_lowdensity"] = {"weapons/tfa_bo3/impacts/wood_01.wav"},
	["wood_furniture"] = {"weapons/tfa_bo3/impacts/wood_01.wav"},
	["wood_create"] = {"weapons/tfa_bo3/impacts/wood_01.wav"},
	["wood_box"] = {"weapons/tfa_bo3/impacts/wood_01.wav"},
	["wood"] = {"weapons/tfa_bo3/impacts/wood_01.wav"},
	["woodladder"] = {"weapons/tfa_bo3/impacts/wood_01.wav"},

	["default"] = {"common/NULL.wav"},
	["default_silent"] = {"common/NULL.wav"},
}

// simpler version
WonderWeapons.BoltImpactSoundMaterials = {
	[MAT_PLASTIC] = {"weapons/tfa_bo3/impacts/canvas_00.wav"},
	[MAT_EGGSHELL] = {"weapons/tfa_bo3/impacts/canvas_00.wav"},
	[MAT_DIRT] = {"weapons/tfa_bo3/impacts/dirt_00.wav"},
	[MAT_ALIENFLESH] = {"weapons/tfa_bo3/impacts/flesh_02.wav", "weapons/tfa_bo3/impacts/flesh_03.wav"},
	[MAT_FLESH] = {"weapons/tfa_bo3/impacts/flesh_02.wav", "weapons/tfa_bo3/impacts/flesh_03.wav"},
	[MAT_BLOODYFLESH] = {"weapons/tfa_bo3/impacts/flesh_02.wav", "weapons/tfa_bo3/impacts/flesh_03.wav"},
	[MAT_FOLIAGE] = {"weapons/tfa_bo3/impacts/foliage_00.wav"},
	[MAT_GRASS] = {"weapons/tfa_bo3/impacts/foliage_00.wav"},
	[MAT_GLASS] = {"weapons/tfa_bo3/impacts/glass_00.wav"},
	[MAT_GRATE] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	[MAT_METAL] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	[MAT_COMPUTER] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	[MAT_VENT] = {"weapons/tfa_bo3/impacts/metal_00.wav"},
	[MAT_ANTLION] = {"weapons/tfa_bo3/impacts/rock_00.wav"},
	[MAT_CONCRETE] = {"weapons/tfa_bo3/impacts/rock_00.wav"},
	[MAT_TILE] = {"weapons/tfa_bo3/impacts/rock_00.wav"},
	[MAT_SAND] = {"weapons/tfa_bo3/impacts/sand_03.wav"},
	[MAT_SNOW] = {"weapons/tfa_bo3/impacts/snow_01.wav"},
	[MAT_SLOSH] = {"weapons/tfa_bo3/impacts/water_00.wav"},
	[MAT_WOOD] = {"weapons/tfa_bo3/impacts/wood_01.wav"},
	[MAT_DEFAULT] = {"common/NULL.wav"},
}

WonderWeapons.PressureSuitDefaults = {}

// Workshop
WonderWeapons.PressureSuitDefaults["models/johnfuckingward.mdl"] = { [1] = 0.5, [2] = 0, [3] = 0.94, [4] = 1.02, [5] = 1.02, [6] = 1.02, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/fatherfuckengarcia.mdl"] = { [1] = 0.5, [2] = 0, [3] = 0.94, [4] = 1.02, [5] = 1.02, [6] = 1.02, [7] = 0, [8] = 0, [9] = 0 }

WonderWeapons.PressureSuitDefaults["models/n7legion/fortnite/hybrid_player_alt.mdl"] = { [1] = -0.3, [2] = 0, [3] = 0, [4] = 1.1, [5] = 1.1, [6] = 1.1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/n7legion/fortnite/hybrid_player.mdl"] = { [1] = -0.3, [2] = 0, [3] = 0, [4] = 1.1, [5] = 1.1, [6] = 1.1, [7] = 0, [8] = 0, [9] = 0 }

WonderWeapons.PressureSuitDefaults["models/pacagma/mizuki_ninja/mizuki/mizuki_player.mdl"] = { [1] = -2.5, [2] = 0, [3] = 0.57, [4] = 1.1, [5] = 1.1, [6] = 1.1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/pacagma/kaiden/kaiden_player.mdl"] = { [1] = -1.5, [2] = 0, [3] = 2, [4] = 1.1, [5] = 1.1, [6] = 1.1, [7] = 0, [8] = 0, [9] = 0 }

WonderWeapons.PressureSuitDefaults["models/player/deltarune/tasque_manager/tasque_Manager_toastador_pm.mdl"] = { [1] = -1, [2] = 0, [3] = 1, [4] = 1.1, [5] = 1.1, [6] = 1.1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/fortnite/fennix/fennix_pm.mdl"] = { [1] = -0.3, [2] = 0, [3] = 0, [4] = 1.09, [5] = 1.09, [6] = 1.09, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/dewobedil/mike_myers/default_p.mdl"] = { [1] = -0.5, [2] = 0, [3] = 0, [4] = 1 , [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }

WonderWeapons.PressureSuitDefaults["models/silly_willy/goob/puro_pm.mdl"] = { [1] = -1.9, [2] = 0, [3] = 0.2, [4] = 1.5, [5] = 1.5, [6] = 1.5, [7] = 21, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/keepitwilde/raventl/raventl_pm.mdl"] = { [1] = -1.3, [2] = 0, [3] = -2.5, [4] = 0.82, [5] = 0.82, [6] = 0.82, [7] = 0, [8] = 0, [9] = 0 }

WonderWeapons.PressureSuitDefaults["models/losos/pseudoregalia/sybil/sybil.mdl"] = { [1] = -0.2, [2] = 0, [3] = 1, [4] = 1.1, [5] = 1.1, [6] = 1.1, [7] = 0, [8] = 0, [9] = 0 }

WonderWeapons.PressureSuitDefaults["models/payton/payton_codkitty.mdl"] = { [1] = -1.5, [2] = 0, [3] = 1, [4] = 1.05, [5] = 1.05, [6] = 1.05, [7] = 0, [8] = 0, [9] = 0 }

WonderWeapons.PressureSuitDefaults["models/captainbigbutt/vocaloid/fall_miku.mdl"] = { [1] = -2.1, [2] = 0, [3] = 0, [4] = 0.95, [5] = 0.95, [6] = 0.95, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/captainbigbutt/vocaloid/green_miku.mdl"] = { [1] = -2.1, [2] = 0, [3] = 0, [4] = 0.95, [5] = 0.95, [6] = 0.95, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/captainbigbutt/vocaloid/miku_sacura.mdl"] = { [1] = -2.1, [2] = 0, [3] = 0, [4] = 0.95, [5] = 0.95, [6] = 0.95, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/captainbigbutt/vocaloid/summer_miku.mdl"] = { [1] = -2.1, [2] = 0, [3] = 0, [4] = 0.95, [5] = 0.95, [6] = 0.95, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/captainbigbutt/vocaloid/winter_miku.mdl"] = { [1] = -2.1, [2] = 0, [3] = 0, [4] = 0.95, [5] = 0.95, [6] = 0.95, [7] = 0, [8] = 0, [9] = 0 }

// Default
WonderWeapons.PressureSuitDefaults["models/player/arctic.mdl"] = { [1] = -1, [2] = 0, [3] = 1, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/guerilla.mdl"] = { [1] = -1, [2] = 0, [3] = 1, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/leet.mdl"] = { [1] = -0.200, [2] = 0, [3] = 1.5, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/phoenix.mdl"] = { [1] = 0, [2] = 0, [3] = 1.5, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/gasmask.mdl"] = { [1] = -0.4, [2] = 0, [3] = 1.5, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/riot.mdl"] = { [1] = -0.7, [2] = 0, [3] = 1, [4] = 1.05, [5] = 1.05, [6] = 1.05, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/swat.mdl"] = { [1] = -0.5, [2] = 0, [3] = 1, [4] = 1.05, [5] = 1.05, [6] = 1.05, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/urban.mdl"] = { [1] = -0.5, [2] = 0, [3] = 1.2, [4] = 1.05, [5] = 1.05, [6] = 1.05, [7] = 0, [8] = 0, [9] = 0 }

WonderWeapons.PressureSuitDefaults["models/player/hostage/hostage_01.mdl"] = { [1] = 0.5, [2] = 0, [3] = 0, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/hostage/hostage_02.mdl"] = { [1] = 0.5, [2] = 0, [3] = 0, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/hostage/hostage_03.mdl"] = { [1] = 0.5, [2] = 0, [3] = 0, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/hostage/hostage_04.mdl"] = { [1] = 0.5, [2] = 0, [3] = 0, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }

WonderWeapons.PressureSuitDefaults["models/player/dod_american.mdl"] = { [1] = -0.5, [2] = 0, [3] = 0, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/dod_german.mdl"] = { [1] = -0.5, [2] = 0, [3] = 0, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }

WonderWeapons.PressureSuitDefaults["models/player/gman_high.mdl"] = { [1] = 0, [2] = 0, [3] = 0.6, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/police.mdl"] = { [1] = 0.5, [2] = 0, [3] = 0.5, [4] = 1.05, [5] = 1.05, [6] = 1.05, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/police_fem.mdl"] = { [1] = 0, [2] = 0, [3] = -1, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }
WonderWeapons.PressureSuitDefaults["models/player/zombie_soldier.mdl"] = { [1] = 0, [2] = 0, [3] = 1, [4] = 1, [5] = 1, [6] = 1, [7] = 0, [8] = 0, [9] = 0 }
