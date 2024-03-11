local bit 						= require 'bit'
require 'moonloader'
local inicfg					= require 'inicfg'
local vkeys						= require 'vkeys'
local ffi 						= require 'ffi'

script_author('Kohtop')
script_version('1.1v beta')
local version = '1.1v beta'
script_name('AdminTools for ARZ-Rugne')

local encoding     = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local hotkey = require('mimgui_hotkeys')

local inicfg = require 'inicfg'
local directIni = 'AdminTools\\config.ini'
local loading_sec = 11

local cradio = true
local cradio1 = false

local ini = inicfg.load(inicfg.load({
    main = {
        aboxs = false,
        pboxs = false,
        pins = false,
        apanel = '',
        pincode = '',
        password = '',
        autob = true,
        bunny = false,
        wallhack = false,
        aforma = false,
        airbrake = false,
        admcheck = false,
        autorep = false,
        astats = false,
    },
    punish = {
        report = 0,
        warn = 0,
        mute = 0,
        kick = 0,
        ban = 0,
        jail = 0,
        number = 0,
        reputation = 0,
        form = 0,
    },
    hotkey = {
        airbrake = '[]',
        autoreport = '[]',
        admintools = '[45]',
        wallhack = '[]',
        wallhackCar = '[]',
        globalCursor = '[]',
        formaTrue = '[]',
        formaFalse = '[]',
        hotkey_tp_menu = '[]',
    },
    stats = {
        OnDayOnline = 0,
        full = 0,
    },
    mimgui = {
        posY = 500,
        posX = 500,
    },
    auth = {
        login = '',
        password = '',
        auth = false,
        prefix = '',
    }
}, directIni))
inicfg.save(ini, directIni)

local hotkey_amenu
local hotkey_forma
local hotkey_forma1
local hotkey_tp_menu

local encodingcheck, encoding	= pcall(require, 'encoding')
local imguicheck, imgui			= pcall(require, 'mimgui')
local monetluacheck, monetlua 	= pcall(require, 'MoonMonet')
local lfscheck, lfs 			= pcall(require, 'lfs')
local sampevcheck, sampev		= pcall(require, 'lib.samp.events')
local print, clock, sin, cos, floor, ceil, abs, format, gsub, gmatch, find, char, len, upper, lower, sub, u8, new, str, sizeof = print, os.clock, math.sin, math.cos, math.floor, math.ceil, math.abs, string.format, string.gsub, string.gmatch, string.find, string.char, string.len, string.upper, string.lower, string.sub, encoding.UTF8, imgui.new, ffi.string, ffi.sizeof

local faicons = require('fAwesome6')
local tag = '{ffbb00}[AdminTools]: {FFFFFF}'

local code, stats, login = new.bool(), new.bool(ini.main.astats), new.bool()
local dayFull = new.int(ini.stats.full)

local sessionOnline = new.int(0)
local sessionAfk = new.int(0)
local sessionFull = new.int(0)
local notf_sX, notf_sY				= convertGameScreenCoordsToWindowScreenCoords(605, 438)
local notify						= {
	msg = {},
	pos = {x = notf_sX - 500, y = notf_sY - 70}
}
notf_sX, notf_sY = nil, nil

local menuItem = 0

local color = {
    imgui.ImVec4(0.8, 1, 0.3, 1),
    imgui.ImVec4(0.23, 0.45, 1, 1),
    }

local menuButtons = {
    {name=u8('Статистика'), icon=faicons('HOUSE'), i = 0},
    {name=u8('Настройки'), icon=faicons('GEAR'), i = 1},
    {name=u8('Админ ПО'), icon=faicons('CODE'), i = 2},
    {name=u8('Режим Слежки'), icon=faicons('BINOCULARS'), i = 3},
    {name=u8('Проверка ботов'), icon=faicons('ROBOT'), i = 8},
    {name=u8('Мониторинг'), icon=faicons('DESKTOP'), i = 4},
    {name=u8('Формы'), icon=faicons('TAG'), i = 6},
    {name=u8('Биндер'), icon=faicons('PAPERCLIP'), i = 7}
    
}

local enable_autoupdate = true
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Загружено %d из %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Загрузка обновления завершена.')sampAddChatMessage(b..'Обновление завершено!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Обновление прошло неудачно. Запускаю устаревшую версию..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Обновление не требуется.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Смиритесь или проверьте самостоятельно на '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/KOHTOP/RugneTools/main/update.json?" .. tostring(os.clock())
            Update.prefix = tag
            Update.url = "https://github.com/KOHTOP/RugneTools"
        end
    end
end

local abox = new.bool(ini.main.aboxs)
local pbox = new.bool(ini.main.pboxs)
local pin = new.bool(ini.main.pins)
local autob = new.bool(ini.main.autob)
local bunnys = new.bool(ini.main.bunny)
local air = new.bool(ini.main.airbrake)
local aforma = new.bool(ini.main.airbrake)
local wallhack = new.bool(ini.main.wallhack)
local admcheck = new.bool(ini.main.admcheck)
local autorep = new.bool(ini.main.autorep)
local astats = new.bool(ini.main.astats)

local apanel = new.char[256](u8(ini.main.apanel))
local pincode = new.char[256](u8(ini.main.pincode))
local password = new.char[256](u8(ini.main.password))
local ilogin = new.char[256](u8(ini.auth.login))
local ipass = new.char[256](u8(ini.auth.password))
local prefix = new.char[256](u8(ini.auth.prefix))

local AI_PAGE = {}
local AI_TOGGLE = {}

local hotkey = require 'mimgui_hotkeys'

function get_clock(time)
    local timezone_offset = 97200 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date('%H:%M:%S', time + timezone_offset)
end

function main()
    while not isSampAvailable() do wait(0) end
        addNotify(format('Успешный запуск!'), 3)
        sampAddChatMessage(tag .. 'Успешный запуск! Для активации скрипта напишите /amenu или нажмите на кнопку, которая установлена в настройках!', -1)
        sampRegisterChatCommand('amenu', function ()
            
            code[0] = not code[0]
        end)
        if autoupdate_loaded and enable_autoupdate and Update then
            pcall(Update.check, Update.json_url, Update.prefix, Update.url)
        end
        hotkey_amenu = hotkey.RegisterHotKey('###HotKey1', false, decodeJson(ini.hotkey.admintools), function() code[0] = not code[0] end) 
        hotkey_forma = hotkey.RegisterHotKey('###HotKey2', false, decodeJson(ini.hotkey.formaTrue), function ()
            if forma and nak then
                sampSendChat('/' .. command .. ' '..fid..' '..ftime..' '..freason)
                forma = false
                nak = false
                ini.punish.form = ini.punish.form + 1
            elseif forma and not nak then
                sampSendChat('/' .. command .. ' '..fid..' '..freason)
                forma = false
                ini.punish.form = ini.punish.form + 1
            end
        end) 
        hotkey_forma1 = hotkey.RegisterHotKey('###HotKey3', false, decodeJson(ini.hotkey.formaFalse), function ()
            if forma then
                sampSendChat('/a [Forma] Отклонил форму от ' .. admnick)
                forma = false
            end
        end) 
        hotkey_tp_menu = hotkey.RegisterHotKey('###HotKey4', false, decodeJson(ini.hotkey.hotkey_tp_menu), function() sampAddChatMessage(tag .. 'Временно недоступно!', -1) end) 
        
        
        zahod = get_clock(os.time())
        sampRegisterChatCommand('test', function (arg)
            ini.punish.warn = arg
            sampAddChatMessage(ini.punish.number, -1)
            inicfg.save(ini, 'AdminTools\\config.ini')
        end)
        sampRegisterChatCommand('test1', function (arg)
            ini.punish.report = arg
            sampAddChatMessage(ini.punish.report, -1)
            inicfg.save(ini, 'AdminTools\\config.ini')
        end)
        sampRegisterChatCommand('test2', function (arg)
            ini.punish.reputation = arg
            sampAddChatMessage(ini.punish.reputation, -1)
            inicfg.save(ini, 'AdminTools\\config.ini')
        end)




    while true do
        wait(0)
        ini.punish.number = ini.punish.warn + ini.punish.mute + ini.punish.ban + ini.punish.kick + ini.punish.jail
        inicfg.save(ini, 'AdminTools\\config.ini')


        if ini.auth.auth then
            loading_sec = loading_sec - 1
            wait(1000)
        end

    end
end


local imgui_notify = imgui.OnFrame(
	function() return true end,
	function(player)
		player.HideCursor = true
		for k = 1, #notify.msg do
			if notify.msg[k] and notify.msg[k].active then
				local i = -1
				for d in gmatch(notify.msg[k].text, '[^\n]+') do
					i = i + 1
				end
				if notify.pos.y - i * 21 > 0 then
					if notify.msg[k].justshowed == nil then
						notify.msg[k].justshowed = clock() - 0.05
					end
					if ceil(notify.msg[k].justshowed + notify.msg[k].time - clock()) <= 0 then
						notify.msg[k].active = false
					end
					imgui.SetNextWindowPos(imgui.ImVec2(notify.pos.x, notify.pos.y - i * 21))
					imgui.SetNextWindowSize(imgui.ImVec2(250, 60 + i * 21))
					if clock() - notify.msg[k].justshowed < 0.3 then
						imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate((clock() - notify.msg[k].justshowed) * 3.34))
					else
						imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, ImSaturate((notify.msg[k].justshowed + notify.msg[k].time - clock()) * 3.34))
					end
					imgui.PushStyleVarFloat(imgui.StyleVar.WindowBorderSize, 0)
					imgui.Begin(u8('Notify ##'..k), _, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoScrollbar)
						local style = imgui.GetStyle()
						local pos = imgui.GetCursorScreenPos()
						local DrawList = imgui.GetWindowDrawList()
						DrawList:PathClear()
	
						local num_segments = 80
						local step = 6.28 / num_segments
						local max = 6.28 * (1 - ((clock() - notify.msg[k].justshowed) / notify.msg[k].time))
						local centre = imgui.ImVec2(pos.x + 15, pos.y + 15 + style.FramePadding.y)
	
						for i = 0, max, step do
							DrawList:PathLineTo(imgui.ImVec2(centre.x + 15 * cos(i), centre.y + 15 * sin(i)))
						end
						DrawList:PathStroke(imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.TitleBgActive]), false, 5)
	
                        imgui.SetCursorPos(imgui.ImVec2(23 - imgui.CalcTextSize(u8(abs(ceil(notify.msg[k].time - (clock() - notify.msg[k].justshowed))))).x * 0.5, 19))
						imgui.Text(tostring(abs(ceil(notify.msg[k].time - (clock() - notify.msg[k].justshowed)))))
	
						imgui.PushFont(font)
						imgui.SetCursorPos(imgui.ImVec2(105, 10))
						imgui.TextColoredRGB('AdminTools')
						imgui.PopFont()

						imgui.SetCursorPosX(60)
                        
						imgui.BeginGroup()
							imgui.CenterText(notify.msg[k].text)
						imgui.EndGroup()
					imgui.End()
					imgui.PopStyleVar(2)
					notify.pos.y = notify.pos.y - 70 - i * 21
				else
					if k == 1 then
						table.remove(notify.msg, k)
					end
				end
			else
				table.remove(notify.msg, k)
			end
		end
		local notf_sX, notf_sY = convertGameScreenCoordsToWindowScreenCoords(605, 438)
		notify.pos = {x = notf_sX - 200, y = notf_sY - 70}
	end
)

function imgui.Menu()
    for i=1, #menuButtons do
        if imgui.PageButton(menuItem == menuButtons[i].i, menuButtons[i].icon, menuButtons[i].name) then
            menuItem = menuButtons[i].i
        end
    end
end

imgui.OnFrame(function() return code[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(898, 485), imgui.Cond.Always)
    imgui.Begin('AdminTools', code, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar)
    imgui.SetCursorPosX(0)
    
    imgui.PushFont(font) -- перед бегином
    if imgui.BeginChild('', imgui.ImVec2(200, 471), false) then
        imgui.Menu()
        imgui.SetCursorPosY(450)
        imgui.CenterText('Версия 1.1 beta')
    end
    imgui.EndChild()
    imgui.SameLine()
    if imgui.BeginChild('1', imgui.ImVec2(685, 471), false) then
        if menuItem == 0 then
            imgui.PushFont(zagol)
            imgui.CenterText('Статистика')
            imgui.PopFont()
            imgui.SetCursorPosY(70)
            imgui.SetCursorPosX(30)
            imgui.BeginChild('Stata', imgui.ImVec2(270, 100), true)
            
            imgui.PushFont(reportf)
            
            imgui.Text(ini.punish.report .. u8' ответов \nна репорт')
            imgui.PopFont()
            imgui.PushFont(ricon)
            imgui.SetCursorPosY(40)
            imgui.SetCursorPosX(190)
            imgui.Text((faicons('MESSAGE')))
            imgui.PopFont()
            imgui.EndChild()
            imgui.SameLine(400)
            imgui.BeginChild('punish', imgui.ImVec2(270, 100), true)
            
            imgui.PushFont(reportf)
            
            imgui.Text(ini.punish.number .. u8' выдано\nнаказаний')
            imgui.PopFont()
            imgui.PushFont(ricon)
            imgui.SetCursorPosY(40)
            imgui.SetCursorPosX(190)
            imgui.Text((faicons('MONITOR_WAVEFORM')))
            imgui.PopFont()
            imgui.EndChild()
            imgui.SetCursorPosX(30)
            imgui.SetCursorPosY(210)
            imgui.BeginChild('Chas', imgui.ImVec2(270, 100), true)
            
            imgui.PushFont(reportf)
            
            imgui.Text(u8'0 часов \nотыграно')
            imgui.PopFont()
            imgui.PushFont(ricon)
            imgui.SetCursorPosY(40)
            imgui.SetCursorPosX(190)
            imgui.Text((faicons('CLOCK')))
            imgui.PopFont()
            imgui.EndChild()
            imgui.SameLine(400)
            imgui.BeginChild('reputation', imgui.ImVec2(270, 100), true)
            
            imgui.PushFont(reportf)
            
            imgui.Text(ini.punish.reputation .. u8' получено\nрепутации')
            imgui.PopFont()
            imgui.PushFont(ricon)
            imgui.SetCursorPosY(40)
            imgui.SetCursorPosX(190)
            imgui.Text((faicons('PLUS')))
            imgui.PopFont()
            imgui.EndChild()
            imgui.SetCursorPosX(30)
            imgui.SetCursorPosY(330)
            imgui.BeginChild('log_punish', imgui.ImVec2(640, 120), true)
            
            imgui.PushFont(reportf)
            
            imgui.CenterText('Лог общих действий')
            imgui.PopFont()
            imgui.Text(u8'[ LOG | Auth ]: Вход ' .. zahod .. u8' [Успешный]')
            imgui.Text(u8'[ LOG | Forma ]: Принята форма от администратора Admin_Tools (/mute 0 1 Test | KOHTOP)')
            imgui.Text(u8'[ LOG | Sing ]: Успешный вход в аккаунт')
            imgui.Text(u8'[ LOG | Exit ]: Выход с игры (отыграно 1д. 13ч. 17м. 18с.)')
            imgui.Text(u8'[ LOG | Forma ]: Принята форма от администратора Admin_Tools (/mute 0 1 Test | KOHTOP)')
            imgui.Text(u8'[ LOG | Info ]: Успешная установка 1.1v beta!')
            imgui.Text(u8'[ LOG | Auth ]: Успешная активация скрипта по коду автора!')
            imgui.EndChild()
            
        elseif menuItem == 1 then
            imgui.CenterText('Основные настройки')
        
            imgui.PushFont(zagol)
            imgui.Text(u8'Автоматический ввод:')
            imgui.PopFont()
            imgui.SetCursorPosX(10)
            imgui.SetCursorPosY(55)
            if imgui.ToggleButton('', pin) then
                ini.main.pins = pin[0] -- меняем значение конфига на значение чекбокса
                inicfg.save(ini, 'AdminTools\\config.ini') -- сохраняем в конфиге
            end
            imgui.SameLine()
            imgui.PushItemWidth(120)
            imgui.SetCursorPosX(58)
            imgui.SetCursorPosY(84)
            if imgui.InputText(u8"Пароль /apanel", apanel, 256, imgui.InputTextFlags.Password) then
                ini.main.apanel = u8:decode(ffi.string(apanel)) -- значение вписывается в конфиг
                inicfg.save(ini, 'AdminTools\\config.ini') -- конфиг сохраняется
            end
            imgui.SetCursorPosX(10)
            imgui.SetCursorPosY(85)
            if imgui.ToggleButton(' ', abox) then
                ini.main.aboxs = abox[0] -- меняем значение конфига на значение чекбокса
                inicfg.save(ini, 'AdminTools\\config.ini') -- сохраняем в конфиге
            end
            imgui.SameLine()
            imgui.PushItemWidth(120)
            imgui.SetCursorPosX(58)
            imgui.SetCursorPosY(114)
            if imgui.InputText(u8"Пароль от аккаунта", password, 256, imgui.InputTextFlags.Password) then
                ini.main.password = u8:decode(ffi.string(password)) -- значение вписывается в конфиг
                inicfg.save(ini, 'AdminTools\\config.ini') -- конфиг сохраняется
            end
            imgui.SetCursorPosX(10)
            imgui.SetCursorPosY(115)
            if imgui.ToggleButton('  ', pbox) then
                ini.main.pboxs = pbox[0] -- меняем значение конфига на значение чекбокса
                inicfg.save(ini, 'AdminTools\\config.ini') -- сохраняем в конфиге
            end
            
            imgui.SameLine()
            imgui.PushItemWidth(120)
            imgui.SetCursorPosX(58)
            imgui.SetCursorPosY(54)
            if imgui.InputText(u8"PIN-код (банк)", pincode, 256, imgui.InputTextFlags.Password) then
                ini.main.pincode = u8:decode(ffi.string(pincode)) -- значение вписывается в конфиг
                inicfg.save(ini, 'AdminTools\\config.ini') -- конфиг сохраняется
            end
            imgui.SetCursorPosY(134)
            imgui.PushFont(zagol)
            imgui.Text(u8'Полезные функции:')
            imgui.PopFont()
            if imgui.BeginChild('2', imgui.ImVec2(320, 280), false) then
                imgui.SetCursorPosX(10)
                if imgui.ToggleButton('Auto /b', autob) then
                    ini.main.autob = autob[0]
                    inicfg.save(ini, 'AdminTools\\config.ini')
                end

                imgui.SetCursorPosX(10)
                if imgui.ToggleButton('AutoForma', aforma) then
                    ini.main.aforma = aforma[0]
                    inicfg.save(ini, 'AdminTools\\config.ini')
                end
                imgui.SetCursorPosX(10)
                --[[
                if imgui.ToggleButton('AirBrake', air) then
                    ini.main.airbrake = air[0]
                    inicfg.save(ini, 'AdminTools\\config.ini')
                end
                imgui.SetCursorPosX(10)
                if imgui.ToggleButton('WallHack [Временно недоступно]', wallhack) then
                    ini.main.wallhack = wallhack[0]
                    inicfg.save(ini, 'AdminTools\\config.ini')
                end
                imgui.SetCursorPosX(10)
                                imgui.SetCursorPosX(10)
                if imgui.ToggleButton('BunnyHop', bunnys) then
                    ini.main.bunny = bunnys[0]
                    inicfg.save(ini, 'AdminTools\\config.ini')
                end
                ]]

                if imgui.ToggleButton('AdminChecker', admcheck) then
                    ini.main.admcheck = admcheck[0]
                    inicfg.save(ini, 'AdminTools\\config.ini')
                end
                imgui.SetCursorPosX(10)
                if imgui.ToggleButton('AutoReport', autorep) then
                    ini.main.autorep = autorep[0]
                    inicfg.save(ini, 'AdminTools\\config.ini')
                end
                imgui.SetCursorPosX(10)
                if imgui.ToggleButton('Статистика', astats) then
                    ini.main.astats = astats[0]
                    inicfg.save(ini, 'AdminTools\\config.ini')
                    stats[0] = not stats[0]
                end
                
                --[[
                for k, v in ipairs(color) do
                    if imgui.ColoredRadioButtonBool('###color1', false or true, v) then
                        cradio = true
                    end
                end
                ]]
            end
            imgui.EndChild()
            imgui.SetCursorPosX(280)
            imgui.SetCursorPosY(20)
            if imgui.BeginChild('###Hotkeys', imgui.ImVec2(390, 450), false) then
                imgui.PushFont(zagol)
                imgui.CenterText('Горячие клавиши')
                imgui.PopFont()
                imgui.SetCursorPosX(65)
                imgui.SetCursorPosY(50)
                if hotkey_amenu:ShowHotKey(imgui.ImVec2(170, 25)) then -- создаем условие, которое будет срабатывать при обновлении бинда пользователем
                    ini.hotkey.admintools = encodeJson(hotkey_amenu:GetHotKey()) -- заносим в конфиг изменённую пользователем комбинацию клавиш
                    inicfg.save(ini, 'AdminTools\\config.ini') -- не забываем конфиг сохранить
                end
                if imgui.IsItemHovered() then
                    imgui.BeginTooltip()
                    imgui.Text(u8'Клавиша по которой вы будите\nоткрыть меню AdminTools')
                    imgui.EndTooltip()
                end
                imgui.SameLine()
                imgui.PushFont(htext)
                imgui.Text(u8'Меню скрипта')
                imgui.PopFont()
                imgui.SetCursorPosX(65)
                
                imgui.SetCursorPosY(85)
                if hotkey_forma:ShowHotKey(imgui.ImVec2(170, 25)) then -- создаем условие, которое будет срабатывать при обновлении бинда пользователем
                    ini.hotkey.formaTrue = encodeJson(hotkey_forma:GetHotKey()) -- заносим в конфиг изменённую пользователем комбинацию клавиш
                    inicfg.save(ini, 'AdminTools\\config.ini') -- не забываем конфиг сохранить
                end
                imgui.SameLine()
                imgui.PushFont(htext)
                imgui.Text(u8'Принять форму')
                imgui.PopFont()
                imgui.SetCursorPosX(65)
                imgui.SetCursorPosY(120)
                if hotkey_forma1:ShowHotKey(imgui.ImVec2(170, 25)) then -- создаем условие, которое будет срабатывать при обновлении бинда пользователем
                    ini.hotkey.formaFalse = encodeJson(hotkey_forma1:GetHotKey()) -- заносим в конфиг изменённую пользователем комбинацию клавиш
                    inicfg.save(ini, 'AdminTools\\config.ini') -- не забываем конфиг сохранить
                end
                imgui.SameLine()
                imgui.PushFont(htext)
                imgui.Text(u8'Отклонить форму')
                imgui.PopFont()
                
                imgui.SetCursorPosX(65)
                imgui.SetCursorPosY(155)
                if hotkey_tp_menu:ShowHotKey(imgui.ImVec2(170, 25)) then -- создаем условие, которое будет срабатывать при обновлении бинда пользователем
                    ini.hotkey.hotkey_tp_menu = encodeJson(hotkey_tp_menu:GetHotKey()) -- заносим в конфиг изменённую пользователем комбинацию клавиш
                    inicfg.save(ini, 'AdminTools\\config.ini') -- не забываем конфиг сохранить
                end
                imgui.SameLine()
                imgui.PushFont(htext)
                imgui.Text(u8'Меню Телепорта')
                imgui.PopFont()
            end
        end

        imgui.PopFont()
        

        imgui.EndChild()
    end
    
--hotkey.KeyEditor('Менюшка', u8'Открытие меню')
     -- перед imgui end
    imgui.End()
end)

function imgui.ColoredRadioButtonBool(label, state, color)
    local DL, p, size = imgui.GetWindowDrawList(), imgui.GetCursorScreenPos(), imgui.ImVec2(20, 20)
    local button = imgui.InvisibleButton('##radio_'..label, size)
    DL:AddCircleFilled(imgui.ImVec2(p.x + size.x / 2, p.y + size.y / 2), size.x / 2, imgui.GetColorU32Vec4(imgui.ImVec4(color.x, color.y, color.z, 0.5)), 100)
    DL:AddCircleFilled(imgui.ImVec2(p.x + size.x / 2, p.y + size.y / 2), size.x / 2.7, imgui.GetColorU32Vec4(color), 100)
    if state then
        DL:AddCircle(imgui.ImVec2(p.x + size.x / 2, p.y + size.y / 2), size.x / 2 + 1, 0xCCffffff, 100, 2)
    end
    return button
end

imgui.OnFrame(function() return stats[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(250, 150), imgui.Cond.Always)
    imgui.Begin('stats', stats, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar)
    imgui.PushFont(statss)
    imgui.CenterText('Статистика')
    imgui.PopFont()
    imgui.Separator()
    
    imgui.CenterText('Отвечено репортов: ' .. ini.punish.report)
    imgui.CenterText('Получено репутации: ' .. ini.punish.reputation)
    imgui.CenterText('Выдано наказаний: ' .. ini.punish.number)
    imgui.CenterText('Принято форм: ' .. ini.punish.form)
    imgui.CenterText('Репортов сейчас: 0')
    imgui.Separator()
    imgui.PushFont(statss)
    imgui.CenterText('Время: ' .. get_clock(os.time()) .. ' [МСК]')
    imgui.PopFont()
    imgui.End()
end)

imgui.OnFrame(function() return login[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(500,500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(500, 250), imgui.Cond.Always)
    imgui.Begin('login', login, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar)
    imgui.PushFont(statss)
    imgui.CenterText('Авторизация')
    imgui.PopFont()
    imgui.Separator()
    if ini.auth.auth then
        imgui.PushFont(atext)
        if loading_sec <= -3 then
            imgui.CenterText('Укажите пожалуйста свой префикс')
        else
            imgui.CenterText('Здравствуйте, ' .. ini.auth.login)
        end
        
        imgui.PopFont()
        imgui.SetCursorPosY(130)
        imgui.PushFont(statss)
        if loading_sec >= 0 then
            imgui.CenterText('Мне нужно ' .. loading_sec .. ' секунд, чтобы настроить скрипт...')
        elseif loading_sec == -1 or loading_sec == -2 or loading_sec == -3 then
            imgui.CenterText('Ещё немного...')
        elseif loading_sec <= -3 then
            imgui.CenterText('/mute 0 10 Test || ' .. ini.auth.prefix)
            imgui.SetCursorPosX(170)
            imgui.PushItemWidth(150)
            if imgui.InputText('###Prefix', prefix, 256) then
                ini.auth.prefix = u8:decode(ffi.string(prefix))
                inicfg.save(ini, 'AdminTools\\config.ini')
            end
        end
        
        
        imgui.PopFont()
    else
        imgui.SetCursorPosX(130)
        imgui.PushItemWidth(120)
        if imgui.InputText('###Login', ilogin, 256) then
            ini.auth.login = u8:decode(ffi.string(ilogin))
            inicfg.save(ini, 'AdminTools\\config.ini')
        end
        imgui.SetCursorPosX(130)
        imgui.PushItemWidth(120)
        if imgui.InputText('###Password', ipass, 256) then
            ini.auth.password = u8:decode(ffi.string(ipass))
            inicfg.save(ini, 'AdminTools\\config.ini')
        end
        if imgui.Button(u8'Готово', imgui.ImVec2(120, 25)) then
            lua_thread.create(function ()
                sampAddChatMessage(tag .. 'Проверка правильности данных авторизации...', -1)
                sampAddChatMessage(tag .. 'Обычно это занимает до 5-ти секунд!', -1)
                wait(1000)
                sampAddChatMessage(tag .. 'Связываемся с сервером...', -1)
                wait(1390)
                sampAddChatMessage(tag .. 'Получение данных пользователя...', -1)
                wait(3000)
                ini.auth.auth = true
            end)
        end
    end
   
    imgui.End()
end)

function addNotify(msg, time)
	local col = imgui.ColorConvertU32ToFloat4(4281558783)
	local r,g,b = col.x*255, col.y*255, col.z*255
	msg = gsub(msg, '{WC}', '{SSSSSS}')
	msg = gsub(msg, '{MC}', format('{%06X}', bit.bor(bit.bor(b, bit.lshift(g, 8)), bit.lshift(r, 16))))

	notify.msg[#notify.msg+1] = {text = msg, time = time, active = true, justshowed = nil}
end
function ImSaturate(f)
	return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
end

imgui.OnInitialize(function()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    font = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory() .. '\\resource\\fonts\\EagleSans.ttf', 16, imgui.ImFontConfig(), glyph_ranges) -- или getWorkingDirectory() .. '\\recource\\EagleSans.ttf'
     -- или getWorkingDirectory() .. '\\recource\\EagleSans.ttf'
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 15, config, iconRanges)
    local glyph_rangess = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    fontd = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory() .. '\\resource\\fonts\\EagleSans.ttf', 25, imgui.ImFontConfig(), glyph_rangess) -- или getWorkingDirectory() .. '\\recource\\EagleSans.ttf'
    local glyph_rangesss = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    zagol = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory() .. '\\resource\\fonts\\EagleSans.ttf', 30, imgui.ImFontConfig(), glyph_rangesss) -- или getWorkingDirectory() .. '\\recource\\EagleSans.ttf'
    local glyph_rangesss = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    reportf = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory() .. '\\resource\\fonts\\EagleSans.ttf', 35, imgui.ImFontConfig(), glyph_rangesss) -- или getWorkingDirectory() .. '\\recource\\EagleSans.ttf'
    ricon = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 65, config, iconRanges)
    statss = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory() .. '\\resource\\fonts\\EagleSans.ttf', 19, imgui.ImFontConfig(), glyph_rangesss) -- или getWorkingDirectory() .. '\\recource\\EagleSans.ttf'
    atext = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory() .. '\\resource\\fonts\\EagleSans.ttf', 30, imgui.ImFontConfig(), glyph_rangesss) -- или getWorkingDirectory() .. '\\recource\\EagleSans.ttf'
    htext = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory() .. '\\resource\\fonts\\EagleSans.ttf', 21, imgui.ImFontConfig(), glyph_rangesss) -- или getWorkingDirectory() .. '\\recource\\EagleSans.ttf'
    
    
    theme()
end)

function sampev.onServerMessage(color, text)
	if text:find('%[A%] %{......%}.* %{......%}(.*)%[%d+%]%: /(.*) (%d+) (%d+) (.*)') then --[A] {ff0000}Владелец.Проекта {99CC00}Arizona_Rugne[1]: /mute 0 1 Test
		lua_thread.create(function ()	
			admnick, command, fid, ftime, freason = text:match('%[A%] %{......%}.* %{......%}(.*)%[%d+%]%: /(.*) (%d+) (%d+) (.*)')
			wait(300)
			
			forma = true
			nak = true
			if forma and nak then
				addNotify('/' .. command ..' '..fid..' '..ftime..' '..freason, 5)
				printStyledString('Forma', 2000, 4)
				wait(5000)
				forma = false
				nak = false
			end
		end)
	elseif text:find('%[A%] %{......%}.* %{......%}(.*)%[%d+%]%: /(.*) (%d+) (.*)') then
		lua_thread.create(function ()	
			admnick, command, fid, freason = text:match('%[A%] %{......%}.* %{......%}(.*)%[%d+%]%: /(.*) (%d+) (.*)')
			wait(300)
			
			forma = true
			if forma and not nak then
				addNotify('/' .. command ..' '..fid..' '..freason, 5)
				printStyledString('Forma', 2000, 4)
				wait(5000)
				forma = false
				nak = false
			end
		end)
	end
    if text:find('%[A%] %{......%}.* %{......%}.*%[%d+%]%: Бот проверка на тулс') then
        sampSendChat('/a [AdminTools] Прошёл проверку на наличие тулса ' .. version)
        sampSendChat('/a [AdminTools] UID: -1 | Сайт выдаёт ошибку #404')
        return false
	end
end


function imgui.PageButton(bool, icon, name, but_wide)
    
    local ToU32 = imgui.ColorConvertFloat4ToU32
	but_wide = but_wide or 190
	local duration = 0.25
	local DL = imgui.GetWindowDrawList()
	local p1 = imgui.GetCursorScreenPos()
	local p2 = imgui.GetCursorPos()
	local col = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
    local function bringFloatTo(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return from + (count * (to - from) / 100), true
        end
        return (timer > duration) and to or from, false
    end
		
	if not AI_PAGE[name] then
		AI_PAGE[name] = { clock = nil }
	end
	local pool = AI_PAGE[name]

	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.00, 0.00, 0.00))
    local result = imgui.InvisibleButton(name, imgui.ImVec2(but_wide, 35))
    if result and not bool then 
    	pool.clock = os.clock() 
    end
    local pressed = imgui.IsItemActive()
    imgui.PopStyleColor(3)
	if bool then
		if pool.clock and (os.clock() - pool.clock) < duration then
			local wide = (os.clock() - pool.clock) * (but_wide / duration)
			DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2((p1.x + 190) - wide, p1.y + 35), 0x10FFFFFF, 15, 10)
	       	DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 5, p1.y + 35), ToU32(col))
			DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 35), ToU32(imgui.ImVec4(col.x, col.y, col.z, 0.6)), 15, 10)
		else
			DL:AddRectFilled(imgui.ImVec2(p1.x, (pressed and p1.y + 3 or p1.y)), imgui.ImVec2(p1.x + 5, (pressed and p1.y + 32 or p1.y + 35)), ToU32(col))
			DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 190, p1.y + 35), ToU32(imgui.ImVec4(col.x, col.y, col.z, 0.6)), 15, 10)
		end
	else
		if imgui.IsItemHovered() then
			DL:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 190, p1.y + 35), 0x10FFFFFF, 15, 10)
		end
	end
	imgui.SameLine(10); imgui.SetCursorPosY(p2.y + 8)
	if bool then
		imgui.Text((' '):rep(3) .. icon)
		imgui.SameLine(60)
		imgui.Text(name)
	else
		imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), (' '):rep(3) .. icon)
		imgui.SameLine(60)
		imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), name)
	end
	imgui.SetCursorPosY(p2.y + 40)
	return result
end



function imgui.GradientSelectable(text, size, bool)  
    local button = imgui.InvisibleButton('##'..text, size)    
    local dl = imgui.GetWindowDrawList()
    local rectMin = imgui.GetItemRectMin()
    local p = imgui.GetCursorScreenPos()
    local ts = imgui.CalcTextSize(text)
    
    if imgui.IsItemHovered() then
        dl:AddRectFilledMultiColor(imgui.ImVec2(rectMin.x, rectMin.y), imgui.ImVec2(rectMin.x + size.x, rectMin.y + size.y), 
            imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ButtonActive]), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0,0,0,0)), 
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0,0,0,0)), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.ButtonActive]));
    end
    if bool then  
        dl:AddRectFilledMultiColor(imgui.ImVec2(rectMin.x, rectMin.y), imgui.ImVec2(rectMin.x + size.x, rectMin.y + size.y), 
            imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Separator]), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0,0,0,0)), 
                imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0,0,0,0)), imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.Separator]));
    end
    imgui.SameLine(1,1)
    imgui.PushFont(Font[19])
    imgui.Text(text)
    imgui.PopFont()
    
    
    
    return button
end

function time()
    startTime = os.time()
    while true do
        wait(1000)
        if ini.auth.active then
            nowTime = os.date("%H:%M:%S", os.time())

            sessionOnline[0] = sessionOnline[0] + 1
            sessionFull[0] = os.time() - startTime
            sessionAfk[0] = sessionFull[0] - sessionOnline[0]
            

            ini.stats.online = ini.onDay.online + 1
            ini.stats.full = dayFull[0] + sessionFull[0]
            ini.stats.afk = ini.onDay.full - ini.onDay.online

        else
            startTime = startTime + 1
        end
    end
end

function imgui.custom_togglebutton(name, bool, size)
    local function bringFloatTo(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return from + (count * (to - from) / 100), true
        end
        return (timer > duration) and to or from, false
    end

    local rounding = imgui.GetStyle().FrameRounding
    local size = size or imgui.ImVec2(40, 20)
    local dl = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()

    if UI_CUSTOM_TOGGLEBUTTON == nil then UI_CUSTOM_TOGGLEBUTTON = {} end

    if UI_CUSTOM_TOGGLEBUTTON[name] == nil then
        UI_CUSTOM_TOGGLEBUTTON[name] = {
            argument = bool[0],
            bool = false,
            alignment = {bool[0] and size.x / 1.5 - 5 or 0, true},
            clock = 0
        }
    end

    local go_anim = true
    if UI_CUSTOM_TOGGLEBUTTON[name].argument ~= bool[0] then
        UI_CUSTOM_TOGGLEBUTTON[name].argument = bool[0]
        if go_anim then
            UI_CUSTOM_TOGGLEBUTTON[name].bool = true
            UI_CUSTOM_TOGGLEBUTTON[name].clock = os.clock()
        else
            UI_CUSTOM_TOGGLEBUTTON[name].alignment = {bool[0] and size.x / 1.5 - 5 or 0, true}
        end
    end

    local color = {
        constant_color = bool[0] and imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.CheckMark]) or imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.FrameBg]),
        temp_color = bool[0] and imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.CheckMark]) or imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.FrameBg])
    }

    local get_cursor_y = imgui.GetCursorPosY()
    if imgui.InvisibleButton(name, imgui.ImVec2(size)) then UI_CUSTOM_TOGGLEBUTTON[name].bool = true; UI_CUSTOM_TOGGLEBUTTON[name].clock = os.clock(); bool[0] = not bool[0] end
    if imgui.IsItemHovered() then color.temp_color = imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]) end
    if imgui.IsItemActive() then color.temp_color = imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.FrameBgActive]) end
    imgui.SameLine()
    imgui.BeginGroup()
    imgui.SetCursorPosY(get_cursor_y + (size.y - imgui.CalcTextSize(name).y) / 2)
    imgui.Text(name)
    imgui.EndGroup()

    if UI_CUSTOM_TOGGLEBUTTON[name].bool then
        UI_CUSTOM_TOGGLEBUTTON[name].alignment = {bringFloatTo((bool[0] and 0 or size.x / 1.5 - 5), (bool[0] and size.x / 1.5 - 5 or 0), UI_CUSTOM_TOGGLEBUTTON[name].clock, 0.3)}
        if UI_CUSTOM_TOGGLEBUTTON[name].alignment[2] == false then UI_CUSTOM_TOGGLEBUTTON[name].bool = false end
    end

    dl:AddRect(p, imgui.ImVec2(p.x + size.x, p.y + size.y), color.temp_color, rounding, nil, 2)
    dl:AddRectFilled(imgui.ImVec2(p.x + 5 + UI_CUSTOM_TOGGLEBUTTON[name].alignment[1], p.y + 5), imgui.ImVec2(p.x + size.x - size.x / 1.5 + UI_CUSTOM_TOGGLEBUTTON[name].alignment[1], p.y + size.y - 5), color.constant_color, rounding)
end

function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowWidth()/2-imgui.CalcTextSize(u8(text)).x/2)
    imgui.Text(u8(text))
end

function imgui.ToggleButton(str_id, value, hintText, exText)
    local ToU32 = imgui.ColorConvertFloat4ToU32
	local duration = 0.9
	local p = imgui.GetCursorScreenPos()
    local DL = imgui.GetWindowDrawList()
	local size = imgui.ImVec2(40, 20)
    local title = str_id:gsub('##.*$', '')
    local ts = imgui.CalcTextSize(title)
    local cols = {
    	enable = imgui.GetStyle().Colors[imgui.Col.ButtonActive],
    	disable = imgui.GetStyle().Colors[imgui.Col.TextDisabled]	
    }
    local radius = 6
    local o = {
    	x = 4,
    	y = p.y + (size.y / 2)
    }
    local A = imgui.ImVec2(p.x + radius + o.x, o.y)
    local B = imgui.ImVec2(p.x + size.x - radius - o.x, o.y)
    local function bringVec4To(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec4(
                from.x + (count * (to.x - from.x) / 100),
                from.y + (count * (to.y - from.y) / 100),
                from.z + (count * (to.z - from.z) / 100),
                from.w + (count * (to.w - from.w) / 100)
            ), true
        end
        return (timer > duration) and to or from, false
    end
    
    local function bringVec2To(from, to, start_time, duration)
        local timer = os.clock() - start_time
        if timer >= 0.00 and timer <= duration then
            local count = timer / (duration / 100)
            return imgui.ImVec2(
                from.x + (count * (to.x - from.x) / 100),
                from.y + (count * (to.y - from.y) / 100)
            ), true
        end
        return (timer > duration) and to or from, false
    end

    if AI_TOGGLE[str_id] == nil then
        AI_TOGGLE[str_id] = {
        	clock = nil,
        	color = value[0] and cols.enable or cols.disable,
        	pos = value[0] and B or A
        }
    end
    local pool = AI_TOGGLE[str_id]
    
    imgui.BeginGroup()
	    local pos = imgui.GetCursorPos()
	    local result = imgui.InvisibleButton(str_id, imgui.ImVec2(size.x, size.y))
	    if result then
	        value[0] = not value[0]
	        pool.clock = os.clock()
	    end
	    if #title > 0 then
		    local spc = imgui.GetStyle().ItemSpacing
		    imgui.SetCursorPos(imgui.ImVec2(pos.x + size.x + spc.x, pos.y + ((size.y - ts.y) / 2)))
	    	imgui.Text(u8(title))
    	end
    imgui.EndGroup()

 	if pool.clock and os.clock() - pool.clock <= duration then
        pool.color = bringVec4To(
            imgui.ImVec4(pool.color),
            value[0] and cols.enable or cols.disable,
            pool.clock,
            duration
        )

        pool.pos = bringVec2To(
        	imgui.ImVec2(pool.pos),
        	value[0] and B or A,
        	pool.clock,
            duration
        )
    else
        pool.color = value[0] and cols.enable or cols.disable
        pool.pos = value[0] and B or A
    end

	DL:AddRect(p, imgui.ImVec2(p.x + size.x, p.y + size.y), ToU32(pool.color), 4, 15, 1)
	DL:AddCircleFilled(pool.pos, radius, ToU32(pool.color))
    local text = hintText or ''
    if text ~= '' then
        imgui.SameLine()
        imgui.HelpMarker(u8(text))
    end
    local extext = exText or ''
    if extext ~= '' then
        imgui.SameLine()
        imgui.ExMarker(u8(extext))
    end

    return result
end

function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end
    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImVec4(r/255, g/255, b/255, a/255)
    end
    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end
    render_text(text)
end

function theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    -->> Sizez

    imgui.GetStyle().IndentSpacing = 21
    imgui.GetStyle().ScrollbarSize = 14
    imgui.GetStyle().GrabMinSize = 10

    imgui.GetStyle().WindowBorderSize = 0
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 0

    imgui.GetStyle().WindowRounding = 5
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().ScrollbarRounding = 2.5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.50, 0.50)

    -->> Colors
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)

    colors[clr.WindowBg]               = ImVec4(0.15, 0.16, 0.37, 1.00)
    colors[clr.ChildBg]                = ImVec4(0.17, 0.18, 0.43, 1.00)
    colors[clr.PopupBg]                = colors[clr.WindowBg]

    colors[clr.Border]                 = ImVec4(0.33, 0.34, 0.62, 1.00)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)

    colors[clr.TitleBg]                = ImVec4(0.18, 0.20, 0.46, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(1, 0, 0, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.18, 0.20, 0.46, 1.00)
    colors[clr.MenuBarBg]              = colors[clr.ChildBg]

    colors[clr.ScrollbarBg]            = ImVec4(0.14, 0.14, 0.36, 1.00)
    colors[clr.ScrollbarGrab]          = ImVec4(0.22, 0.22, 0.53, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.20, 0.21, 0.53, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.25, 0.25, 0.58, 1.00)

    colors[clr.Button]                 = ImVec4(0.25, 0.25, 0.58, 1.00)
    colors[clr.ButtonHovered]          = ImVec4(0.23, 0.23, 0.55, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.27, 0.27, 0.62, 1.00)

    colors[clr.CheckMark]              = ImVec4(0.39, 0.39, 0.83, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.39, 0.39, 0.83, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.48, 0.48, 0.100, 1.00)

    colors[clr.FrameBg]                = colors[clr.Button]
    colors[clr.FrameBgHovered]         = colors[clr.ButtonHovered]
    colors[clr.FrameBgActive]          = colors[clr.ButtonActive]

    colors[clr.Header]                 = colors[clr.Button]
    colors[clr.HeaderHovered]          = colors[clr.ButtonHovered]
    colors[clr.HeaderActive]           = colors[clr.ButtonActive]

    colors[clr.Separator]              = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.SeparatorHovered]       = colors[clr.SliderGrabActive]
    colors[clr.SeparatorActive]        = colors[clr.SliderGrabActive]

    colors[clr.ResizeGrip]             = colors[clr.Button]
    colors[clr.ResizeGripHovered]      = colors[clr.ButtonHovered]
    colors[clr.ResizeGripActive]       = colors[clr.ButtonActive]

    colors[clr.Tab]                    = colors[clr.Button]
    colors[clr.TabHovered]             = colors[clr.ButtonHovered]
    colors[clr.TabActive]              = colors[clr.ButtonActive]
    colors[clr.TabUnfocused]           = colors[clr.Button]
    colors[clr.TabUnfocusedActive]     = colors[clr.Button]

    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)

    colors[clr.TextSelectedBg]         = ImVec4(0.33, 0.33, 0.57, 1.00)
    colors[clr.DragDropTarget]         = ImVec4(1.00, 1.00, 0.00, 0.90)

    colors[clr.NavHighlight]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.NavWindowingHighlight]  = ImVec4(1.00, 1.00, 1.00, 0.70)
    colors[clr.NavWindowingDimBg]      = ImVec4(0.80, 0.80, 0.80, 0.20)

    colors[clr.ModalWindowDimBg]       = ImVec4(0.00, 0.00, 0.00, 0.90)
end