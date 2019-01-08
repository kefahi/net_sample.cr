require "./nic/*"

lib LibC
  IFHWADDRLEN = 6
end

class NetSample::NIC
  @@nics : Hash(String, self) = get_nic_info

  def self.inaddr_of(if_name)
    @@nics[if_name]?.try &.inaddr
  end

  def self.in6addr_of(if_name)
    @@nics[if_name]?.try &.in6addr
  end

  def self.hwaddr_of(if_name)
    @@nics[if_name]?.try &.hwaddr
  end

  def self.[](if_name)
    @@nics[if_name]
  end

  def self.[]?(if_name)
    @@nics[if_name]?
  end

  def self.each(&block)
    @@nics.values.each do |nic|
      yield nic
    end
  end

  property inaddr : String?
  property in6addr : String?
  setter hwaddr : Bytes?

  def initialize(@name : String)
  end

  def to_s(io : IO)
    io << "<NIC: " << @name.inspect
    io << ", " << "inet: " << @inaddr if @inaddr
    io << ", " << "inet6: " << @in6addr if @in6addr
    if @hwaddr
      io << ", " << "hw: "
      internal_hwaddr(io)
    end
    io << ">"
  end

  private def internal_hwaddr(io : IO)
    i = 0
    if bytes = @hwaddr
      byte_size = bytes.size
      loop do
        io << ("%02x" % bytes[i])
        i += 1
        if i == byte_size
          break
        end
        io << ':'
      end
      io << ":??" unless byte_size == LibC::IFHWADDRLEN
    end
  end

  def hwaddr
    if bytes = @hwaddr
      String.build do |io|
        hwaddr(io)
      end
    else
      nil
    end
  end
end
