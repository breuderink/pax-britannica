print "Initializing brain-computer interface."
local mindplay = require 'mindplay'

DETECTIONS_PER_SECOND = 8
local function isnan(n) return tostring(n) == tostring(0/0) end
local probability = 0/0

function pressed()
  if probability > .90 then -- this works with NaNs as well.
    probability = 0 -- prevent continuous flipping.
    return true
  end
  return false
end


function annotate(s)
  print(os.clock() .. ' TODO: annotate "' .. s .. '"')
end


    

-- TODO: make this configurable, and perform some error handling?
local mp = mindplay.init('localhost:5000', 'test_user', '1')
local next_request = os.clock() + 1/DETECTIONS_PER_SECOND
local response = nil

game.actors.new_generic('log', function()
  function update()
    -- this is running every (?) frame.

    -- keep an eye on the clock for making new requests:
    if os.clock() > next_request then
      assert(response == nil) -- TODO: use a list!
      response = mindplay.request_detection(mp)
      next_request = os.clock() + 1/DETECTIONS_PER_SECOND
    end
    
    -- poll for new network traffic:
    mindplay.update(mp)

    -- if there is a response, handle it.
    if response then
      probability = mindplay.detection(response, 'blink')

      if not isnan(probability) then
        -- otherwise, we could free an incomplete response!
        mindplay.response_destroy(mp, response)
        response = nil
      end
    end
  end
end)
