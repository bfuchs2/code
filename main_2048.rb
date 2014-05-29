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
    @font = Gosu::Font.new(self, Gosu::default_font_name, tilesize/2)
    @smallFont = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @@WAIT = 0.2
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
  def move dir, increment = false, board = @board, score = @score
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
      for row in 0...4
        unless newBoard[row] == Array.new(4, 0)
          #rather than deleting the zeroes, all the following things need to be kept track of for movement
          if increment
            posn = 0
            while posn < 4
              if newBoard[row][posn] == 0
                for inc in posn+1..3
                  @moveFactor[row][inc]+= 1
                end
                newBoard[row].delete_at(posn)
              else
                posn+=1
              end
            end
          else
            newBoard[row].delete(0) #but if nothing is being changed, we do it this way 
          end
          #now it's time to combine similar tiles
          if increment
            newBoard[row].each_index{ |i|
              if newBoard[row][i] == newBoard[row][i+1]
                newScore += newBoard[row][i]
                newBoard[row][i] *= 2
                @moveFactor[row].each_index do |inc|
                  if inc > i
                    @moveFactor[row][inc] += 1
                  end
                end
                newBoard[row].delete_at(i + 1)
              end
            }
          else
            newBoard[row].each_index{ |i|
              if newBoard[row][i] == newBoard[row][i+1]
                newBoard[row][i] *= 2
                newBoard[row].delete_at(i + 1)
              end
            }
          end
          newBoard[row].concat(Array.new(4-newBoard[row].size, 0))
        end
      end
      @score += newScore if increment
    elsif dir == Dir::Right
      newBoard = move Dir::Up, increment, rotate
      3.times{
        newBoard = rotate newBoard
        @moveFactor = rotate @moveFactor
      }
    elsif dir == Dir::Left
      newBoard = move Dir::Down, increment, rotate
      3.times{
        newBoard = rotate newBoard
        @moveFactor = rotate @moveFactor
      }
    elsif dir == Dir::Down
      for row in 0...4
        unless newBoard[row] == Array.new(4, 0)
          #rather than deleting the zeroes, all the following things need to be kept track of for movement
          if increment
            posn = 3
            while posn >= 0
              if newBoard[row][posn] == 0
                for inc in 0..posn
                  @moveFactor[row][inc]+= 1
                end
                newBoard[row].delete_at(posn)
              else
                posn-=1
              end
            end
          else
            newBoard[row].delete(0) #but if nothing is being changed, we do it this way 
          end
          #now it's time to combine similar tiles
          if increment
            newBoard[row].each_index{ |i|
              if newBoard[row][-i-1] == newBoard[row][-i-2]
                newScore += newBoard[row][-1]
                newBoard[row][-i-1] *= 2
                @moveFactor[row].each_index do |inc|
                  if inc <= i
                    @moveFactor[row][inc] += 1
                  end
                end
                newBoard[row].delete_at(-i-2)
              end
            }
          else
            newBoard[row].each_index{ |i|
              if newBoard[row][i] == newBoard[row][i+1]
                newBoard[row][i] *= 2
                newBoard[row].delete_at(i + 1)
              end
            }
          end
          (4-newBoard[row].size).times{newBoard[row].unshift(0)}
        end
      end
      @score += newScore if increment
    end
    newBoard
  end

  def update
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
      placeRandomTile if button_down? Gosu::KbQ
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
    @movement += 1
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
    if @moving and @movement >= @tilesize
      @moving = false
      @oldBoards.push @board
      @board = @futureBoard
      @movement = 0
      placeRandomTile
    end
  end

end

game = Main.new
game.show