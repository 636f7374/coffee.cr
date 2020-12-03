module Coffee::Serialization
  class Range
    include YAML::Serializable

    property ipRange : String
    property export : String?
    property needles : String | Array(String | NeedleEntry)
    property excludes : Exclude?
    property timeout : TimeOut?
    property type : String

    def initialize
      @ipRange = String.new
      @export = nil
      @needles = String.new
      @excludes = Exclude.new
      @timeout = TimeOut.new
      @type = String.new
    end

    def parse_iata_needles(needles : String | Array(String | NeedleEntry), list : Array(Tuple(Needle::IATA, Int32)))
      case needles
      when Array(String | NeedleEntry)
        needles.each do |item|
          if item.is_a? String
            _item = Needle::IATA.parse? item

            list << Tuple.new _item, 10_i32 if _item
          else
            _item = Needle::IATA.parse? item.value
            _priority = item.priority || 10_i32

            list << Tuple.new _item, _priority if _item
          end
        end
      when String
        _item = Needle::IATA.parse? needles

        list << Tuple.new _item, 10_i32 if _item
      end
    end

    def parse_edge_needles(needles : String | Array(String | NeedleEntry), list : Array(Tuple(Needle::IATA, Int32)))
      case needles
      when Array(String | NeedleEntry)
        needles.each do |item|
          if item.is_a? String
            _edge = Needle::Edge.parse? item
            _item = _edge.to_iata? if _edge

            list << Tuple.new _item, 10_i32 if _item
          else
            _edge = Needle::Edge.parse? item.value
            _item = _edge.to_iata? if _edge
            _priority = item.priority || 10_i32

            list << Tuple.new _item, _priority if _item
          end
        end
      when String
        _edge = Needle::Edge.parse? needles
        _item = _edge.to_iata? if _edge

        list << Tuple.new _item, 10_i32 if _item
      else
      end
    end

    def parse_region_needles(needles : String | Array(String | NeedleEntry), list : Array(Tuple(Needle::IATA, Int32)))
      case needles
      when Array(String | NeedleEntry)
        needles.each do |item|
          if item.is_a? String
            _region = Needle::Region.parse? item
            next unless _region

            _region.each do |region_item|
              list << Tuple.new region_item, 10_i32
            end
          else
            _region = Needle::Region.parse? item.value
            next unless _region

            _priority = item.priority || 10_i32

            _region.each do |region_item|
              list << Tuple.new region_item, _priority
            end
          end
        end
      when String
        _region = Needle::Region.parse? needles

        _region.try &.each do |region_item|
          list << Tuple.new region_item, 10_i32
        end
      else
      end
    end

    def to_iata_needles?(needles : String | Array(String | NeedleEntry), flag : Needle::Flag) : Array(Tuple(Needle::IATA, Int32))?
      list = [] of Tuple(Needle::IATA, Int32)

      case flag
      when .iata?
        parse_iata_needles needles, list
      when .edge?
        parse_edge_needles needles, list
      when .region?
        parse_region_needles needles, list
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

    def exclude_needles(iatas : Array(Tuple(Needle::IATA, Int32))) : Array(Tuple(Needle::IATA, Int32))
      return iatas unless _excludes = excludes
      return iatas unless flag = Needle::Flag.parse? _excludes.type
      return iatas unless _excludes = to_iata_needles? _excludes.needles, flag

      _excludes.each do |_exclude_item|
        iatas.each do |iata|
          if _excludes.first == iata.first
            iatas.delete Tuple.new _exclude_item.first, _exclude_item.last
          end
        end
      end

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

    class NeedleEntry
      include YAML::Serializable

      property value : String
      property priority : Int32?

      def initialize(@value : String, @priority : Int32 = 1_i32)
      end
    end
  end
end
