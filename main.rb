#author bfuchs2
#2048 in Ruby using Gosu
require 'gosu'

class Main < Gosu::Window
  attr_reader :board
  module Dir
    Up, Right, Down, Left, Undo = *0..4
  end

  def initialize(tilesize = 100)
    super tilesize*4, tilesize*4+30, false
    @tilesize = tilesize
    self.caption = "2048"
    @rand = Random.new
    regen
    @font = Gosu::Font.new(self, Gosu::default_font_name, tilesize-20)
    @smallFont = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @@WAIT = 0.3
  end

  def regen
    @board = Array.new(4){ |x|
      Array.new(4, 0)
    }
    placeRandomTile
    placeRandomTile
    @oldBoards = Array.new
    @kbDownTime = Time.now
    @score = 0
  end

  def placeRandomTile(board = @board)
    numSpaces = 0
    board.each{ |line|
      line.each{|node|
        numSpaces += 1 if node == 0
      }
    }
    return if numSpaces == 0
    posn = @rand.rand numSpaces
    board.each_index{ |line|
      board[line].each_index{|node|
        if board[line][node] == 0 and posn >= 1
        posn -= 1
        elsif board[line][node] == 0 and posn == 0
        board[line][node] = @rand.rand(6) == 2 ? 4 : 2
        return
        end
      }
    }
  end

  def gameOver
    @board == move(Dir::Up) and @board == move(Dir::Right) and @board == move(Dir::Down) and @board == move(Dir::Left)
  end

  def rotate board = @board#rotates the board 90degrees clockwise
    Array.new(4){|x|
      Array.new(4){|y|
        board[3-y][x]
      }
    }
  end

  #the move method must be purely functional, as it is called to check if the board changes
  def move dir, increment = false, board = @board, score = @score
    newScore = 0
    newBoard = Array.new(4){ |x|
      Array.new(board[x])
    }
    if dir == Dir::Up
      for row in 0...4
        unless newBoard[row] == Array.new(4, 0)
          newBoard[row].delete(0)
          newBoard[row].each_index{ |i|
            if newBoard[row][i] == newBoard[row][i+1]
            newScore += newBoard[row][i]
            newBoard[row][i] *= 2
            newBoard[row].delete_at(i + 1)
            end
          }
          newBoard[row].concat(Array.new(4-newBoard[row].size, 0))
        end
      end
      @score += newScore if increment
    elsif dir == Dir::Right
      newBoard = move Dir::Up, increment, rotate
      3.times{newBoard = rotate newBoard}
    elsif dir == Dir::Left
      newBoard = move Dir::Down, increment, rotate
      3.times{newBoard = rotate newBoard}
    elsif dir == Dir::Down
      for row in 0...4
        unless newBoard[row] == Array.new(4, 0)
          newBoard[row].delete(0)
          newBoard[row].each_index{ |i|
            if newBoard[row][newBoard[row].size-i] == newBoard[row][newBoard[row].size-1-i]
            newScore = newBoard[row][newBoard[row].size-i]
            newBoard[row][newBoard[row].size-i] *= 2
            newBoard[row].delete_at(newBoard[row].size-1-i)
            end
          }
          (4-newBoard[row].size).times{ newBoard[row].unshift(0)}
        end
      end
      @score += newScore if increment
    end
    newBoard
  end

  def update
    regen if button_down? Gosu::KbR
    if Time.now - @kbDownTime > @@WAIT
      dir = Dir::Up if button_down? Gosu::KbUp
      dir = Dir::Right if button_down? Gosu::KbRight
      dir = Dir::Left if button_down? Gosu::KbLeft
      dir = Dir::Down if button_down? Gosu::KbDown
      if dir
        @oldBoards.push @board
        @board = move dir, true
        placeRandomTile @board unless @board == @oldBoards[-1]
        @kbDownTime = Time.now
      elsif button_down? Gosu::KbU and Time.now - @kbDownTime > @@WAIT
        @board = @oldBoards.pop unless @oldBoards.size == 0
        @kbDownTime = Time.now
      end
      placeRandomTile if button_down? Gosu::KbQ
    end
  end

  def draw
    @smallFont.draw("score:#{@score}", 20, 5, 1, 1.0, 1.0, 0xf0f0f000)
    @board.each_index do |x|
      @board[x].each_index do |y|
        unless @board[x][y] == 0
          @font.draw("#{@board[x][y]}", x*@tilesize+20, y*@tilesize+50, 0, 1.0, 1.0, 0xffffff00)
        end
      end
    end
    if gameOver
      @font.draw("YOU SUCK", 20, 2*@tilesize-50, 1, 1.0, 1.0, 0xffff0000)
      @smallFont.draw("your final score was #{@score}", 20, 2*@tilesize+15, 1, 1.0, 1.0, 0xf0f00000)
    end
  end

end

game = Main.new
game.show