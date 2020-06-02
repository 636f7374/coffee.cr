module Coffee::Serialization
  class Range
    include YAML::Serializable

    property ipRange : String
    property export : String?
    property needles : String | Array(String)
    property excludes : Exclude?
    property timeout : TimeOut?
    property type : String

    def initialize
      @ipRange = String.new
      @export = String.new
      @needles = String.new
      @excludes = Exclude.new
      @timeout = TimeOut.new
      @type = String.new
    end

    def to_iata_needles?(needles : String | Array(String), flag : Needle::Flag) : Array(Needle::IATA)?
      list = [] of Needle::IATA

      case flag
      when .iata?
        case needles
        when Array(String)
          needles.each do |item|
            _item = Needle::IATA.parse? item

            list << _item if _item
          end
        when String
          _item = Needle::IATA.parse? needles

          list << _item if _item
        else
        end
      when .edge?
        case needles
        when Array(String)
          needles.each do |item|
            _edge = Needle::Edge.parse? item
            _item = _edge.to_iata? if _edge

            list << _item if _item
          end
        when String
          _edge = Needle::Edge.parse? needles
          _item = _edge.to_iata? if _edge

          list << _item if _item
        else
        end
      when .region?
        case needles
        when Array(String)
          needles.each do |item|
            _region = Needle::Region.parse? item
            next unless _region

            _region.each { |item| list << item }
          end
        when String
          _region = Needle::Region.parse? needles

          _region.try &.each { |item| list << item }
        else
        end
      end

      return if list.empty?
      list
    end

    private def export_to_writer : Writer?
      return unless _export = export
      _export = File.open _export, "ab" rescue nil
      return unless _export

      Writer.new _export
    end

    def exclude_needles(iatas : Array(Needle::IATA)) : Array(Needle::IATA)
      return iatas unless _excludes = excludes
      return iatas unless flag = Needle::Flag.parse? _excludes.type
      return iatas unless _excludes = to_iata_needles? _excludes.needles, flag

      _excludes.each { |exclude| iatas.delete exclude }

      iatas
    end

    def to_task(writer : Writer? = nil, command_line : Bool = false) : Task?
      return unless flag = Needle::Flag.parse? type
      return unless _needles = to_iata_needles? needles, flag

      _needles = exclude_needles _needles

      _ip_range = IPAddress.new ipRange rescue nil
      return unless _ip_range

      writer = export_to_writer unless writer
      _timeout = timeout || TimeOut.new

      task = Task.new _ip_range, _needles, command_line, _timeout
      task.writer = writer if writer

      task
    end

    class Exclude
      include YAML::Serializable

      property needles : String | Array(String)
      property type : String

      def initialize
        @needles = String.new
        @type = String.new
      end
    end
  end
end
