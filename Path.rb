require 'osx/cocoa'

# wrap all the goop that NSBezierPath uses to draw stuff. Use to draw stuff.
#
# It's like Logo!

class Path
    attr_reader :path
    attr_accessor :x, :y

    # no arguments; just x = Path.new --- now you have a path
    def initialize(x, y)
        @x, @y = [x, y]
        @path = OSX::NSBezierPath.bezierPath
    end

    def shadow(&block)
        begin
            cur = OSX::NSGraphicsContext.currentContext
            cur.saveGraphicsState

            sh = OSX::NSShadow.alloc.init
            sh.setShadowOffset(OSX::NSMakeSize(4.0, -4.0))
            sh.setShadowBlurRadius(3.0)
            sh.setShadowColor(OSX::NSColor.blackColor.colorWithAlphaComponent(0.3))
            sh.set

            instance_eval(&block)

            sh.release
        ensure
            cur.restoreGraphicsState
        end
    end

    # takes a block; everything in the block is a path command (because it's instance-evalled); for
    # example:
    #
    # p = Path.new
    # p.go {
    #     move_to 50, 50
    #     line_to 100, 100
    #     line_to 100, 50
    #     line_to 50, 50
    #     stroke_width 3.0
    #     stroke 0.4
    # }
    #
    # This will draw a yellowy triangle.
    def go(save=true, &block)
        @path = OSX::NSBezierPath.bezierPath # reset

        if not block_given?
            raise "need a block" if not @block and not @first_do
        else
            @block = block
        end

        begin
            cur = OSX::NSGraphicsContext.currentContext if save
            cur.saveGraphicsState
            move_to @x, @y
            instance_eval(&@first_do) if @first_do
            instance_eval(&@block) if @block
        ensure
            cur.restoreGraphicsState if save
        end
        return self
    end

    def first_do(&block)
        @first_do = block
    end

    # Set the stroke color, and then call stroke.
    #
    # Colors are Hue, Saturation, Brightness, Alpha --- each is a percentage
    #
    # Play with Hue to get a sense of what the values are.
    def stroke(hsb=nil)
        if hsb
            c = OSX::NSColor.colorWithCalibratedHue_saturation_brightness_alpha(hsb[0], hsb[1] || 1.0, hsb[2] || 1.0,  hsb[3] || 1.0)
            c.setStroke
        end
        @path.stroke
    end

    # Like stroke, but fill
    def fill(hsb = nil)
        if hsb
            c = OSX::NSColor.colorWithCalibratedHue_saturation_brightness_alpha(hsb[0], hsb[1] || 1.0, hsb[2] || 1.0,  hsb[3] || 1.0)
            c.setFill
        end
        @path.fill
    end

    # Make an NSPoint structure; you won't use this directly
    def point(x, y)
        OSX::NSMakePoint(x, y)
    end

    # Make an NSRect structure; you won't use this directly
    def rect(x, y, w, h)
        OSX::NSMakeRect(x, y, w, h)
    end

    # Move the turtle to x, y
    def move_to(x, y)
        @path.moveToPoint(point(x, y))
    end

    # Turtle down, move-to
    def line_to(x, y)
        @path.lineToPoint(point(x, y))
    end

    # Turtle down, move-to x, y --- but use [c1x, c1y], [c2x, c2y] as bezier control points
    def curve_to(x, y, c1x, c1y, c2x, c2y)
        @path.curveToPoint_controlPoint1_controlPoint2(point(x, y), point(c1x, c1y), point(c2x, c2y))
    end

    # Close the path
    def close
        @path.closePath
    end

    # Set the stroke width
    def stroke_width=(x)
        @path.setLineWidth(x)
    end

    # Set or retrieve the stroke with
    def stroke_width(x=nil)
        stroke_width = x if x
        @path.lineWidth
    end

    # Does this path contain x, y (for mouseover)
    def contains?(x, y)
        @path.containsPoint(point(x, y))
    end

    # Add a rectangle, x, y, width, height
    def add_rect(x, y, w, h)
        @path.appendBezierPathWithRect(rect(x, y, w, h))
    end

    # Add a roundrect, x y w h and x, y radius
    def roundrect(x, y, w, h, xr=0.5, yr=0.5)
        @path.appendBezierPathWithRoundedRect_xRadius_yRadius(rect(x, y, w, h), xr, yr)
    end

    # Add an ellipse
    def ellipse(x, y, w, h)
        @path.appendBezierPathWithOvalInRect(rect(x, y, w, h))
    end

    # Add an arc from x1, y1 to x2, y2 with the radius
    def arc(x1, y1, x2, y2, r=30)
        @path.usingappendBezierPathWithArcFromPoint_toPoint_radius(point(x1, y1), point(x2, y2), r)
    end
end
