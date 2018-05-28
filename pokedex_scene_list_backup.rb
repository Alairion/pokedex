#--------------------------------------------
#| Script par Alairion pour Pokémon Origins |
#| ~Scene Pokedex                           |
#--------------------------------------------

#$game_system.se_play($data_system.cancel_se)
#$game_system.se_play($data_system.decision_se)
#$game_system.se_play($data_system.buzzer_se)

module Pokedex

  class Scene_List
  
    class Slot
      attr_accessor :slot
      attr_accessor :caught
      attr_accessor :number
      attr_accessor :poke
      attr_accessor :selected
    
      def initialize(x, y)
        @slot = Sprite.new
        @slot.x = x
        @slot.y = y
        @slot.z = 50
        @slot.visible = false
        
        @caught = Sprite.new
        @caught.x = x + 15
        @caught.y = y + 10
        @caught.z = 50
        @caught.visible = false
        
        @number = Sprite.new
        @number.bitmap = Bitmap.new(48, 20)
        @number.bitmap.font.name = $fontface
        @number.bitmap.font.size = 20
        @number.bitmap.font.bold = true
        @number.bitmap.font.color = Color.new(255,255,255,255)
        @number.x = x + 31 #15 + 16(caught icon)
        @number.y = y + 8
        @number.z = 50
        @number.visible = false
        
        @poke = Sprite.new
        @poke.x = x + 15
        @poke.y = y + 28
        @poke.z = 50
        @poke.visible = false
        
        @selected = false
      end
      
    end
  
    def initialize(id = 1)
      @background = Sprite.new
      @background.bitmap = Bitmap.new("Graphics/Pokedex/pokedex_list_back.png")
      @background.x = 0
      @background.y = 0
      @background.z = 0
      
      @foreground = Sprite.new
      @foreground.bitmap = Bitmap.new("Graphics/Pokedex/pokedex_list_front.png")
      @foreground.x = 0
      @foreground.y = 0
      @foreground.z = 100
      
      @current_name = Sprite.new
      @current_name.bitmap = Bitmap.new(324, 36)
      @current_name.bitmap.font.name = $fontface
      @current_name.bitmap.font.size = $fontsize
      @current_name.bitmap.font.color = Color.new(255,255,255,255)
      @current_name.x = 160
      @current_name.y = 14
      @current_name.z = 100
      
      @list_cursor = Sprite.new #604; 84 <-> 604; 382
      @list_cursor.bitmap = Bitmap.new("Graphics/Pokedex/list_cursor.png")
      @list_cursor.x = 609
      @list_cursor.y = 84
      @list_cursor.z = 100
      
      @filed_slot = Bitmap.new("Graphics/Pokedex/filled_slot_nselect.png")
      @selected_slot = Bitmap.new("Graphics/Pokedex/slot_select.png")
      @caught_icon = Bitmap.new("Graphics/Pokedex/caught.png")
      
      $truncated = false if not $truncated
      
      if $truncated
        @pokemon_count = 0
        1.upto($data_pokemon.size - 1) do |i|
          @pokemon_count += 1 if $data_pokedex[i][0]
        end
      else
        @pokemon_count = $data_pokemon.size - 1
        ($data_pokemon.size - 1).downto(1) do |i|
          if $data_pokedex[i][0]
            @pokemon_count = i
            break
          end
        end
      end
        
      if $truncated #Id -> index in truncated mode
        index = 1
        1.upto(id - 1) do |i|
          index += 1 if $data_pokedex[i][0]
        end
        id = index
      end
      
      @current_index = [(id - 1) % 5, @pokemon_count - 1].min #Between 0 and 14: the actual selected slot by the player.
      
      
      if (@pokemon_count > 5) and (id + 5 > @pokemon_count)
        @current_index += 5
        if (@pokemon_count > 10) and (id + 10 > @pokemon_count)
          @current_index += 5
        end
      end
        
      @global_index = id - @current_index #The index in the top-left corner slot of the list.
      
      #[ 0 ][ 1 ][ 2 ][ 3 ][ 4 ]
      #[ 5 ][ 6 ][ 7 ][ 8 ][ 9 ]
      #[ 10][ 11][ 12][ 13][ 14]
      @slots = Array.new(15)
      @slots[0] = Slot.new(51, 79)
      @slots[1] = Slot.new(161, 79)
      @slots[2] = Slot.new(271, 79)
      @slots[3] = Slot.new(381, 79)
      @slots[4] = Slot.new(491, 79)
      @slots[5] = Slot.new(51, 193)
      @slots[6] = Slot.new(161, 193)
      @slots[7] = Slot.new(271, 193)
      @slots[8] = Slot.new(381, 193)
      @slots[9] = Slot.new(491, 193)
      @slots[10] = Slot.new(51, 307)
      @slots[11] = Slot.new(161, 307)
      @slots[12] = Slot.new(271, 307)
      @slots[13] = Slot.new(381, 307)
      @slots[14] = Slot.new(491, 307)
      
      @poke_bitmaps = Hash.new
      
      @slots.each_with_index do |slot, i|
        slot.caught.bitmap = @caught_icon
        refresh_slot_info(i, id_at(@global_index + i))
      end
      
      refresh_current_name
      refresh_slots
    end
    
    def main
      Graphics.transition
      
      loop do
        Graphics.update
        Input.update
        
        update
        
        if $scene != self
          break
        end
      end
      
      cleanup
      
      Graphics.freeze
    end

    def update
      if Input.trigger?(Input::X) #Touche A du clavier
        $game_system.se_play($data_system.decision_se)
        $truncated ? untruncate : truncate
      end
      
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        $truncated = false
        $scene = Scene_Intro.new
        return
      end
      
      if Input.trigger?(Input::C)
        if $data_pokedex[id_at(@global_index + @current_index)][0]
          $game_system.se_play($data_system.decision_se)
          $scene = Scene_Info.new(id_at(@global_index + @current_index))
          return
        end
      end
      
      if Input.repeat?(Input::RIGHT)
        move_right
        return
      end
      
      if Input.repeat?(Input::LEFT)
        move_left
        return
      end
      
      if Input.repeat?(Input::DOWN)
        move_down
        return
      end
      
      if Input.repeat?(Input::UP)
        move_up
        return
      end
      
      @list_cursor.y = 84 + (((id_at(@global_index).to_f / ($data_pokemon.size - 1).to_f) * 100.0) * 2.98).to_i
    end
    
    def truncate
      $truncated = true
      @pokemon_count = 0
      @global_index = 1
      @current_index = 0
      1.upto($data_pokemon.size - 1) do |i|
        @pokemon_count += 1 if $data_pokedex[i][0]
      end
      @slots.each_with_index do |slot, i|
        refresh_slot_info(i, id_at(@global_index + i))
      end
      refresh_slots
      refresh_current_name
    end 
    
    def untruncate
      $truncated = false
      @pokemon_count = $data_pokemon.size - 1
      ($data_pokemon.size - 1).downto(1) do |i|
        if $data_pokedex[i][0]
          @pokemon_count = i
          break
        end
      end
      @global_index = 1
      @current_index = 0
      @slots.each_with_index do |slot, i|
        refresh_slot_info(i, id_at(@global_index + i))
      end
      refresh_slots
      refresh_current_name
    end
    
    def id_at(index)
      if $truncated
        i = 0
        1.upto($data_pokemon.size - 1) do |j|
          i += 1 if $data_pokedex[j][0]
          if i == index
            return j
          end
        end
        return 10000 
      else
        return index
      end
    end
    
    def move_right
      if @global_index + @current_index < @pokemon_count
        if @current_index == 14
          @current_index = 10
          @global_index += 5
          0.upto(14) do |i|
            refresh_slot_info(i, id_at(@global_index + i))
          end
        else
          @current_index += 1
          refresh_slot_info(@current_index, id_at(@global_index + @current_index))
        end
        $game_system.se_play($data_system.decision_se)
        refresh_slots
        refresh_current_name
      else
        goto_top
        $game_system.se_play($data_system.decision_se)
      end
    end
    
    def move_left
      if @global_index + @current_index > 1
        if @current_index == 0
          @current_index = 4
          @global_index -= 5
          0.upto(14) do |i|
            refresh_slot_info(i, id_at(@global_index + i))
          end
        else
          @current_index -= 1
          refresh_slot_info(@current_index, id_at(@global_index + @current_index))
        end
        $game_system.se_play($data_system.decision_se)
        refresh_slots
        refresh_current_name
      else
        goto_bottom
        $game_system.se_play($data_system.decision_se)
      end
    end
    
    def move_down
      if @global_index + @current_index + 4 < @pokemon_count
        if @current_index > 9
          @global_index += 5
          0.upto(14) do |i|
            refresh_slot_info(i, id_at(@global_index + i))
          end
        else
          @current_index += 5
          refresh_slot_info(@current_index, id_at(@global_index + @current_index))
        end
        $game_system.se_play($data_system.decision_se)
        refresh_slots
        refresh_current_name
      else
        goto_top
        $game_system.se_play($data_system.decision_se)
      end
    end

    def move_up
      if @global_index + @current_index > 5
        if @current_index < 5
          @global_index -= 5
          0.upto(14) do |i|
            refresh_slot_info(i, id_at(@global_index + i))
          end
        else
          @current_index -= 5
          refresh_slot_info(@current_index, id_at(@global_index + @current_index))
        end
        $game_system.se_play($data_system.decision_se)
        refresh_slots
        refresh_current_name
      else
        goto_bottom
        $game_system.se_play($data_system.decision_se)
      end
    end
    
    def goto_bottom
      @current_index = [((@pokemon_count - 1) % 5) + 10, @pokemon_count - 1].min
      @global_index = @pokemon_count - @current_index
      0.upto(14) do |i|
        refresh_slot_info(i, id_at(@global_index + i))
      end
      refresh_slots
      refresh_current_name
    end
    
    def goto_top
      @current_index = 0
      @global_index = 1
      0.upto(14) do |i|
        refresh_slot_info(i, id_at(@global_index + i))
      end
      refresh_slots
      refresh_current_name
    end
    
    def refresh_current_name
      @current_name.bitmap.clear
      if $data_pokedex[id_at(@global_index + @current_index)][0] #Caught or seen
        @current_name.bitmap.draw_text(0, 0, @current_name.bitmap.width, @current_name.bitmap.height, POKEMON_S::Pokemon_Info.name(id_at(@global_index + @current_index)), 1)
      else
        @current_name.bitmap.draw_text(0, 0, @current_name.bitmap.width, @current_name.bitmap.height, "???", 1)
      end
    end
    
    def refresh_slot_info(slot_index, poke_id)
      if poke_id <= id_at(@pokemon_count)
        @slots[slot_index].number.bitmap.clear
        @slots[slot_index].number.bitmap.draw_text(0, 0, 48, 20, poke_id.to_s, 1)
        @slots[slot_index].number.visible = true
        
        if $data_pokedex[poke_id][1] #Caught
          @slots[slot_index].poke.bitmap = load_poke_bitmap(poke_id)
          @slots[slot_index].caught.visible = true
          @slots[slot_index].poke.visible = true
          @slots[slot_index].poke.opacity = 255
        elsif $data_pokedex[poke_id][0] #Seen
          @slots[slot_index].poke.bitmap = load_poke_bitmap(poke_id)
          @slots[slot_index].caught.visible = false
          @slots[slot_index].poke.visible = true
          @slots[slot_index].poke.opacity = 150
        else
          @slots[slot_index].caught.visible = false
          @slots[slot_index].poke.visible = false
        end
      else
        @slots[slot_index].number.visible = false
        @slots[slot_index].caught.visible = false
        @slots[slot_index].poke.visible = false
      end
    end
    
    def refresh_slots
      @slots.each_with_index do |slot, i|
        if i == @current_index
          slot.slot.bitmap = @selected_slot
          slot.slot.visible = true
          slot.selected = true
        elsif @global_index + i <= @pokemon_count
          if $data_pokedex[id_at(@global_index + i)][1] #Caught
            slot.slot.bitmap = @filed_slot
            slot.slot.visible = true
            slot.selected = false
          else
            slot.slot.visible = false
            slot.selected = false
          end
        else
          slot.slot.visible = false
          slot.selected = false
        end
      end
    end
    
    def load_poke_bitmap(poke_id)
      @poke_bitmaps[poke_id] = Bitmap.new("Graphics/Battlers/Icon/#{sprintf("%03d", poke_id)}") if @poke_bitmaps[poke_id] == nil
      return @poke_bitmaps[poke_id]
    end
    
    def cleanup
      @background.dispose
      @foreground.dispose
      @current_name.dispose
      @list_cursor.dispose
      @filed_slot.dispose
      @selected_slot.dispose
      @caught_icon.dispose
      @slots.each do |slot|
        slot.slot.dispose
        slot.caught.dispose
        slot.number.dispose
        slot.poke.dispose
      end
      @poke_bitmaps.each do |id, bmp|
        bmp.dispose
      end
      @poke_bitmaps.clear
    end
    
  end


end