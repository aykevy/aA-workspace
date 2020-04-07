require_relative "piece"
require_relative "null_piece"
require_relative "sliding_piece"
require_relative "stepping_piece"
require_relative "pawns"

class Board

    attr_accessor :rows

    def initialize
        @rows = Array.new(8) { Array.new(8) }
    end

    def setup_board
        valid_rows = [0, 1, 6, 7]
        @rows.each_with_index do | sub_arr, row_idx |
            if valid_rows.include?(row_idx)
                sub_arr.each_with_index do | piece, col_idx |
                    @rows[row_idx][col_idx] = Piece.new("color", self, [row_idx, col_idx])
                end
            else
                sub_arr.each_with_index do | piece, col_idx |
                    @rows[row_idx][col_idx] = NullPiece.new("color", self, [row_idx, col_idx])
                end
            end
        end
    end

    def print_board
        @rows.each do | sub_arr |
            render_row = ""
            sub_arr.each do | piece |
                piece.is_a?(NullPiece) ? render_row += "?" : render_row += "."
                render_row += " "
            end
            puts render_row
        end
    end

    def move_piece(start_pos, end_pos)
        r1, c1 = start_pos
        r2, c2 = end_pos

        if @rows[r1][c1].is_a?(NullPiece)
            raise "Error, starting position is a null_piece"
        elsif @rows[r2][c2].is_a?(Piece) && !@rows[r2][c2].is_a?(NullPiece) #specify error on null cause null derives from piece
            raise "Error, there is a piece there." #Tentative, will change for capturing.
        end
    end


end

b = Board.new
b.setup_board
b.print_board
b.move_piece([0,0], [0,0])
