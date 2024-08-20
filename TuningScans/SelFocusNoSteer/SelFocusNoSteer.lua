--[[
    ExtractionSteering2DScan.lua - scan the intitial ion start position and the extraction steering and record the ion's displacement from the ion axis in the SEL
]]

simion.workbench_program()

-- make a circular array of start positions 
local ycenter = 35         -- center of circle in y
local zcenter = 35         -- center of circle in z
local rad_target = 4       -- radius of circle
local ext_center = -1650    -- voltage for extraction y,z steering at center of target
local ext_range = 500      -- Range of focus voltages
local nvolts = 50          -- number of voltages in focus scan range (increment = (2*range)/(n-1)) 26
local nions = 250
local excel_enable = 0  -- Use Excel? (1=yes, 0=no)

local ypos = 35      -- present y position
local zpos = 35      -- present z position
local data_rec    -- tracks the data to be written to file    
local half_angle 
local angle_center = 15
local angle_range = 10
local nangle = 5
filled = false
-- ion optics tuning
local ext_energy = 1300     -- voltage on ion target (defines beam energy)
local ext_lens1 = -2500     -- voltage on 3rd extraction electrode (first einzel lens)
local ext_lens2 = 1200      -- voltage on 5th extraction electrode (second einzel lens)
local ext_y = 0            -- voltage on y axis steering of 6th extraction electrode quad (symmetric steering)
local ext_z = 0            -- voltage on z axis steering of 6th extraction electrode quad (symmetric steering)
local bender = 920          -- Bender Voltage
local sel_focus = 0      -- common voltage on sel for focus
local collector = 0
local deflector = 0

-- figure out spacing of spots
sel_inc = (2*ext_range)/(nvolts-1)
angle_inc = (2*angle_range)/(nangle-1)
function segment.flym()
    sim_trajectory_image_control = 1 -- don't keep trajectories

    file = io.open("data\\ke_20\\SelFocusNoSteer_ke_20_nvolts_"..nvolts.."_Vcenter_"..ext_center.."_nangle_"..nangle.."_Acenter_"..angle_center.."_filled_"..tostring(filled)..".csv", "w")
    --file:write("Generated from IonStartLocation.iob\nYpos,Zpos,ExtElec,Bender,SEL,RFQ,CaptureElec,End")
    file:write("Generated from SelFocusNoSteer.iob\nBender = "..bender.."V\nSel Focus,Half angle,Efficiency")
            
    for ex = 1,nvolts do
      sel_focus = ext_center - ext_range + (ex-1)*sel_inc
      for angle = 1,nangle do 
        half_angle = angle_center - angle_range+(angle-1)*angle_inc
        -- Regenerate particle definitions in case FE cathode properties changed.
        local PL = simion.import 'particlelib.lua'
        PL.reload_fly2('SelFocusNoSteer.fly2', {
        -- variables to pass to FLY2 file.
        ypos=ypos,
        zpos=zpos,
        nions=nions,
        half_angle= half_angle,
        filled = false
        })
        data_rec = {sel_focus, half_angle,nil}
        run()
      end
    end
    file:close()
end

-- called on start of each run.
local first
local rec_pos
local dist_after_deflector
local dist_before_deflector
local efficiency
local ion_count
function segment.initialize_run()
  first = true
  rec_pos = -1
  dist_after_deflector = {}
  efficiency = 0
  ion_count = 0
end

function segment.fast_adjust()
  -- set extraction optics
  adj_elect1 = ext_energy
  adj_elect2 = 0
  adj_elect3 = ext_lens1
  adj_elect4 = 0
  adj_elect5 = ext_lens2
  -- set extraction steering
  adj_elect6 = -ext_z
  adj_elect7 = -ext_y
  adj_elect8 = ext_z
  adj_elect9 = ext_y
  -- set bender with only a few buttons
  adj_elect10 = bender
  adj_elect20 = -1 * bender
  adj_elect30 = -1 * bender
  adj_elect40 = bender
  -- set SEL steering
  adj_elect101 = sel_focus 
  adj_elect102 = sel_focus 
  adj_elect103 = sel_focus 
  adj_elect104 = sel_focus

  -- set faraday cup optics
  adj_elect113 = deflector
end


  -- called on every time-step for each particle in PA instance.
function segment.other_actions()
  -- Update the PE surface display on first time-step of run.
  if first 
  then 
    first = false
    sim_update_pe_surface = 1
  end
  -- These if conditionals are checked each time-step on each ion in the run. Very useful for recording individual ion data at some point in the run.
  -- record ion location at faraday cup deflector

  if (ion_py_mm >= 1055 and ion_py_mm <= 1069 and ion_px_mm>=97 and ion_px_mm <=106 and ion_pz_mm >=30 and ion_pz_mm <= 39 and rec_pos ~= ion_number)
  then
    efficiency = efficiency + 1
    rec_pos = ion_number
  end
end

--Record the data at the end of the run
function segment.terminate_run()
    data_rec[3] = efficiency/ion_count 
    file:write('\n',tostring(table.concat(data_rec, ", ")))
end

function segment.terminate()
    ion_count = ion_count+1
end 