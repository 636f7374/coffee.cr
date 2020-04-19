module Coffee::Serialization
  class Option
    include YAML::Serializable

    property ipRange : String
    property export : String?
    property needles : String | Array(String)
    property timeout : TimeOut?
    property type : String

    def initialize
      @ipRange = String.new
      @export = String.new
      @needles = String.new
      @timeout = TimeOut.new
      @type = String.new
    end

    def iata_needles? : Array(Needle::IATA)?
      list = [] of Needle::IATA
      _needles = needles

      case Needle::Flag.parse? type
      when Needle::Flag::IATA
        case _needles
        when Array(String)
          _needles.each do |item|
            _item = Needle::IATA.parse? item

            list << _item if _item
          end
        when String
          _item = Needle::IATA.parse? _needles

          list << _item if _item
        else
        end
      when Needle::Flag::Edge
        case _needles
        when Array(String)
          _needles.each do |item|
            _edge = Needle::Edge.parse? item
            _item = _edge.to_iata? if _edge

            list << _item if _item
          end
        when String
          _edge = Needle::Edge.parse? _needles
          _item = _edge.to_iata? if _edge

          list << _item if _item
        else
        end
      when Needle::Flag::Region
        case _needles
        when Array(String)
          _needles.each do |item|
            _region = Needle::Region.parse? item
            next unless _region

            _region.each { |item| list << item }
          end
        when String
          _region = Needle::Region.parse? _needles

          _region.try &.each { |item| list << item }
        else
        end
      else Nil
      end

      list
    end

    private def export_to_writer : Writer?
      return unless _export = export
      _export = File.open _export, "ab" rescue nil
      return unless _export

      Writer.new _export
    end

    def to_task(writer : Writer? = nil) : Task?
      return unless needles = iata_needles?

      _ip_range = IPAddress.new ipRange rescue nil
      return unless _ip_range

      writer = export_to_writer unless writer
      _timeout = timeout || TimeOut.new

      task = Task.new _ip_range, needles, _timeout
      task.writer = writer if writer

      task
    end
  end
end
