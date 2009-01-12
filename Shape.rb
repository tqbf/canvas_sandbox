require 'helpers'

class Shape
    attr_accessor :pre, :post
    attr_accessor :x, :y

    def redraw
        @canvas.redraw
    end

    def make(klass, opts={})
        klass.new(@x, @y, opts.merge(:canvas => @canvas, :parent => self))
    end

    def initialize(x, y, opts={})
        @canvas = opts[:canvas] || raise("need a canvas")
        @pre = opts[:pre] || []
        @post = opts[:post] || []
        @x = x
        @y = y + 5
        @parent = opts[:parent]
        @canvas.register(self)
    end

    def children
        pre + post
    end

    def draw
        @pre.each {|c| c.draw}
        draw_myself
        @post.each {|c| c.draw}
    end

    def draw_myself; end

    def hit?(x, y)
        best = nil
        children.each do |c|
            break if (best = c.hit?(x, y))
        end
        best
    end

    def double_click
    end

    def mouse_down(where, prev=nil)
    end

    def mouse_up(where, prev=nil)
    end

    def reposition(point)
        children.each {|c| c.reposition(point) }

        @x += point.x
        @y += point.y
    end

    def detach(obj=self)
        victim, parent = [obj, nil]
        if obj == self and @parent
            parent = @parent
        elsif obj != self
            parent = self
        end

        if parent
            parent.pre.delete victim
            parent.post.delete victim
        end

        @canvas.unregister(self)
    end
end
