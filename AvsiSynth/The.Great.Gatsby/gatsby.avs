source=FFVideoSource("C:\video.mkv")

#crop

cropped=source.Crop(0, 280, -0, -280)

#fis dirtylines

# none

#resize
#2.4:1

cropped=cropped.spline36Resizemod(1280,534)
#spline36Resizemod(1920,800,0,0)

#deband

DEBAND1=cropped.f3kdb(Y=32, grainY=42, grainC=45, cr=32, cb=32,dynamic_grain=true)
DEBAND2=mt_merge(cropped,cropped.f3kdb(dither_algo=3,y=40,cb=35,cr=35,grainY=50,grainC=50),cropped.mt_binarize(35,true),u=3,v=4)
DEBAND3=cropped.f3kdb(Y=40, grainY=40, grainC=0, cr=0, cb=0,dynamic_grain=true)
DEBAND4=mt_merge(cropped,cropped.f3kdb(dither_algo=3,y=40,cb=35,cr=35,grainy=50,grainc=50),cropped.mt_binarize(36,true),u=3,v=4)
DEBAND5=mt_merge(cropped,cropped.f3kdb(dither_algo=3,y=40,cb=35,cr=35,grainy=50,grainc=50),cropped.mt_binarize(38,true),u=3,v=4)

#其实感觉2,4,5有点多余 还不如换成1/3

cropped

#赋值给last

ConditionalFilter(last , DEBAND1 , "SceneType" , "<" , "0" )
ConditionalFilter(last , DEBAND2 , "SceneType" , "<" , "1" )
ConditionalFilter(last , DEBAND3 , "SceneType" , "<" , "2" )
ConditionalFilter(last , DEBAND4 , "SceneType" , "<" , "3" )
ConditionalFilter(last , DEBAND5 , "SceneType" , "<" , "4" )
#共进行5轮替换 每次用符合条件的片段替换上次获得的片段

ConditionalReader("D:\DEBAND.txt" , "SceneType")

SelectRangeEvery(every=4000, length=60, offset=0, audio=false)

#ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false).subtitle("filtered source",1100)