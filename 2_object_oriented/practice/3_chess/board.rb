require_relative "piece"
require_relative "null_piece"
require_relative "sliding_piece"
require_relative "stepping_piece"
require_relative "pawns"

class Board

    attr_accessor :rows, :moves_list

    def initialize
        @rows = Array.new(8) { Array.new(8) }
        @moves_list = []
    end

    def copy
        dup_board = Board.new()
        dup_board.setup_board
        dup_board.simulate(@moves_list)
        dup_board
    end

    def simulate(moves_list)
        moves_list.each do | start, dest = sub_arr |
            move_piece(start, dest)
        end
    end

    def set_pawns(row, col)
        color = row == 1 ? :black : :white
        @rows[row][col] = Pawn.new(color, self, [row, col])
        @rows[row][col].set_symbol(:pawn)
    end

    def set_rooks(row, col, color)
        @rows[row][col] = SlidingPiece.new(color, self, [row, col])
        @rows[row][col].set_symbol(:rook)
    end

    def set_knights(row, col, color)
        @rows[row][col] = SteppingPiece.new(color, self, [row, col])
        @rows[row][col].set_symbol(:knight)
    end

    def set_bishops(row, col, color)
        @rows[row][col] = SlidingPiece.new(color, self, [row, col])
        @rows[row][col].set_symbol(:bishop)
    end

    def set_queens(row, col, color)
        @rows[row][col] = SlidingPiece.new(color, self, [row, col])
        @rows[row][col].set_symbol(:queen)
    end

    def set_kings(row, col, color)
        @rows[row][col] = SteppingPiece.new(color, self, [row, col])
        @rows[row][col].set_symbol(:king)
    end

    def set_pieces(row, col)
        if row == 1 || row == 6
            set_pawns(row, col)
        elsif row == 0 || row == 7
            case col
            when 0, 7
                row == 0 ? set_rooks(row, col, :black) : set_rooks(row, col, :white)
            when 1, 6
                row == 0 ? set_knights(row, col, :black) : set_knights(row, col, :white)
            when 2, 5
                row == 0 ? set_bishops(row, col, :black) : set_bishops(row, col, :white)
            when 3
                row == 0 ? set_queens(row, col, :black) : set_queens(row, col, :white)
            when 4
                row == 0 ? set_kings(row, col, :black) : set_kings(row, col, :white)
            end
        end
    end

    def set_null(row, col)
        @rows[row][col] = NullPiece.new(:color, self, [row, col])
    end

    def setup_board
        valid_rows = [0, 1, 6, 7]
        @rows.each_with_index do | sub_arr, row_i |
            if valid_rows.include?(row_i)
                sub_arr.each_with_index { | _, col_i | set_pieces(row_i, col_i) }
            else
                sub_arr.each_with_index { | _, col_i | set_null(row_i, col_i) }
            end
        end
    end

    def piece?(pos)
        x, y = pos
        @rows[x][y].is_a?(Piece) && !@rows[x][y].is_a?(NullPiece)
    end

    def opposite_color?(pos)
        x, y = pos
        @board.rows[x][y].color != @color
    end

    def check(pos)
        @rows.each do | row |
            row.each do | piece |
                if piece?(piece.pos)
                    return true if piece.get_moves.include?(pos)
                end
            end
        end
        false
    end

    def check_king_exits(king)

        #possible exits works even with 2 checks if u can catch one of them at least
        #still need to check if theres no possible moves, and if so, check to see if
        #any of ur pieces can capture existing pieces that are invalid array
        valid = []
        invalid = []

        moves = king.get_moves
        moves.each_with_index do | move, idx |
            
            #puts "Possible Valid/Unvalid Move #{idx + 1}"
            dup_board = copy
            dup_piece = king.copy_king(king.color, dup_board, move, king.symbol)

            r1, c1 = king.pos
            r2, c2 = move

            dup_board.rows[r2][c2] = dup_piece
            dup_board.rows[r1][c1] = NullPiece.new(:color, dup_board, [r1, c1])

            dup_board.check(move) ? invalid << move : valid << move
            #dup_board.print_board
        end
        [valid, invalid]
    end

    def check_king_rescue(invalid_moves, king)

        checking_pieces = []

        @rows.each do | row |
            row.each do | piece |
                checking_pieces << piece if piece?(piece.pos) && piece.get_moves.include?(king.pos)
            end
        end

        viable_moves = []

        #if amount of pieces checking you == 2 or higher AND valid is empty
        # simply return checkmated.
        if checking_pieces.length > 1
            puts "Checkmated"

        #if amount of pieces checking you == 1
        # simply see if any of ur other pieces can kill OFF that piece
        # if so, then u are not checkmated.
        else
            to_kill = checking_pieces.pop
            @rows.each do | row |
                row.each do | piece |
                    if piece.color == king.color
                        viable_moves << piece if piece?(piece.pos) && piece.get_moves.include?(to_kill.pos)
                    end
                end
            end
        end

        if viable_moves.empty?
            puts "Checkmated"
        else
            puts "Not yet checkmated, possible moves: #{viable_moves}"
        end
    end

    def checkmate?(king)
        valid_action, invalid_action = check_king_exits(king)
        puts "Valid: #{valid_action}"
        puts "Invalid: #{invalid_action}"

        if valid_action.empty?
            check_king_rescue(invalid_action, king)
        else
            puts "Not yet checkmated, possible moves: #{valid_action}"
        end


        print_board
    end

    def print_board
        puts "   0   1   2   3   4   5   6   7 "
        puts "---------------------------------"
        @rows.each_with_index do | sub_arr, idx |
            render_row = "#{idx}  "
            sub_arr.each do | piece |
                if piece.is_a?(NullPiece)
                    render_row += ". "
                else
                    piece.color == :white ? render_row += "*" : render_row += "$"
                    case piece.symbol
                    when :pawn
                        render_row += "P"
                    when :rook
                        render_row += "R"
                    when :knight
                        render_row += "N"
                    when :bishop
                        render_row += "B"
                    when :queen
                        render_row += "Q"
                    when :king
                        render_row += "K"
                    end
                end
                render_row += "  "
            end
            puts render_row
        end
        puts
    end

    def valid_move?(start, dest)
        x, y = start
        valid_moves = @rows[x][y].get_moves
        puts
        print valid_moves
        puts
        valid_moves.include?(dest)
    end

    def move_piece(start_pos, end_pos)
        moves_list << [start_pos, end_pos]
        r1, c1 = start_pos
        r2, c2 = end_pos

        #if @rows[r1][c1].is_a?(NullPiece)
            #raise "Error, starting position is a null_piece"
        #elsif @rows[r2][c2].is_a?(Piece) && !@rows[r2][c2].is_a?(NullPiece) #specify error on null cause null derives from piece
            #raise "Error, there is a piece there." #Tentative, will change for capturing.
        #end

        piece_color = @rows[r1][c1].color
        piece_type = @rows[r1][c1].symbol

        @rows[r1][c1] = NullPiece.new(:color, self, [r1, c1])

        case piece_type
        when :pawn
            @rows[r2][c2] = Pawn.new(piece_color, self, [r2, c2])
        when :rook, :bishop, :queen
            @rows[r2][c2] = SlidingPiece.new(piece_color, self, [r2, c2])
        when :knight, :king
            @rows[r2][c2] = SteppingPiece.new(piece_color, self, [r2, c2])
        end
        @rows[r2][c2].set_symbol(piece_type)

        #-----Testing Here-----
        #print_board

    end
end