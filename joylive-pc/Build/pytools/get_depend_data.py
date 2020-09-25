#!python
# -*- coding: utf-8 -*-
#
#
# brief     get depend data for ini config
# $Rev::           $:  Revision of last commit
# $Author::        $:  Author of last commit
# $Date::          $:  Date of last commit
#


u"""从外部获取指定依赖的数据"""

import os
import sys
import distutils.dir_util
import shutil
import hashlib
import logging
import ConfigParser
import urllib2
import tarfile
import tools.osutils

REPO_CACHE_DIR = os.path.join(os.environ['APPDATA'], 'dw_repo')
REPO_URL_ROOT = "http://repo.yypm.com/dwintegrate"

class ConfigurePhase(object):

    def __init__(self, depends_dir, depends_cfg):
        self._logger = logging.getLogger(__name__)
        self._depends_dir=depends_dir
        self._config_file=depends_cfg

    def configure(self):
        distutils.dir_util.mkpath(REPO_CACHE_DIR)
        distutils.dir_util.mkpath(self._depends_dir)

        depends = ConfigParser.SafeConfigParser()
        # depends中，必须允许大写的key
        depends.optionxform = str
        depends.read(self._config_file)

        # 整个依赖库，称为repository，简称repo
        # repo下面，分repo_section，如dw3rd、internal等
        # 每个repo_session，包含若干个artifact

        for repo_section in depends.sections():
            artifacts = {}

            for artifact_name, artifact_version in depends.items(repo_section):
                artifacts[artifact_name] = Artifact(repo_section, artifact_name, artifact_version, self._depends_dir)

            self._tidy_outofdate_artifact(repo_section, artifacts)

            for artifact in artifacts.itervalues():
                artifact.config()

        # 没有对应的videosdk版本构建先这样处理.
        print('copy Build\depends')
        tools.osutils.copy('..\\shadow\\bin\\release', [
                    {
                        'dir': '.\\depends',
                        'include': ['*.exe', '*.dll'],
                    },
                ])
        print('copy yyvideosdk2015')
        tools.osutils.copy('..\\shadow\\bin\\release', [
                    {
                        'dir': '.\\yyvideosdk2015\\bin\\release',
                        'include': ['**'],
                    },
                ])

    def _tidy_outofdate_artifact(self, repo_section, artifacts):
        repo_section_dir = os.path.join(self._depends_dir, repo_section)
        if os.path.isdir(repo_section_dir):
            for d in os.listdir(repo_section_dir):
                if not artifacts.has_key(d):
                    distutils.dir_util.remove_tree(os.path.join(repo_section_dir, d))

class Artifact(object):

    def __init__(self, section, name, version, depends_dir):
        self._logger = logging.getLogger(__name__)

        self._section = section
        self._name = name
        self._version = version
        self._depends_dir = depends_dir

        # 每个artifact都在3个地方存在：
        #   repo：http服务器上，放着version.info和若干tar.gz
        #   cache：本地的%AppData%/dw_repo里，作为http服务器的缓存，同样有version.info和tar.gz
        #   local：working copy内，被实际使用到的文件。只有tar.gz和解压后的内容，不包含version.info

        self._repo_path = "%s/%s/%s/%s" % (REPO_URL_ROOT,
            self._section,
            self._name,
            self._version)

        self._cache_path = os.path.join(REPO_CACHE_DIR,
            self._section,
            self._name,
            self._version)

        self._local_path = os.path.join(self._depends_dir,
            self._section,
            self._name)
        # 注意，local在存放时，并不需要self._version

        self._logger.debug('''artifact paths:
     repo: %s
    cache: %s
    local: %s''' % (self._repo_path,
        self._cache_path,
        self._local_path))

        self._cache_version_info_path = os.path.join(self._cache_path, 'version.info')

    def config(self):
        self._logger.info('config [%s.%s] start', self._name, self._version)
        self._config()
        self._logger.info('config [%s.%s] finish', self._name, self._version)

    def _config(self):
        # version为latestbuild的artifact，不作缓存
        if self._version == 'latestbuild':
            self._sync_local_with_repo()
            return

        if not self._cache_ok():
            self._sync_cache_with_repo()
            if not self._cache_ok():
                raise Exception('cache still not ok')

        version_config = self._read_version_config()

        if not self._local_ok(version_config):
            self._sync_local_with_cache(version_config)

        self._transfer_to_bin()

    def _read_version_config(self):
        version_config = ConfigParser.SafeConfigParser()
        # version_config中，必须允许大写的key
        version_config.optionxform = str
        version_config.read(self._cache_version_info_path)

        return version_config

    def _sync_local_with_repo(self):
        u"""直接从repo下载到local，由于没有version.info，只能尝试去下载"""
        if os.path.exists(self._local_path):
            distutils.dir_util.remove_tree(self._local_path)
        distutils.dir_util.mkpath(self._local_path)

        file_list = [
            'bin.tar.gz',
            'dev.tar.gz',
            'pdb.tar.gz',
        ]

        for f in file_list:
            self._download_ignore_404(f, self._local_path)

        self._unpack_all_tar()
        self._transfer_to_bin()

    def _cache_ok(self):
        self._logger.info('check cache integrity of [%s] ...', self._cache_path)

        if not os.path.isdir(self._cache_path):
            self._logger.info('dir [%s] is not exist', self._cache_path)
            return False

        if not os.path.isfile(self._cache_version_info_path):
            self._logger.info('file [%s] is not exist', self._cache_version_info_path)
            return False

        version_config = self._read_version_config()

        if not version_config.has_section('md5'):
            self._logger.info('config section [md5] is not exist')

        result = self._check_files_md5(version_config, self._cache_path)
        if result:
            self._logger.info('cache integrity OK')

        return result

    def _sync_cache_with_repo(self):
        if os.path.exists(self._cache_path):
              distutils.dir_util.remove_tree(self._cache_path)
        distutils.dir_util.mkpath(self._cache_path)

        self._download_respect_404('version.info', self._cache_path)

        version_config = self._read_version_config()

        for key in version_config.options('md5'):
            self._download_respect_404(key, self._cache_path)

    def _local_ok(self, version_config):
        self._logger.info('check local integrity of [%s] ...', self._local_path)
        if not os.path.isdir(self._local_path):
            self._logger.info('dir [%s] is not exist', self._local_path)
            return False

        result = self._check_files_md5(version_config, self._local_path)
        if result:
            self._logger.info('cache integrity OK')

        return result

    def _sync_local_with_cache(self, version_config):
        if os.path.exists(self._local_path):
            distutils.dir_util.remove_tree(self._local_path)
        distutils.dir_util.mkpath(self._local_path)

        for key in version_config.options('md5'):
            shutil.copy(os.path.join(self._cache_path, key), self._local_path)

        self._unpack_all_tar()

    def _check_files_md5(self, version_config, target_dir):
        result = True
        for key in version_config.options('md5'):
            file_path = os.path.join(target_dir, key)

            if os.path.isfile(file_path):
                expect_md5 = version_config.get('md5', key)
                actual_md5 = self._md5sum(file_path)
                if expect_md5 != actual_md5:
                    self._logger.info('md5 of [%s] is wrong', file_path)
                    result = False
            else:
                self._logger.info('file [%s] is not exist', file_path)
                result = False

        return result

    def _download_respect_404(self, file_name, dest_dir):
        self._download(file_name, dest_dir, True)

    def _download_ignore_404(self, file_name, dest_dir):
        self._download(file_name, dest_dir, False)

    def _download(self, file_name, dest_dir, report_404):
        url = "%s/%s" % (self._repo_path, file_name)
        dest = os.path.join(dest_dir, file_name)

        ret = None
        try:
            ret = urllib2.urlopen(url, timeout=30)
        except urllib2.HTTPError as e:
            if report_404:
                raise Exception('download fail [%s]' % url)
            else:
                self._logger.debug('[%s] is not exist', url)

        if ret != None:
            with open(dest, 'wb') as w:
                w.write(ret.read())
            self._logger.info('download success [%s]', url)

    def _unpack_all_tar(self):
        # unpack 只会发生在local
        for f in os.listdir(self._local_path):
            if f.endswith('.tar.gz'):
                gz_path = os.path.join(self._local_path, f)

                tar = tarfile.open(gz_path, 'r:gz')
                tar.extractall(self._local_path)
                tar.close()

    def _md5sum(self, file_path, block_size=2**20):
        file = open(file_path, mode="rb")
        md5 = hashlib.md5()
        while True:
            data = file.read(block_size)
            if not data:
                break
            md5.update(data)
        file.close()
        result = md5.hexdigest()
        self._logger.debug("[%s] md5: [%s]", file_path, result)
        return result

    def _transfer_to_bin(self):
        artifact_bin_dir = os.path.join(os.getcwd(), self._local_path, 'bin')
        artifact_bin_debug_dir = os.path.join(os.getcwd(), self._local_path, 'bin', 'debug\\')
        artifact_bin_release_dir = os.path.join(os.getcwd(), self._local_path, 'bin', 'release\\')

        if os.path.isdir(artifact_bin_debug_dir):
            print('copy %s' % artifact_bin_debug_dir)
            tools.osutils.copy('..\\shadow\\bin\\debug', [
                    {
                        'dir': artifact_bin_debug_dir,
                        'include': ['**'],
                    },
                ])

        if os.path.isdir(artifact_bin_release_dir):
            print('copy %s' % artifact_bin_release_dir)
            tools.osutils.copy('..\\shadow\\bin\\release', [
                    {
                        'dir': artifact_bin_release_dir,
                        'include': ['**'],
                    },
                ])
            # 存在release目录，但是缺少debug目录的artifact，把它的release当作debug来用
            if not os.path.isdir(artifact_bin_debug_dir):
                tools.osutils.copy(os.path.join('..\\shadow\\bin', 'debug'), [
                        {
                            'dir': artifact_bin_release_dir,
                        },
                    ])

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print >> sys.stderr,'*** Error: Not enougth parameter ***'
        sys.exit(1)

    log_file = os.path.realpath(sys.argv[0])[0:-3] + '.log'
    logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s[line:%(lineno)d] %(levelname)s %(message)s',
                    datefmt='%a, %d %b %Y %H:%M:%S',
                    filename=log_file,
                    filemode='w')
    configure_phase_ = ConfigurePhase(sys.argv[1], sys.argv[2])
    configure_phase_.configure()
