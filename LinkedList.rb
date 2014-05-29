#author bfuchs2
#a semi-functional linked list implementation in Ruby
#I wrote this to help me learn Ruby then stopped working on it
class LL  
 attr_accessor :parent, :object, :child
  
  def get(i)
    if( i < 0)
      return @parent.get(i + 1)
    elsif(i == 0)
      @object
    else
      @child.get(i - 1)
    end
  end
  
  def getLink(i)
    if(i < 0)
      return @parent.getLink(i + 1)
    elsif(i == 0)
      self
    else
      @child.getLink(i-1)
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
        @child.parent = self 
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
  
  def initialize(object, parent = nil, child = nil)
    if(object.is_a? Array)
      @object = object.shift
      if(!object.empty?)
        @child = LL.new(object, self)
      end
    end
    @object = object
    @parent = parent
    @child = child
  end
  
  def toArray
    if(@child)
      @child.toArray.unshift(@object) 
    else
      [@object]
    end
  end
  
  def self.moveTo(topLink, from, to) 
    link = topLink.getLink(from)
    topLink.remove(from)
    topLink.insert(link.object, to)
  end
  
  def add(object)
    if(@child)
      @child.add(object)
    else
      @child = LL.new(object, self)
    end
    toArray
  end
  
  def linkInsert(link, index)
    if(index == 0)#self becomes link, child becomes self
      return @parent.linkInsert(link, 1) if(@parent)
      @child = LL.new(@object, self, @child)
      @object = link.object
    elsif(index == 1)#insert at child
      link.parent = self
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
      temp = @child
      @child = LL.new(@object, self, temp)
      @object = object
      return toArray
    end
    if(@child == nil)
      @child = LL.new(object, self)
    elsif(index > 1)
      @child.insert(object, index - 1)
    else
      temp = child
      @child = LL.new(object, self, temp)
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
  end
  
  def self.sSort(topLink, lo = 0, hi = topLink.length-1)
      #rather than swapping elements, this method will simply move them
      return if(lo == hi)
      iter = smallestLink = topLink.getLink(lo)
      while(iter.child)
        iter = iter.child
        smallestLink = iter if smallestLink.compareTo(iter) == 1
      end
      print smallestLink.parent.object, ", " if smallestLink.parent
      print smallestLink.object, ", "
      print smallestLink.child.object, ", " if smallestLink.child
      if(smallestLink != topLink.getLink(lo))
        topLink.linkInsert(smallestLink, lo)
        #topLink.linkRemove(smallestLink)
        smallestLink.parent.child = smallestLink.child if(smallestLink.parent)
        smallestLink.child.parent = smallestLink.parent if(smallestLink.child)
      end
      print topLink.toArray, "\n"
      sSort(topLink, lo+1, hi)   
  end
  
  def self.qSort(topLink)
    pivot = topLink.getLink(topLink.length()/2)
    for i in 0..topLink.length-1
      toSort = topLink.getLink(i)
      if(toSort.compareTo(pivot) == 1) 
      end
    end
  end
  
  def self.iSort(topLink)
    for i in 1..topLink.length-1
      toSort = topLink.getLink(i)
      topLink.remove(i)
      for p in 0..i-1
        comp = topLink.getLink(p)
        if toSort.compareTo(comp) == 1 #note: -1 --> 'toSort' before 'comp' and vice versa
          #comp before toSort: make toSort comp's child 
          topLink.linkInsert(toSort, p)
          break
        end
      end
    end
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

ll = LL.generate(5)
print ll.toArray, "\n"
LL.iSort(ll)
puts ll.toArray
