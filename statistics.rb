load 'euler_general.rb'

module Stat
  def Stat.populate(*x)
    ret = Array.new
    (0...(x.size/2)).each{|i|
      x[i*2+1].times{
        ret << x[i*2]
      }
    } 
    return ret
  end

  def Stat.sum(x)
    total = 0
    x.each{|i|total+=i}
    return total
  end
  
  def Stat.mean(x)
    return sum(x)*1.0/x.length
  end
  
  def Stat.variance(x)
    sum = 0
    m = mean(x)
    x.each{|i|
      sum += (i - m )**2 
    }
    return sum
  end
  
  def Stat.stdDev(x)
    return variance(x)**0.5
  end
  
  def Stat.nPr(n, r)
    Eg.factorial(n)/Eg.factorial(n-r)
  end
  
  def Stat.nCr(n, r)
    return nPr(n, r)/Eg.factorial(r)
  end
  
  def Stat.prob(n, p, k)
    return nCr(n, k) * (p**k) * ((1-p)**(n-k))
  end
  
  class G
    #private method for handling various values for k
    def self.generic(k, size)
      case k
      when nil
        return Array.new(size){|index| yield(index).round(3)}
      when Numeric
        return yield(k)
      when Range, Array
        sum = 0
        k.each{|index| sum += yield(index)}
        return sum
      end
    end
  end
  
  def Stat.binom(n, p, k = nil)
    return G.generic(k, n+1){|x| prob(n, p, x)}
  end
  
  def Stat.poisson(x, lambda)
    return (lambda**x)/(Eg.factorial(x)*(Math::E**lambda))
  end
  
  #returns probability that the first success will occur on the xth trial
  def Stat.geom(p, x = nil)
    G.generic(x, 4.0/p){|k| (1-p)**(k-1)*p}
  end
  
  #returns probability that the kth success will occur on the xth trial
  def Stat.negBinom(p, k, x = nil)
    G.generic(x, 2.0*k/p){|xi| nCr(xi-1, k-1)*(p**k)*((1-p)**(xi-k))}  
  end
  
  def Stat.hypergeom(bigN, bigS, n, x = nil)
    G.generic(x, n+1){|xi| 1.0*nCr(bigS, xi)*nCr(bigN-bigS, n-xi)/nCr(bigN, n)}
  end
  
  #returns probability that xi number of outcomes will occur
  #note that in this case, pi and xi are arrays 
  def Stat.multinom(pi, xi, n)
    bottom = 1.0
    xi.each{|xii| bottom *= Eg.factorial(xii)}
    top = 1.0
    pi.each_index{|i| top *= pi[i]**xi[i]}
    return Eg.factorial(n)*top/bottom
  end
end