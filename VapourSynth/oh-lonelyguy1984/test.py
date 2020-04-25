import vapoursynth as vs
import sgvsfunc as sg
import havsfunc as ha
import adjust as adj

core = vs.core
core.num_threads = 3
core.max_cache_size = 80000


src_path = r"C:/ohlonelyguy.mkv"
src = core.lsmas.LWLibavSource(source=src_path, threads=1)

cropped = src
cropped = core.std.Trim(cropped, 0, 125389)
cropped = core.std.Crop(cropped, 0, 0, 18, 18)

#fix dirty lines and single black borders

#40031
'''
cropped = sg.FixColumnBrightnessProtect2(cropped, 1, 3)
cropped = sg.FixColumnBrightnessProtect2(cropped, 5, 2)
cropped = sg.FixColumnBrightnessProtect2(cropped, 3, 4)

cropped = sg.FixColumnBrightnessProtect2(cropped, 1915, -1)
cropped = sg.FixColumnBrightnessProtect2(cropped, 1917, -5)
cropped = sg.FixColumnBrightnessProtect2(cropped, 1918, -2)

cropped = core.fb.FillBorders(cropped, 0, 0, 1, 1, mode="fillmargins")
cropped = sg.bbmod(cropped, 0, 0, 1, 1, blur = 20)
#40031
'''
#start
cropped = sg.FixColumnBrightnessProtect2(cropped, 1915, -2)
cropped = sg.FixColumnBrightnessProtect2(cropped, 1917, -5)
cropped = sg.FixColumnBrightnessProtect2(cropped, 1918, -2)
cropped = sg.FixColumnBrightnessProtect2(cropped, 1919, 61)

cropped = sg.FixColumnBrightnessProtect2(cropped, 3, 3)
cropped = sg.FixColumnBrightnessProtect2(cropped, 2, -1)
#cropped = sg.FixColumnBrightnessProtect2(cropped, 1, 5)
cropped = sg.FixColumnBrightnessProtect2(cropped, 0, 62)

cropped = core.fb.FillBorders(cropped, 0, 0, 1, 1, mode="fillmargins")
#end


stack_top = core.std.Crop(cropped, 0, 0, 0, 1042)
stack_mid = core.std.Crop(cropped, 0, 0, 2, 2)
stack_bottom = core.std.Crop(cropped, 0, 0, 1042, 0)

stack_top = adj.Tweak(stack_top, sat = 2)
stack_bottom = adj.Tweak(stack_bottom, sat = 1.8)
cropped = core.std.StackVertical([stack_top, stack_mid, stack_bottom])

cropped = sg.bbmod(cropped, 1,0,0,0)

cropped_addborder = core.std.Trim(src, 125390, 130179)
cropped_addborder = core.std.Crop(cropped_addborder, 60, 60, 32, 32)
cropped_addborder = sg.FixColumnBrightnessProtect2(cropped_addborder, 0, 58)#需饱和度
cropped_addborder = sg.FixColumnBrightnessProtect2(cropped_addborder, 1797, -3)
cropped_addborder = sg.FixColumnBrightnessProtect2(cropped_addborder, 1798, 56) #需饱和度
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 1, 20) #需饱和度
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 2, -8)
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 4, 3)
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 1010, 3)
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 1012, -10)
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 1013, 19) #需饱和度
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 1014, 81) #需饱和度

cropped_addborder = core.fb.FillBorders(cropped_addborder, 0, 1, 1, 1, mode="fillmargins")

#1800 x 1016

YUV444 = core.resize.Bicubic(cropped_addborder, format=vs.YUV444P8)
TW_Left = core.std.Crop(YUV444, 0, 1799, 0, 0)
TW_Right = core.std.Crop(YUV444, 1798, 0, 0, 0)

TW_Top = core.std.Crop(YUV444, 1, 2, 0, 1014)
TW_TtoB = core.std.Crop(YUV444, 1, 2, 2, 3)
TW_Bottom3 = core.std.Crop(YUV444, 1, 2, 1013, 2)
TW_Bottom1 = core.std.Crop(YUV444, 1, 2, 1015, 0)

TW_Left = adj.Tweak(TW_Left, sat = 1.6)
TW_Right = adj.Tweak(TW_Right, sat = 1.6)
TW_Top = adj.Tweak(TW_Top, sat = 1.6)
TW_Bottom3 = adj.Tweak(TW_Bottom3, sat = 1.15)

TW_temp = core.std.Crop(YUV444, 1, 2, 0, 1)
TW_temp = sg.bbmod(TW_temp, 0,1,0,0,128,20)

TW_temp = core.std.StackVertical([TW_temp, TW_Bottom1])
TW_temp = sg.bbmod(TW_temp, 0,1,0,0,128,20)
TW_Bottom1and2 = core.std.Crop(TW_temp, 0, 0, 1014, 0)

TW_LtoR = core.std.StackVertical([TW_Top, TW_TtoB, TW_Bottom3, TW_Bottom1and2])

YUV444 = core.std.StackHorizontal([TW_Left, TW_LtoR, TW_Right])

cropped_addborder = core.resize.Bicubic(YUV444, format=vs.YUV420P8)

cropped_addborder = core.std.AddBorders(cropped_addborder, 60, 60, 14, 14)


cropped = core.std.Splice([cropped, cropped_addborder])


#core.resize.Spline36(clip = cropped, format = vs.RGB24, dither_type = "error_diffusion", matrix_in_s = "709").set_output()

#125390 130179

'''
new_height = round(cropped.height*1280/cropped.width/2)*2
new_width = round(cropped.width*720/cropped.height/2)*2

if new_height < 720 and new_width >= 1280 :
	new_width = 1280
elif new_height >= 720 and new_width < 1280 :
	new_height = 720

resized = core.resize.Spline36(clip	= cropped, width = new_width, height = new_height, src_left = 0, src_top = 0, src_height = cropped.height, src_width = cropped.width)

#resized = core.text.Text(resized, "Source", alignment = 9)

resized = sg.FrameInfo(resized, "Source")

sample = core.std.SelectEvery(resized, 8000, range(200))
#每隔3000取200帧
sample = core.std.AssumeFPS(sample, resized)
#同步帧率 sample同步为resized的帧率
'''

sample = core.std.SelectEvery(cropped, 8000, range(200))
#每隔3000取200帧
sample = core.std.AssumeFPS(sample, cropped)
#同步帧率 sample同步为resized的帧率
sample.set_output()