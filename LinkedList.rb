#author bfuchs2
#a semi-functional linked list implementation in Ruby
#I wrote this to help me learn Ruby then stopped working on it
class LL  
 attr_accessor :object, :child
  
  def get(i)
    if(i == 0)
      return @object
    else
      return @child.get(i - 1)
    end
  end
  
  def getLink(i)
    if(i == 0)
      return self
    elsif(@child == nil)
      return nil
    else
      return @child.getLink(i-1)
    end
  end
  
  def linkRemove(link)
    return print "woops" if link == nil
    if(link == self)
      @object = @child.object
      remove(1)
    elsif(link == @child)
      @child = @child.child
      @child.parent = self
    elsif(@child)
      @child.linkRemove(link)
    end
  end
  
  def remove(i)
    if(i == 0)
      @object = @child.object
      remove(1)
    elsif(i == 1)
      #removes all pointers to the child object
      if(@child)
        @child = @child.child
      end
    elsif(@child)
      @child.remove(i - 1)
    end
    toArray
  end
  
  def length
    if @child
      1 + @child.length
    else 
      1
    end
  end
  
  def initialize(obj, child = nil)
    if(obj.is_a? Array)
      @object = obj[0]
      obj.shift
      if not obj.empty?
        @child = LL.new(obj)
      end
    else
      @object = obj
      @child = child
    end
  end
  
  def toArray
    if(@child)
      @child.toArray.unshift(@object) 
    else
      [@object]
    end
  end
  
  def add(object)
    if(@child)
      @child.add(object)
    else
      @child = LL.new(object)
    end
  end
  
  def push(object)
    add(object)
  end
  
  def linkInsert(link, index)
    if(index == 0)#self becomes link, child becomes self
      @child = LL.new(@object, @child)
      @object = link.object
    elsif(index == 1)#insert at child
      link.child = @child
      @child = link
    elsif(@child == nil)
      @child = link
    else
      @child.linkInsert(link, index-1)
    end
  end

  def insert(object, index)
    if(index == 0)
      @child = LL.new(@object, @child)
      @object = object
    elsif(@child == nil)
      @child = LL.new(object)
    elsif(index > 1)
      @child.insert(object, index - 1)
    else
      temp = child
      @child = LL.new(object, temp)
    end
    toArray
  end
  
  #returns 1 if other > self
  #returns -1 if self > other
  def compareTo(other)
    comp = @object <=> other.object
    if comp == nil
      if @object.is_a? String
        comp = -1
      else
        comp = 1
      end
    end
    comp
  end
  
  #the following two methods are because I kept forgetting how compareTo works
  def greaterThan(other)
    return compareTo(other) == 1
  end
  
  def lessThan(other)
    return compareTo(other) == -1
  end
  
  def linkSwap(one, two)
    one.object, two.object = two.object, one.object
  end
  
  def self.bucketSort(topLink)
    i = topLink
    while i.child
      if(i.greaterThan(i.child))
        topLink.linkSwap(i, i.child)
        i = topLink
      else
        i = i.child
      end
    end
    return topLink
  end
  
  def self.selectionSort(topLink)
    place = topLink
    while place
      min = i = place
      while i
        min = i if i.lessThan(min)
        i = i.child
      end
      topLink.linkSwap(place, min)
      place = place.child
    end
    topLink
  end
  
  def self.generate(i = 15, max = 100)
    r = Random.new
    ll = LL.new(r.rand(max))
    for x in 1..i
      ll.add(r.rand(max))
    end
    return ll
  end

end
