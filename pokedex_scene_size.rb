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

   #Just some display tasks. Nothing more to say. You can check out the way i resize the sprites.
  class Scene_Size
  
    def initialize(id)
      @poke_id = id
      
      @background = Sprite.new
      @background.bitmap = Bitmap.new("Graphics/Pokedex/pokedex_info3.png")
      @background.x = 0
      @background.y = 0
      @background.z = 0
      
      @player_sprite = Sprite.new
      @player_sprite.x = 334
      @player_sprite.y = 0
      @player_sprite.z = 100
      @player_sprite.color = Color.new(0, 0, 0, 255)  
      
      @info_text = Sprite.new
      @info_text.x = 55
      @info_text.y = 349
      @info_text.z = 100
      @info_text.bitmap = Bitmap.new(532, 84) 
      @info_text.bitmap.font.name = $fontface
      @info_text.bitmap.font.size = $fontsize
      @info_text.bitmap.font.color = Color.new(60, 60, 60)
      @info_text.bitmap.draw_text(0, 0, 532, 84, "Taille comparé à #{POKEMON_S::Player.name}", 1) 
      
      @unknown_data = Sprite.new
      @unknown_data.bitmap = Bitmap.new("Graphics/Pokedex/message_box.png")
      @unknown_data.bitmap.font.name = $fontface
      @unknown_data.bitmap.font.size = $fontsize
      @unknown_data.bitmap.font.color = Color.new(60, 60, 60)
      @unknown_data.bitmap.draw_text(3, 11, 273, 53, "Données manquantes", 1) 
      @unknown_data.x = 173
      @unknown_data.y = 134
      @unknown_data.z = 100
      @unknown_data.visible = false
      
      @player_sprite.bitmap = Bitmap.new("...")
      
      @poke_sprite = Sprite.new
      @poke_sprite.x = 0
      @poke_sprite.y = 0
      @poke_sprite.z = 100
      @poke_sprite.color = Color.new(0, 0, 0, 255)  
      
      refresh_trainer_size
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
        $scene = Scene_List.new(@poke_id)
        return
      end
      
      if Input.trigger?(Input::RIGHT)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Moves.new(@poke_id)
        return
      end
      
      if Input.trigger?(Input::LEFT)
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
            return
          end
        end
        $game_system.se_play($data_system.buzzer_se)
      end
    end
    
    def refresh_trainer_size
      i = 0
      j = 0
      while @player_sprite.bitmap.get_pixel(i,j).alpha == 0
        i += 1
        if i > @player_sprite.bitmap.width
          i = 0
          j += 1
        end
      end
      top_pixel = j
        
      i = 0
      j = @player_sprite.bitmap.height
      while @player_sprite.bitmap.get_pixel(i, j).alpha == 0
        i += 1
        if i > @player_sprite.bitmap.width
          i = 0
          j -= 1
        end
      end
      down_pixel = j
      
      @player_sprite_size = [down_pixel.to_f - top_pixel.to_f, down_pixel.to_f]
    end
    
    def refresh_poke_size
      i = 0
      j = 0
      while @poke_sprite.bitmap.get_pixel(i,j).alpha == 0
        i += 1
        if i > @poke_sprite.bitmap.width
          i = 0
          j += 1
        end
      end
      top_pixel = j
        
      i = 0
      j = @poke_sprite.bitmap.height
      while @poke_sprite.bitmap.get_pixel(i, j).alpha == 0
        i += 1
        if i > @poke_sprite.bitmap.width
          i = 0
          j -= 1
        end
      end
      down_pixel = j
      
      @poke_sprite_size = [down_pixel.to_f - top_pixel.to_f, down_pixel.to_f]
    end
    
    def refresh
      
      if $data_pokedex[@poke_id][1]
        @poke_sprite.bitmap.dispose if @poke_sprite.bitmap != nil
        @poke_sprite.bitmap = Bitmap.new("Graphics/Battlers/Front_Male/" + sprintf("%03d", @poke_id) + ".png")
        refresh_poke_size
        
        zoom_poke = 1.0  
        zoom_player = 1.0
        trainer_size = 1.8
        if $data_pokemon[@poke_id][9][2].to_f > trainer_size
          zoom_poke = 1.0
          zoom_player = trainer_size / POKEMON_S::Pokemon_Info.height(@poke_id).to_f * @poke_sprite_size[0] / @player_sprite_size[0]
        else  
          zoom_poke = POKEMON_S::Pokemon_Info.height(@poke_id).to_f / trainer_size * @player_sprite_size[0] / @poke_sprite_size[0]
          zoom_player = 1.0
        end
        
        @poke_sprite.ox = @poke_sprite.bitmap.width / 2
        @poke_sprite.oy = @poke_sprite_size[1]
        @poke_sprite.x = 141 + @poke_sprite.ox 
        @poke_sprite.y = 92 + 160
        
        @player_sprite.ox = @player_sprite.bitmap.width / 2  
        @player_sprite.oy = @player_sprite_size[1]
        @player_sprite.x = 339 + @player_sprite.ox  
        @player_sprite.y = 92 + 160
        
        @poke_sprite.zoom_x = @poke_sprite.zoom_y = zoom_poke
        @player_sprite.zoom_x = @player_sprite.zoom_y = zoom_player
        
        @poke_sprite.visible = true
        @player_sprite.visible = true
        @info_text.visible = true
        @unknown_data.visible = false
      else
        @poke_sprite.visible = false
        @player_sprite.visible = false
        @info_text.visible = false
        @unknown_data.visible = true
      end
      
    end
    
    def cleanup
      @background.dispose
      @player_sprite.dispose
      @info_text.dispose
      @poke_sprite.dispose
      @unknown_data.dispose
    end
    
  end

end