class Shoes
  module Swt
    class LinkSegment
      def initialize(fitted_layout, range)
        @regions = []
        @range = range
        @fitted_layout = fitted_layout

        lines = lines_for_link(layout, start_position, end_position)

        add_regions_for_lines(lines)
        offset_regions!(fitted_layout.element_left, fitted_layout.element_top)
      end

      def add_regions_for_lines(lines)
        first_line = lines.shift
        last_line  = lines.pop

        if last_line.nil?
          add_region_for_single_line(start_position, end_position, first_line)
        else
          add_regions_for_first_and_last_lines(start_position, end_position,
                                               first_line, last_line)
          add_regions_for_remaining_lines(lines)
        end
      end

      def lines_for_link(layout, start_position, end_position)
        bounds = []
        0.upto(layout.line_count-1) do |i|
          bounds << layout.line_bounds(i)
        end

        bounds.select do |bound|
          bound.y >= start_position.y && bound.y <= end_position.y
        end
      end

      def add_region_for_single_line(start_position, end_position, first_line)
        add_region(start_position.x, start_position.y,
                   end_position.x,   end_position.y + first_line.height)
      end

      def add_regions_for_first_and_last_lines(start_position, end_position,
                                              first_line, last_line)
        add_region(start_position.x, start_position.y,
                   layout.width,     start_position.y + first_line.height)
        add_region(0,              end_position.y,
                   end_position.x, end_position.y + last_line.height)
      end

      def add_regions_for_remaining_lines(lines)
        lines.each do |line|
          add_region(line.x,              line.y,
                     line.x + line.width, line.y + line.height)
        end
      end

      def add_region(left, top, right, bottom)
        @regions << Region.new(left, top, right, bottom)
      end

      def offset_regions!(left, top)
        @regions.each do |region|
          region.offset_by!(left, top)
        end
      end

      def in_bounds?(x, y)
        @regions.any? {|region| region.in_bounds?(x, y)}
      end

      def start_position
        @fitted_layout.get_location(@range.first, false)
      end

      def end_position
        @fitted_layout.get_location(@range.last, true)
      end

      def layout
        @fitted_layout.layout
      end

      class Region
        def initialize(start_x, start_y, end_x, end_y)
          @start_x = start_x
          @start_y = start_y
          @end_x = end_x
          @end_y = end_y
        end

        def offset_by!(left, top)
          @start_x += left
          @end_x   += left

          @start_y += top
          @end_y   += top
        end

        def in_bounds?(x, y)
          (@start_x..@end_x).include?(x) and (@start_y..@end_y).include?(y)
        end
      end
    end
  end
end
