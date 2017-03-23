class Maze
  attr_accessor :grid, :solution, :path_length, :frontier, :came_from, :cost_so_far, :solution, :distance_map, :start, :finish
  def initialize(maze_file)
    @grid = File.readlines(maze_file).map {|line| line.chomp.chars}
    @solution = File.readlines(maze_file).map {|line| line.chomp.chars}
    @distance_map = Hash.new
    @counter = 0
    @path_length = 0
    @frontier = PriorityQueue.new
    @came_from = {}
    @cost_so_far = {}
    @path_length = 0
    @start = nil
    @finish = nil
  end
  
  def [](pos)
    row,col = pos
    @grid[row][col]
  end
  
  def []=(pos,token)
    row,col = pos
    @grid[row][col] = token
  end
  
  def up_from(pos)
    row,col = pos
    [row - 1, col]
  end
    
  def right_from(pos)
    row,col = pos
    [row, col + 1]
  end
  
  def left_from(pos)
    row, col = pos
    [row, col - 1]
  end
  
  def down_from(pos)
    row, col = pos
    [row + 1, col]
  end
  
  def neighbors(pos)
    [left_from(pos),up_from(pos),right_from(pos),down_from(pos)].select {|position| self[position] == " " || self[position] == "S"}
  end
  
  def calculate_start_and_finish
    @grid.each_with_index do |line,row|
      line.each_index do |col|
        if @grid[row][col] == "S"
          @start = [row,col]
        elsif @grid[row][col] == "E"
          @finish = [row,col]
        end
        if @start && @finish
          return
        end
      end
    end
  end
  
  # def calculate_finish
  #   @grid.each_with_index do |line,row|
  #     line.each_index do |col|
  #       if @grid[row][col] == "E"
  #         @finish = [row,col]
  #         return
  #       end
  #     end
  #   end
  # end
  
  def heuristic(pos1,pos2)
    if @distance_map[pos2]
      return @distance_map[pos2]
    else
      x1,y1 = pos1
      x2,y2 = pos2
      @distance_map[pos2] = (x1-x2)**2 + (y1-y2)**2
    end
  end
  
  def solve_maze
    @came_from[self.finish] = nil
    @cost_so_far[self.finish] = 0
    @frontier << [self.finish, 0]
    new_cost = nil
    priority = nil
    while !@frontier.empty?
      current = @frontier.pop
      if current == self.start
        break
      end
      # p "cost----------"
      # p @cost_so_far
      # p "frontier---------"
      # p @frontier.elements
      # p "came_from-------"
      # p @came_from
      self.neighbors(current).each do |next_pos|
        # if self[next_pos] != "S" && self[next_pos] != " "
        #   next
        # end
        # if next_pos == down_from(current) || next_pos == left_from(current)
        #   new_cost = @cost_so_far[current]
        # else
          new_cost = @cost_so_far[current] + 1
        # end
        if !@cost_so_far[next_pos] || new_cost < @cost_so_far[next_pos]
          @cost_so_far[next_pos] = new_cost
          priority = new_cost + heuristic(self.start,next_pos)
          @frontier << [next_pos,-priority]
          @came_from[next_pos] = current
          # row,col = next_pos
          # @solution[row][col] = "#"
          # File.open("solution.txt","a") do |f|
          #   @solution.each {|x| line = x.join; f.puts line}
          # end
        end
      end
    end
  end
  
  
  def create_path
    z = self.start
    loop do
      z = @came_from[z]
      if z == self.finish
        break
      end
      @path_length += 1
      self[z] = "X"
    end
  end
  
  def create_maze_solution(output_file)
    self.calculate_start_and_finish
    # self.calculate_finish
    s = Time.now
    self.solve_maze
    t = Time.now
    self.create_path
    File.open(output_file,"w") do |f|
      self.grid.each {|line| f.puts line.join}
      # self.solution.each {|line| f.puts line.join}
      f.puts ""
      f.puts "Shortest Path length is #{@path_length}"
      fin = Time.now
      f.puts "Took #{(t-s)*1000} ms to solve and #{(fin-t)*1000} ms to make path"
    end
  end
end

class PriorityQueue
  attr_accessor  :elements
  def initialize
    @elements = [nil]
    @positions = [nil]
  end

  def <<(element)
    @elements << element[1]
    @positions << element[0]
    bubble_up(@elements.size - 1)
  end

def bubble_up(index)
  parent_index = (index / 2)
  return if index <= 1
  return if @elements[parent_index] >= @elements[index]
  exchange(index, parent_index)

  bubble_up(parent_index)
end
  
def exchange(source, target)
  @elements[source], @elements[target] = @elements[target], @elements[source]
  @positions[source], @positions[target] = @positions[target], @positions[source]
end

def pop
  exchange(1, @elements.size - 1)

  max = @elements.pop
  current = @positions.pop
  bubble_down(1)
  current
end
def empty?
  @elements == [nil]
end

def bubble_down(index)
  # p @elements.size
  child_index = (index * 2)

  return if child_index > @elements.size - 1
  not_the_last_element = child_index < @elements.size - 1
  left_element = @elements[child_index]
  if child_index != @elements.size - 1
    right_element = @elements[child_index+1]
  end
  child_index += 1 if not_the_last_element && right_element > left_element

  return if @elements[index] >= left_element

  exchange(index, child_index)

  bubble_down(child_index)
end

end

puts "Input file:"
name = gets.chomp
maze = Maze.new(name)
puts "Output file:"
name = gets.chomp
maze.create_maze_solution(name)