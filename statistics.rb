load 'euler_general.rb'

def sum(x)
  total = 0
  x.each{|i|total+=i}
  return total
end

def mean(x)
  return sum(x)/x.length
end

def variance(x)
  sum = 0
  m = mean(x)
  x.each{|i|
    sum += (i - m )**2 
  }
  return sum
end

def stdDev(x)
  return variance(x)**0.5
end

def prob(n, p, k)
  return Eg.factorial(n)/(Eg.factorial(n-k)*Eg.factorial(k)) * (p**k) * ((1-p)**(n-k))
end

def binom(n, p, k = nil)
  case k
  when nil
    return Array.new(n){|index| prob(n, p, index)}
  when Numeric
    return prob(n, p, k)
  when Range
    sum = 0
    k.each{|index| sum += prob(n, p, index)}
    return sum
  end
end