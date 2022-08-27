#===============================================================================
# * One screen Day-Care Checker item - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It makes a One screen Day-Care Checker
# (like in DPP) activated by item. This display the pokémon sprite, names,
# levels, genders and if them generate an egg.
#
#===============================================================================
#
# To this script works, put it above main, put a 480x320 background in 
# DCCBACKPATH location and, like any item, you need to add in the "items.txt"
# and in the script. There an example below using the name DAYCARESIGHT, but
# you can use any other name changing the DCCITEM and the item that be added in
# txt. You can change the internal number too:
#
# 631,DAYCARESIGHT,DayCare Sight,DayCare Sight,8,0,"A visor that can be use for see certains Pokémon in Day-Care to monitor their growth.",2,0,6
# 
#===============================================================================

DCCITEM=:DAYCARESIGHT # Change this and the item.txt if you wish another name
DCCBACKPATH= "Graphics/Pictures/dccbackground" # You can change if you wish 
# If you wish that the pokémon is positioned like in battle (have the distance
# defined in metadata, even the BattlerAltitude) change the below line to true
DCCBATTLEPOSITION = false

class DayCareCheckerScene  

def startScene
  @sprites={}
  @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
  @viewport.z=99999
  @pkmn1=$PokemonGlobal.daycare[0][0]
  @pkmn2=$PokemonGlobal.daycare[1][0]
  # If you wish that if there only one pokémon, it became right 
  # positioned, them uncomment the four below lines
  #if !@pkmn1 && @pkmn2
  #  @pkmn1=@pkmn2
  #  @pkmn2=nil
  #end  
  textPositions=[]
  baseColor=Color.new(12*8,12*8,12*8)
  shadowColor=Color.new(26*8,26*8,25*8)
  @sprites["background"]=IconSprite.new(0,0,@viewport)
  @sprites["background"].setBitmap(DCCBACKPATH)

  pokemony=Graphics.height/2-32
  pokemonyadjust=pokemony-32 
  if @pkmn1
    @sprites["pokemon1"]=PokemonSprite.new(@viewport)
    @sprites["pokemon1"].setPokemonBitmap(@pkmn1)
    @sprites["pokemon1"].mirror=true
   pbPositionPokemonSprite(@sprites["pokemon1"],32,pokemony)

    @sprites["pokemon1"].y=pokemonyadjust + adjustBattleSpriteY(
        @sprites["pokemon1"],@pkmn1.species,1) if DCCBATTLEPOSITION

    textPositions.push([_INTL("{1} Lv{2}{3}",@pkmn1.name,@pkmn1.level.to_s,
        genderString(@pkmn1.gender)),32,44,false,baseColor,shadowColor])
  end
  if @pkmn2
    @sprites["pokemon2"]=PokemonSprite.new(@viewport)
    @sprites["pokemon2"].setPokemonBitmap(@pkmn2)
   pbPositionPokemonSprite(@sprites["pokemon2"],Graphics.width-168,pokemony)

    @sprites["pokemon2"].y=pokemonyadjust + adjustBattleSpriteY(
        @sprites["pokemon2"],@pkmn2.species,1) if DCCBATTLEPOSITION

    textPositions.push([_INTL("{1} Lv{2}{3}",@pkmn2.name,@pkmn2.level.to_s,
        genderString(@pkmn2.gender)),Graphics.width-16,44,true,baseColor,
        shadowColor])
  end
  if Kernel.pbEggGenerated?
    @sprites["egg"]=IconSprite.new(Graphics.width/2-68,pokemony+32,@viewport)
    @sprites["egg"].setBitmap("Graphics/Battlers/egg")
    # To works with different egg sprite sizes
    @sprites["egg"].x-=(@sprites["egg"].bitmap.width/8-16)*3
    # Uncomment the below line to only a egg shadow be show
    #@sprites["egg"].color=Color.new(0,0,0,255)    
  end
  @sprites["overlay"]=Sprite.new(@viewport)
  @sprites["overlay"].bitmap=BitmapWrapper.new(Graphics.width,Graphics.height)
  pbSetSystemFont(@sprites["overlay"].bitmap)
  if !textPositions.empty?
    pbDrawTextPositions(@sprites["overlay"].bitmap,textPositions)
  end
  pbFadeInAndShow(@sprites) { update }
end

def genderString(gender)
  ret="  "
  if gender==0
    ret=" ♂"
  elsif gender==1
    ret=" ♀"
  end 
  return ret
end  

def middleScene
  loop do
    Graphics.update
    Input.update
    self.update
    if Input.trigger?(Input::B) || Input.trigger?(Input::C)
      break
    end
  end 
end

def update
  pbUpdateSpriteHash(@sprites)
end

def endScene
  pbFadeOutAndHide(@sprites) { update }
  pbDisposeSpriteHash(@sprites)
  @viewport.dispose
end
end

class DayCareChecker

def initialize(scene)
  @scene=scene
end

def startScreen
  @scene.startScene
  @scene.middleScene
  @scene.endScene
end
end

# Item handlers 

ItemHandlers.addUseFromBag(DCCITEM, proc {|item|
   pbFadeOutIn(99999){ 
     scene=DayCareCheckerScene.new
     screen=DayCareChecker.new(scene)
     screen.startScreen
   }
   next 1 # Continue
})

ItemHandlers.addUseInField(DCCITEM, proc {|item|
   pbFadeOutIn(99999){ 
     scene=DayCareCheckerScene.new
     screen=DayCareChecker.new(scene)
     screen.startScreen
   }
   next 1 # Continue
})