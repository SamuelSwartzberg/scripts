function switchOutputDevice()
  for i=1, #hs.audiodevice.allOutputDevices() do
    if hs.audiodevice.allOutputDevices()[i] == hs.audiodevice.defaultOutputDevice() then
      if i == #hs.audiodevice.allOutputDevices() then
        hs.audiodevice.allOutputDevices()[1]:setDefaultOutputDevice()
        break
      else 
        hs.audiodevice.allOutputDevices()[i+1]:setDefaultOutputDevice()
        break
      end
    end
  end
end

function switchInputDevice()
  for i=1, #hs.audiodevice.allInputDevices() do
    if hs.audiodevice.allInputDevices()[i] == hs.audiodevice.defaultInputDevice() then
      if i == #hs.audiodevice.allInputDevices() then
        hs.audiodevice.allInputDevices()[1]:setDefaultInputDevice()
        break
      else 
        hs.audiodevice.allInputDevices()[i+1]:setDefaultInputDevice()
        break
      end
    end
  end
end