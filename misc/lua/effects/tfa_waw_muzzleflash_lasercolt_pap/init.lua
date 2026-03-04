include("tfa/bo3_muzzleflash_base.lua")

EFFECT.Life = 0.1
EFFECT.FlashSize = 300
EFFECT.FlashDecay = 4000
EFFECT.FlashLife = 0.2
EFFECT.FlashBrightness = 1
EFFECT.Color = Color(20, 20, 255, 255)
EFFECT.MuzzleEffect = "waw_lasercolt_muzzleflash_2"

EFFECT.UseCustomMuzzleColor = true
EFFECT.ColorControlPoint = 2

EFFECT.UsePlayerColor = true //overwrites dlight color and the muzzleflash color (if EFFECT.UseCustomMuzzleColor is true)
