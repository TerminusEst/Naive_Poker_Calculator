#cython_test_compiler
# python cython_test_compiler.py build_ext --inplace

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext = Extension("SCORE", sources = ["combinations.pyx"])

setup(ext_modules=[ext], cmdclass = {'build_ext': build_ext})
