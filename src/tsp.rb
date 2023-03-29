# Kenneth Ezekiel 13521089
# Sorry if this project is not modular as I am still learning about ruby and still figuring out how to make things modular with different classes

require './PriorityQueue'

class TSP
  def initialize(cost_matrix)
    @cost_matrix = cost_matrix
    @num_cities = cost_matrix.length
    @visited = Array.new(@num_cities, false)
  end

  # Returns the reduced cost matrix
  def reduce_matrix
    reduced_matrix = @cost_matrix.map(&:clone)
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
      min_cost = reduced_matrix.map { |row| row[j] }.min
      low_bound += min_cost
      reduced_matrix.each_with_index do |row, i|
        row[j] -= min_cost
      end
    end
    # @cost_matrix = reduced_matrix
    puts "Reduced cost matrix"
    reduced_matrix.to_a.each { |row| puts row.inspect }
    return low_bound
  end

  # Gets the lower bound of a tour
  # A partial tour is a list of city numbers
  def lower_bound(tour, current_cost = 0, tour_start = 0)
    last_city = tour.last
    unvisited_cities = (0...@num_cities).to_a - tour
    while !unvisited_cities.empty?
      # Find the minimum cost edge from the last city to an unvisited city
      min_cost = Float::INFINITY
      city = nil
      unvisited_cities.each do |next_city|
        if @cost_matrix[last_city][next_city] <= min_cost
          min_cost = @cost_matrix[last_city][next_city]
          city = next_city
        end
      end
      # If there are no unvisited cities left, return the cost of going back to the starting city
      if city.nil?
        current_cost += @cost_matrix[last_city][tour.first]
        break
      end
      # Add the cost of the minimum edge to the total cost and mark the city as visited
      current_cost += min_cost
      last_city = city
      unvisited_cities.delete(city)
    end
    return current_cost
  end


  # Branch-and-Bound Algorithm
  def branch_and_bound
    # Initialize prio queue. will be a tuple of the lower bound (cost) and the current tour (this will be used for the FIFO and least-cost search)
    prio_queue = PriorityQueue.new
    # Start tour at city 0
    initial_tour = [0]
    @visited[0] = true
    initial_bound = 0
    # initial_bound = lower_bound(initial_tour)
    prio_queue.push(initial_bound, initial_tour)

    # Initialize best tour
    best_tour = nil
    best_cost = Float::INFINITY

    # Search for the optimal tour present
    while !prio_queue.empty?
      # Dequeue the node with the lowest cost (lower bound)
      current_node = prio_queue.pop
      # puts current_node.inspect
      current_bound, current_tour = current_node

      # If the lower bound of the node is greater than or equal to the best tour found so far, prune the node
      if current_bound >= best_cost
        next
      end

      # If the node represents a complete tour, update the best tour if the cost is lower than the current best tour
      if current_tour.length == @num_cities
        if current_bound < best_cost
          best_tour = current_tour
          best_cost = current_bound
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
          new_bound = lower_bound(new_tour)
          prio_queue.push(new_bound, new_tour)
        end
      end
      current_tour.each do |city|
        @visited[city] = false
      end
    end

    return best_tour, best_cost
  end
end

cost_matrix = [
  [Float::INFINITY, 20, 30, 10, 11],
  [15, Float::INFINITY, 16, 4, 2],
  [3, 5, Float::INFINITY, 2, 4],
  [19, 6, 18, Float::INFINITY, 3],
  [16, 4, 7, 16, Float::INFINITY]
]

# cost_matrix = [
#   [Float::INFINITY, 10, 15, 20],
#   [10, Float::INFINITY, 35, 25],
#   [15, 35, Float::INFINITY, 30],
#   [20, 25, 30, Float::INFINITY]
# ]
tsp = TSP.new(cost_matrix)

# low_bound = tsp.reduce_matrix

best_tour, best_cost = tsp.branch_and_bound

best_cost += tsp.reduce_matrix
puts "Best tour: #{best_tour}"
puts "Best cost: #{best_cost}"
