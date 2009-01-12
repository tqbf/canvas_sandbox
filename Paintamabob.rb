require 'helpers'
require 'Path'
require 'Shape'
require 'PatchBox'
require 'Grid'

class Paintamabob <  OSX::NSView
    attr_accessor :stroke
    attr_accessor :fill
    attr_accessor :shapes

    def register(obj)
        @shapes << obj
    end

    def unregister(obj)
        @shapes.delete obj
    end

    def awakeFromNib
        $paint = self
        @shapes = []
    end

    def initWithFrame(frame)
        super_initWithFrame(frame)
        # Initialization code here.
        return self
    end

    def addClicked(sender)
        @shapes << PatchBox.new(100 + rand(200), 100 + rand(200), :name => Time.now.to_i.to_s, :canvas => self)
        redraw
    end
    ib_action :addClicked

    def drawRect(rect)
        # Drawing code here.
        OSX::NSColor.blackColor.set

        if not @patch
            @p1 = PatchBox.new(50, 200, :name => "foo box", :canvas => self)
            @shapes << @p1
            @patch = PatchBox.new(400, 100, :name => "foo box", :canvas => self)
            @shapes << @patch
        end

        @grid ||= Grid.new
        @grid.draw

        @shapes.each {|p| p.draw}

        @block.call if @block
    end

    def redraw(&block)
        @block = block if block_given?
        self.setNeedsDisplay(1)
    end

    def mouseDown(e)
        p = self.convertPoint_fromView(e.locationInWindow, nil)

        sx, sy = [p.x, p.y]

        hit = nil
        @shapes.each do |shape|
            break if (hit = shape.hit?(p.x, p.y))
        end

        return hit.double_click if hit and e.clickCount > 1

        while(e.oc_type != OSX::NSLeftMouseUp)
            p = self.convertPoint_fromView(e.locationInWindow, nil)

            hit = hit.mouse_down(p, OSX::NSMakePoint(sx, sy)) if hit

            sx, sy = [p.x, p.y]

            redraw

            e = window.nextEventMatchingMask(OSX::NSLeftMouseDraggedMask | OSX::NSLeftMouseUpMask)
        end

        hit.mouse_up(self.convertPoint_fromView(e.locationInWindow, nil), OSX::NSMakePoint(sx, sy)) if hit
    end

    def acceptsFirstMouse(e)
        return 1
    end
end
