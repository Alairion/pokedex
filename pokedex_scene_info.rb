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

  class Scene_Info
  
    def initialize(id, mode = "pkdx")
      @poke_id = id
      @mode = mode
      @_break = false
      
      @background = Sprite.new
      @background.bitmap = Bitmap.new("Graphics/.../pokedex_info1.png")
      @background.x = 0
      @background.y = 0
      @background.z = 100
      
      @pokemon_name = Sprite.new
      @pokemon_name.x = 3
      @pokemon_name.y = 55
      @pokemon_name.z = 100
      @pokemon_name.bitmap = Bitmap.new(318, 40) 
      @pokemon_name.bitmap.font.name = $fontface
      @pokemon_name.bitmap.font.size = $fontsize
      @pokemon_name.bitmap.font.color = Color.new(255, 255, 255)
      
      @pokemon_sprite = Sprite.new
      @pokemon_sprite.x = 68
      @pokemon_sprite.y = 74
      @pokemon_sprite.z = 100
      
      @pokemon_family = Sprite.new
      @pokemon_family.x = 322
      @pokemon_family.y = 55
      @pokemon_family.z = 100
      @pokemon_family.bitmap = Bitmap.new(317, 40) 
      @pokemon_family.bitmap.font.name = $fontface  
      @pokemon_family.bitmap.font.size = $fontsize
      @pokemon_family.bitmap.font.color = Color.new(60, 60, 60)
      
      @pokemon_descr = Sprite.new
      @pokemon_descr.x = 23
      @pokemon_descr.y = 260
      @pokemon_descr.z = 100
      @pokemon_descr.bitmap = Bitmap.new(596, 155) 
      @pokemon_descr.bitmap.font.name = $fontface  
      @pokemon_descr.bitmap.font.size = $fontsize
      @pokemon_descr.bitmap.font.color = Color.new(60, 60, 60)
      
      @pokemon_info = Sprite.new
      @pokemon_info.x = 322
      @pokemon_info.y = 102
      @pokemon_info.z = 100
      @pokemon_info.bitmap = Bitmap.new(317, 152) 
      @pokemon_info.bitmap.font.name = $fontface  
      @pokemon_info.bitmap.font.size = $fontsize
      @pokemon_info.bitmap.font.color = Color.new(60, 60, 60)
      
      @pokemon_type1 = Sprite.new
      @pokemon_type1.x = 431
      @pokemon_type1.y = 108
      @pokemon_type1.z = 100
      
      @pokemon_type2 = Sprite.new
      @pokemon_type2.x = 535
      @pokemon_type2.y = 108
      @pokemon_type2.z = 100
      
      @type_bitmaps = Array.new(18) #preload types bitmaps
      1.upto(17) do |i|
        @type_bitmaps[i] = Bitmap.new("Graphics/.../T#{i}.png")
      end
      
      @unknown_data = Sprite.new
      @unknown_data.bitmap = Bitmap.new("Graphics/.../message_box.png")
      @unknown_data.bitmap.font.name = $fontface
      @unknown_data.bitmap.font.size = $fontsize
      @unknown_data.bitmap.font.color = Color.new(60, 60, 60)
      @unknown_data.bitmap.draw_text(3, 11, 273, 53, "Données manquantes", 1) 
      @unknown_data.x = 175
      @unknown_data.y = 296
      @unknown_data.z = 100
      @unknown_data.visible = false
      
      refresh
    end
    
    def main
      Graphics.transition
      Audio.se_play("Audio/SE/Cries/" + sprintf("%03d", @poke_id) + "Cry.wav")
      
      loop do
        Graphics.update
        Input.update
        
        update
        
        if (@mode != "battle" and $scene != self) or @_break
          break
        end
      end
      
      cleanup
      
      Graphics.freeze
    end

    def update
      case @mode
        when "pkdx"
          if Input.trigger?(Input::B)
            $game_system.se_play($data_system.cancel_se)
            $scene = Scene_List.new(@poke_id)
            return
          end
      
          if Input.trigger?(Input::C)
            Audio.se_play("Audio/SE/Cries/" + sprintf("%03d", @poke_id) + "Cry.wav")
            return
          end
      
          if Input.trigger?(Input::RIGHT)
            $game_system.se_play($data_system.decision_se)
            $scene = Scene_Zone.new(@poke_id)
            return
          end
      
          if Input.repeat?(Input::DOWN)
            (@poke_id + 1).upto($data_pokemon.size - 1) do |i|
              if $data_pokedex[i][0] or $data_pokedex[i][1]
                @poke_id = i
                $game_system.se_play($data_system.decision_se)
                refresh
                Audio.se_play("Audio/SE/Cries/" + sprintf("%03d", @poke_id) + "Cry.wav")
                return
              end
            end
            $game_system.se_play($data_system.buzzer_se)
          end
      
          if Input.repeat?(Input::UP)
            (@poke_id - 1).downto(1) do |i|
              if $data_pokedex[i][0] or $data_pokedex[i][1]
                @poke_id = i
                $game_system.se_play($data_system.decision_se)
                refresh
                Audio.se_play("Audio/SE/Cries/" + sprintf("%03d", @poke_id) + "Cry.wav")
                return
              end
            end
            $game_system.se_play($data_system.buzzer_se)
          end
          
        when "map"
          if Input.trigger?(Input::B) or Input.trigger?(Input::C) 
            $game_system.se_play($data_system.cancel_se)  
            Graphics.freeze  
            $scene = Scene_Map.new  
            return  
          end           
          
          if Input.trigger?(Input::DOWN) or Input.trigger?(Input::UP) or Input.trigger?(Input::LEFT) or Input.trigger?(Input::RIGHT)
            $game_system.se_play($data_system.buzzer_se)  
          end  
              
        when "battle"  
          if Input.trigger?(Input::B) or Input.trigger?(Input::C)
            $game_system.se_play($data_system.cancel_se)  
            Graphics.freeze  
            @_break = true  
          end           
          
          if Input.trigger?(Input::DOWN) or Input.trigger?(Input::UP) or Input.trigger?(Input::LEFT) or Input.trigger?(Input::RIGHT)
            $game_system.se_play($data_system.buzzer_se)  
          end  
        end
    end
      
    
    def refresh
      Graphics.freeze
      
      @pokemon_name.bitmap.clear
      @pokemon_name.bitmap.draw_text(20, 0, 318, 40, "N.#{sprintf("%03d", @poke_id)} : " + POKEMON_S::Pokemon_Info.name(@poke_id)) 
      
      @pokemon_sprite.bitmap.dispose if @pokemon_sprite.bitmap != nil
      @pokemon_sprite.bitmap = Bitmap.new("Graphics/Battlers/Front_Male/#{sprintf("%03d", @poke_id)}.png")
      
      if $data_pokedex[@poke_id][1] #Caught
        @pokemon_family.bitmap.clear
        @pokemon_family.bitmap.draw_text(20, 0, 317, 40, "Pokémon #{POKEMON_S::Pokemon_Info.spec(@poke_id)}") 
        
        #A way to auto wrap sentenses. (Probably the best with only RGSS)
        descr_words = POKEMON_S::Pokemon_Info.descr(@poke_id).split
        descr_lines = []
        i = 0
        while i < descr_words.size
          new_line = ""
          while i < descr_words.size and @pokemon_descr.bitmap.text_size(new_line + descr_words[i]).width < 550
            new_line = new_line + descr_words[i]
            new_line = new_line + ' '
            i += 1
          end
          descr_lines[descr_lines.size] = new_line
        end
        @pokemon_descr.bitmap.clear
        descr_lines.each_with_index do |line, i|
          @pokemon_descr.bitmap.draw_text(20, 10 + (i * 30), 556, 30, line)
        end
      
        @pokemon_info.bitmap.clear
        @pokemon_info.bitmap.draw_text(0, 0, 100, 48, "Type :", 2) 
        @pokemon_info.bitmap.draw_text(0, 53, 100, 48, "Taille :", 2)
        @pokemon_info.bitmap.draw_text(0, 105, 100, 48, "Poids :", 2)
        @pokemon_info.bitmap.draw_text(110, 53, 206, 48, "#{POKEMON_S::Pokemon_Info.height(@poke_id)}", 1)
        @pokemon_info.bitmap.draw_text(110, 105, 206, 48, "#{POKEMON_S::Pokemon_Info.weight(@poke_id)}", 1)
        
        if POKEMON_S::Pokemon_Info.type2(@poke_id) != 0
          @pokemon_type1.bitmap = @type_bitmaps[POKEMON_S::Pokemon_Info.type1(@poke_id)]
          @pokemon_type1.visible = true
          @pokemon_type1.x = 431
          @pokemon_type2.bitmap = @type_bitmaps[POKEMON_S::Pokemon_Info.type2(@poke_id)]
          @pokemon_type2.visible = true
          @pokemon_type2.x = 535
        else
          @pokemon_type1.bitmap = @type_bitmaps[POKEMON_S::Pokemon_Info.type1(@poke_id)]
          @pokemon_type1.visible = true
          @pokemon_type1.x = 483
          @pokemon_type2.visible = false
        end
        @unknown_data.visible = false
      else #Seen
        @pokemon_family.bitmap.clear
        @pokemon_family.bitmap.draw_text(20, 0, 317, 40, "Pokémon ???") 
        
        @pokemon_descr.bitmap.clear
      
        @pokemon_info.bitmap.clear
        @pokemon_info.bitmap.draw_text(0, 0, 100, 48, "Type :", 2) 
        @pokemon_info.bitmap.draw_text(0, 53, 100, 48, "Taille :", 2)
        @pokemon_info.bitmap.draw_text(0, 105, 100, 48, "Poids :", 2)
        @pokemon_info.bitmap.draw_text(110, 0, 206, 45, "???", 1)
        @pokemon_info.bitmap.draw_text(110, 53, 206, 48, "???", 1)
        @pokemon_info.bitmap.draw_text(110, 105, 206, 48, "???", 1)
        
        @pokemon_type1.visible = false
        @pokemon_type2.visible = false
        @unknown_data.visible = true
      end
      
      Graphics.transition
    end
    
    def cleanup
      @background.dispose
      @pokemon_name.dispose
      @pokemon_sprite.dispose
      @pokemon_family.dispose
      @pokemon_descr.dispose
      @pokemon_info.dispose
      @pokemon_type1.dispose
      @pokemon_type2.dispose
      1.upto(17) do |i|
        @type_bitmaps[i].dispose
      end
      @type_bitmaps.clear
      @unknown_data.dispose
    end
    
  end

end