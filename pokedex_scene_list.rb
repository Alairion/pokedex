#--------------------------------------------
#| Script par Alairion pour Pokémon Origins |
#| ~Scene Pokedex                           |
#| Ces scripts sont rendus publiques à but  |
#| "pédagogique" et personne n'est autorisé |
#| à l'utiliser tel quel. Vous pouvez par   |
#| contre vous en inspirer de la structure  |
#| et des algorithmes utilisés.             |
#| Noter aussi que ces scripts ont été      |
#| réalisé sous PSP 0.8 et ne sont          |
#| directement fonctionnels.                |
#| (Pas les ressources graphiques notamment)|
#--------------------------------------------

#--------------------------------------------
#| Script by Alairion for Pokémon Origins   |
#| ~ Pokedex Scene                          |
#| These scripts are made public for        |
#| "educational" purpose and nobody is      |
#| allowed to use it as is. You can inspire |
#| yourself with the structure / algorithms |
#| used.                                    |
#| Also note that these scripts were        |    
#| realized under PSP 0.8 and don't work.   |
#| (Missing graphics ressources, ...)       |
#--------------------------------------------

module Pokedex

  class Scene_List
  
    #This class represent a slot of the list. 
    #It contains the pokemon srpite, his pokédex number, the pokédex status (caught/seen) and a boolean to know if the player is on this one.
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
      @background.bitmap = Bitmap.new("Graphics/.../pokedex_list_back.png")
      @background.x = 0
      @background.y = 0
      @background.z = 0
      
      @foreground = Sprite.new
      @foreground.bitmap = Bitmap.new("Graphics/.../pokedex_list_front.png")
      @foreground.x = 0
      @foreground.y = 0
      @foreground.z = 100
      
      @current_name = Sprite.new #The name of the Pokémon selected by the player.
      @current_name.bitmap = Bitmap.new(324, 36)
      @current_name.bitmap.font.name = $fontface
      @current_name.bitmap.font.size = $fontsize
      @current_name.bitmap.font.color = Color.new(255,255,255,255)
      @current_name.x = 160
      @current_name.y = 14
      @current_name.z = 100
      
      @list_cursor = Sprite.new #[604, 84] <-> [604, 382] #The right hand cursor with indicates where is the selected Pokémon in the list.
      @list_cursor.bitmap = Bitmap.new("Graphics/.../list_cursor.png")
      @list_cursor.x = 609
      @list_cursor.y = 84
      @list_cursor.z = 100
      
      #Preload bitmaps used very often, because HDD are very slow.
      @filed_slot = Bitmap.new("Graphics/.../filled_slot_nselect.png")
      @selected_slot = Bitmap.new("Graphics/.../slot_select.png")
      @caught_icon = Bitmap.new("Graphics/.../caught.png")
      
      $truncated = false if not $truncated #Handle the truncated mod (Only seen and caught Pokémon are displayed)
      
      if $truncated
        @pokemon_count = 0 #The maximum number of slots. The list ends at the bigger id of all the seew or caught Pokémon.
        1.upto($data_pokemon.size - 1) do |i| #Only count seen or caught Pokémon (truncated)
          @pokemon_count += 1 if $data_pokedex[i][0]
        end
      else
        @pokemon_count = $data_pokemon.size - 1
        ($data_pokemon.size - 1).downto(1) do |i| #Stop the list a the bigger id of the all the seew or caught Pokémon.
          if $data_pokedex[i][0]
            @pokemon_count = i
            break
          end
        end
      end
        
      if $truncated #Convert id to index in truncated mode
        index = 1
        1.upto(id - 1) do |i|
          index += 1 if $data_pokedex[i][0]
        end
        id = index
      end
      
      @current_index = [(id - 1) % 5, @pokemon_count - 1].min #Between 0 and 14: the actual selected slot by the player. "min" prevents from bugs when @pokemon_count < 5
      
      
      if (@pokemon_count > 5) and (id + 5 > @pokemon_count) #Select the slot of the current Pokémon if id != 1. Prevents from bugs when @pokemon_count < 14
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
      0.upto(14) do |i|
        @slots[i] = Slot.new(51 + ((i % 5) * 110), 79 + ((i / 5) * 114))
      end
      
      @poke_bitmaps = Hash.new #The key of my script. When tou move inside the list, Pokémon's sprites are loaded only once.
      
      @slots.each_with_index do |slot, i| #Refresh everything (End initialization)
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
      if Input.trigger?(Input::X) #Switch mode
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
      
      @list_cursor.y = 84 + (((id_at(@global_index).to_f / ($data_pokemon.size - 1).to_f) * 100.0) * 2.98).to_i #Refresh cursor position
    end
    
    def truncate #Switch to truncated mode (Similar to initialize in truncated mode)
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
    
    def untruncate #Leave truncated mode (Similar to initialize in not truncated mode)
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
    
    def id_at(index) #Compute the id at the given index. This function is used to make most functions available in both modes.
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
    
    def move_right #Moves on right, just refresh display
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
        $game_system.se_play($data_system.cursor_se)
        refresh_slots
        refresh_current_name
      else
        goto_top
        $game_system.se_play($data_system.decision_se)
      end
    end
    
    def move_left #Moves on left, just refresh display
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
        $game_system.se_play($data_system.cursor_se)
        refresh_slots
        refresh_current_name
      else
        goto_bottom
        $game_system.se_play($data_system.decision_se)
      end
    end
    
    def move_down #Moves on down, just refresh display
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
        $game_system.se_play($data_system.cursor_se)
        refresh_slots
        refresh_current_name
      else
        goto_top
        $game_system.se_play($data_system.decision_se)
      end
    end

    def move_up #Moves on up, just refresh display
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
        $game_system.se_play($data_system.cursor_se)
        refresh_slots
        refresh_current_name
      else
        goto_bottom
        $game_system.se_play($data_system.decision_se)
      end
    end
    
    def goto_bottom #Go to the last Pokémon, just refresh display
      @current_index = [((@pokemon_count - 1) % 5) + 10, @pokemon_count - 1].min
      @global_index = @pokemon_count - @current_index
      0.upto(14) do |i|
        refresh_slot_info(i, id_at(@global_index + i))
      end
      refresh_slots
      refresh_current_name
    end
    
    def goto_top #Go to the first Pokémon, just refresh display
      @current_index = 0
      @global_index = 1
      0.upto(14) do |i|
        refresh_slot_info(i, id_at(@global_index + i))
      end
      refresh_slots
      refresh_current_name
    end
    
    def refresh_current_name #Just refresh display
      @current_name.bitmap.clear
      if $data_pokedex[id_at(@global_index + @current_index)][0] #Caught or seen
        @current_name.bitmap.draw_text(0, 0, @current_name.bitmap.width, @current_name.bitmap.height, POKEMON_S::Pokemon_Info.name(id_at(@global_index + @current_index)), 1)
      else
        @current_name.bitmap.draw_text(0, 0, @current_name.bitmap.width, @current_name.bitmap.height, "???", 1)
      end
    end
    
    def refresh_slot_info(slot_index, poke_id) #Just refresh display of each slots
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
    
    def refresh_slots  #Just refresh display of the state of each slots (selected, visible, ...)
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
          slot.slot.visible = false #Note that i don't delete the sprite, so I don't have to recreate it.
          slot.selected = false
        end
      end
    end
    
    def load_poke_bitmap(poke_id) #Return a bitmap. Only load unloaded bitmaps.
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