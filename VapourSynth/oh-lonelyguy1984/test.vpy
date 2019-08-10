import vapoursynth as vs
core = vs.core
core.num_threads = 1
core.max_cache_size = 1000

src_path = r"C:/fivefeetapart.mkv"
src = core.lsmas.LWLibavSource(source=src_path, threads=1)

cropped = core.std.Crop(src, 0, 0, 140, 140)

new_height = round(cropped.height*1280/cropped.width/2)*2
new_width = round(cropped.width*720/cropped.height/2)*2

if new_height < 720 and new_width >= 1280 :
	new_width = 1280
elif new_height >= 720 and new_width < 1280 :
	new_height = 720

resized = core.resize.Spline36(clip	= cropped, width = new_width, height = new_height, src_left = 0, src_top = 0, src_height = cropped.height, src_width = cropped.width)

#resized = core.text.Text(resized, "Source", alignment = 9)

#resized = core.text.FrameProps(resized)

sample = core.std.SelectEvery(resized, 8000, range(200))
#每隔3000取200帧
sample = core.std.AssumeFPS(sample, resized)
#同步帧率 sample同步为resized的帧率

sample.set_output()


