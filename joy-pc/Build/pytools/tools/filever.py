import os
import struct
import glob

import optparse
import array
from ctypes import *


def GetFileVersion(filename):
    """
    extra version from a file
    """
    size = windll.version.GetFileVersionInfoSizeA(filename, None)
    if not size:
        return ''

    string_buf = create_string_buffer(size)
    windll.version.GetFileVersionInfoA(filename, None, size, string_buf)
    r = c_uint()
    l = c_uint()

    # Look for codepages
    windll.version.VerQueryValueA(string_buf, '\\VarFileInfo\\Translation', byref(r), byref(l))
    if not l.value:
        return ''

    codepages = array.array('H', string_at(r.value, l.value))
    codepage = tuple(codepages[:2].tolist())

    windll.version.VerQueryValueA(string_buf, ('\\StringFileInfo\\%04x%04x\\FileVersion') % codepage, byref(r), byref(l))
    ver_str = string_at(r.value, l.value)
    
    ver_number = []
    for ver_str in ver_str.split('.'):
        ver_number.append(int(ver_str.strip('\x00')) & 0xffff)

    return ver_number
    