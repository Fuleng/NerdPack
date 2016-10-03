NeP.Lexer = {}

local tokens = {
	{ 'string', { '^\'.-\'', '^".-"' } },
	{ 'logic', { '^and', '^or', '^&&', '^||', '^&', '^|' } },
	{ 'constant', { '^true', '^false', '^nil', '^null' } },
	{ 'comparator', { '^>=', '^=>',  '^>', '^<=', '^=<', '^<', '^==', '^!=', '^~=', '^=' } },
	{ 'not', { '^not', '^!' } },
	{ 'identifier', {'^[_%a][_%w]*'} },
	{ 'number', { '^%d+%.?%d*', '^%d+%.?%d*', '^%.%d+' } },
	{ 'operator', {'^[%*/%-%+%%^]'} },
	{ 'nest', {'^[{}]'}},
	{ 'character', {'^[@,:\'%(%)%[%]%.#%$~`\\\";?%s]'} },
}

local function FindPatern(Strg, token, patterns)
	
end

function NeP.Lexer:Tokenize(Strg)
	local list = {}
	local index = 1
	local length = #Strg + 1
	while index < length do
		for i = 1, #tokens do
			local token, patterns = tokens[i][1], tokens[i][2]
			for i = 1, #patterns do
				local sI, eI = Strg:find(patterns[i], index)
				if sI then
					index = eI + 1
					list[#list+1] = {
						kind = token,
						value = Strg:sub(sI, eI),
						from = sI,
						to = eI
					}
				end
			end
		end
	end
	return list
end

function NeP.Lexer:STRING(eval)
	local temp = self:Tokenize(eval)
end

function NeP.Lexer:TABLE(eval)
	for i=1, #eval do
		self:Lex(eval[i])
	end
end

function NeP.Lexer:FUNCTION(eval)
	eval = {
		type = 'func',
		func = eval
	}
end

function NeP.Lexer:Lex(eval)
	local type = type(eval):upper()
	print(type)
	if self[type] then
		self[type](self, eval)
	end
end