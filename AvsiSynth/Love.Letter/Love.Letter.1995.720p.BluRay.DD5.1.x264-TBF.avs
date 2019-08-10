Source=FFVideoSource("C:\temp\Source.mkv")
Source=Source.Crop(2,140,-2,-140)

safeYV24=Source.ConvertToYV24()
safe=Source


Function FixChromaBleeding (clip input) {

  # prepare to work on the V channel and reduce to speed up and filter noise
  area = input.tweak(sat=4.0).VtoY.ReduceBy2

  # select and normalize both extremes of the scale
  red = area.Levels(255,1.0,255,255,0)
  blue = area.Levels(0,1.0,0,0,255)

  # merge both masks
  mask = MergeLuma(red, blue, 0.5).Levels(250,1.0,250,255,0)

  # expand to cover beyond the bleeding areas and shift to compensate the resizing
  mask = mask.ConvertToRGB32.GeneralConvolution(0,"0 0 0 0 0 1 1 1 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0").ConvertToYV12

  # back to full size and binarize (also a trick to expand)
  mask = mask.BilinearResize(Width(input),Height(input)).Levels(10,1.0,10,0,255)

  # prepare a version of the image that has its chroma shifted and less saturated
  input_c = input.ChromaShift(C=-4).tweak(sat=0.8)

  # combine both images using the mask
  return input.overlay(input_c,mask=mask,mode="blend",opacity=1)
}

Dirtyline_H0=StackVertical( \
safe.FixRowBrightness(5, 16, 231, 16, 235).FixRowBrightness(3, 16, 236, 16, 235).FixRowBrightness(2, 16, 222, 16, 235).FixRowBrightness(1, 16, 237, 10, 225).FixRowBrightness(0, 16, 204, 16, 235) \
.Crop(0, 0, 0, -8), \
safe.FixRowBrightness(792, 16, 239, 16, 235).FixRowBrightness(794, 16, 240, 16, 235).FixRowBrightness(795, 16, 240, 16, 235).FixRowBrightness(796, 16, 222, 16, 230).FixRowBrightness(797, 16, 243, 16, 220) \
.Crop(0, 792, 0, -2), \
safe.FixRowBrightness(798, 16, 210, 16, 235).FixRowBrightness(799, 16, 240, 16, 235) \
.FillMargins(0, 0, 0, 1).SmoothTweak(saturation=1.9) \
.Crop(0, 798, 0, 2) \
)


#Vertical lines_default 

Dirtyline_H0V3=StackHorizontal( \
Dirtyline_H0.BalanceBorders(0, 0, 2, 0, thresh=100, blur=999).FillMargins(1, 0, 0, 0) \
.FixColumnBrightness(0, 16, 223, 16, 225).FixColumnBrightness(1, 16, 223, 16, 225) \
.Crop(0, 0, -4, 0).FixChromaBleeding()\
.SmoothTweak(0,  1, 1.5,12) \
.Crop(0, 0, -1910, 0), \
Dirtyline_H0 \
.Crop(2, 0, 0, 0).BalanceBorders(0, 0, 2, 0, thresh=128, blur=999) \
.Crop(0, 0, -2, 0).FixChromaBleeding() \
.Crop(0, 0, -1908, 0), \
Dirtyline_H0.FixColumnBrightness(1912, 16, 242, 16, 235).FixColumnBrightness(1913, 16, 218, 16, 235).FixColumnBrightness(7, 16, 238, 16, 235) \
.Crop(6, 0, 1908, 0), \
Dirtyline_H0.FixColumnBrightness(1914, 16, 125, 16, 235).FixColumnBrightness(1915, 16, 41, 14, 280) \
.SmoothTweak(0,  1, 1.8) \
.FillMargins(0, 0, 1, 0) \
.Crop(1914, 0, 2, 0) \
).Spline36Resize(1280, 538, 0, 0, 0, 0)

#仅解决左边较重的褐色脏线
Dirtyline_H0V4=StackHorizontal( \
Dirtyline_H0.BalanceBorders(0, 0, 2, 0, thresh=100, blur=999).FillMargins(1, 0, 0, 0) \
.FixColumnBrightness(0, 16, 223, 16, 225).FixColumnBrightness(1, 16, 223, 16, 225) \
.Crop(0, 0, -4, 0).FixChromaBleeding()\
.SmoothTweak(0,  1, 1.5,6) \
.Crop(0, 0, -1910, 0), \
Dirtyline_H0 \
.Crop(2, 0, 0, 0).BalanceBorders(0, 0, 2, 0, thresh=128, blur=999) \
.Crop(0, 0, -2, 0).FixChromaBleeding().SmoothTweak(0,  1, 1.5,3) \
.Crop(0, 0, -1910, 0), \
Dirtyline_H0 \
.Crop(4, 0, 0, 0).BalanceBorders(0, 0, 2, 0, thresh=128, blur=999).FixChromaBleeding() \
.Crop(0, 0, -1910, 0), \
Dirtyline_H0.FixColumnBrightness(1912, 16, 242, 16, 235).FixColumnBrightness(1913, 16, 218, 16, 235) \
.Crop(6, 0, 1908, 0), \
Dirtyline_H0.FixColumnBrightness(1914, 16, 125, 16, 235).FixColumnBrightness(1915, 16, 41, 14, 280) \
.SmoothTweak(0,  1, 1.8) \
.FillMargins(0, 0, 1, 0) \
.Crop(1914, 0, 2, 0) \
).Spline36Resize(1280, 538, 0, 0, 0, 0)

#基础上解决左边时不时出现的白带问题
Dirtyline_H0V5=StackHorizontal( \
Dirtyline_H0.BalanceBorders(0, 0, 2, 0, thresh=100, blur=999).FillMargins(1, 0, 0, 0) \
.FixColumnBrightness(0, 16, 223, 16, 225).FixColumnBrightness(1, 16, 223, 16, 225) \
.Crop(0, 0, -4, 0).FixChromaBleeding()\
.SmoothTweak(0,  1, 1.5,6) \
.Crop(0, 0, -1910, 0), \
Dirtyline_H0 \
.Crop(2, 0, 0, 0).BalanceBorders(0, 0, 2, 0, thresh=128, blur=999) \
.Crop(0, 0, -2, 0).FixChromaBleeding().SmoothTweak(0,  1, 1.5,3) \
.Crop(0, 0, -1910, 0), \
Dirtyline_H0 \
.Crop(4, 0, 0, 0).BalanceBorders(0, 0, 2, 0, thresh=128, blur=999).FixChromaBleeding() \
.Crop(0, 0, -1910, 0), \
Dirtyline_H0.FixColumnBrightness(1912, 16, 242, 16, 235).FixColumnBrightness(1913, 16, 218, 16, 235) \
.Crop(6, 0, 1908, 0), \
Dirtyline_H0.FixColumnBrightness(1914, 16, 125, 16, 235).FixColumnBrightness(1915, 16, 41, 14, 280) \
.SmoothTweak(0,  1, 1.8) \
.FillMargins(0, 0, 1, 0) \
.Crop(1914, 0, 2, 0) \
).Spline36Resize(1280, 538, 0, 0, 0, 0).FixColumnBrightness(11, 16, 228, 16, 225).FixColumnBrightness(8, 16, 228, 16, 225).FixColumnBrightness(7, 16, 228, 16, 225).FixColumnBrightness(6, 16, 228, 16, 225).FixColumnBrightness(5, 16, 228, 16, 225).FixColumnBrightness(3, 16, 222, 16, 225)


#基础上解决右边脏线变化问题
Dirtyline_H0V6=StackHorizontal( \
Dirtyline_H0.BalanceBorders(0, 0, 2, 0, thresh=100, blur=999).FillMargins(1, 0, 0, 0) \
.FixColumnBrightness(0, 16, 223, 16, 225).FixColumnBrightness(1, 16, 223, 16, 225) \
.Crop(0, 0, -4, 0).FixChromaBleeding()\
.SmoothTweak(0,  1, 1.5,12) \
.Crop(0, 0, -1910, 0), \
Dirtyline_H0 \
.Crop(2, 0, 0, 0).BalanceBorders(0, 0, 2, 0, thresh=128, blur=999) \
.Crop(0, 0, -2, 0).FixChromaBleeding() \
.Crop(0, 0, -1908, 0), \
Dirtyline_H0.FixColumnBrightness(1912, 16, 242, 16, 235).FixColumnBrightness(1913, 16, 218, 16, 235).FixColumnBrightness(7, 16, 238, 16, 235) \
.Crop(6, 0, 1908, 0), \
Dirtyline_H0.FixColumnBrightness(1914, 16, 118, 16, 235).FixColumnBrightness(1915, 16, 41, 14, 280) \
.SmoothTweak(0,  1, 1.8) \
.FillMargins(0, 0, 1, 0) \
.Crop(1914, 0, 2, 0) \
).Spline36Resize(1280, 538, 0, 0, 0, 0)

Function Little (clip input)
{
      return input.F3kdb(range=30, Y=80, Cb=64, Cr=80, grainY=125, grainC=80, sample_mode=2, blur_first=True, dynamic_grain=False, opt=-1, mt=True, dither_algo=3, keep_tv_range=False, input_mode=0, input_depth=8, output_mode=0, output_depth=8)
}

Dirtyline_H0V3_L=Dirtyline_H0V3.Little()

Function Mid (clip input)
{
      return input.F3kdb(range=30, Y=120, Cb=64, Cr=140, grainY=125, grainC=130, sample_mode=2, blur_first=True, dynamic_grain=False, opt=-1, mt=True, dither_algo=3, keep_tv_range=False, input_mode=0, input_depth=8, output_mode=0, output_depth=8)
}

Function Hard (clip input)
{
      return input.F3kdb(range=30, Y=160, Cb=64, Cr=180, grainY=125, grainC=170, sample_mode=2, blur_first=True, dynamic_grain=False, opt=-1, mt=True, dither_algo=3, keep_tv_range=False, input_mode=0, input_depth=8, output_mode=0, output_depth=8)
}

Dirtyline_H0V3

#警告 下面代码有误  == 应为  ！=  这个地方让前面的修脏线 修deband 完全失效  也就是说...相当于没有修...由于发出后才发现本错误 只能引以为戒

ConditionalFilter(Dirtyline_H0V3 , Dirtyline_H0V3_L , "SceneType" , "==" , "31" )
ConditionalFilter(Dirtyline_H0V3 , Dirtyline_H0V3.Mid() , "SceneType" , "==" , "32" )
ConditionalFilter(Dirtyline_H0V3 , Dirtyline_H0V3.Hard() , "SceneType" , "==" , "33" )
ConditionalFilter(Dirtyline_H0V3 , Dirtyline_H0V4 , "SceneType" , "==" , "40" )
ConditionalFilter(Dirtyline_H0V3 , Dirtyline_H0V4.Little() , "SceneType" , "==" , "41" )
ConditionalFilter(Dirtyline_H0V3 , Dirtyline_H0V4.Mid() , "SceneType" , "==" , "42" )
ConditionalFilter(Dirtyline_H0V3 , Dirtyline_H0V4.Hard() , "SceneType" , "==" , "43" )
ConditionalFilter(Dirtyline_H0V3 , Dirtyline_H0V5 , "SceneType" , "==" , "50" )
ConditionalFilter(Dirtyline_H0V3 , Dirtyline_H0V5.Little() , "SceneType" , "==" , "51" )
ConditionalFilter(Dirtyline_H0V3 , Dirtyline_H0V5.Mid() , "SceneType" , "==" , "52" )
ConditionalFilter(Dirtyline_H0V3 , Dirtyline_H0V5.Hard() , "SceneType" , "==" , "53" )
ConditionalFilter(Dirtyline_H0V3 , Dirtyline_H0V6 , "SceneType" , "==" , "60" )

ConditionalReader("D:\压制临时存放\LOVE LETTER\data.txt" , "SceneType")

