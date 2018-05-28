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

  #Just some display tasks. Nothing more to say.
  class Scene_Zone
  
    def initialize(id)
      @poke_id = id
      
      @background = Sprite.new
      @background.bitmap = Bitmap.new("Graphics/.../pokedex_info2.png")
      @background.x = 0
      @background.y = 0
      @background.z = 0
      
      @info_text = Sprite.new
      @info_text.x = 183
      @info_text.y = 224
      @info_text.z = 100
      @info_text.bitmap = Bitmap.new(273, 53) 
      @info_text.bitmap.font.name = $fontface
      @info_text.bitmap.font.size = $fontsize
      @info_text.bitmap.font.color = Color.new(60, 60, 60)
      
      @poke_icon = Sprite.new
      @poke_icon.x = 288
      @poke_icon.y = 124
      @poke_icon.z = 100
      
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
        $scene = Scene_List.new(@poke_id)
        return
      end
      
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_variables[50] = @poke_id
        $game_switches[164] = true
        $scene = Scene_Carte.new
        return
      end
      
      if Input.trigger?(Input::RIGHT)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Size.new(@poke_id)
        return
      end
      
      if Input.trigger?(Input::LEFT)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Info.new(@poke_id)
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
    
  def refresh
      @info_text.bitmap.clear
      if $data_pokedex[@poke_id][0] or $data_pokedex[@poke_id][1]
        @info_text.bitmap.draw_text(0, 0, 273, 53, "Ouvrir la carte", 1)
      else
        @info_text.bitmap.draw_text(0, 0, 273, 53, "Données manquantes", 1)
      end
      
      @poke_icon.bitmap.dispose if @poke_icon.bitmap != nil
      @poke_icon.bitmap = Bitmap.new("Graphics/Battlers/Icon/#{sprintf("%03d", @poke_id)}")
      
    end
    
    def cleanup
      @background.dispose
      @info_text.dispose
      @poke_icon.dispose
    end
    
  end


end