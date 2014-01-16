class Player

  def initialize
    @max_health = 20
    @min_health = 10
    @is_full_recover = true
    @health_level_last_turn = 20
    @directions = [:forward, :backward, :right, :left]
    @enemy_directions = []
    @most_close_enemies_are_binded = false
    @warrior = nil
    @is_resting = false
    @found_captives = false
    @is_a_unit_in_front = false
    @are_boombs_active = true
  end

  def play_turn(warrior)

    @warrior = warrior

    clean_the_room!

    bind_close_enemies! unless @most_close_enemies_are_binded && @is_a_unit_in_front

    rest! if (needs_rest? && !im_being_attack?)

    attack_enemies_binded! if @most_close_enemies_are_binded && !@is_resting

    rescue_captives! if !@is_resting && @enemy_directions.empty?

  end

  def clean_the_room!
    spaces_with_units = @warrior.listen 
    direction = @warrior.direction_of_stairs
    spaces_with_units.each do |unit|
      if !@warrior.feel(@warrior.direction_of(unit)).empty?
        @is_a_unit_in_front = true    
        break
      else
        if @warrior.feel(@warrior.direction_of(unit)).stairs? 
          direction = go_around_stairs!
        else
          direction = @warrior.direction_of(unit)
        end
         @is_a_unit_in_front = false  
         break
      end
    end
    @warrior.walk!(direction)  if !needs_rest? && !@is_a_unit_in_front
  end

  def go_around_stairs!
    @directions.each do |direction|
      if @warrior.feel(direction).empty? && !@warrior.feel(direction).stairs?
        direction
        break
      end
    end
  end

  def rescue_captives!
    @directions.each do |direction|
      space = @warrior.feel(direction)
      if  space.captive? 
        @warrior.rescue!(direction)
        @found_captives = true
        break
      else
        @found_captives = false
      end
    end
    @found_captives
  end

  def bind_close_enemies!
    directions_chequed = 0
    @directions.each do |direction|
      directions_chequed += 1
      space = @warrior.feel(direction)
      if  space.enemy? 
        @enemy_directions << direction
        @warrior.bind!(direction)
        break
      end
    end
    if !@enemy_directions.empty? && directions_chequed == 4
      @most_close_enemies_are_binded = true 
    end
  end

  def attack_enemies_binded!
    if !@warrior.feel(@enemy_directions.last).empty?
      @warrior.attack!(@enemy_directions.last)
    else
      @enemy_directions.pop
      if @enemy_directions.empty?
        @most_close_enemies_are_binded = false
      end
    end
  end

  def needs_rest?
    if @warrior.health < @min_health || !@is_full_recover
      @is_full_recover = false
      true
    else
      false
    end
  end

  def rest!
    if @warrior.health < @max_health
      @warrior.rest!
      @is_resting = true
    else
      @is_resting = false
      @is_full_recover = true
      @health_level_last_turn  = @warrior.health
    end
  end

  def im_being_attack?
    if  @warrior.health < @health_level_last_turn
      @health_level_last_turn = @warrior.health
      true
    else
      false
    end
  end

end
