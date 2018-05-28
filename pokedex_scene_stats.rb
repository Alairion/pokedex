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
  class Scene_Stats
  
    def initialize(id)
      @poke_id = id
      
      @background = Sprite.new
      @background.bitmap = Bitmap.new("Graphics/.../pokedex_info5.png")
      @background.x = 0
      @background.y = 0
      @background.z = 0
      
      @poke_icon = Sprite.new
      @poke_icon.x = 577
      @poke_icon.y = 245
      @poke_icon.z = 100
      
      @weakness_bitmaps = Array.new(5)
      0.upto(4) do |i|
        @weakness_bitmaps[i] = Bitmap.new("Graphics/.../weakness#{i}.png")
      end
      
      @weaknesses = Array.new(17)
      0.upto(5) do |i|
        @weaknesses[i] = Sprite.new
        @weaknesses[i].x = 262 + (i * 63)
        @weaknesses[i].y = 137
        @weaknesses[i].z = 100
      end
      6.upto(11) do |i|
        @weaknesses[i] = Sprite.new
        @weaknesses[i].x = 262 + ((i - 6) * 63)
        @weaknesses[i].y = 209
        @weaknesses[i].z = 100
      end
      12.upto(16) do |i|
        @weaknesses[i] = Sprite.new
        @weaknesses[i].x = 262 + ((i - 12) * 63)
        @weaknesses[i].y = 281
        @weaknesses[i].z = 100
      end
      
      @base_stats = Array.new(6)
      0.upto(5) do |i|
        @base_stats[i] = Sprite.new
        @base_stats[i].bitmap = Bitmap.new(57, 33)
        @base_stats[i].bitmap.font.name = $fontface
        @base_stats[i].bitmap.font.size = $fontsize
        @base_stats[i].bitmap.font.color = Color.new(0, 0, 0)
        @base_stats[i].x = 178
        @base_stats[i].y = 102 + (i * 36)
        @base_stats[i].z = 100
        @base_stats[i].visible = false
      end
      
      @given_evs_stats = Array.new(2)
      0.upto(1) do |i|
        @given_evs_stats[i] = Sprite.new
        @given_evs_stats[i].bitmap = Bitmap.new(171, 33)
        @given_evs_stats[i].bitmap.font.name = $fontfacebattle
        @given_evs_stats[i].bitmap.font.size = $fontsize
        @given_evs_stats[i].bitmap.font.color = Color.new(0, 0, 0)
        @given_evs_stats[i].x = 8
        @given_evs_stats[i].y = 354 + (i * 37)
        @given_evs_stats[i].z = 100
        @given_evs_stats[i].visible = false
      end
      
      @given_evs_values = Array.new(2)
      0.upto(1) do |i|
        @given_evs_values[i] = Sprite.new
        @given_evs_values[i].bitmap = Bitmap.new(57, 33)
        @given_evs_values[i].bitmap.font.name = $fontface
        @given_evs_values[i].bitmap.font.size = $fontsize
        @given_evs_values[i].bitmap.font.color = Color.new(0, 0, 0)
        @given_evs_values[i].x = 178
        @given_evs_values[i].y = 354 + (i * 37)
        @given_evs_values[i].z = 100
        @given_evs_values[i].visible = false
      end
      
      @unknown_data = Sprite.new
      @unknown_data.bitmap = Bitmap.new("Graphics/.../message_box.png")
      @unknown_data.bitmap.font.name = $fontface
      @unknown_data.bitmap.font.size = $fontsize
      @unknown_data.bitmap.font.color = Color.new(60, 60, 60)
      @unknown_data.bitmap.draw_text(3, 11, 273, 53, "Données manquantes", 1) 
      @unknown_data.x = 174
      @unknown_data.y = 227
      @unknown_data.z = 100
      @unknown_data.visible = false
      
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
      
      if Input.trigger?(Input::LEFT)
        $game_system.se_play($data_system.decision_se)
        $scene = Scene_Moves.new(@poke_id)
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
      @poke_icon.bitmap.dispose if @poke_icon.bitmap != nil
      @poke_icon.bitmap = Bitmap.new("Graphics/Battlers/Icon/#{sprintf("%03d", @poke_id)}")
      if $data_pokedex[@poke_id][1]
        poke_type1 = POKEMON_S::Pokemon_Info.type1(@poke_id)
        poke_type2 = POKEMON_S::Pokemon_Info.type2(@poke_id)
        1.upto(17) do |i|
          @weaknesses[i - 1].visible = false
          multiplier = $data_table_type[poke_type1][i] * $data_table_type[poke_type2][i] #Damage multiplier
          @weaknesses[i - 1].bitmap = @weakness_bitmaps[0] if (multiplier + 0.001 > 0.0  and multiplier - 0.001 < 0.0)
          @weaknesses[i - 1].bitmap = @weakness_bitmaps[1] if (multiplier + 0.001 > 2.0  and multiplier - 0.00001 < 2.0)
          @weaknesses[i - 1].bitmap = @weakness_bitmaps[2] if (multiplier + 0.001 > 4.0  and multiplier - 0.001 < 4.0)
          @weaknesses[i - 1].bitmap = @weakness_bitmaps[3] if (multiplier + 0.001 > 0.5  and multiplier - 0.001 < 0.5)
          @weaknesses[i - 1].bitmap = @weakness_bitmaps[4] if (multiplier + 0.001 > 0.25 and multiplier - 0.001 < 0.25)
          @weaknesses[i - 1].visible = true if multiplier != 1
        end
        0.upto(5) do |i|
          @base_stats[i].bitmap.clear
          @base_stats[i].visible = true
        end
        @base_stats[0].bitmap.draw_text(0, 0, 57, 33, "#{POKEMON_S::Pokemon_Info.base_hp(@poke_id)}", 1)
        @base_stats[1].bitmap.draw_text(0, 0, 57, 33, "#{POKEMON_S::Pokemon_Info.base_atk(@poke_id)}", 1)
        @base_stats[2].bitmap.draw_text(0, 0, 57, 33, "#{POKEMON_S::Pokemon_Info.base_dfe(@poke_id)}", 1)
        @base_stats[3].bitmap.draw_text(0, 0, 57, 33, "#{POKEMON_S::Pokemon_Info.base_ats(@poke_id)}", 1)
        @base_stats[4].bitmap.draw_text(0, 0, 57, 33, "#{POKEMON_S::Pokemon_Info.base_dfs(@poke_id)}", 1)
        @base_stats[5].bitmap.draw_text(0, 0, 57, 33, "#{POKEMON_S::Pokemon_Info.base_spd(@poke_id)}", 1)
        
        stats_names = ["Points de Vie", "Attaque", "Défense", "Vitesse", "Attaque Spéciale", "Défense Spéciale"]
        poke_evs_give = POKEMON_S::Pokemon_Info.battle_list(@poke_id)
        positive_value_indexes = []
        0.upto(5) do |i|
          positive_value_indexes.push(i) if poke_evs_give[i] > 0
        end
        if positive_value_indexes.size == 1
          @given_evs_stats[0].bitmap.clear
          @given_evs_stats[0].bitmap.draw_text(0, 0, 171, 33, stats_names[positive_value_indexes[0]])
          @given_evs_stats[0].visible = true
          @given_evs_stats[1].visible = false
          @given_evs_values[0].bitmap.clear
          @given_evs_values[0].bitmap.draw_text(0, 0, 57, 33, "#{poke_evs_give[positive_value_indexes[0]]}", 1)
          @given_evs_values[0].visible = true
          @given_evs_values[1].visible = false
        elsif positive_value_indexes.size == 2
          @given_evs_stats[0].bitmap.clear
          @given_evs_stats[0].bitmap.draw_text(0, 0, 171, 33, stats_names[positive_value_indexes[1]])
          @given_evs_stats[0].visible = true
          @given_evs_values[0].bitmap.clear
          @given_evs_values[0].bitmap.draw_text(0, 0, 57, 33, "#{poke_evs_give[positive_value_indexes[1]]}", 1)
          @given_evs_values[0].visible = true
          @given_evs_stats[1].bitmap.clear
          @given_evs_stats[1].bitmap.draw_text(0, 0, 171, 33, stats_names[positive_value_indexes[1]])
          @given_evs_stats[1].visible = true
          @given_evs_values[1].bitmap.clear
          @given_evs_values[1].bitmap.draw_text(0, 0, 57, 33, "#{poke_evs_give[positive_value_indexes[1]]}", 1)
          @given_evs_values[1].visible = true
        end
        @unknown_data.visible = false
      else
        0.upto(16) do |i|
          @weaknesses[i].visible = false
        end
        0.upto(5) do |i|
          @base_stats[i].visible = false
        end
        0.upto(1) do |i|
          @given_evs_stats[i].visible = false
        end
        0.upto(1) do |i|
          @given_evs_values[i].visible = false
        end
        @unknown_data.visible = true
      end
    end
    
    def cleanup
      @background.dispose
      @poke_icon.dispose
      0.upto(16) do |i|
        @weaknesses[i].dispose
      end
      0.upto(5) do |i|
        @base_stats[i].dispose
      end
      0.upto(1) do |i|
        @given_evs_stats[i].dispose
      end
      0.upto(1) do |i|
        @given_evs_values[i].dispose
      end
      @unknown_data.dispose
    end
    
  end

end