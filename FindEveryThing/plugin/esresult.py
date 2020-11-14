#coding=utf-8
import os
command ="es e:\\dabao137"
r = os.popen(command)
info = r.readlines()
print(info)
# for line in info:
    # line = line.strip('\r\n')
    # print(line)
