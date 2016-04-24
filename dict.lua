-- ITU standard
-- dot (.) one time-unit
-- dash (-) three time-units
-- inter-element gap (while signaling one character) one time-unit
-- short gap (Between letters) three time-units
-- medium gap (Between words) seven time-units

local d = {}
d['a'] = '.-'
d['b'] = '-...'
d['c'] = '-.-.'
d['d'] = '-..'
d['e'] = '.'
d['f'] = '..-.'
d['g'] = '--.'
d['h'] = '....'
d['i'] = '..'
d['j'] = '.---'
d['k'] = '-.-'
d['l'] = '.-..'
d['m'] = '--'
d['n'] = '-.'
d['o'] = '---'
d['p'] = '.--.'
d['q'] = '--.-'
d['r'] = '.-.'
d['s'] = '...'
d['t'] = '-'
d['u'] = '..-'
d['v'] = '...-'
d['w'] = '.--'
d['x'] = '-..-'
d['y'] = '-.--'
d['z'] = '--..'

d['1'] = '.----'
d['2'] = '..---'
d['3'] = '...--'
d['4'] = '....-'
d['5'] = '.....'
d['6'] = '-....'
d['7'] = '--...'
d['8'] = '---..'
d['9'] = '----.'
d['0'] = '-----'

return d

