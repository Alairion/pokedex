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

  #Looks like the Scene_List.
  class Scene_Moves
  
    class Info_Item #I use a struct to help me. This struct represents the "items" (a.k.a a move and its informations).
      attr_accessor :move_id
      attr_accessor :name
      attr_accessor :power
      attr_accessor :accuracy
      attr_accessor :pp
      attr_accessor :level
      attr_accessor :type
      attr_accessor :effect
    
      def initialize(y)
        @name = Sprite.new
        @name.x = 77
        @name.y = y
        @name.z = 100
        @name.bitmap = Bitmap.new(84, 20)
        @name.bitmap.font.name = $fontface
        @name.bitmap.font.size = $fontsizesmall
        @name.bitmap.font.color = Color.new(255, 255, 255)
        
        @power = Sprite.new
        @power.x = 161
        @power.y = y
        @power.z = 100
        @power.bitmap = Bitmap.new(80, 20)
        @power.bitmap.font.name = $fontface
        @power.bitmap.font.size = $fontsizesmall
        @power.bitmap.font.color = Color.new(255, 255, 255)
        
        @accuracy = Sprite.new
        @accuracy.x = 241
        @accuracy.y = y
        @accuracy.z = 100
        @accuracy.bitmap = Bitmap.new(80, 20)
        @accuracy.bitmap.font.name = $fontface
        @accuracy.bitmap.font.size = $fontsizesmall
        @accuracy.bitmap.font.color = Color.new(255, 255, 255)
        
        @pp = Sprite.new
        @pp.x = 321
        @pp.y = y
        @pp.z = 100
        @pp.bitmap = Bitmap.new(80, 20)
        @pp.bitmap.font.name = $fontface
        @pp.bitmap.font.size = $fontsizesmall
        @pp.bitmap.font.color = Color.new(255, 255, 255)
        
        @level = Sprite.new
        @level.x = 401
        @level.y = y
        @level.z = 100
        @level.bitmap = Bitmap.new(80, 20)
        @level.bitmap.font.name = $fontface
        @level.bitmap.font.size = $fontsizesmall
        @level.bitmap.font.color = Color.new(255, 255, 255)
        
        @type = Sprite.new
        @type.x = 496
        @type.y = y
        @type.z = 100
        @type.zoom_x = @type.zoom_y = 0.5
        
        @effect = Sprite.new
        @effect.x = 585
        @effect.y = y + 2
        @effect.z = 100
        @effect.zoom_x = @effect.zoom_y = 0.5
      end
      
    end
  
    def initialize(id)
      @poke_id = id
      @global_index = 0 #0 -> POKEMON_S::Pokemon_Info.skills_list(@poke_id).size - 14, the top move index.
      @index = 0 #0 -> 14
      @scrolling = false #If true: the user il scrolling on the pokemon's moves
      
      @background = Sprite.new
      @background.bitmap = Bitmap.new("Graphics/.../pokedex_info4.png")
      @background.x = 0
      @background.y = 0
      @background.z = 0
      
      @poke_icon = Sprite.new
      @poke_icon.x = 0
      @poke_icon.y = 119
      @poke_icon.z = 100
      
      @unknown_data = Sprite.new
      @unknown_data.bitmap = Bitmap.new("Graphics/.../message_box.png")
      @unknown_data.bitmap.font.name = $fontface
      @unknown_data.bitmap.font.size = $fontsize
      @unknown_data.bitmap.font.color = Color.new(60, 60, 60)
      @unknown_data.bitmap.draw_text(3, 11, 273, 53, "Données manquantes", 1) 
      @unknown_data.x = 206
      @unknown_data.y = 261
      @unknown_data.z = 100
      @unknown_data.visible = false
      
      @type_bitmaps = Array.new(18)
      1.upto(17) do |i|
        @type_bitmaps[i] = Bitmap.new("Graphics/.../T#{i}.png")
      end
      @categories_bitmaps = Array.new(3)
      @categories_bitmaps[0] = Bitmap.new("Graphics/.../skill_physical.png")
      @categories_bitmaps[1] = Bitmap.new("Graphics/.../skill_special.png")
      @categories_bitmaps[2] = Bitmap.new("Graphics/.../skill_other.png")
      
      @list = Array.new(15)
      0.upto(14) do |i|
        @list[i] = Info_Item.new(128 + (i * 24))
      end
      
      @abilities = Array.new(3)
      0.upto(2) do |i|
        @abilities[i] = Sprite.new
        @abilities[i].y = 79
        @abilities[i].z = 100
        @abilities[i].bitmap = Bitmap.new(200, 20)
        @abilities[i].bitmap.font.name = $fontface
        @abilities[i].bitmap.font.size = $fontsizesmall
        @abilities[i].bitmap.font.color = Color.new(255, 255, 255)
      end
      
      @cursor = Sprite.new
      @cursor.bitmap = Bitmap.new("Graphics/.../moves_cursor.png")
      @cursor.x = 69
      @cursor.y = 132
      @cursor.z = 100
      @cursor.visible = false
      
      refresh
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
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        if @scrolling and $data_pokedex[@poke_id][1]
          @scrolling = false #Stop scrolling
          @cursor.visible = false
        else
          $scene = Scene_List.new(@poke_id)
        end
        return
      end
      
      if Input.trigger?(Input::C)
        if not @scrolling and $data_pokedex[@poke_id][1]
          $game_system.se_play($data_system.decision_se)
          @scrolling = true #Start scrolling
          @cursor.x = 69
          @cursor.y = 132
          @cursor.visible = true
        else
          $game_system.se_play($data_system.buzzer_se)
        end
        return
      end
    
      if Input.trigger?(Input::RIGHT)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Stats.new(@poke_id)
        return
      end
      
      if Input.trigger?(Input::LEFT)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Size.new(@poke_id)
        return
      end
      
      if Input.repeat?(Input::DOWN)
        if @scrolling
          move_down
          return
        else
          (@poke_id + 1).upto($data_pokemon.size - 1) do |i|
            if $data_pokedex[i][0] or $data_pokedex[i][1]
              @poke_id = i
              @global_index = 0
              @index = 0
              $game_system.se_play($data_system.decision_se)
              refresh
              return
            end
          end
          $game_system.se_play($data_system.buzzer_se)
        end
        return
      end
      
      if Input.repeat?(Input::UP)
        if @scrolling
          move_up
          return
        else
          (@poke_id - 1).downto(1) do |i|
            if $data_pokedex[i][0] or $data_pokedex[i][1]
              @poke_id = i
              @global_index = 0
              @index = 0
              $game_system.se_play($data_system.decision_se)
              refresh
              return
            end
          end
          $game_system.se_play($data_system.buzzer_se)
        end
      end
    end
      
    def move_down
      if @global_index + @index < POKEMON_S::Pokemon_Info.skills_list(@poke_id).size / 2 - 1 #We can move down
        $game_system.se_play($data_system.decision_se)
        if @index < 13 #Just move the cursor
          @cursor.y += 24
          @index += 1
        else #Move the informations
          @global_index += 1
          if @global_index + @index == POKEMON_S::Pokemon_Info.skills_list(@poke_id).size / 2 - 1
            0.upto(14) do |i|
              hide_slot(i)
            end
            poke_skills = POKEMON_S::Pokemon_Info.skills_list(@poke_id)
            0.upto([poke_skills.size / 2 - 1 - @global_index, 14].min) do |i|
              refresh_slot(i, POKEMON_S::Skill_Info.id(poke_skills[(i + @global_index) * 2 + 1]), poke_skills[(i + @global_index) * 2])
            end
          else
            0.upto(14) do |i|
              hide_slot(i)
            end
            poke_skills = POKEMON_S::Pokemon_Info.skills_list(@poke_id)
            0.upto([poke_skills.size / 2 - 1 - @global_index, 14].min) do |i|
              refresh_slot(i, POKEMON_S::Skill_Info.id(poke_skills[(i + @global_index) * 2 + 1]), poke_skills[(i + @global_index) * 2])
            end
          end
        end
      else
        $game_system.se_play($data_system.buzzer_se)
      end
    end
    
    def move_up
      if @global_index + @index > 0 #We can move up
        $game_system.se_play($data_system.decision_se)
        if @index > 0 #Just move the cursor
          @cursor.y -= 24
          @index -= 1
        else #Move the informations
          @global_index -= 1
          0.upto(14) do |i|
            hide_slot(i)
          end
          poke_skills = POKEMON_S::Pokemon_Info.skills_list(@poke_id)
          0.upto([poke_skills.size / 2 - 1 - @global_index, 14].min) do |i|
            refresh_slot(i, POKEMON_S::Skill_Info.id(poke_skills[(i + @global_index) * 2 + 1]), poke_skills[(i + @global_index) * 2])
          end
        end
      else
        $game_system.se_play($data_system.buzzer_se)
      end
    end
    
  def refresh
      if $data_pokedex[@poke_id][1]
        abilities = POKEMON_S::Pokemon_Info.ability_list(@poke_id).clone
        abilities.push($data_ability[$data_hidden_ability[@poke_id][1]][0]) if $data_hidden_ability[@poke_id] != nil
        refresh_abilities_slots(abilities, $data_hidden_ability[@poke_id] != nil)
        
        poke_skills = POKEMON_S::Pokemon_Info.skills_list(@poke_id)
        0.upto(14) do |i|
          hide_slot(i)
        end
        0.upto([poke_skills.size / 2 - 1, 14].min) do |i|
          refresh_slot(i, POKEMON_S::Skill_Info.id(poke_skills[i * 2 + 1]), poke_skills[i * 2])
        end
        @unknown_data.visible = false
      else
        0.upto(14) do |i|
          hide_slot(i)
        end
        refresh_abilities_slots(["???"], false)
        @unknown_data.visible = true
      end
      @poke_icon.bitmap.dispose if @poke_icon.bitmap != nil
      @poke_icon.bitmap = Bitmap.new("Graphics/Battlers/Icon/#{sprintf("%03d", @poke_id)}")
    end
    
    def refresh_abilities_slots(abilities_list, hidden)
      0.upto(2) do |i|
        @abilities[i].visible = false
        @abilities[i].bitmap.clear
      end
        
      if $data_pokedex[@poke_id][1]
        if abilities_list.size == 1
          @abilities[0].visible = true
          @abilities[0].x = 221
          @abilities[0].bitmap.font.color = Color.new(0, 0, 0, 255)
          @abilities[0].bitmap.draw_text(0, 0, 200, 20, abilities_list[0], 1)
        elsif abilities_list.size == 2
          @abilities[0].visible = true
          @abilities[0].x = 121
          @abilities[0].bitmap.font.color = Color.new(0, 0, 0, 255)
          @abilities[0].bitmap.draw_text(0, 0, 200, 20, abilities_list[0], 1)
          @abilities[1].visible = true
          @abilities[1].x = 321
          @abilities[1].bitmap.font.color = hidden ? @abilities[abilities_list.size - 1].bitmap.font.color = Color.new(255, 50, 50, 255) : Color.new(0, 0, 0, 255)
          @abilities[1].bitmap.draw_text(0, 0, 200, 20, abilities_list[1], 1)
        elsif abilities_list.size == 3
          @abilities[0].visible = true
          @abilities[0].x = 21
          @abilities[0].bitmap.font.color = Color.new(0, 0, 0, 255)
          @abilities[0].bitmap.draw_text(0, 0, 200, 20, abilities_list[0], 1)
          @abilities[1].visible = true
          @abilities[1].x = 221
          @abilities[1].bitmap.font.color = Color.new(0, 0, 0, 255)
          @abilities[1].bitmap.draw_text(0, 0, 200, 20, abilities_list[1], 1)
          @abilities[2].visible = true
          @abilities[2].x = 421
          @abilities[2].bitmap.font.color = hidden ? @abilities[abilities_list.size - 1].bitmap.font.color = Color.new(255, 0, 0, 255) : Color.new(0, 0, 0, 255)
          @abilities[2].bitmap.draw_text(0, 0, 200, 20, abilities_list[2], 1)
        end
      end
    end
    
    def refresh_slot(slot_index, move_id, learn_level)
      @list[slot_index].name.bitmap.draw_text(0, 0, 84, 20, POKEMON_S::Skill_Info.name(move_id), 1)
      if POKEMON_S::Skill_Info.base_damage(move_id) == 0
        @list[slot_index].power.bitmap.draw_text(0, 0, 80, 20, "-", 1)
      else
        @list[slot_index].power.bitmap.draw_text(0, 0, 80, 20, "#{POKEMON_S::Skill_Info.base_damage(move_id)}", 1)
      end
      @list[slot_index].accuracy.bitmap.draw_text(0, 0, 80, 20, "#{POKEMON_S::Skill_Info.accuracy(move_id)}", 1)
      @list[slot_index].pp.bitmap.draw_text(0, 0, 80, 20, "#{POKEMON_S::Skill_Info.pp(move_id)}", 1)
      if learn_level == 1
        @list[slot_index].level.bitmap.draw_text(0, 0, 80, 20, "Innée", 1)
      elsif learn_level > 0
        @list[slot_index].level.bitmap.draw_text(0, 0, 80, 20, "#{learn_level}", 1)
      end
      @list[slot_index].type.bitmap = @type_bitmaps[POKEMON_S::Skill_Info.type(move_id)]
      @list[slot_index].type.visible = true
      @list[slot_index].effect.bitmap = @categories_bitmaps[POKEMON_S::Skill_Info.kind(move_id)]
      @list[slot_index].effect.visible = true
    end
    
    def hide_slot(slot_index)
      @list[slot_index].name.bitmap.clear
      @list[slot_index].power.bitmap.clear
      @list[slot_index].accuracy.bitmap.clear
      @list[slot_index].pp.bitmap.clear
      @list[slot_index].level.bitmap.clear
      @list[slot_index].type.visible = false
      @list[slot_index].effect.visible = false
    end
    
    def cleanup
      @background.dispose
      @poke_icon.dispose
      @unknown_data.dispose
      
      1.upto(17) do |i|
        @type_bitmaps[i].dispose
      end
      @type_bitmaps.clear
      0.upto(2) do |i|
        @categories_bitmaps[i].dispose
      end
      @categories_bitmaps.clear
      0.upto(14) do |i|
        @list[i].name.dispose
        @list[i].power.dispose
        @list[i].accuracy.dispose
        @list[i].pp.dispose
        @list[i].level.dispose
        @list[i].type.dispose
        @list[i].effect.dispose
      end
      @list.clear
      0.upto(2) do |i|
        @abilities[i].dispose
      end
      @abilities.clear
      
      @cursor.dispose
    end
    
  end

end