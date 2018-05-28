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

#In this file there is a big differency between "map" and "zone"
#A zone is made of at least one map but can be composed of multiple maps.
#A map is a part of a zone (a house, a Pokémon centre, the outside, ...)

module Pokedex
  BUILDINGS_ID = [...] #contains the id of the zone that are buildings
  CAVES_ID = [...] #contains the id of the zone that are caves
  WHITELIST_ID = [..] #contains the id of the zone that are displayed in the interface

  AREA_SWITCHES = [[], ...] #contains the switch index that give use information about the zone visited.
    
  #I use 3 helper structs in this one because it was really hard to do.
  class Scene_Biotope

    class Pokemon_Info
      attr_accessor :id #Pokemon ID
      attr_accessor :area #0 = plaine; 1 = building; 2 = cave; 3 = water (surf); 4 = water (fishing); 
      attr_accessor :day_night #0 = both, 1 = day, 2 = night
      attr_accessor :pokedex #0 = not seen or caught; 1 = seen; 2 = caught (and seen)
      
      def initialize(id)
        @id = id
        @area = 0
        @day_night = 0
        @pokedex = 0
        if $data_pokedex[@id][1] #Caught
          @pokedex = 2
        elsif $data_pokedex[@id][0] #Seen
          @pokedex = 1
        end
      end
    end
    
    class Zone_Info
      attr_accessor :id #Zone ID
      attr_accessor :name #Zone name
      attr_accessor :map_ids #Map ids of the maps that compose that zone
      attr_accessor :infos #The Pokemon_Info of each pokemon found on the map
      
      def initialize(id)
        @id = id
        @name = $data_zone[@id][0]
        
        @map_ids = Array.new
        1.upto($data_mapzone.size - 1) do |i|
          @map_ids.push(i) if $data_mapzone[i][0] == @id
        end
        
        @data_map = Hash.new
        
        @infos = Array.new
        1.upto($data_pokemon.size - 1) do |i|
          add_pokemon_info(i, 0) if POKEMON_S::Pokemon_Info.where(i).include?(@id)
          
          @map_ids.each do |mapid|
            POKEMON_S::Data_Fishing.fishing_id(mapid).each do |fishing_data|
              if fishing_data != nil
                add_pokemon_info(i, 2) if fishing_data[0] == i
              end
            end
          end
            
          #Add surf if available
          
        end
        
        @data_map.clear
      end
      
      def has_already?(info)
        @infos.each do |info2|
          if info.id == info2.id and info.area == info2.area
            return true
          end
        end
        return false
      end
      
      def add_pokemon_info(id, category) #category: 0 = land, 1 = surf, 2 = fishing
        info = Pokemon_Info.new(id)
        set_area(info, category)
        set_day_night(info)
        @infos.push(info) if not has_already?(info)
      end
      
      def set_area(info, category)
        if category == 0
          if BUILDINGS_ID.include?(@id)
            info.area = 1
          elsif CAVES_ID.include?(@id)
            info.area = 2
          end
        elsif category == 1
          #Add surf if available
        elsif category == 2
          @map_ids.each do |mapid|
            POKEMON_S::Data_Fishing.fishing_id(mapid).each do |fishing_data|
              if fishing_data != nil
                info.area = 4 if fishing_data[0] == info.id
              end
            end
          end
        end
      end
      
      def set_day_night(info)
        encounter_lists = load_data("...") #Here i load a personalized data file that only contains all the encounter of each maps
        @map_ids.each do |mapid|
          if info.area == 4
            POKEMON_S::Data_Fishing.fishing_id(mapid).each do |fishing_data|
              if fishing_data != nil
                if fishing_data[0] == info.id
                  info.day_night |= 3 if fishing_data[2] == 0 #I use bitmask for technical reasons...
                  info.day_night |= 1 if fishing_data[2] == 1
                  info.day_night |= 2 if fishing_data[2] == 2
                end
              end
            end
          elsif info.area == 3
            #Add surf if available
          elsif info.area == 0
            encounter_lists[@id].each do |e|
              if encounter_contain?(e, info.id)
                info.day_night |= 1 if $data_encounter[e][3] == 178
                info.day_night |= 2 if $data_encounter[e][3] == 177 or $data_encounter[e][3] == 179
              end
            end
          end
        end
        
        info.day_night = 0 if info.day_night == 3 #That why there is a bitmask
      end
      
      def encounter_contain?(e, id)
        if $data_encounter[e][0] > 0
          1.upto($data_encounter[e][2].size - 1) do |i|
            if $data_encounter[e][2][i][0] == id
              return true 
            end
          end
        end
        return false
      end
      
    end
    
    class Slot
      attr_accessor :background
      attr_accessor :fishing
      attr_accessor :poke_icon
      
      def initialize(x, y)
        @background = Sprite.new
        @background.x = x
        @background.y = y
        @background.z = 50
        
        @fishing = Sprite.new
        @fishing.x = x
        @fishing.y = y + 49
        @fishing.z = 100
        
        @poke_icon = Sprite.new
        @poke_icon.x = x + 1
        @poke_icon.y = y + 1
        @poke_icon.z = 75
      end
      
    end
    
    def visited?(id)
      AREA_SWITCHES[id].each do |switch|
        if $game_switches[switch]
          return true
        end
      end
      return false
    end
    
    def initialize
      @zone_infos = Array.new #Load all informations. So we just have to display without thinking of them.
      WHITELIST_ID.each do |i|
        @zone_infos.push(Zone_Info.new(i)) if visited?(i)
      end
      @zone_infos.each do |info|
        #Sort the Pokémon of the exch maps by area, then in each area sot then by day/night cycle, then by id.
        info.infos.sort! { |right, left| right.area != left.area ? right.area <=> left.area : right.day_night != left.day_night ? right.day_night <=> left.day_night : right.id <=> left.id} if info
      end
      
      @background = Sprite.new
      @background.bitmap = Bitmap.new("Graphics/.../biotope.png")
      @background.x = 0
      @background.y = 0
      @background.z = 0
      
      @cursor = Sprite.new
      @cursor.bitmap = Bitmap.new("Graphics/Pokedex/moves_cursor.png")
      @cursor.x = 53
      @cursor.y = 40
      @cursor.z = 100
      @index = 0
      @global_index = 0
      
      #preloads...
      @surf_fishing_d = Bitmap.new("Graphics/.../surf_fishing_d.png")
      @surf_fishing_dn = Bitmap.new("Graphics/.../surf_fishing_dn.png")
      @surf_fishing_n = Bitmap.new("Graphics/.../surf_fishing_n.png")
      @unknown = Bitmap.new("Graphics/.../unknown.png")
      @building = Bitmap.new("Graphics/.../building.png")
      @cave = Bitmap.new("Graphics/.../cave.png")
      @fishing = Bitmap.new("Graphics/.../fishing.png")
      @forest_plain_d = Bitmap.new("Graphics/.../forest_plain_d.png")
      @forest_plain_dn = Bitmap.new("Graphics/.../forest_plain_dn.png")
      @forest_plain_n = Bitmap.new("Graphics/.../forest_plain_n.png")
    
      #Same trick as in Scene_List
      @poke_bitmaps = Hash.new
      
      @slots = Array.new(24)
      0.upto(23) do |i|
        @slots[i] = Slot.new(329 + ((i % 4) * 73), 17 + ((i / 4) * 75))
      end
      
      @list = Array.new(10)
      0.upto(9) do |i|
        @list[i] = Sprite.new
        @list[i].x = 61
        @list[i].y = 26 + 44 * i
        @list[i].z = 100
        @list[i].bitmap = Bitmap.new(245, 40)
        @list[i].bitmap.font.name = $fontface
        @list[i].bitmap.font.size = $fontsize
        @list[i].bitmap.font.color = Color.new(255,255,255,255)
      end
      
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
        $scene = Scene_Intro.new
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
    end
    
    def refresh
      @list.each_with_index do |item, i|
        item.bitmap.clear
        item.bitmap.draw_text(0, 0, 245, 40, @zone_infos[@global_index + i].name, 1)
      end
    
      @slots.each do |slot|
        slot.background.bitmap = nil
        slot.fishing.bitmap = nil
        slot.poke_icon.bitmap = nil
      end
      
      @cursor.y = 40 + 44 * @index
    
      @zone_infos[@global_index + @index].infos.each_with_index do |info, i|
        break if i > 23 #to be sure...
        
        if info.area == 0 #0 = plaine; 1 = building; 2 = cave; 3 = water (surf); 4 = water (fishing); 
          @slots[i].background.bitmap = @forest_plain_dn if info.day_night == 0 #0 = both, 1 = day, 2 = night
          @slots[i].background.bitmap = @forest_plain_d if info.day_night == 1
          @slots[i].background.bitmap = @forest_plain_n if info.day_night == 2
        elsif info.area == 1
          @slots[i].background.bitmap = @building
        elsif info.area == 2
          @slots[i].background.bitmap = @cave
        elsif info.area == 4
          @slots[i].background.bitmap = @surf_fishing_dn if info.day_night == 0
          @slots[i].background.bitmap = @surf_fishing_d if info.day_night == 1
          @slots[i].background.bitmap = @surf_fishing_n if info.day_night == 2
        end
        @slots[i].fishing.bitmap = @fishing if info.area == 4
        if info.pokedex == 0 #0 = not seen or caught; 1 = seen; 2 = caught (and seen)
          @slots[i].poke_icon.bitmap = @unknown
          @slots[i].poke_icon.color = Color.new(0,0,0,0)
        elsif info.pokedex == 1
          @slots[i].poke_icon.bitmap = load_poke_bitmap(info.id)
          @slots[i].poke_icon.color = Color.new(0,0,0,255)
        elsif info.pokedex == 2
          @slots[i].poke_icon.bitmap = load_poke_bitmap(info.id)
          @slots[i].poke_icon.color = Color.new(0,0,0,0)
        end
      end
    end
    
    def move_down
      $game_system.se_play($data_system.cursor_se)
      if @global_index + @index < @zone_infos.size - 2
        if @index == 9
          @global_index += 1
          refresh
        else
          @index += 1
          refresh
        end
      end
    end
    
    def move_up
      $game_system.se_play($data_system.cursor_se)
      if @global_index + @index > 0
        if @index == 0
          @global_index -= 1
          refresh
        else
          @index -= 1
          refresh
        end
      end
    end
    
    def load_poke_bitmap(poke_id)
      @poke_bitmaps[poke_id] = Bitmap.new("Graphics/Battlers/Icon/#{sprintf("%03d", poke_id)}") if @poke_bitmaps[poke_id] == nil
      return @poke_bitmaps[poke_id]
    end
    
    def cleanup
      @background.dispose
      @cursor.dispose
      @surf_fishing_d.dispose
      @surf_fishing_dn.dispose
      @surf_fishing_n.dispose
      @unknown.dispose
      @building.dispose
      @cave.dispose
      @fishing.dispose
      @forest_plain_d.dispose
      @forest_plain_dn.dispose
      @forest_plain_n.dispose
      @poke_bitmaps.each do |i, bmp|
        bmp.dispose
      end
      @poke_bitmaps.clear
      @list.each do |sprite|
        sprite.dispose
      end
      @list.clear
      @slots.each do |slot|
        slot.background.dispose
        slot.fishing.dispose
        slot.poke_icon.dispose
      end
      @slots.clear
    end
    
  end

end