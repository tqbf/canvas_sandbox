require 'helpers'

class Grid
    def draw
        bgcolor ||= [221.0/359.0, 0.25, 0.5]
        fgcolor ||= [222.0/359.0, 0.08, 0.65]

        Path.new(0, 0).go {
            add_rect 0, 0, 1000, 1000
            fill bgcolor
        }

        Path.new(0, 0).go {
            0.step(1000, 50) do |i|
                move_to 0, i
                line_to 1000, i
                move_to i, 0
                line_to i, 1000
            end

            @path.setLineWidth(0.0)
            stroke fgcolor
        }
    end

end
