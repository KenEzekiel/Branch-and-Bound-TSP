class PriorityQueue
  def initialize
    @items = []
  end

  # Add an item to the queue with a priority
  def push(priority, item)
    @items.push([priority, item])
    # puts "Push Prio #{priority} node #{item}"
    @items.sort!
  end

  # Remove and return the item with the highest priority
  def pop

    item = @items.shift
    # puts "Pop item #{item}"
    return item
  end

  # Return the number of items in the queue
  def size
    @items.size
  end

  # Check if the queue is empty
  def empty?
    @items.empty?
  end
end
