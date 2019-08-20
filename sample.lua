----------------------------------------------
-- Sample of Slib14SEGx8v3.lua for W4.00.03
-- Original code is
-- https://github.com/maenoh/led-14seg/blob/add-new-file/14SEGx8v3_makerfaire2019_dynamic.ino
-- Copyright (c) 2018, AoiSaya,maenoh
-- All rights reserved.
-- 2019/08/18 rev.0.01
-----------------------------------------------
function chkBreak(n)
	sleep(n or 0)
	if fa.sharedmemory("read", 0x00, 0x01, "") == "!" then
		error("Break!",2)
	end
end
fa.sharedmemory("write", 0x00, 0x01, "-")

local script_path = function()
	local  str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*/)")
end

local function demo(str, n_disp)
	local pat
	local target_seg={}
	local mask={}
	local step = 8*n_disp

	for msg=1,#str-1, step do
		pat = led:getPat(str:sub(msg,msg+step-1))
		for g_ch = 1,step do
			mask[g_ch]=0
			target_seg[g_ch]=0
		end
		for g_ch = 1,step do
			for seg_id=0,15 do
				target_seg[g_ch] = 2^seg_id
				mask[g_ch] = mask[g_ch] + 2^seg_id
				for k=1,6 do
					led:write(target_seg,mask,pat)
				end
			end
		end
		for k=1,500 do
			led:write(target_seg,mask,pat)
			chkBreak()
		end
	end
end

--main
local myDir  = script_path()
led = require (myDir.."lib/Slib14SEGx8v3")

local n_disp=1

led:setup(n_disp)

for i=1,1000 do
	led:print("FLASHAIR")
	chkBreak()
end

demo("MAKER-FAIRE-2019MAENOH! 14SEGBAR",n_disp)
led:cls()
