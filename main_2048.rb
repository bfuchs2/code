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
    @@ANIMATION_SPEED = 3
    self.caption = "2048"
    @rand = Random.new
    regen
    @font = Gosu::Font.new(self, Gosu::default_font_name, tilesize/2)
    @smallFont = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @@WAIT = 0.2
  end

  def regen
    @board = Array.new(4){ |x|
      Array.new(4, 0)
    }
    @moveFactor = Array.new(4){ |x|
      Array.new(4, 0)
    }
    placeRandomTile
    placeRandomTile
    @oldBoards = Array.new
    @kbDownTime = Time.now
    @score = 0
    @moving = false
    @movement = 0
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

  #the move method creates a new array of what the board would look like if the corresponding
  #direction were pressed
  #increment determines if the score should be changed by this move (if it's actually happening or just
  #the computer thinking)
  def move dir, increment = false, board = @board
    newScore = 0 if increment
    newBoard = Array.new(4){ |x|
      Array.new(board[x])
    }
    if increment
      @moveFactor = Array.new(4){ |x|
        Array.new(4, 0)  
      }
    end
    if dir == Dir::Up
      for column in 0...4
        isNew = -1 #only declared here for scope reasons TODO check to see if this is necesary
        for row in 0...4
          slid = false
          if newBoard[column][row] > 0
            for checker in (row+1)...4#this for loop only deals with the combining of similar tiles
              if newBoard[column][checker] == newBoard[column][row] and isNew != row
                newScore += newBoard[column][row] if increment
                newBoard[column][row] *= 2
                isNew = row #that should work... right?
                #puts newBoard
                newBoard[column][checker] = 0
                @moveFactor[column][checker] = checker - row if increment
              elsif newBoard[column][checker] > 0
                break
              end
            end#end for checker
          else#i.e newBoard[column][row] not greater than 0
            for mover in (row+1)...4#this for loop deals with sliding tiles without combining
              if newBoard[column][mover] > 0
                newBoard[column][row] = newBoard[column][mover]
                newBoard[column][mover] = 0
                @moveFactor[column][mover] = mover - row if increment
                slid = true
                break
              end
            end#end for mover
          end#end if newBoard[column][row] > 0
          redo if slid
        end#end for row
      end#end for column
      @score += newScore if increment
    elsif dir == Dir::Right
      newBoard = move Dir::Up, increment, rotate(newBoard)
      3.times{
        newBoard = rotate newBoard
        @moveFactor = rotate @moveFactor
      }
    elsif dir == Dir::Left
      newBoard = move Dir::Down, increment, rotate(newBoard)
      3.times{
        newBoard = rotate newBoard
        @moveFactor = rotate @moveFactor
      }
    elsif dir == Dir::Down
      newBoard = move Dir::Right, increment, rotate(newBoard)
      3.times{
        newBoard = rotate newBoard
        @moveFactor = rotate @moveFactor
      }
    end
    newBoard
  end

  def update
    @movement += @@ANIMATION_SPEED
    if @moving and @movement >= @tilesize
      @moving = false
      @oldBoards.push @board
      @board = @futureBoard
      @movement = 0
      placeRandomTile
    end
    return if @moving  
    regen if button_down? Gosu::KbR
    if Time.now - @kbDownTime > @@WAIT and !@moving
      dir = Dir::Up if button_down? Gosu::KbUp
      dir = Dir::Right if button_down? Gosu::KbRight
      dir = Dir::Left if button_down? Gosu::KbLeft
      dir = Dir::Down if button_down? Gosu::KbDown
      if dir
        if @board != move(dir, false)
          @futureBoard = move(dir, true)
          @moveDir = dir
          @moving = true
          @kbDownTime = Time.now
        end
      elsif button_down? Gosu::KbU and Time.now - @kbDownTime > @@WAIT
        @board = @oldBoards.pop unless @oldBoards.size == 0
        @kbDownTime = Time.now
      end
      placeRandomTile if button_down? Gosu::KbQ #TODO for testing only
      
    end
  end

  def tileCoords(x, y)
    if !@moving or @moveFactor[x][y] == 0
      [x*@tilesize+20, y*@tilesize+50]
    else
      moveAmount = @movement*@moveFactor[x][y]
      case @moveDir
      when Dir::Up then 
        [x*@tilesize+20, y*@tilesize+50-moveAmount]
      when Dir::Right then 
        [x*@tilesize+20+moveAmount, y*@tilesize+50]
      when Dir::Down then 
        [x*@tilesize+20, y*@tilesize+50+moveAmount]
      when Dir::Left then 
        [x*@tilesize+20-moveAmount, y*@tilesize+50]
      end
    end
  end
  
  def draw
    @smallFont.draw("score:#{@score}", 20, 5, 1, 1.0, 1.0, 0xf0f0f000)
    @board.each_index do |x|
      @board[x].each_index do |y|
        unless @board[x][y] == 0
          @font.draw("#{@board[x][y]}", *tileCoords(x, y), 0, 1.0, 1.0, 0xffffff00)
        end
      end
    end
    if gameOver
      @font.draw("YOU SUCK", 20, 2*@tilesize, 1, 1.0, 1.0, 0xffff0000)
      @smallFont.draw("your final score was #{@score}", 20, 2.5*@tilesize, 1, 1.0, 1.0, 0xf0f00000)
    end
    #I know you aren't supposed to do computation in the draw method
    #but this makes it so much easier
  end

end

game = Main.new
game.show