#author Bernard
#a vector class to help compute the TAM212 homework
#note that invalid operations may still return a value
#e.g. <2, 3> dot <3, 2, 1> returns 13 even though it isn't valid
#I have better things to do than foolproof this
#use with caution 
class Vector

  attr_accessor :nums
  def initialize(x, y)
    @nums = [x, y]
  end
  
  def initialize(arr)
    @nums = Array.new(arr)
  end
  
  def +(other)
    Vector.new(Array.new(nums.size){ |i|
        @nums[i] + other.nums[i]
      })
  end
  
  def -(other)
    Vector.new(Array.new(@nums.size){ |i|
        @nums[i] - other.nums[i]
      })
  end
  
  def *(coef)
    Vector.new(@nums.collect{|i|
      i*coef
    })
  end
  
  def /(coef)
    Vector.new(@nums.collect{|i|
      i/coef
    })
  end
      
  def dot(other)
    total = 0
    for x in 0...@nums.size
      total += @nums[x] * other.nums[x]
    end
    total
  end
  
  def cross(other)
    Vector.new([
      @nums[1]*other.nums[2] - @nums[2]*other.nums[1],
      @nums[2]*other.nums[0] - @nums[0]*other.nums[2],
      @nums[0]*other.nums[1] - @nums[1]*other.nums[0]
      ])
  end
  
  def length
    total = 0
    @nums.each{|x|
      total += x*x
    }
    total**0.5
  end
  
end

def pos(m1, r1x, r1y, m2, m3, r3x, r3y, rcx, rcy)
r1m = Vector.new([r1x, r1y])*m1*1.0
r3m = Vector.new([r3x, r3y])*m3
rcm = Vector.new([rcx, rcy])*(m1+m2+m3)
print ((rcm - r1m - r3m)/m2).nums
end

a = Vector.new([3, 2])
b = Vector.new([3, 2, 1])
print (a.dot b)


  