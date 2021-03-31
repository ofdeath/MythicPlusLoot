if not(GetLocale() == "koKR") then
  return
end
local AddonName, MPL = ...;
local L = MPL.L or {}
--
-- Armor type
L["Cloth"] = "천"
L["Leather"] = "가죽"
L["Mail"] = "사슬"
L["Plate"] = "판금"

-- Armor slot
L["Head"] = "머리"
L["Neck"] = "목"
L["Shoulder"] = "어깨"
L["Back"] = "등"
L["Chest"] = "가슴"
L["Wrist"] = "손목"
L["Hands"] = "손"
L["Waist"] = "허리"
L["Legs"] = "다리"
L["Feet"] = "발"
L["Finger"] = "손가락"
L["Trinket"] = "장신구"
L["One-Hand"] = "한손 장비"
L["Off-Hand"] = "보조 장비"
L["Two-Hand"] = "양손 장비"
L["Ranged"] = "원거리 장비"
L["Favorites"] = "즐겨찾기"

-- Source list
L["Dungeon Drop"] = "던전 드랍"
L["Weekly Vault"] = "금고 보상"

-- Dungeons
L["Plaguefall"] = "역병 몰락지 (Plaguefall)"
L["De Other Side"] = "저편 (De Other Side)"
L["Halls of Atonement"] = "속죄의 전당 (Halls of Atonement)"
L["Mists of Tirna Scithe"] = "티르너 사이드의 안개 (Mists of Tirna Scithe)"
L["Sanguine Depths"] = "핏빛 심연 (Sanguine Depths)"
L["Spires of Ascension"] = "승천의 첨탑 (Spires of Ascension)"
L["The Necrotic Wake"] = "죽음의 상흔 (The Necrotic Wake)"
L["Theater of Pain"] = "고통의 투기장 (Theater of Pain)"

-- General
L["Item Slot"] = "아이템 슬롯"
L["Mythic Level"] = "신화 단계"
L["Source"] = "소스"
L["Armor Type"] = "방어구 타입"

-- Other
L["The profile %s doesn't exist"] = "%s의 프로파일 없음"
