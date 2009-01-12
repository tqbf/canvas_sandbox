require 'Shape'

class Connection < Shape
    attr_accessor :src, :dst

    def initialize(x, y, opts={} )
        super(x, y, opts)
        @src = opts[:src] || raise("need a source")
        @dst = opts[:dst]

        @color = [10.degrees, 0, 1, 0.5]
    end

    def draw_myself
        conncolor = @color
        hloc = [@src.x + (@src.width - 5),
                @src.y + (@src.height - 5)]
        tloc = [@dst.x ,
                @dst.y ]

        midpoint = Array.new(2)
        midpoint[0] = hloc[0] + ((tloc[0] - hloc[0]) / 2)
        midpoint[1] = hloc[1] + ((tloc[1] - hloc[1]) / 2)

        (@path = Path.new(*hloc)).go {
            curve_to(tloc[0], tloc[1],
                     midpoint[0] + 30, midpoint[1] + 30,
                     midpoint[0] - 30, midpoint[1] - 30)
            @path.setLineWidth(3.0)
            stroke conncolor
        }
    end

    def mouse_down(where, prev=nil)
        if prev
            @dst = @dst + (where - prev)

            if (target = @canvas.shapes.find do |s|
                    s.kind_of? Smocket and s.hit?(where.x, where.y)
                end)
                @color = [58.degrees, 0.60, 1]
            else
                @color = [10.degrees, 0, 1]
            end
        end
        redraw
        self
    end

    def mouse_up(where, prev=nil)
        if (target = @canvas.shapes.find do |s|
            s.kind_of? Smocket and s.hit?(where.x, where.y)
        end)
            @color = [58.degrees, 0.60, 1, 0.5]
            @dst = target
            target.connection = self
        else
            @src.connection = nil if @src.kind_of? Smocket
            @dst.connection = nil if @dst.kind_of? Smocket
            detach
        end

        redraw
    end
end
