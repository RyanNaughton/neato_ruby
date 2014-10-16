require 'serialport'

class Robot

  USB_REGEX = /tty.usbmodem/

  def initialize(port = nil)
    @port = port unless port.nil?
  end

  def port
    @port ||= get_port
  end

  def device
    @device ||= get_device
  end

  def reconnect!
    @port = get_port
    @device = get_device
  end

  def clear_buffer
    while true do
      char = device.getc
      char ? printf("%c", char) : break
    end
  end

  def enable_testmode
    clear_buffer
    device.write "testmode On\n"
    clear_buffer
  end

  def disable_testmode
    clear_buffer
    device.write "testmode Off\n"
    clear_buffer
  end

  def enable_lds_rotation
    clear_buffer
    device.write "SetLDSRotation On\n"
    clear_buffer
  end

  def disable_lds_rotation
    clear_buffer
    device.write "SetLDSRotation Off\n"
    clear_buffer
  end

  def get_lds_scan
    clear_buffer
    device.write "GetLDSScan\n"
    lds_scan = (1..363).map do |x|
      device.readline("\n")
    end
    lds_scan = lds_scan.map{|row| row.gsub("\r\n","").split(",")}
    lds_scan[1..-2]
  end

  private

  def get_port
    Dir["/dev/*"].find{|io| USB_REGEX.match(io) }
  end

  def get_device
    if port
      device = SerialPort.new port
      device.read_timeout = 1
      device
    else
      nil
    end
  end

end
