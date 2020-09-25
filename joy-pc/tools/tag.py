# -*- coding: utf-8 -*-
import os
import shutil

def replaceFile(filePath):
    print('replace file begin')
    with open(filePath, 'r') as in_file:
        data = in_file.read()
        pass
    writeFile(filePath, data)
    print('replace file end')
    pass

def writeFile(filePath, data):
    data = data.replace('2117985714', '请到官方申请，并输入 APPID')
    data = data.replace('eeb85a58-6cc5-11ea-8247-b42e995a6c82', '请输入申请的美颜字串')

    with open(filePath, 'w') as out_file:
        out_file.write(data)
        pass

    pass

def pushTag(dir, tagVersion, fileName):
    """
    1. 把不发布的文件，copy，并修改内部的值
    2. git add，commit，push

    1. 获取 iOS 版本号
    2. 获取 git commit 信息
    3. 创建 tag
    4. push tag

    1. 把重命名的文件换成原来的文件名
    2. git add，commit，push
    """

    # 获取 commit + branch
    commitId = os.popen("git rev-parse --short HEAD").read()
    print('=== commit id = ' + commitId)
    commitId = commitId[:-1]

    branchId = os.popen("git symbolic-ref --short -q HEAD").read()
    print('=== branch id = ' + branchId)
    branchId = branchId[:-1]

    gitTagCommit = branchId + '_' + commitId

    srcFile = dir + fileName
    dstFile = dir + fileName + "1"

    shutil.copyfile(srcFile,dstFile)
    print("copy src:" + srcFile + ", dst:" + dstFile)

    replaceFile(srcFile)

    addFile = srcFile[2:]
    gitAdd = "git add " + addFile
    print(gitAdd)
    print(os.popen(gitAdd).read())

    gitCommit = 'git commit -m "delete ' + addFile + ' appid and off number "'
    print(gitCommit)
    print(os.popen(gitCommit).read())

    gitPush = "git push origin " + branchId
    print(gitPush)
    print(os.popen(gitPush).read())

    # =======================

    gitDelTag = 'git tag -d ' + tagVersion
    print(os.popen(gitDelTag).read())

    gitTagCommit = branchId + "_" + commitId
    gitAddTag = 'git tag -a ' + tagVersion + ' -m ' + gitTagCommit
    print(gitAddTag)
    print(os.popen(gitAddTag).read())

    gitPushTag = 'git push origin ' + tagVersion
    print(gitPushTag)
    print(os.popen(gitPushTag).read())

    # =======================

    os.remove(srcFile)
    os.rename(dstFile, srcFile)
    print("rename src:" + dstFile + ", dst:" + srcFile)
    pass

    addFile = srcFile[2:]
    gitAdd = "git add " + addFile
    print(gitAdd)
    print(os.popen(gitAdd).read())

    gitCommit = 'git commit -m "add ' + addFile + '"'
    print(gitCommit)
    print(os.popen(gitCommit).read())

    gitPush = "git push origin " + branchId
    print(gitPush)
    print(os.popen(gitPush).read())

    pass

if __name__ == "__main__":
    dir = "./../src/mainui/"
    tagVersion = 'v1.0.1'
    fileName = "AppInfo.h"
    pushTag(dir, tagVersion, fileName)
    pass
