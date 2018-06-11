import re


file = 'tcs_def_LMTS.rtv'
pattern  = r'-TC =>'
with open(file, 'r') as f :
    testy = ''
    cfgs = ' '
    for line in f:
        if re.findall(pattern,line):
            print "fsf"
            isTest = re.findall(r'"A\w*"',line)
            isCfg = re.findall(r'"C\w*"', line)
            if isTest:
                testy += isTest[0]
                testy += " "
            if isCfg:
                cfgs += isCfg[0]
                cfgs += " "





    print testy
    print cfgs

