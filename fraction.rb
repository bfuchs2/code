class Fraction < Numeric
  attr_reader :num, :den
  attr_accessor :active
  include Comparable
  
  def initialize(num = 0, den = 1, active = true)
   @den = den.to_i
   raise ZeroDivisionError, 'denominator cannot be 0' if @den == 0
   @num = num.to_i
   @active = active
   simplify! if @active
  end
  
  def simplify!
      flip = (@den < 0) != (@num < 0)
      @den = @den.abs
      @num = @num.abs
      min = @den.abs < @num.abs ? @den.abs : @num.abs
      if true # TODO optimize min < 10000 
        for x in 2..min
          while @den % x == 0 and @num % x == 0
            @num /= x
            @den /= x
          end
        end
      else
        for x in Eg.primes(min)
          while @den % x == 0 and @num % x == 0
            @num /= x
            @den /= x
          end
        end
      end
      @num *= -1 if flip
  end
  
  def invert
    Fraction.new(@den, @num, @active)
  end
  
  def inverse
    invert
  end
  #returns a float representation of the fraction
  def eval
    (num*1.0/den)
  end

  #returns an array of digits representing the decimal form of the fraction
  def toDigArray(prec = 100)
    localNum = @num.abs
    a = Array.new
    prec.times{
       a.push((localNum/@den))
       localNum = (localNum*10) % (@den*10)
    }
    a[0] *= -1 if @num < 0
    return a
  end
  
  def +(other)
    if other.is_a? Fraction
      return Fraction.new(@num*other.den+other.num*@den, @den*other.den, @active)
    else
      return Fraction.new(@num + other*@den, @den, @active)
    end
  end
  
  def *(other)
    if other.is_a? Fraction
      return Fraction.new(@num*other.num, @den*other.den, @active)
    elsif (other.round - other).abs > other/100
      return eval*other
    else
      return Fraction.new(@num*other, @den, @active)
    end     
  end
  
  def /(other)
    if other.is_a? Fraction
      return Fraction.new(@num*other.den, @den*other.num, @active)
    elsif (other.round - other).abs > other/100
       return eval/other
    else
       return Fraction.new(@num, @den*other, @active)
    end
  end
  
  def -(other)
    if other.is_a? Fraction
      return Fraction.new(@num*other.den-other.num*@den, @den*other.den, @active)
    else
      return Fraction.new(@num - other*@den, @den, @active)
    end
  end
  
  #returns the evaluations of the fraction to an arbitrary length
  def toStringDecimal(prec = 100, arr = toDigArray(prec))
    string = arr.shift.to_s
    string += "."
    arr.each{|x| string += x.to_s}
    string
  end
  
  #returns the reciprocal length of the fraction
  def length(prec = 100, dec = toDigArray(prec))
    (prec/2).times{dec.shift}
    for len in 1...(dec.length/2)
      ret = true
      for x in 0...len
          value = dec[x]
          for iter in 1...(dec.length/len)
            ret = false if value != dec[iter*len+x]
          end
      end
      return len if ret
    end
    return length(prec*2)
  end
  
  def to_s
    @num.to_s + "/" + @den.to_s
  end
  
  def <=>(other)
    return eval <=> (other.is_a?(Fraction) ? other.eval : other)
  end
  
  def suc
    return self+1
  end
  
  def >(other)
    return eval > (other.is_a?(Fraction) ? other.eval : other)
  end
  
  def <(other)
    return eval < (other.is_a?(Fraction) ? other.eval : other)
  end
  
  def ==(other)
    return eval == (other.is_a?(Fraction) ? other.eval : other)
  end
  
  def <=(other)
    !self>other
  end
  
  def >=(other)
    !self<other
  end
  
  def **(other)
    if other.is_a? Fraction
      ans = Fraction.new(@num**(other.eval), @den**(other.eval))
      if (@num.round - @num).abs < @nums/100 and (@den.round - @den).abs < @den/100
        return Fraction.new(ans.nums.round, ans.den.round)
      else
        return ans.eval
      end
    else
      Fraction.new(@num**other, @den**other, @active)
    end  
  end
  
end