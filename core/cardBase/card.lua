--[[--ldoc desc
@module card
@author KevinZhang

Date   2018-03-28 11:17:40
Last Modified by   KevinZhang
Last Modified time 2018-03-28 14:28:06
]]

local Card = {};

--[[	
	16位表示一张牌, 0xABCD
	AB: 00-4F 用来表示癞子牌的牌值
		50-FF 用来表示特殊牌标记
	CD: C, 花色
		D, 牌点
]]


local ByteMap = {
	[0x01] = "方块A", [0x02] = "方块2", [0x03] = "方块3",  [0x04] = "方块4", [0x05] = "方块5", [0x06] = "方块6", [0x07] = "方块7",
	[0x08] = "方块8", [0x09] = "方块9", [0x0a] = "方块10", [0x0b] = "方块J", [0x0c] = "方块Q", [0x0d] = "方块K",

	[0x11] = "梅花A", [0x12] = "梅花2", [0x13] = "梅花3",  [0x14] = "梅花4", [0x15] = "梅花5", [0x16] = "梅花6", [0x17] = "梅花7",
	[0x18] = "梅花8", [0x19] = "梅花9", [0x1a] = "梅花10", [0x1b] = "梅花J", [0x1c] = "梅花Q", [0x1d] = "梅花K",

	[0x21] = "红桃A", [0x22] = "红桃2", [0x23] = "红桃3",  [0x24] = "红桃4", [0x25] = "红桃5", [0x26] = "红桃6", [0x27] = "红桃7",
	[0x28] = "红桃8", [0x29] = "红桃9", [0x2a] = "红桃10", [0x2b] = "红桃J", [0x2c] = "红桃Q", [0x2d] = "红桃K",

	[0x31] = "黑桃A", [0x32] = "黑桃2", [0x33] = "黑桃3",  [0x34] = "黑桃4", [0x35] = "黑桃5", [0x36] = "黑桃6", [0x37] = "黑桃7",
	[0x38] = "黑桃8", [0x39] = "黑桃9", [0x3a] = "黑桃10", [0x3b] = "黑桃J", [0x3c] = "黑桃Q", [0x3d] = "黑桃K",

	[0x4e] = "小王",  [0x4f] = "大王",	
}
Card.ByteMap = new(BiMap, ByteMap);

Card.CardFlag = {
	Default			= 0, --默认	
	Tribute			= 0x50,
}

local ValueMap = {	
	[3] = "3";
	[4] = "4";
	[5] = "5";
	[6] = "6";
	[7] = "7";
	[8] = "8";
	[9] = "9";
	[10] = "10";
	[11] = "J",
	[12] = "Q",
	[13] = "K",
	[14] = "A",
	[15] = "2",
	[16] = "小王",
	[17] = "大王",
}
Card.ValueMap = new(BiMap, ValueMap);

local ColorMap = {
	[0] = "方块";
	[1] = "梅花";
	[2] = "红桃";
	[3] = "黑桃";	
}
Card.ColorMap = new(BiMap, ColorMap);

local function __tostring(t)
	if t.value < 16 then
		if not Card.isLaizi(t) then
			local original = Card.getLaiziCard(card)
			return string.format("%s%s(原 %s%s)", 
				Card.ColorMap:getValueByKey(t.color) or tostring(t.color), 
				Card.ValueMap:getValueByKey(t.value) or tostring(t.value),
				Card.ValueMap:getValueByKey(original.color) or tostring(original.color),
				Card.ValueMap:getValueByKey(original.value) or tostring(original.value)
				);
		else
			return string.format("%s%s(%s)", 
				Card.ColorMap:getValueByKey(t.color) or tostring(t.color), 
				Card.ValueMap:getValueByKey(t.value) or tostring(t.value),
				__tostring(Card.getLaiziCard(t)));
		end
	end

	return Card.ValueMap:getValueByKey(t.value) or tostring(t.value);
end

local function __eq(t1, t2)
	if Card.isLaizi(t1) then
		return t1.flag == t2.byte;
	elseif Card.isLaizi(t2) then
		return t2.flag == t1.byte;
	else		
		return t1.byte == t2.byte;
	end
end

local function __lt(t1, t2)
	if t1.value == t2.value then
		return t1.color < t2.color;
	end
	return t1.value < t2.value;
end

local function __le(t1, t2)
	if t1.value == t2.value then
		return t1.color <= t2.color;
	end
	return t1.value < t2.value;
end

function Card.new( byte )
	local card = new(Card);
	card.byte = byte;
	card.value = bit.band(byte, 0x000f);
	card.color = bit.band(bit.brshift(byte, 4), 0x00f);
	card.flag = bit.brshift(byte, 8);

	if card.flag ~= Card.CardFlag.Default then
		card.byte = bit.band(byte, 0x00ff);
	end
	
	if card.value < 3 then
		card.value = card.value + 13;
	elseif card.value > 13 then
		card.value = card.value + 2;
	end

	setmetatable(card, {
		__tostring = __tostring,
		__eq = __eq,
		__le = __le,
		__lt = __lt,
	})

	return card;
end

--获取癞子转变的新牌
function Card.getChangeCard(laizi,target)
	local newByte = bit.blshift(laizi.byte, 8) + target.byte;
	return Card.new(newByte);
end

--是否由癞子转变
function Card.isLaizi(card)
	return card.flag > 0x00 and card.flag <= 0x4f;
end

--获取癞子牌的原始牌值
function Card.getLaiziCard(card)
	return Card.new(card.flag)
end

function Card.isTribute(card)
	return card.flag == Card.CardFlag.Tribute;
end

function Card.getTributeCard(card)
	local newByte = bit.blshift(Card.CardFlag.Tribute, 8) + card.byte;
	return Card.new(newByte);
end

return Card;