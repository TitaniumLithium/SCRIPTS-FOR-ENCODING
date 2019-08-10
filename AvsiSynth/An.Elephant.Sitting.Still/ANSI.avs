source=FFVideoSource("C:\An.Elephant.Sitting.Still.2018.1080p.TWN.BluRay.REMUX.AVC.AC3.5.1-SUPER.mkv")

resized=source.spline36Resizemod(1280,720)

resized

untouched_8=last
untouched_16=last.f3kdb(y=0, cb=0, cr=0, grainy=0, grainc=0, dynamic_grain=true, input_depth=8, output_depth=16)
mask_16=last.GradFun3(smode=2, thr=0.25, thrc=0.25, elast=3, elastc=3, radius=14, radiusc=14, wmin=1, debug=1, lsb=true)
debanded_16=last.Dither_convert_8_to_16().f3kdb(16, 36, 48, 48, 58, 58, dither_algo=2, input_depth=16, output_depth=16, random_algo_grain=2)
dither_merge16(debanded_16, untouched_16, mask_16)
f3kdb(y=0, cb=0, cr=0, grainy=0, grainc=0, dynamic_grain=true, input_depth=16, output_depth=8)
done_8=last

DEBAND1=done_8

ConditionalFilter(last, DEBAND1, "SceneType" , "<" , "0")

ConditionalReader("D:\avss\elephant\DEBAND.txt" , "SceneType")
last#.Histogram("luma")
last.ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false).subtitle("filtered",1200)

