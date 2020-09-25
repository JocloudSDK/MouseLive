#使用说明
#1、新建一个空的文件夹
#2、将dev.tar.gz、bin.tar.gz和该文件拷贝到新建的空文件夹下
#3、运行该脚本，生成打包文件package.zip

import tarfile
import shutil
import zipfile
import os
 
def get_file_name(file_dir):
	L=[]
	for root,dirs,files in os.walk(file_dir):
		for file in files:
			L.append(file)
	return L


def un_tar(file_names, file_path):
	file_name=file_names
	tar = tarfile.open(file_path+"\\"+file_name)
	
	if file_name.find(".tar.gz")!=-1:
		file_name=file_name.replace(".tar.gz", "")
	else:
		pass
	
	
	if os.path.isdir(file_name):
		pass
	else:
		pass
		
	names = tar.getnames()
	
	for name in names:
		print(name)
		tar.extract(name, file_path )
	return

def mkdir(path):
    path=path.strip()
    path=path.rstrip("\\")
    isExists=os.path.exists(path)
    if not isExists:
        os.makedirs(path) 
        print path + "create success"
        return True
    else:
        print path + "is exist"
        return False
		
def zip_pack(package_path):
    file_news = package_path +'.zip' 
    z = zipfile.ZipFile(file_news,'w',zipfile.ZIP_DEFLATED) 
    for dirpath, dirnames, filenames in os.walk(package_path):
        fpath = dirpath.replace(package_path,'') 
        fpath = fpath and fpath + os.sep or ''
        for filename in filenames:
            z.write(os.path.join(dirpath, filename),fpath+filename)
    z.close()
	
def del_fold(cur_dir):
	package_dir = cur_dir + "\\package"
	include_dir = package_dir + "\\include"
	lib_dir = package_dir + "\\lib"
	dll_dir = package_dir + "\\dll"
	zip_dir = package_dir + ".zip"

	if (os.path.exists(package_dir)):
		shutil.rmtree(package_dir)
	if (os.path.exists(include_dir)):
		shutil.rmtree(include_dir)
	if (os.path.exists(lib_dir)):
		shutil.rmtree(lib_dir)
	if (os.path.exists(dll_dir)):
		shutil.rmtree(dll_dir)
	if os.path.isfile(zip_dir):
		os.remove(zip_dir)
 
if __name__ == '__main__':
	cur_dir=os.getcwd()
	package_dir = cur_dir + "\\package"
	include_dir = package_dir + "\\include"
	lib_dir = package_dir + "\\lib"
	dll_dir = package_dir + "\\dll"

	del_fold(cur_dir)

	files=[]
	files=get_file_name(cur_dir)
	for file_name in files:
		if file_name.find(".tar.gz")!=-1:
			un_tar(file_name, cur_dir)
		else:
			pass

	mkdir(package_dir)
	mkdir(include_dir)
	mkdir(lib_dir)
	mkdir(dll_dir)

	shutil.copy(cur_dir + "\\lib\\release\\MediaCloudSdk.lib", lib_dir)
	src_inc_folder = cur_dir + "\\include\\YYMediaSdk"

	for files in os.listdir(src_inc_folder):
		src = os.path.join(src_inc_folder, files)
		dst = os.path.join(include_dir, files)
		shutil.copy(src, dst)

			
	dll_list = ["Argo_pc.dll", "AudioDec.dll", "AudioEnc.dll", "AudioEngine.dll",	\
			   "AudioUtil.dll", "avcodec-57.dll", "avformat-57.dll", "avstp.dll",	\
			   "avutil-55.dll", "concrt140.dll", "Decoder.dll", "deviceinfokit.dll", "dwipcproc.exe",		\
			   "dwipcproc_x64.exe", "dwipcwrapper.dll", "dwipcwrapper_x64.dll", 
			   "dwx265.dll", "dwx265_x64.dll", "dwx265test.exe", "HookAudio.dll", "hwCodecTest.exe",	\
			   "hwdec.dll", "libhwcodec.dll", "libhwdecoder.dll",		\
			   "libprotobuf.dll", "Mdegrain_Dll.dll", "MediaCloudSdk.dll",	\
			   "Mp3enc.dll", "msvcp120.dll", "msvcr120.dll", "NetIoFV.dll", "of_effect.dll", "of_glew.dll",		\
			   "reportsdk.dll", "servicesdk.dll", "swresample-2.dll", "swscale-4.dll", "TransMod.dll", "transportfilter.dll",	\
			   "VideoInputFV.dll", "VideoSdk.dll"]

	src_lib_folder = cur_dir + "\\bin\\release"
	for dlls in dll_list:
		src = os.path.join(src_lib_folder, dlls)
		dst = os.path.join(dll_dir, dlls)
		shutil.copy(src, dst)

	zip_pack(package_dir)
	shutil.rmtree(package_dir)
	shutil.rmtree(cur_dir + "\\bin")
	shutil.rmtree(cur_dir + "\\include")
	shutil.rmtree(cur_dir + "\\lib")



