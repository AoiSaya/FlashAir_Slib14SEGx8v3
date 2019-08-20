-----------------------------------------------
-- SoraMame library of 14SEGx8 for W4.00.03
-- Copyright (c) 2019, AoiSaya,maenoh
-- All rights reserved.
-- 2019/08/19 rev.0.02
-----------------------------------------------
--[[
Pin assign
	PIN SPI	14SEGx8
CLK  5
CMD  2	DO 	SI
D0	 7	CLK	SK
D1	 8	CS 	RK
D2	 9	DI
D3	 1	RSV
VCC  4		V
VSS1 3		G
VSS2 6
--]]


local Slib14SEGx8 = {
	digits_as = {
		0x7F, -- digit0
		0xBF, -- digit1
		0xDF, -- digit2
		0xEF, -- digit3
		0xF7, -- digit4
		0xFB, -- digit5
		0xFD, -- digit6
		0xFE  -- digit7
	};
	digits_bs = {
		0x80, -- digit0
		0x40, -- digit1
		0x20, -- digit2
		0x10, -- digit3
		0x08, -- digit4
		0x04, -- digit5
		0x02, -- digit6
		0x01  -- digit7
	};
	seg14 = {
		0x0000, --Space
		0x4006, --!
		0x0000, --"
		0xffFF, --#
		0x12ED, --$
		0x2424, --%
		0x2930, --&
		0x0400, --'
		0x0039, --(
		0x000F, --)
		0x3f00, --*
		0x12C0, --+
		0x2000, --,
		0x00C0, ---
		0x4000, --.
		0x0000, --/
		0x003F, --0
		0x0006, --1
		0x00DB, --2
		0x00CF, --3
		0x00E6, --4
		0x00ED, --5
		0x00FD, --6
		0x0027, --7
		0x00FF, --8
		0x00EF, --9
		0x0C00, --:
		0x2100, --;
		0x0C40, --<
		0x00C8, --=
		0x2180, -->
		0x5083, --?
		0x10BF, --@
		0x2486, --A
		0x04FD, --B
		0x003B, --C
		0x120F, --D
		0x00F9, --E
		0x0071, --F
		0x00BD, --G
		0x00F6, --H
		0x1209, --I
		0x001E, --J
		0x0C70, --K
		0x0038, --L
		0x0536, --M
		0x0936, --N
		0x003F, --O
		0x00F3, --P
		0x083F, --Q
		0x08F3, --R
		0x019D, --S  0x09, 0x1B, //S
		0x1201, --T
		0x003E, --U
		0x2430, --V
		0x2836, --W
		0x2D00, --X
		0x1500, --Y
		0x2409	--Z  0x24, 0x2D, //Z
	};
}

function Slib14SEGx8:setup(n_disp,led_type) -- n_disp:number of 8-digit display unit, led_type=1:AG,2:BG
	led_type = led_type or 2
	self.n_disp = n_disp
	self.led_bs = (led_type==2)

  	fa.spi("mode",0)
  	fa.spi("init",1) -- 1.6MHz
  	fa.spi("bit",24)
  	self:cls()
end

function Slib14SEGx8:getPat(str)
  	local n
  	local pat ={}

  	for i=1,#str do
		n = string.byte(string.sub(str,i,i))-0x20
		pat[i] = self.seg14[n+1]
	end

  	return pat
end

function Slib14SEGx8:write(fg,mask,bg) -- 74HC595 x 3
  	local digit, g_ch, fg_pat, mask_pat, bg_pat, data
  	local n_disp = self.n_disp
  	local digits = self.led_bs and self.digits_bs or self.digits_as
  	local scode  = self.led_bs and 0xffff or 0x0000
  	local SHL	 = bit32.lshift
  	local XOR	 = bit32.bxor
  	local OR	   = bit32.bor
  	local AND	 = bit32.band

  	for ch=1,8 do
		digit = digits[ch]
		for disp_id=0,n_disp-1 do
		  	g_ch = disp_id*8+ch
	  		fg_pat	 = fg and fg[g_ch] or 0x00
	  		mask_pat = mask and mask[g_ch] or 0x00
	  		bg_pat	 = bg and bg[g_ch] or 0x00
	  		fg_pat	 = fg_pat or 0x00
	  		mask_pat = mask_pat or 0x00
	  		bg_pat	 = bg_pat or 0x00
	  		data = XOR(OR(AND(bg_pat,mask_pat),fg_pat),scode)
	  		fa.spi("write",SHL(data,8)+digit)
		end
		fa.spi("cs",0)
		fa.spi("cs",1)
  	end
end

function Slib14SEGx8:print(str) -- 74HC595 x 3
  	local digit, g_ch, n, pat, ng
  	local n_disp = self.n_disp
  	local digits = self.led_bs and self.digits_bs or self.digits_as
  	local scode  = self.led_bs and 0xffff or 0x0000
  	local SHL	 = bit32.lshift
  	local XOR	 = bit32.bxor

  	for ch=1,8 do
		digit = digits[ch]
		for disp_id=0,n_disp-1 do
	  		g_ch = disp_id*8+ch
	  		n	= (g_ch>#str) and 0 or string.byte(string.sub(str,g_ch,g_ch))-0x20
	  		pat = self.seg14[n+1]
	  		pat = pat or 0x00
	  		fa.spi("write",SHL(XOR(pat,scode),8)+digit)
		end
		fa.spi("cs",0)
		fa.spi("cs",1)
  	end
end

function Slib14SEGx8:cls()
	self:write()
end

collectgarbage()
return Slib14SEGx8
