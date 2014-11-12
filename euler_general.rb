#author bfuchs2
#a bunch of general purely functional methods that are useful
#for various Project Euler problems
class Eg
  def self.factorial(n)#O(n)
    return n if n < 2
    n * factorial(n-1)
  end
  
  #returns all prime numbers less than or equal to n
  #using the sieve of Eratosthenes
  def self.primes(n)#O(n^2)
    #note: the nth index contains n + 2
    primes = Array.new(n-1){|i| i + 2}
    x = 0
    while x < primes.length
      prime = primes[x]
      i = 2
      while i * prime < primes.length + 2
        primes[i * prime - 2] = nil
        i += 1
      end
      x+= 1
      until primes[x] or x > primes.length
        x += 1
      end
    end
    primes.compact
  end
  
  #prime factors of n
  def self.factor(n)#O(sqrt(n))
    return [1] if n == 1
    r = Array.new
    for x in 2..Math.sqrt(n)
      while n % x == 0
        n /= x
        r.push(x)
      end
    end
    r.push(n) if n != 1
    r
  end
  
  #prime factors of n
  def self.factors(n)#O(n)
    r = Array.new
    for x in 1..n-1
      if(n % x == 0)
        r.push(x)
      end
    end
    return r
  end
  
  def self.fib(n)#O(n)
    a = b = 1
    (n-1).times{
      a += b
      a,b = b,a
    }
    return a
  end
  
  def self.fibArray(n)#O(n)
    r = [1, 1]
    (n-2).times{
      r.push(r[-1] + r[-2])
    }
    return r
  end
  
  def self.integrate(start, fin, prec = 6)#O(10^n) where n is the precision
    total = 0
    prec = (10.0**prec)/(fin-start)
    for x in (prec*start).to_i..(prec*fin).to_i
      total += yield(x/prec)
    end
    total/prec
  end
  
  def self.derive(x, prec = 10)#O(1)
    prec = 10.0**prec
    y1 = yield(x-1/prec)
    y2 = yield(x+1/prec)
    (y2-y1)*prec/2
  end
  
  def self.eval(x)#O(1)
    yield(x)
  end
  
  def self.q(primes)
    ret = 1
    for p in primes
      ret *= p
    end
    return ret + 1
  end
end
