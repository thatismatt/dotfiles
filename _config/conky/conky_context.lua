require "cairo"

CairoContext = {}

function CairoContext:new(w)
   local cs = cairo_xlib_surface_create(
      w.display, w.drawable, w.visual,
      w.width, w.height)
   local cr = cairo_create(cs)
   cc = {
      cs = cs,
      cr = cr
   }
   setmetatable(cc, self)
   self.__index = self
   return cc
end

function CairoContext:destroy()
   cairo_destroy(self.cr)
   cairo_surface_destroy(self.cs)
   self.cr = nil
end

function CairoContext:rgba(r, g, b, a)
   cairo_set_source_rgba(self.cr, r, g, b, a)
end

function CairoContext:circle(x, y, radius, thickness)
   cairo_arc(self.cr, x, y, radius - thickness / 2, 0, 2 * math.pi)
   cairo_set_line_width(self.cr, thickness)
   cairo_stroke(self.cr)
end

function CairoContext:rect(x, y, w, h)
   cr = self.cr
   cairo_rectangle(cr, x, y, w, h)
   cairo_fill(cr)
end

function CairoContext:text(x, y, t, f, s)
   cr = self.cr
   cairo_select_font_face(cr, f, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
   cairo_set_font_size(cr, s)
   cairo_move_to(cr, x, y)
   cairo_show_text(cr, t)
end

function CairoContext:move(x, y)
   cairo_move_to(self.cr, x, y)
end

function CairoContext:line(x, y)
   cairo_line_to(self.cr, x, y)
end

function CairoContext:poly(ps)
   self:move(ps[1].x, ps[1].y)
   for k, p in pairs(ps) do
      self:line(p.x, p.y)
   end
   cairo_fill(cr)
end
