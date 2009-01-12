require 'osx/cocoa'
require 'extensions'

class Hash
    def nsdict
        OSX::NSDictionary.dictionaryWithDictionary(self)
    end
    def to_nsdict; nsdict; end
end

class String
    def nsstring
        OSX::NSString.alloc.initWithString(self)
    end
    def to_nsstring; nsstring; end

    def to_font(size = 9.0)
        OSX::NSFont.fontWithName_size(self, size)
    end

    def self.opts_to_cocoa_attrs(opts)
        @@cocoa_attrs ||= {
            :font => OSX::NSFontAttributeName,
            :graf => OSX::NSParagraphStyleAttributeName,
            :color => OSX::NSForegroundColorAttributeName,
            :underline => OSX::NSUnderlineStyleAttributeName,
            :superscript => OSX::NSSuperscriptAttributeName,
            :bgcolor => OSX::NSBackgroundColorAttributeName,
            :attachment => OSX::NSAttachmentAttributeName,
            :ligature => OSX::NSLigatureAttributeName,
            :baseline_offset => OSX::NSBaselineOffsetAttributeName,
            :kern => OSX::NSKernAttributeName,
            :link => OSX::NSLinkAttributeName,
            :stroke_width => OSX::NSStrokeWidthAttributeName,
            :strole_color => OSX::NSStrokeColorAttributeName,
            :underline_color => OSX::NSUnderlineColorAttributeName,
            :strike => OSX::NSStrikethroughStyleAttributeName,
            :strike_color => OSX::NSStrikethroughColorAttributeName,
            :shadow => OSX::NSShadowAttributeName,
            :oblique => OSX::NSObliquenessAttributeName,
            :expansion => OSX::NSExpansionAttributeName,
            :cursor => OSX::NSCursorAttributeName,
            :tooltip => OSX::NSToolTipAttributeName,
            :marked_clause => OSX::NSMarkedClauseSegmentAttributeName,
        }

        drawopts = opts.map do |k, v|
            [ @@cocoa_attrs[k], v ]
        end.to_hash.nsdict
    end

    def cocoa_size(opts)
        nsstring.sizeWithAttributes(self.class.opts_to_cocoa_attrs(opts))
    end

    def cocoa_draw(opts)
        rect = opts.delete(:rect) || [0, 0, size * 20, size]
        rect = OSX::NSMakeRect(*rect)

        nsstring.drawInRect_withAttributes(rect, self.class.opts_to_cocoa_attrs(opts))
    end
end

class Fixnum
    def degrees
        self / 359.0
    end
end

class OSX::NSPoint
    def -(p)
        OSX::NSMakePoint(self.x - p.x, self.y - p.y)
    end

    def +(p)
        OSX::NSMakePoint(self.x + p.x, self.y + p.y)
    end
end

class Array
    def to_point
        OSX::NSMakePoint(self[0], self[1])
    end

    def to_hsb
        OSX::NSColor.colorWithCalibratedHue_saturation_brightness_alpha(self[0],
                                                                        self[1] || 1.0,
                                                                        self[2] || 1.0,
                                                                        self[3] || 1.0)
    end
end

def OSX::NSMutableSet
    def <<(x)
        self.addObject(x)
        return self
    end
end
