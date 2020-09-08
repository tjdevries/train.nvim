local motion = {}

function motion:new(m)
  local obj = {}

  if type(m) == 'string' then
    obj.movement = m
    obj.description = ''
  elseif type(m) == 'table' then
    obj.movement = m.movement
    obj.description = m.description
  end

  return setmetatable(obj, self)
end

return motion
