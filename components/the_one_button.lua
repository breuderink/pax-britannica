require 'glfw'
require 'math'

local old_states = {}
states = {false, false, false, false}

local player_keys = {
  string.byte('A'),
  string.byte('F'),
  string.byte('H'),
  string.byte('L')
}

local player_joysticks = {
  glfw.JOYSTICK_1,
  glfw.JOYSTICK_2,
  glfw.JOYSTICK_3,
  glfw.JOYSTICK_4
}

function held(i)
  assert(1 <= i and i <= 4)
  return states[i]
end

function pressed(i)
  assert(1 <= i and i <= 4)
  return states[i] and not old_states[i]
end

function released(i)
  assert(1 <= i and i <= 4)
  return not states[i] and old_states[i]
end

game.actors.new_generic('the_one_button', function ()
  function update_setup ()
    old_states = states
    for i = 1, 4 do
      -- Toggle virtual button with keyboard or joystick:
      if game.keyboard.key_pressed(player_keys[i]) or
        glfw.GetJoystickButtons(player_joysticks[i], 1)[1] == glfw.PRESS then
        states[i] = not old_states[i] 
      end

      -- Toggle virtual button with brain-computer interface
      if i == 1 then
        -- read BCI input
        states[i] = old_states[i]
        if game.brain_computer_interface.pressed() then
          states[i] = not old_states[i]
        end
      end
    end
  end
end)
