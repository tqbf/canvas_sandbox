require 'Shape'
require 'Connection'

class Smocket < Shape
    def width; 10; end
    def height; 10; end

    attr_accessor :connection

    def initialize(x, y, opts={})
        super(x, y, opts)

        @right = opts[:right]
        @label = opts[:label] || raise("need label")
        @rank = opts[:rank] || 1

        @@font ||= "Helvetica".to_font

        raise "need a parent" if not @parent
    end

    def draw_myself
        color = [359.degrees, 0.15, 0.39]

        if not @right
            padded_start = [5,0].to_point + @parent
            ranked_start = [0,(@rank*12)].to_point + padded_start

            (@dot = Path.new(ranked_start.x, ranked_start.y)).go {
                ellipse ranked_start.x, ranked_start.y, 7, 7
                stroke color
            }

            @label.cocoa_draw(:rect => [ranked_start.x + 11, ranked_start.y - 6, 100, 15],
                              :color => color.to_hsb,
                              :font => @@font)
        else
            padded_start = [@parent.width - 15,0].to_point + @parent
            ranked_start = [0,(@rank*12)].to_point + padded_start

            (@dot = Path.new(ranked_start.x, ranked_start.y)).go {
                ellipse ranked_start.x, ranked_start.y, 7, 7
                stroke color
            }

            strsize = @label.cocoa_size(:font => @@font).width

            @label.cocoa_draw(:rect => [ranked_start.x - (strsize + 5), ranked_start.y - 6, strsize + 5, 15],
                              :color => color.to_hsb,
                              :font => @@font)
        end

        @x = ranked_start.x
        @y = ranked_start.y
    end

    def hit?(x, y)
        return self if @dot and @dot.contains? x, y
        nil
    end

    def mouse_down(where, prev=nil)
        if not @connection
            @pre << (ret = make(Connection, :src => self,
                                            :dst => where))
            @connection = ret
            ret
        elsif @connection.src == self
            ret = @connection
            @connection.src = @connection.dst
            @connection.dst = where
        else
            ret = @connection
            @connection.dst = where
        end
        ret
    end
end
