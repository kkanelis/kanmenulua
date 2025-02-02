script_name("kanmenu")
script_version("0.6.6 Mafia Checker / 03.02.2025")

require "lib.moonloader"
local event = require "lib.samp.events"
local imgui = require "imgui"
local encoding = require "encoding"
local inicfg = require 'inicfg'
local weapons = require 'lib.game.weapons'
encoding.default = "CP1251"


-------------------------------------------------------------------------------------------------------------



function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((prefix..'tiek atjauninats '..thisScript().version..' uz '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Augsupieladets %d no %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Atjauninasanas lejupielade ir pabeigta.')
                      sampAddChatMessage((prefix..'Atjauninasana pabeigta!'), color)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'Atjauninasana failed. Tiek izmantota pedeja versija..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': Nav nepieciesams atjauninajums.')
            end
          end
        else
          print('v'..thisScript().version..': Es nevaru parbaudit, vai nav atjauninajumu. Pienemiet to vai parbaudiet pats '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end


-------------------------------------------------------------------------------------------------------------



local inicfg = require 'inicfg'
local cfg = inicfg.load({
  config = {
    ap = false,
    arp = false,
    drugs = false,
    hook = false,
    gang = false,
    abh = false,
    rvk = false,
    sbv = false,
    aex = false,
    garp = false,
    carp = false,
    mafia = false,

  }
}, 'kan.ini')

local checkgang = imgui.ImBool(cfg.config.gang)
local enable_sprinthook = imgui.ImBool(cfg.config.hook)
local enable_drugs = imgui.ImBool(cfg.config.drugs)
local autocapture2 = imgui.ImBool(cfg.config.arp)
local cbunnyhop = imgui.ImBool(cfg.config.abh)
local antirvanka = imgui.ImBool(cfg.config.rvk)
local sbiv = imgui.ImBool(cfg.config.sbv)
local antiexplosion = imgui.ImBool(cfg.config.aex)
local gunarp = imgui.ImBool(cfg.config.garp)
local cararp = imgui.ImBool(cfg.config.carp)
local checkmafia = imgui.ImBool(cfg.config.mafia)
local show_main_window = imgui.ImBool(false)


function save()
  inicfg.save(cfg, 'kan.ini')
end

-------------------------------------------------------------------------------------------------------------



function main()
  if not isSampfuncsLoaded() or not isSampLoaded() then return end
  while not isSampAvailable() do wait(100) end

  -- Reģistrē komandas
  sampRegisterChatCommand("ws", function() show_main_window.v = not show_main_window.v end)
  sampRegisterChatCommand("dg", SellGunCommand(24))
  sampRegisterChatCommand("m4", SellGunCommand(31))
  sampRegisterChatCommand("dgm", SellGunCommandMafia(24))
  sampRegisterChatCommand("m4m", SellGunCommandMafia(31))
  sampRegisterChatCommand("sm", function() sampSendChat("/setmaterials") end)
  sampRegisterChatCommand("sd", function() sampSendChat("/setdrugs") end)
  sampRegisterChatCommand("flood", function() toggleFlooder() end)
  sampRegisterChatCommand('color', handleColorCommand)

  local url = 'https://pastebin.com/raw/51q0xeRt'
  local request = require('requests').get(url)
  
  local playerId = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
  local nick = sampGetPlayerNickname(playerId)
  local function res()
    for n in request.text:gmatch('[^\r\n]+') do
        if nick == n then return true end
    end
  end

  if res() then
    print('v'..thisScript().version..': Ir pieejas')
  else
    print('v'..thisScript().version..': Haha jebnatij tev nav pieeja')
    thisScript():unload()
  end

  autoupdate("https://raw.githubusercontent.com/kkanelis/kanmenulua/refs/heads/main/version.json", '['..string.upper(thisScript().name)..']: ', "https://github.com/kkanelis/kanmenulua")

  while true do
    wait(0)
    imgui.Process = show_main_window.v

    if enable_drugs.v then drugs() end
    if enable_sprinthook.v then sprinthook() end
    if sbiv.v then sbivs() end
    if checkgang.v then gangVisuals() end
    if checkmafia.v then mafiaVisuals() end
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------



-- ANTI BUNNYHOP --

local lastweapon = 0
local currentWeapon = 0

function event.onSendPlayerSync(data)


-------------------------------------------------------------------------------------------------------------------------------------------



--- ANTI BUNNYHOP FAIL ---

    if cbunnyhop then
        if bit.band(data.keysData, 0x28) == 0x28 then
            data.keysData = bit.bxor(data.keysData, 0x20)
        end
    end


-------------------------------------------------------------------------------------------------------------------------------------------


--- Auto rp weapons ---


    currentWeapon = getCurrentCharWeapon(playerPed)

    if gunarp.v then
        if(lastweapon ~= currentWeapon) then
            if(currentWeapon == 0) then
                sampSendChat("/me nolika nost ieroci")
            elseif(currentWeapon == 23) then
                sampSendChat(string.format("/me ar veiklu roku kustibu nolika '%s' un ta vieta iznema Tazer ieroci", weapons.names[lastweapon]))    
            elseif(lastweapon == 0) then
                sampSendChat(string.format("/me panema %s", weapons.names[currentWeapon]))
            else	
                sampSendChat(string.format("/me ar veiklu roku kustibu nolika '%s' un ta vieta iznema '%s'", weapons.names[lastweapon], weapons.names[currentWeapon]))
            end
            lastweapon = currentWeapon
        end	
    end

-------------------------------------------------------------------------------------------------------------------------------------------

end


-------------------------------------------------------------------------------------------------------------------------------------------



-- Auto RP vehicle damage --

function event.onSendVehicleDamaged(vehicleId)
	local rslt, ger = sampGetCarHandleBySampVehicleId(vehicleId)

    if cararp.v then
        if rslt then
            curhp = getCarHealth(ger)
            last = lasthp - 60
            if(curhp < last) then
                sampSendChat("/do vaditajs un transportlidzeklis negadijuma cietis nedaudz, var turpinat celu.")
            end
            lasthp = curhp
        end	
    end
end	
		
function event.onSendEnterVehicle(vehicleId)
	res, nig = sampGetCarHandleBySampVehicleId(vehicleId)
	if res then
		lasthp = getCarHealth(nig)
	end	
end			
	


-------------------------------------------------------------------------------------------------------------------------------------------



-- Checkers --

function event.onPlayerJoin(playerId)
  updateGangCounts()
end

function event.onPlayerQuit(playerId)
  updateGangCounts()
end

function updateGangCounts()
  onlsg, ongsg, onbg, onvg, onrg, onvla = 0, 0, 0, 0, 0, 0
  onim, onmm, oncm, onlm = 0, 0, 0, 0
  
  reslt, mansid = sampGetPlayerIdByCharHandle(playerPed)
  if reslt then
      local playerColor = sampGetPlayerColor(mansid)
      if playerColor == 4294860800 then onlsg = onlsg + 1 end
      if playerColor == 0xC800D900 then ongsg = ongsg + 1 end
      if playerColor == 0xC8D900D3 then onbg = onbg + 1 end
      if playerColor == 0xC8FFC801 then onvg = onvg + 1 end
      if playerColor == 0xAA83BFBF then onrg = onrg + 1 end
      if playerColor == 0xC801FCFF then onvla = onvla + 1 end

      ---------------------------------------------------------
      --- mafia checker ---
      if playerColor == 0xFFFE00B4 then onim = onim + 1 end
      if playerColor == 0xFFAEF72F then onmm = onmm + 1 end
      if playerColor == 0xFF003300 then oncm = oncm + 1 end
      if playerColor == 0xFFAFAFAF then onlm = onlm + 1 end
  end

  for i = 0, 140 do
      if sampIsPlayerConnected(i) then
          local playerColor = sampGetPlayerColor(i)
          if playerColor == 4294860800 then onlsg = onlsg + 1 end
          if playerColor == 0xC800D900 then ongsg = ongsg + 1 end
          if playerColor == 0xC8D900D3 then onbg = onbg + 1 end
          if playerColor == 0xC8FFC801 then onvg = onvg + 1 end
          if playerColor == 0xAA83BFBF then onrg = onrg + 1 end
          if playerColor == 0xC801FCFF then onvla = onvla + 1 end
          
          ---------------------------------------------------------
          --- mafia checker ---
          if playerColor == 0xFFFE00B4 then onim = onim + 1 end
          if playerColor == 0xFFAEF72F then onmm = onmm + 1 end
          if playerColor == 0xFF003300 then oncm = oncm + 1 end
          if playerColor == 0xFFAFAFAF then onlm = onlm + 1 end
      end
  end
end


function gangVisuals()

  sampTextdrawCreate(301, "GSG:", 5.0, 360)
  sampTextdrawCreate(302, "BG:", 5.0, 370)
  sampTextdrawCreate(303, "VG:", 5.0, 380)
  sampTextdrawCreate(304, "RG:", 5.0, 390)
  sampTextdrawCreate(305, "VLA:", 5.0, 400)
  sampTextdrawCreate(306, "LSG:", 5.0, 410)
  
  sampTextdrawCreate(1301, "0", 20.0, 360)
  sampTextdrawCreate(1302, "0", 20.0, 370)
  sampTextdrawCreate(1303, "0", 20.0, 380)
  sampTextdrawCreate(1304, "0", 20.0, 390)
  sampTextdrawCreate(1305, "0", 20.0, 400)
  sampTextdrawCreate(1306, "0", 20.0, 410)

  for i = 301, 306 do
      sampTextdrawSetStyle(i, 1)
      sampTextdrawSetOutlineColor(i, 1, 0xFF000000) -- Black outline
  end

  for i = 1301, 1306 do
    sampTextdrawSetStyle(i, 1)
    sampTextdrawSetOutlineColor(i, 1, 0xFF000000) -- Black outline
  end



  
  sampTextdrawSetLetterSizeAndColor(301, 0.2, 0.9, 0xFF00FF00) -- GSG (Green)
  sampTextdrawSetLetterSizeAndColor(302, 0.2, 0.9, 0xFFFF00FF) -- BG (Pink)
  sampTextdrawSetLetterSizeAndColor(303, 0.2, 0.9, 0xFFFFFF00) -- VG (Yellow)
  sampTextdrawSetLetterSizeAndColor(304, 0.2, 0.9, 0xFF00CCCC) -- RG (Cyan)0xFF00CCCC
  sampTextdrawSetLetterSizeAndColor(305, 0.2, 0.9, 0xFF00FFFF) -- VLA (Blue)0xFF00FFFF
  sampTextdrawSetLetterSizeAndColor(306, 0.2, 0.9, 0xFFFF5D00) -- LSG (Orange)

  sampTextdrawSetLetterSizeAndColor(1301, 0.2, 0.9, 0xFF00FF00) -- GSG (Green)
  sampTextdrawSetLetterSizeAndColor(1302, 0.2, 0.9, 0xFFFF00FF) -- BG (Pink)
  sampTextdrawSetLetterSizeAndColor(1303, 0.2, 0.9, 0xFFFFFF00) -- VG (Yellow)
  sampTextdrawSetLetterSizeAndColor(1304, 0.2, 0.9, 0xFF00CCCC) -- RG (Cyan)0xFF00CCCC
  sampTextdrawSetLetterSizeAndColor(1305, 0.2, 0.9, 0xFF00FFFF) -- VLA (Blue)0xFF00FFFF
  sampTextdrawSetLetterSizeAndColor(1306, 0.2, 0.9, 0xFFFF5D00) -- LSG (Orange)





  if checkgang.v then

    sampTextdrawSetString(301, "GSG:")
    sampTextdrawSetString(302, "BG:")
    sampTextdrawSetString(303, "VG:")
    sampTextdrawSetString(304, "RG:")
    sampTextdrawSetString(305, "VLA:")
    sampTextdrawSetString(306, "LSG:")	

    sampTextdrawSetString(1301, ongsg)
    sampTextdrawSetString(1302, onbg)
    sampTextdrawSetString(1303, onvg)
    sampTextdrawSetString(1304, onrg)
    sampTextdrawSetString(1305, onvla)
    sampTextdrawSetString(1306, onlsg)

  else

    sampTextdrawDelete(301)
    sampTextdrawDelete(302)
    sampTextdrawDelete(303)
    sampTextdrawDelete(304)
    sampTextdrawDelete(305)
    sampTextdrawDelete(306)
    sampTextdrawDelete(1301)
    sampTextdrawDelete(1302)
    sampTextdrawDelete(1303)
    sampTextdrawDelete(1304)
    sampTextdrawDelete(1305)
    sampTextdrawDelete(1306)

  end
end


function mafiaVisuals()

  sampTextdrawCreate(201, "IM:", 5.0, 340)
  sampTextdrawCreate(202, "MM:", 5.0, 330)
  sampTextdrawCreate(203, "CM:", 5.0, 320)
  sampTextdrawCreate(204, "LM:", 5.0, 310)

  sampTextdrawCreate(1201, "0", 20.0, 340)
  sampTextdrawCreate(1202, "0", 20.0, 330)
  sampTextdrawCreate(1203, "0", 20.0, 320)
  sampTextdrawCreate(1204, "0", 20.0, 310)

  for i = 201, 204 do
    sampTextdrawSetStyle(i, 1)
    sampTextdrawSetOutlineColor(i, 1, 0xFF000000) -- Black outline
  end

  for i = 1201, 1204 do
    sampTextdrawSetStyle(i, 1)
    sampTextdrawSetOutlineColor(i, 1, 0xFF000000) -- Black outline
  end

  sampTextdrawSetLetterSizeAndColor(201, 0.2, 0.9, 0xFFFE00B4) -- IM  
  sampTextdrawSetLetterSizeAndColor(202, 0.2, 0.9, 0xFFaef72f) -- MM
  sampTextdrawSetLetterSizeAndColor(203, 0.2, 0.9, 0xFF003300) -- CM
  sampTextdrawSetLetterSizeAndColor(204, 0.2, 0.9, 0xFFAFAFAF) -- LM

  sampTextdrawSetLetterSizeAndColor(1201, 0.2, 0.9, 0xFFfe00b4) -- IM
  sampTextdrawSetLetterSizeAndColor(1202, 0.2, 0.9, 0xFFaef72f) -- MM  
  sampTextdrawSetLetterSizeAndColor(1203, 0.2, 0.9, 0xFF003300) -- CM
  sampTextdrawSetLetterSizeAndColor(1204, 0.2, 0.9, 0xFFAFAFAF) -- LM

  if checkmafia.v then

    sampTextdrawSetString(201, "IM:")
    sampTextdrawSetString(202, "MM:")
    sampTextdrawSetString(203, "CM:")
    sampTextdrawSetString(204, "LM:")

    sampTextdrawSetString(1201, onim)
    sampTextdrawSetString(1202, onmm)
    sampTextdrawSetString(1203, oncm)
    sampTextdrawSetString(1204, onlm)

  else 

    sampTextdrawDelete(201)
    sampTextdrawDelete(202)
    sampTextdrawDelete(203)
    sampTextdrawDelete(204)
    sampTextdrawDelete(1201)
    sampTextdrawDelete(1202)
    sampTextdrawDelete(1203)
    sampTextdrawDelete(1204)

  end

end

-------------------------------------------------------------------------------------------------------------------------------------------




-------------------------------------------------------------------------------------------------------------------------------------------



-- NARKOTIKAS -- 



function drugs()
  if not sampIsChatInputActive() and not sampIsDialogActive() and not sampIsScoreboardOpen() and not isSampfuncsConsoleActive() then
      if isKeyJustPressed(VK_X) then
        lua_thread.create(function()
          sampSendChat("/usedrugs 20")
          wait(350)
          clearCharTasksImmediately(PLAYER_PED)
      end)
    end
  end
end

function event.onSetPlayerDrunk(drunkLevel)
  return {1}
end



-------------------------------------------------------------------------------------------------------------------------------------------


--  --



-------------------------------------------------------------------------------------------------------------------------------------------



-- SELL GUN --




function SellGunCommand(weaponId)
  return function()
    local result, playerId = sampGetPlayerIdByCharHandle(playerPed)
    if result then
      sampSendChat(string.format("/sellgun %d %d 999 1", playerId, weaponId))
    end
  end
end

function SellGunCommandMafia(weaponId)
  return function()
    local result, playerId = sampGetPlayerIdByCharHandle(playerPed)
    if result then
      sampSendChat(string.format("/sellgun %d %d 250 1", playerId, weaponId))
    end
  end
end

-------------------------------------------------------------------------------------------------------------------------------------------



-- ANTI CAR EXPLOSION --

function acarExplosion()
    if antiexplosion and isCharInAnyCar(PLAYER_PED) then
      local veh = storeCarCharIsInNoSave(PLAYER_PED)
      if getCarHealth(veh) < hp then
          setCarHealth(veh, hp)
      end
  end
end

function event.onSendVehicleSync(data)
  if antiexplosion == true then 
      data.vehicleHealth = hp
      return data
  end
end



-------------------------------------------------------------------------------------------------------------------------------------------



-- ON MESSAGE --



function event.onServerMessage(color, text)

  -- AUTO RECAPTURE
  if autocapture2.v and text:find("WIN") then
    sampSendChat("/capture")
  end

  -- NARKOTIKAS NOTIFY ---

  if text:find("narkotikas izlietotas") then
    lua_thread.create(function()
      wait(30 * 1000)
      sampAddChatMessage("Vari lietot atkal narkotikas", 0x951d19)
    end)
  end

  -- STOP FLOODER -- 

  if geis == true then
    if text:find("saka uzbrukt bandas zonai") or text:find("Jusu zonai uzbruk") then
      geis = false
    end
  end

end




-------------------------------------------------------------------------------------------------------------------------------------------



-- SPRINT HOOK --



local bike = {
  [510] = true,
  [509] = true,
  [481] = true,
}

local moto = {
  [586] = true,
  [581] = true,
  [523] = true,
  [522] = true,
  [521] = true,
  [471] = true,
  [468] = true,
  [463] = true,
  [462] = true,
  [461] = true,
  [448] = true,
}

function sprinthook()
  if isCharOnAnyBike(playerPed) and isKeyDown(0xA0) then
      if bike[vehicleModel] then
        setGameKeyState(16, 255)
        wait(5)
        setGameKeyState(16, 0)
      elseif moto[vehicleModel] then
        setGameKeyState(1, -128)
        wait(5)
        setGameKeyState(1, 0)
      end
  end
    if isCharOnFoot(playerPed) and isKeyDown(32) then
      setGameKeyState(16, 256)
      wait(10)
      setGameKeyState(16, 0)
    elseif isCharInWater(playerPed) and isKeyDown(32) then 
      setGameKeyState(16, 256)
      wait(10)
      setGameKeyState(16, 0)
  end
end



-------------------------------------------------------------------------------------------------------------------------------------------



-- SBIVS --

function sbivs()
  if not sampIsCursorActive() then
    if wasKeyPressed(VK_R) then
      if isCharOnFoot(PLAYER_PED) then 
        clearCharTasksImmediately(PLAYER_PED)
      end 
    end
  end
end



-------------------------------------------------------------------------------------------------------------------------------------------



-- Flooder --


function toggleFlooder()
  if not geis then
      geis = true
      lua_thread.create(function()
          while geis do
              sampSendChat("/capture")
              wait(10)
          end
      end)
  else
      geis = false
  end
end




-------------------------------------------------------------------------------------------------------------------------------------------



-- ANTI RVANKA --

function event.onPlayerSync(id, data)
	if antirvanka then
		local x, y, z = getCharCoordinates(PLAYER_PED)
		if x - data.position.x > -1.5 and x - data.position.x < 1.5 then
			if (data.moveSpeed.x >= 1.5 or data.moveSpeed.x <= -1.5) or (data.moveSpeed.y >= 1.5 or data.moveSpeed.y <= -1.5) or (data.moveSpeed.z >= 0.5 or data.moveSpeed.z <= -0.5) then
				data.moveSpeed.x, data.moveSpeed.y, data.moveSpeed.z = 0, 0, 0
			end
		end
	end
	return {id, data}
end

function event.onVehicleSync(id, vehid, data)
	if antirvanka then
		local x, y, z = getCharCoordinates(PLAYER_PED)
		if x - data.position.x > -1.5 and x - data.position.x < 1.5 then
			if (data.moveSpeed.x >= 1.5 or data.moveSpeed.x <= -1.5) or (data.moveSpeed.y >= 1.5 or data.moveSpeed.y <= -1.5) or (data.moveSpeed.z >= 0.5 or data.moveSpeed.z <= -0.5) then
				data.moveSpeed.x, data.moveSpeed.y, data.moveSpeed.z = 0, 0, 0
				data.position.x = data.position.x - 5
			end
		end
	end
	return {id, vehid, data}
end



-------------------------------------------------------------------------------------------------------------------------------------------


-- Clear Chat --



function ClearChat() 
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
  sampAddChatMessage('', 0xFFFFFF)
end


-------------------------------------------------------------------------------------------------------------------------------------------



-- MENU UI --



function imgui.TextQuestion(text)
  imgui.SameLine()
  imgui.TextDisabled('(?)')
  if imgui.IsItemHovered() then
      imgui.BeginTooltip()
      imgui.PushTextWrapPos(450)
      imgui.TextUnformatted(text)
      imgui.PopTextWrapPos()
      imgui.EndTooltip()
  end
end


function imgui.OnDrawFrame()
  if show_main_window.v then
    local style = imgui.GetStyle()

    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    style.WindowRounding = 2
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 8
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0
    style.WindowPadding = imgui.ImVec2(4.0, 4.0)
    style.FramePadding = imgui.ImVec2(3.5, 3.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

    colors[clr.WindowBg]              = ImVec4(0.14, 0.12, 0.16, 1.00);
    colors[clr.ChildWindowBg]         = ImVec4(0.30, 0.20, 0.39, 0.00);
    colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90);
    colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30);
    colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[clr.FrameBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68);
    colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45);
    colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35);
    colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57);
    colors[clr.ScrollbarBg]           = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31);
    colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00);
    colors[clr.SliderGrab]            = ImVec4(0.41, 0.19, 0.63, 0.24);
    colors[clr.SliderGrabActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44);
    colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
    colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00);
    colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76);
    colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
    colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20);
    colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75);
    colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59);
    colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00);
    colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63);
    colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63);
    colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43);
    colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35);

    local sw, sh = getScreenResolution()

    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), 0, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(600, 360), 0)

    imgui.Begin('kan.lua', show_main_window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)



    -----------------------------------------------------------------------------------------------------------------
    
    

    imgui.NewLine() 
    
    imgui.BeginChild("koks", imgui.ImVec2(194, 300), true)
    imgui.Text("Prieks capture")

    if imgui.CollapsingHeader('Capture') then

      if imgui.Button("Flooder (/capture)", imgui.ImVec2(194 * 0.6, 150 * 0.15)) then 
        toggleFlooder()
      end imgui.TextQuestion("Floodos tev 0ms /capture")

      if imgui.Checkbox("Auto ReCapture", autocapture2) then
        cfg.config.arp = autocapture2.v
        save()
      end imgui.TextQuestion("Darbosies uz lai parspamotu kamer kada cita karo")
      imgui.Separator()

    end

    if imgui.Checkbox("Use Drugs (X)", enable_drugs) then
      cfg.config.drugs = enable_drugs.v
      save()
    end imgui.TextQuestion("Izmanto 20 drugs")

    if imgui.Checkbox("Sprint Hook", enable_sprinthook) then 
      cfg.config.hook = enable_sprinthook.v
      save()
    end imgui.TextQuestion("Turi tikai 'SPACE' prieks skriesanas un riteniem/mociem 'SHIFT'")

    imgui.Separator()
    imgui.Text("Checkers")

    if imgui.Checkbox("Gang Checker", checkgang) then 
      cfg.config.gang = checkgang.v

      if not checkgang.v then
        gangVisuals()
      end

      save()
    end imgui.TextQuestion("Parada citu bandu speletaju skaitu")

    if imgui.Checkbox("Mafia Checker", checkmafia) then 
      cfg.config.mafia = checkmafia.v

      if not checkmafia.v then
        mafiaVisuals()
      end

      save()
    end imgui.TextQuestion("Parada citu mafiju speletaju skaitu")

    imgui.EndChild()



    -----------------------------------------------------------------------------------------------------------------
    


    imgui.SameLine()

    imgui.BeginChild("koks2", imgui.ImVec2(194, 300), true)
    imgui.Text("Roleplay atveigosanai")
    if imgui.Button('Gang RP', imgui.ImVec2(194 * 0.3, 150 * 0.15)) then 
      lua_thread.create(function()
          sampSendChat("/do Skatos uz bandanu ar labo aci, tās raksts piesaista manu uzmanību")
          wait(2000)
          sampSendChat("/me uzmanigi panemu bandanu ar labo roku")
          wait(2000)
          sampSendChat("/do Bandana ir silta, un es to turu stingri sava roka")
          wait(2000)
          sampSendChat("/me iztiru mazos puteklus no bandanas, kas ir uz tas virsmas")
          wait(2000)
          sampSendChat("/do Ar otru roku es uzmanigi turu bandanu pie mutes, lai pievienotu to vel labak")
          wait(2000)
          sampSendChat("/me novers uzmanibu no apkartnes un ar abu roku pirkstiem piespiezu mezglu bandanai")
          wait(2000)
          sampSendChat("/do Mezgls klust stingrs, bandana tagad ciesi un drosi tureta ap kaklu")
          wait(2000)
          sampSendChat("/me paskatoties uz rezultatu, piekritu, ka bandana izskatas perfekti uz manam pleciem")
      end)
    end
    imgui.TextQuestion("Noerpo tev bandanas pacelsanu/uzvliksanu")

    if imgui.Checkbox("Ierocu Auto RP", gunarp) then
        cfg.config.garp = gunarp.v
        save()
    end imgui.TextQuestion("Bus tev autorp kad mainis ierocus")

    if imgui.Checkbox("Automasinas Auto RP", cararp) then
        cfg.config.carp = cararp.v
        save()
    end imgui.TextQuestion("Noerpos ja ietrieksies kaut kur siena automatiski")
    imgui.Separator()


    imgui.Text("ANTI Lietinas")

    if imgui.Checkbox("Anti BunnyHop", cbunnyhop) then
      cfg.config.abh = cbunnyhop.v
      save()
    end imgui.TextQuestion("Vari skriet lekt, nebus jaatlaiz 'SPACE'")

    if imgui.Checkbox("Anti Rvanka", antirvanka) then
      cfg.config.rvk = antirvanka.v
      save()
    end imgui.TextQuestion("Hakeris neaizlidinas tevi projam uz galaktiku citu")

    if imgui.Checkbox("Anti Explosion", antiexplosion) then
      cfg.config.aex = antiexplosion.v
      save()
    end imgui.TextQuestion("Masina tev nezusprags.")

    imgui.EndChild()


    -----------------------------------------------------------------------------------------------------------------


    -----------------------------------------------------------------------------------------------------------------
  



    -----------------------------------------------------------------------------------------------------------------
    imgui.SameLine()

    imgui.BeginChild("koks3", imgui.ImVec2(194, 300), true)

    if imgui.CollapsingHeader('Commands') then
        imgui.Text("/dg - deagles 500 lodes")
        imgui.Text("/m4 - m4 500 lodes")
        imgui.Text("/dgm - deagles 250 lodes")
        imgui.Text("/m4m - m4 250 lodes")
        imgui.Text("/sm - isak sakot /setmaterials")
        imgui.Text("/sd - isak sakot /setdrugs")
        imgui.Text("/flood - floodos /capture")
    end

    imgui.Separator()

    imgui.Text("Misc")

    if imgui.Button("Clear Chat", imgui.ImVec2(194 * 0.4, 150 * 0.15)) then
        ClearChat()
    end

    if imgui.Checkbox("Sbiv", sbiv) then
      cfg.config.sbv = sbiv.v
      save()
    end imgui.TextQuestion("Uzspied R un animacija tev kruta bus")

    imgui.EndChild()

    imgui.End()
  end
end