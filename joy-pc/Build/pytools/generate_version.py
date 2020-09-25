#读取svn号及version.info文件更新dll的版本信息
import os
import re
import codecs
import logging
import subprocess
import xml.etree.ElementTree
import time

def getMainVer(fileName):
    with open(fileName) as f:
        for line in f:
            line = line.replace(' ', '')
            result = re.search("mainVersion=", line)
            if not result:
                continue
            keyValue = line.split("=")
            return keyValue[1]
    return "1.0";

def getSvnRevision():
    logger = logging.getLogger(__name__)
    log_xml = subprocess.check_output('svn log --limit 1 --xml')
    logger.info(log_xml)
    log_entry_element = xml.etree.ElementTree.XML(log_xml).find('logentry')
    revision = log_entry_element.get('revision')
    return revision

def getGitRevision():
    logger = logging.getLogger(__name__)
    revision = subprocess.check_output('git rev-parse --short HEAD')
    revision = bytes.decode(revision)
    revision = revision[:-1]
    revision = str(int(revision, 16))
    logger.info(revision)
    return revision

def getDataBuilderNumber():
    logger = logging.getLogger(__name__)
    now = time.strftime('%m%d')
    bdnumber = os.environ.get('BUILD_NUMBER') 
    revision = now + bdnumber
    logger.info(revision)
    return revision

def setRcVersion(rcfile, mainVerStr, svnVer):
    mainVer = mainVerStr.split(".")
    version1 = 'FILEVERSION ' + mainVer[0] + ',' + mainVer[1] + ',' + svnVer[:4] + ',' + svnVer[4:]
    version2 = '\"ProductVersion\", \"' + mainVerStr + '.' + svnVer + '\"'
    with codecs.open(rcfile, 'r', 'GBK') as f:
        content = f.read()
    pattern = re.compile('FILEVERSION \d+,\d+,\d+,\d+')
    content = pattern.sub(version1, content)
    pattern = re.compile('\"ProductVersion\", \"[\d, ]+\"')
    content = pattern.sub(version2, content)
    with codecs.open(rcfile, 'w',' GBK') as f:
        f.write(content)
    return

if __name__ == "__main__":
    pythonPath = os.path.abspath(os.path.dirname(__file__))
    slnPath = os.path.abspath(os.path.join(pythonPath, "../.."))
    cwdPath = os.getcwd()
    os.chdir(slnPath)
    if os.environ.get('BUILD_NUMBER') is None:
        os._exit(0)
    svnVer = getDataBuilderNumber()
    versionFile = slnPath + os.sep + "VideoSdk" + os.sep + "VideoSDKRevision.h"
    with codecs.open(versionFile, 'r', 'GBK') as f:
        content = f.read()
    pattern = re.compile(r'(?<=VIDEO_SDK_REVISION = _T\(")\d+(?="\);)')
    content = pattern.sub(svnVer, content)
    with codecs.open(versionFile, 'w', ' GBK') as f:
        f.write(content)
    mainVerStr = getMainVer(slnPath + os.sep + "Build" + os.sep + "config" + os.sep + "version.info")

    rcFile1 = slnPath + os.sep + 'VideoSdk' + os.sep + 'VideoSdk.rc'
    rcFile2 = slnPath + os.sep + 'VideoInputFV' + os.sep + 'VideoInputFV.rc'
    rcFile3 = slnPath + os.sep + 'libhwcodec' + os.sep + 'libhwcodec.rc'
    rcFile4 = slnPath + os.sep + 'ipc' + os.sep + 'hwdec' + os.sep + 'hwdec.rc'
    rcFile5 = slnPath + os.sep + 'YYMediaSdk' + os.sep + 'YYMediaSdk.rc'
    setRcVersion(rcFile1, mainVerStr, svnVer)
    setRcVersion(rcFile2, mainVerStr, svnVer)
    setRcVersion(rcFile3, mainVerStr, svnVer)
    setRcVersion(rcFile4, mainVerStr, svnVer)
    setRcVersion(rcFile5, mainVerStr, svnVer)

    os.chdir(cwdPath)
