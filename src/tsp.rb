# Kenneth Ezekiel 13521089
# Sorry if this project is not modular as I am still learning about ruby and still figuring out how to make things modular with different classes

require './PriorityQueue'

class TSP
  def initialize(cost_matrix)
    @cost_matrix = cost_matrix
    @num_cities = cost_matrix.length
    @visited = Array.new(@num_cities, false)
    @init_bound, @cost_matrix = reduce_matrix(@cost_matrix)
  end

  # Returns the reduced cost matrix
  def reduce_matrix(cost_matrix)
    reduced_matrix = cost_matrix.map(&:clone)
    low_bound = 0
    # Substract the row in cost matrix with the smallest element
    reduced_matrix.each_with_index do |row, i|
      min_cost = row.min
      low_bound += min_cost
      row.map! { |cost| cost - min_cost }
    end
    # Subtract the col in cost matrix with the smallest element
    @num_cities.times do |j|
      # Get j-th column of cost matrix
      min_cost = 99999
      reduced_matrix.each_with_index do |row, i|
        min_cost = row[j] if row[j] < min_cost
      end
      low_bound += min_cost
      reduced_matrix.each_with_index do |row, i|
        row[j] -= min_cost
      end
    end

    cost_matrix = reduced_matrix
    # puts "Reduced cost matrix"
    # reduced_matrix.to_a.each { |row| puts row.inspect }
    return low_bound, cost_matrix
  end

  def print_matrix(matrix)
    puts "Reduced cost matrix"
    matrix.to_a.each { |row| puts row.inspect }
  end

  def to_infinite(row, col, matrix)
    matrix[row].map { |elmt| 99999 }
    for a in 0..@num_cities-1 do
      matrix[a][col] = 99999
    end
    matrix[col][row] = 99999
    return matrix
  end


  # Will return lower_bound_cost and updated cost_matrix
  def lower_bound(last_tour, current_tour, last_bound)
    cost_matrix = @cost_matrix.map(&:clone)
    next_city = current_tour.last
    current_city = last_tour.last

    # Get the cost from the current_city to the next_city
    cost = cost_matrix[current_city][next_city]

    # Set all the row from current_city to infinite
    cost_matrix[current_city].map! { |cost| 99999 }
    # Set all the col for the next_city to infinite

    for a in 0..@num_cities-1 do
      cost_matrix[a][next_city] = 99999
    end
    # Prevent going backwards
    cost_matrix[next_city][current_city] = 99999
    current_bound, cost_matrix = reduce_matrix(cost_matrix)
    cost_matrix = to_infinite(current_city, next_city, cost_matrix)
    return cost, cost_matrix
  end



  # Branch-and-Bound Algorithm
  def branch_and_bound
    # Initialize prio queue. will be a tuple of the lower bound (cost) and the current tour (this will be used for the FIFO and least-cost search)
    prio_queue = PriorityQueue.new
    # Start tour at city 0
    initial_tour = [0]
    @visited[0] = true
    initial_bound = @init_bound
    # initial_bound = lower_bound(initial_tour)
    prio_queue.push(initial_bound, initial_tour, @cost_matrix)
    total_bound = initial_bound

    # Initialize best tour
    best_tour = nil
    best_cost = 99999
    best_cost_matrix = nil

    # Search for the optimal tour present
    while !prio_queue.empty?
      # Dequeue the node with the lowest cost (lower bound)
      current_node = prio_queue.pop
      # puts current_node.inspect
      current_bound, current_tour, current_cost_matrix = current_node

      # If the lower bound of the node is greater than or equal to the best tour found so far, prune the node
      if current_bound >= best_cost
        next
      end

      # If the node represents a complete tour, update the best tour if the cost is lower than the current best tour
      if current_tour.length == @num_cities
        if current_bound < best_cost
          best_tour = current_tour
          best_cost = current_bound
          best_cost_matrix = current_cost_matrix
        end
        next
      end

      # Expand the node by adding each unvisited city to the end of the partial tour
      # Then compute the lower bound (cost) of the new partial tour
      current_tour.each do |city|
        @visited[city] = true
      end
      @num_cities.times do |j|
        if !@visited[j]
          # Add the unvisited city to the new partial tour
          new_tour = current_tour + [j]
          new_bound, new_cost_matrix = lower_bound(current_tour, new_tour, current_bound)
          prio_queue.push(new_bound + current_bound, new_tour, new_cost_matrix)
        end
      end
      current_tour.each do |city|
        @visited[city] = false
      end
    end

    return best_tour, best_cost, best_cost_matrix
  end
end

def print_matrix(matrix)
  matrix.to_a.each { |row| puts row.inspect }
end

# cost_matrix = [
#   [99999, 20, 30, 10, 11],
#   [15, 99999, 16, 4, 2],
#   [3, 5, 99999, 2, 4],
#   [19, 6, 18, 99999, 3],
#   [16, 4, 7, 16, 99999]
# ]

# cost_matrix = [
#   [99999, 10, 15, 20],
#   [10, 99999, 35, 25],
#   [15, 35, 99999, 30],
#   [20, 25, 30, 99999]
# ]

puts "Please enter filename (without .txt extension) : "
filename = gets.chomp

file = File.open("../test/#{filename}.txt")

puts "Adjacent matrix: "
cost_matrix = File.read("../test/#{filename}.txt").split("\n")
puts cost_matrix
cost_matrix.map! { |row| row.split(" ") }
cost_matrix = cost_matrix.map! { |row| row.map! { |elmt| elmt == "inf" ? 99999 : elmt.to_i } }

file.close

tsp = TSP.new(cost_matrix)


best_tour, best_cost, best_cost_matrix = tsp.branch_and_bound

# tsp.print_matrix(best_cost_matrix)
# best_cost += tsp.reduce_matrix

# for a in 0..cost_matrix.length-1 do
#   best_cost += cost_matrix[a % cost_matrix.length][(a + 1) % cost_matrix.length]
# end
puts "Best tour: #{best_tour}"
puts "Best cost: #{best_cost}"
