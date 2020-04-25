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
cropped = core.std.Crop(cropped, 0, 0, 18, 18)


sample = core.std.SelectEvery(cropped, 120000, range(200))
#每隔3000取200帧
sample = core.std.AssumeFPS(sample, cropped)
#同步帧率 sample同步为resized的帧率
sample = core.resize.Bicubic(sample, matrix_s="709")
sample.set_output()