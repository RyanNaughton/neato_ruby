# SetMotor 900 900 100

# GetLDSScan
# SetLDSRotation Off

# echo "GetLDSScan" > /dev/tty.usbmodemfa131


# fd = IO.sysopen("/dev/tty.usbmodemfd121", "w")
# a = IO.new(fd,"w")
# $stderr.puts "PlaySound 2"
# a.puts "World"

# fd = IO.sysopen "/dev/tty.usbmodemfa131", "w"
# ios = IO.new(fd, "w")
# ios.puts "ZetCode"
# ios.close

r = Robot.new
while true do
  angle = r.angle_of_max_distance
  puts "angle is #{angle}"
  #max_visible_distance = r.max_visible_distance
  #distance = (max_visible_distance < 10000 &&  max_visible_distance > -10000) ? max_visible_distance ?
  distance = 200
  r.turn(angle)
  sleep(1)
  r.set_motor(distance, distance, 100)
  sleep(3)
end


require 'serialport'
sp = SerialPort.new "/dev/tty.usbmodemfa131"
sp.write "PlaySound 2\n"
while true do
   printf("%c", sp.getc)
 end

 sp.write "testmode On\n"
 sp.write "SetLDSRotation On\n"
 sp.write "GetLDSScan\n"
 
 sp.readline(100)
 lds_scan = (1..363).map do |x|
  sp.readline("\n")
end
lds_scan = lds_scan.map{|row| row.gsub("\r\n","").split(",")}
lds_scan[1..-2]

sp.write "SetLDSRotation Off\n"
sp.write "testmode Off\n"

# http://stackoverflow.com/questions/10161758/reading-from-serial-port-in-a-ruby-on-rails-application-hangs/10534407#10534407
# http://stackoverflow.com/questions/6356565/reading-from-a-serial-port-with-ruby

# http://playground.arduino.cc/interfacing/ruby
# http://www.cmrr.umn.edu/~strupp/serial.html
# https://github.com/hparra/ruby-serialport/wiki