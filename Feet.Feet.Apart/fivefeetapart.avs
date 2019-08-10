source=FFVideoSource("C:\fivefeetapart.mkv")

cropped=source.crop(0,140,0,-140).spline36Resizemod(1280,534)

DEBAND1=cropped.f3kdb(Y=40, grainY=50, grainC=45, cr=32, cb=32,dynamic_grain=true)
DEBAND2=cropped.f3kdb(Y=40, grainY=40, grainC=0, cr=0, cb=0,dynamic_grain=true)
#DEBAND1=cropped.f3kdb(Y=40, grainY=60, grainC=64, cr=32, cb=32,dynamic_grain=true,dither_algo=3)
#DEBAND2=cropped.f3kdb(Y=40, grainY=52, grainC=0, cr=0, cb=0,dynamic_grain=true,dither_algo=3)

cropped

ConditionalFilter(last, DEBAND1, "SceneType" , "<" , "0")
ConditionalFilter(last, DEBAND2, "SceneType" , "<" , "1")

ConditionalReader("D:\avss\fivefeetapart\DEBAND.txt" , "SceneType")

last#.SelectRangeEvery(every=4000, length=100, offset=300, audio=false).trim(0,3975)#.ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false).subtitle("FILTERED 34.9M",1800)

last#.Histogram("luma")