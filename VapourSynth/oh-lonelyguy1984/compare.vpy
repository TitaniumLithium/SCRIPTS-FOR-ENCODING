
import vapoursynth as vs
import sgvsfunc as sg
import havsfunc as ha
import adjust as adj

import os,shutil,re,logging

core = vs.core
core.num_threads = 3
core.max_cache_size = 80000


src_path = r"C:/ohlonelyguy.mkv"
src = core.lsmas.LWLibavSource(source=src_path, threads=1)

cropped = src
cropped = core.std.Trim(cropped, 0, 125389)
cropped = core.std.Crop(cropped, 0, 0, 18, 18)

#修复脏线 （第一部分）
cropped = sg.FixColumnBrightnessProtect2(cropped, 1915, -2)
cropped = sg.FixColumnBrightnessProtect2(cropped, 1917, -5)
cropped = sg.FixColumnBrightnessProtect2(cropped, 1918, -2)
cropped = sg.FixColumnBrightnessProtect2(cropped, 1919, 61)

cropped = sg.FixColumnBrightnessProtect2(cropped, 3, 3)
cropped = sg.FixColumnBrightnessProtect2(cropped, 2, -1)
cropped = sg.FixColumnBrightnessProtect2(cropped, 0, 61)

#填充单pixel黑边
cropped = core.fb.FillBorders(cropped, 0, 0, 1, 1, mode="fillmargins")

stack_top = core.std.Crop(cropped, 0, 0, 0, 1042)
stack_mid = core.std.Crop(cropped, 0, 0, 2, 2)
stack_bottom = core.std.Crop(cropped, 0, 0, 1042, 0)

stack_top = adj.Tweak(stack_top, sat = 2)
stack_bottom = adj.Tweak(stack_bottom, sat = 1.8)
cropped = core.std.StackVertical([stack_top, stack_mid, stack_bottom])

cropped = sg.bbmod(cropped, 1,0,0,0)

#修复脏线（第二部分）
cropped_addborder = core.std.Trim(src, 125390, 130179)
cropped_addborder = core.std.Crop(cropped_addborder, 60, 60, 32, 32)
cropped_addborder = sg.FixColumnBrightnessProtect2(cropped_addborder, 0, 58)
cropped_addborder = sg.FixColumnBrightnessProtect2(cropped_addborder, 1797, -3)
cropped_addborder = sg.FixColumnBrightnessProtect2(cropped_addborder, 1798, 56) 
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 1, 20)
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 2, -8)
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 4, 3)
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 1010, 3)
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 1012, -10)
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 1013, 19) 
cropped_addborder = sg.FixRowBrightnessProtect2(cropped_addborder, 1014, 81)

#填充单pixel黑边
cropped_addborder = core.fb.FillBorders(cropped_addborder, 0, 1, 1, 1, mode="fillmargins")


#调整饱和度 及 使用bbmod

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

#手动增加第二部分黑边
cropped_addborder = core.std.AddBorders(cropped_addborder, 60, 60, 14, 14)

#合并两部分
cropped = core.std.Splice([cropped, cropped_addborder])






encode=[]
name=[]

match_str = r'\.mkv$'

encode_path = r"D:\queues\ohlonelyguy\crf01"

content=[str(x) for x in os.listdir(encode_path) if os.path.isfile(os.path.join(encode_path,str(x)))]

if content != [] :
	for i in range(len(content)):
		if(re.search(match_str,content[i])) :
			encode.append(core.lsmas.LWLibavSource(source=os.path.join(encode_path, content[i]), threads=1))
			name.append(content[i])

sample = core.std.SelectEvery(cropped, 8000, range(200))
sample = core.std.AssumeFPS(sample, cropped)
sum = sample
output = []

for i in range(len(encode)):
	encode[i] = core.resize.Bicubic(encode[i], format=vs.YUV420P8, matrix_in_s = "709", matrix_in = 1, primaries_in = 1, transfer_in = 1, matrix_s="709",transfer = 1, primaries = 1)
	#encode[i] = core.Butteraugli.butteraugli(sample, encode[i])
	encode[i] = sg.FrameInfo(encode[i], name[i])
	#sum = sum + encode[i]
	#output.append(core.std.Trim(sum,i*3400-1,i*6800-2))


#core.resize.Bicubic(sample, format=vs.YUV420P8, matrix_in_s = "709", matrix_in = 1, primaries_in = 1, transfer_in = 1, matrix_s="709",transfer = 1, primaries = 1).set_output()
#encodeout = core.std.SetFrameProp(encodeout, prop="_Primaries", delete=True)
#core.Butteraugli.butteraugli(f1, f2).set_output()
#encode[1].set_output()
core.imwri.Write(core.std.SelectEvery(sample, 100, range(1)), "PNG", "D:\compare\00\%d,png")
encode[3].set_output()-
