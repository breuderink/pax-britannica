print "Initializing brain-computer interface."
local idport = require 'idport'

-- Definitions.
DETECTIONS_PER_SECOND = 8
local function isnan(n) return tostring(n) == tostring(0/0) end
local NAN = 0/0

-- Define some IDport related functions.
local RESPONSE_READY = 2
local RESPONSE_INVALID = 3

local function cleanup_transfers(list)
  for i, r in ipairs(list) do
    s = idport.response_status(r)
    assert(s ~= RESPONSE_INVALID, 'Invalid response from server!')
    if (s == RESPONSE_READY) or (s == RESPONSE_INVALID) then
      idport.response_destroy(r)
      table.remove(list, i)
    end
  end
end

-- Initialize API and setup bookkeeping.
local detections = {}
local annotations = {}
local probability = 0/0 -- TODO: replace with table.


-- Define functions to be called from within PB:
function pressed()
  if probability > .90 then -- this works with NaNs as well.
    probability = 0 -- prevent continuous flipping.
    return true
  end
  return false
end

function annotate(s)
  print("Annotating: " .. s) 
  r = idport.annotate(idp, idport_user, idport_stream, 'Pax Brittanica', s)
  if r then table.insert(annotations, r) end
end


-- TODO: make this configurable, and perform some error handling?
local next_request = os.clock() + 1/DETECTIONS_PER_SECOND

game.actors.new_generic('log', function()
  function update()
    -- This is running every (?) frame. We repeatedly request a
    -- detection, and store the results when they arrive.
    if idp == nill then
      idp = idport.init(idport_url)
      assert(idp)
    end

    if os.clock() > next_request then
      -- It is time to request a new detection, and schedule the next.
      r = idport.request_detection(idp, idport_user, idport_stream)
      if r then table.insert(detections, r) end
      next_request = os.clock() + 1/DETECTIONS_PER_SECOND
    end
    
    -- Poll for new (asynchronous) network traffic:
    idport.update(idp)

    -- Loop over and handle responses:
    for i, r in ipairs(detections) do
      if idport.response_status(r) == RESPONSE_READY then
        probability = idport.detection(r, 'random')
        print('p = ' .. string.format('%.2f', probability))
      end
    end

    cleanup_transfers(detections); 
    cleanup_transfers(annotations)
  end
end)
