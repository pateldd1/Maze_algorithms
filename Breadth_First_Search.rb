class Maze
  attr_accessor :grid, :sol, :counter, :path_length, :start, :finish
  def initialize(maze_file)
    @grid = File.readlines(maze_file).map {|line| line.chomp.chars}
    @sol = File.readlines(maze_file).map {|line| line.chomp.chars}
    @counter = 0
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
  
  def all_around(pos)
    [up_from(pos),left_from(pos),right_from(pos),down_from(pos)]
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
  
  def number_all_positions(start)
    from_positions = [start.dup]
    temp_array = []
    open_positions = []
    until !(from_positions & self.all_around(self.start)).empty?
      @counter += 1
      from_positions.each do |pos|
        open_positions = all_around(pos).select {|around_position| self[around_position] == " "}
        temp_array += open_positions
        if !open_positions.empty?
          open_positions.each do |position|
            self[position]= @counter
            # File.open("solution1.txt","a") do |f|
            #   self.grid.each do |line|
            #     z = line.map do |letter|
            #       if letter.to_i > 0
            #         "#"
            #       else
            #         letter
            #       end
            #     end.join
            #   f.puts z
            # end
            # end
          end
        end
      end
      from_positions = temp_array.dup
      temp_array = []
    end
  end
  
  def navigate_back_one(pos,number)
    positions_around = self.all_around(pos)
    to = positions_around.find {|place| self[place] == number}
    row,col = to
    @sol[row][col]= "X"
    return to
  end
  
  def navigate(finish)
    pos = finish
    @path_length = @counter
    until @counter == 0
      pos = navigate_back_one(pos,@counter)
      @counter -= 1
    end
  end
  
  def create_maze_solution(output_file)
    s = Time.now
    self.calculate_start_and_finish
    # self.calculate_finish
    #numbers from the end to the start and then navigates back to the end
    self.number_all_positions(self.finish)
    t = Time.now
    self.navigate(self.start)
    File.open(output_file,"w") do |f|
      self.sol.each {|line| f.puts line.join}
        # self.grid.each do |line|
        #         z = line.map do |letter|
        #           if letter.to_i > 0
        #             "#"
        #           else
        #             letter
        #           end
        #         end.join
        #       f.puts z
        #     end
      f.puts ""
      f.puts "Shortest Path length is #{@path_length}"
      fin = Time.now
      f.puts "Took #{(fin-s)*1000} ms to solve and #{1000*(fin-t)} ms to make path"
    end
  end
end

puts "Input file:"
name = gets.chomp
maze = Maze.new(name)
puts "Output file:"
name = gets.chomp
maze.create_maze_solution(name)
