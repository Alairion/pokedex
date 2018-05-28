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

  class Scene_Intro
    
    def initialize
      @background = Sprite.new
      @background.bitmap = Bitmap.new("Graphics/__removed__/start.png")
      @background.x = 0
      @background.y = 0
      @background.z = 0
      
      viewed = 0
      1.upto($data_pokemon.size - 1) do |i|
        viewed += 1 if $data_pokedex[i][0]
      end
      
      captured = 0
      1.upto($data_pokemon.size - 1) do |i|
        captured += 1 if $data_pokedex[i][1]
      end
      
      @pokemon_amount = Sprite.new
      @pokemon_amount.x = 0
      @pokemon_amount.y = 305
      @pokemon_amount.z = 100
      @pokemon_amount.bitmap = Bitmap.new(572, 96) 
      @pokemon_amount.bitmap.font.name = $fontface  
      @pokemon_amount.bitmap.font.size = $fontsize  
      @pokemon_amount.bitmap.font.bold = true  
      @pokemon_amount.bitmap.draw_text(0,   10, 320, 64, "POKÉMONS APERÇUS", 2) 
      @pokemon_amount.bitmap.draw_text(250, 10, 320, 64, "POKÉMONS ATTRAPÉS", 2)  
      @pokemon_amount.bitmap.draw_text(0,   22, 320, 64, ". . . . . . . . . . . . . . . . . .", 2)  
      @pokemon_amount.bitmap.draw_text(250, 22, 320, 64, ". . . . . . . . . . . . . . . . . .", 2)  
      @pokemon_amount.bitmap.draw_text(0,   47, 320, 64, "[ "+ sprintf("%03d", viewed) +" ]", 2)  
      @pokemon_amount.bitmap.draw_text(250, 47, 320, 64, "[ "+ sprintf("%03d", captured) +" ]", 2)  
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
      if Input.trigger?(Input::X)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Biotope.new
        return
      end
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        $scene = POKEMON_S::Pokemon_Menu.new(0)
        return
      end
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_List.new
        return
      end
    end
    
    def cleanup
      @pokemon_amount.dispose
      @background.dispose
    end
    
  end
  
end