source=FFVideoSource("C:\greenbook.mkv")

#3836x1916 ---2.002:1
cropped=source.Crop(2,122,-2,-122)

#fix dirty lines

function VerticalDirtyline1 (clip input)
{
 #2+3824+10=3836  
return StackHorizontal( \
input.FixColumnBrightness(1, 16, 232, 16, 237).crop(0,0,2,0), \
input.FixColumnBrightness(2, 16, 232, 16, 235).FixColumnBrightness(3, 16, 234, 16, 236).FixColumnBrightness(4, 16, 233, 16, 235).FixColumnBrightness(5, 16, 232, 16, 235).FixColumnBrightness(27, 16, 235, 16, 235).crop(2,0,-10,0).BalanceBorders(0,0,1,0), \
input.FixColumnBrightness(3835, 16, 235, 16, 228).crop(3826,0,0,0) )
}

function VerticalDirtyline2 (clip input)
{
 #2+3824+10=3836  
return StackHorizontal( \
input.FixColumnBrightness(1, 16, 235, 16, 237).crop(0,0,2,0), \
input.FixColumnBrightness(2, 16, 232, 16, 235).FixColumnBrightness(3, 16, 234, 16, 236).FixColumnBrightness(27, 16, 235, 16, 235).crop(2,0,-10,0).BalanceBorders(0,0,1,0), \
input.FixColumnBrightness(3835, 16, 235, 16, 228).crop(3826,0,0,0) )
}

cropped

ConditionalFilter(last , cropped.FixColumnBrightness(0, 16, 232, 16, 230) , "SceneType" , "<" , "0" )
ConditionalFilter(last , cropped.VerticalDirtyline1() , "SceneType" , "<" , "1" )
ConditionalFilter(last , cropped.FixColumnBrightness(0, 16, 235, 16, 230) , "SceneType" , "<" , "2" )
ConditionalFilter(last , cropped.VerticalDirtyline2() , "SceneType" , "<" , "3" )

ConditionalReader("D:\dirtyline-clips.txt" , "SceneType")

# 2.004 : 1

safe=last.Spline36Resize(1920,958,0,0)

#deband 

deband1=safe.f3kdb(Y=20, grainY=31, grainC=38, cr=32,cb=32)
deband2=safe.f3kdb(Y=22, grainY=35, grainC=45, cr=32,cb=32)
deband3=safe.f3kdb(Y=25, grainY=41, grainC=45, cr=32,cb=32)
deband4=safe.F3kdb(Y=52, grainY=48, grainC=48, cr=48,cb=48)
deband5=safe.f3kdb(Y=28, Cb=0, Cr=0, grainY=0, grainC=0, dither_algo=3, dynamic_grain=false, random_algo_grain=2)

safe

ConditionalFilter(last , deband1 , "SceneType" , "<" , "0" )
ConditionalFilter(last , deband2 , "SceneType" , "<" , "1" )
ConditionalFilter(last , deband3 , "SceneType" , "<" , "2" )
ConditionalFilter(last , deband4 , "SceneType" , "<" , "3" )
ConditionalFilter(last , deband5 , "SceneType" , "<" , "4" )

ConditionalReader("D:\DEBAND-clips.txt" , "SceneType")
