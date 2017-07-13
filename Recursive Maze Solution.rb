  def recursive_solve(position = self.finish)
    if position == self.start
      return true
    end
    if self[position] != " "
      return false
    else
      self[position] = "X"
    end
      return true if recursive_solve(left_from(position))
      return true if recursive_solve(down_from(position))
      return true if recursive_solve(up_from(position))
      return true if recursive_solve(right_from(position))
      self[position] = " "
      return false
  end
