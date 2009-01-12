require 'path'
require 'Shape'
require 'Connection'
require 'Smocket'

class PatchBox < Shape
    attr_accessor :x, :y, :width, :height

    def string_size(s)
        s.size * @@font.pointSize
    end

    def initialize(x, y, opts={})
        super
        @name = opts[:name] || raise("need a name")
        @@font ||= OSX::NSFont.fontWithName_size("Helvetica", 13.0)
        @width = string_size(@name) * 2
        @height = 100

        post << make(Smocket, :label => "Foo thing")
        post << make(Smocket, :label => "Bar thing", :rank => 2)
        post << make(Smocket, :label => "Qux thing", :right => true)
    end

    def go; draw; end

    def connect(p)
        pre << make(Connection, :src => self, :dst => p)
    end

    def draw_myself
        cellbgcolor = [225.degrees, 0.02, 0.91]
        titlecolor = [147.degrees, 0.6, 1]

        xx, yy, w, h = [@x, @y, @width, @height]

        (@path = Path.new(@x, @y)).shadow {
            roundrect xx, yy, w, h, 10, 10
            fill cellbgcolor
        }

        Path.new(@x, @y).go {
            roundrect xx, yy, w, h, 10, 10
            fill cellbgcolor
            stroke [0.4, 0.0, 0.3]
        }

        Path.new(@x, @y).go {
            roundrect xx, (yy + (h - 25.0)), w, 25.0, 10, 10
            fill titlecolor
        }

        Path.new(@x, @y).go {
            add_rect xx, (yy + (h - 50.0)), w, 29
            fill cellbgcolor
        }

        Path.new(@x, @y).go {
            roundrect xx, yy, w, h, 10, 10
            move_to xx, yy + (h - (50 - 29))
            line_to xx + w, yy + (h - (50 - 29))
            stroke [0.5, 0.0, 0.4]
        }

        @name.cocoa_draw(:rect => [@x + 5, @y - 3, 100, 100],
                         :font => @@font)

        if @connection
        end
    end

    def hit?(x, y)
        if not (ret = super(x, y))
            ret = self if (@path and @path.contains? x, y)
        end
        ret
    end

    def mouse_down(where, prev=nil)
        reposition(where - prev) if prev
        self
    end

    def mouse_up(where, prev=nil)
    end
end
