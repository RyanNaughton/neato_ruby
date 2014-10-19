require 'serialport'

class Robot

  USB_REGEX = /ttyACM0/ #/tty.usbmodem/

  attr_accessor :latest_lds_scan

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
    toggle_testmode
  end

  def disable_testmode
    toggle_testmode(false)
  end

  def toggle_testmode(enable = true)
    on_off = enable ? "On" : "Off"
    clear_buffer
    device.write "testmode #{on_off}\n"
    clear_buffer
  end

  def enable_lds_rotation
    toggle_lds_rotation
  end

  def disable_lds_rotation
    toggle_lds_rotation(false)
  end

  def toggle_lds_rotation(enable = true)
    on_off = enable ? "On" : "Off"
    clear_buffer
    device.write "SetLDSRotation #{on_off}\n"
    clear_buffer
  end

  def get_lds_scan
    enable_testmode
    enable_lds_rotation
    clear_buffer
    device.write "GetLDSScan\n"
    lds_scan = (1..363).map do |x|
      device.readline("\n")
    end
    lds_scan = lds_scan.map{|row| row.gsub("\r\n","").split(",")}[1..-2]
    self.latest_lds_scan = {lds_scan: lds_scan, time: Time.now}
    lds_scan
  end

  def is_latest_lds_scan_recent?(more_recent_than = nil)
    return false unless latest_lds_scan
    more_recent_than = !more_recent_than.nil? ? more_recent_than : Time.now - 20
    latest_lds_scan[:time] > more_recent_than
  end

  def set_motor(left_wheel_dist, right_wheel_dist, speed)
    enable_testmode
    clear_buffer
    device.write "SetMotor #{left_wheel_dist} #{right_wheel_dist} #{speed}\n"
  end

  def turn_right(speed = 100)
    turn(90, speed)
  end

  def turn_left(speed = 100)
    turn(-90, speed)
  end

  def turn(degrees, speed = 100)
    degrees = degrees % 360
    if degrees > 180
      degrees = (360 - degrees)*-1
    end
    distance = degrees*2.2222222222222223
    set_motor(distance, distance*-1, speed)
  end

  def angle_of_max_distance
    scan = get_lds_scan
    max_distance = scan.map{|x| x[1].to_i}.max
    scan.find{|s| s[1].to_i == max_distance}[0].to_i
  end

  def max_visible_distance
    #scan = is_latest_lds_scan_recent?(Time.now - 3) ? latest_lds_scan[:lds_scan] : get_lds_scan
    scan = get_lds_scan
    scan.map{|x| x[1].to_i}.max
  end

  # r.device.write "GetDigitalSensors\n"
  # r.clear_buffer

  # r.device.write "GetAnalogSensors\n"
  # r.clear_buffer

  # r.device.write "GetAccel\n"
  # r.clear_buffer

  # r.device.write "GetMotors\n"
  # r.clear_buffer




  private

  def get_port
    Dir["/dev/*"].find{|io| USB_REGEX.match(io) }
  end

  def get_device
    if port
      device = SerialPort.new port
      device.read_timeout = 100
      device
    else
      nil
    end
  end

end
