class PriorityQueue
  def initialize
    @items = []
  end

  # Add an item to the queue with a priority
  def push(priority, item, matrix)
    @items.push([priority, item, matrix])
    # puts "Push Prio #{priority} node #{item}"
    @items.sort!
  end

  # Remove and return the item with the highest priority
  def pop

    item = @items.shift
    # puts "Pop item #{item[0]}, #{item[1]}"
    # item[2].to_a.each { |row| puts row.inspect }
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
