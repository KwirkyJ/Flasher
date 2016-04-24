local RSwitch = require 'radioswitch'



local b = RSwitch.new()
assert(not b:isSelected())
b:toggle()
assert(b:isSelected())
b:toggle()
assert(not b:isSelected())

print('==== RADIOSWITCH PASSED ====')

