#!/bin/sh
scons platform=linux target=template_release
cp demo/bin/libgdexample.linux.template_release.x86_64.so ../gamejam2025/bin/
