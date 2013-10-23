import os
import sys

data = {}
vals = []

#fo = open('questBasic.txt', 'w')
fo = open(sys.argv[2], 'w')

#for fileName in os.listdir('./Quest/'):
for fileName in os.listdir(sys.argv[1]):
    if '.txt' in fileName.lower() and fileName.find("ONDCP ZIP") != -1:
        #f = open('./Quest/' + fileName, 'Ur')
        #fixing (weak) windows file n' path handling
        p = os.path.normpath(sys.argv[1])
        filePath = os.path.join(p, fileName)

        f = open(filePath, 'r')
        for line in f:
            l = line.split(',')
            if len(l) == 10:
                drug = l[6]
                vals = [l[0],l[1].strip('"'),l[8],l[9].strip('\n')]
            elif len(l) == 11:
                drug = l[7]
                vals = [l[0],l[1].strip('"'),l[9],l[10].strip('\n')]
            else:
                drug = l[5]
                vals = [l[0],l[1].strip('"'),l[7],l[8].strip('\n')]

            if vals[0] != '"Date"':
                dt = vals[0].split()
                d = dt[0].split('/')
                m = d[0]
                y = d[2]

                if int(m) < 10:
                    m = '0' + m
                if sys.argv[3] == 'Month':
                    date = y + m
                else:
                    date = y

                if vals[2] != '':
                    val = [m,y,vals[2],vals[3]]
                    zip3 = vals[1]
                    
                    if not zip3 in data:
                        data[zip3] = {}
                    if not date in data[zip3]:
                        data[zip3][date] = {}
                    if not drug in data[zip3][date]:
                        data[zip3][date][drug] = val
                    else:
                        vold = data[zip3][date][drug]
                        vnew = ['','',0,0]
                        vnew[0] = vold[0]
                        vnew[1] = vold[1]
                        vnew[2] = int(vold[2]) + int(vals[2])
                        vnew[3] = int(vold[3]) + int(vals[3])
                        data[zip3][date][drug] = vnew
                
        f.close()

aggdata = []
drugs = ['"Amphetamines"','"Cocaine Metabolite"','"Marijuana Metabolite"','"Opiates"',\
         '"Phencylidine"']
for zip3,d in data.iteritems():
    dates = d.keys()
    dates.sort()

    vals = []

    for i in range(len(dates)):
        dt = dates[i]
        vals.append(dt)
        vals.append(zip3)

        for i in range(len(drugs)):
            drug = drugs[i]
            if not drug in data[zip3][dt]:
                vals.append('')
            else:
                vals.append((float(data[zip3][dt][drug][3]) / float(data[zip3][dt][drug][2]))*1000)
        aggdata.append(vals)
        vals = []

fo.write('DATE,ZIP3,Amphetamines,Cocaine,Marijuana,Opiates,Phencylidine\n')
for l in aggdata:
    s = ''
    for i in range(len(l)-1):
        s += str(l[i]) + ','
    s += str(l[len(l)-1]) + '\n'
    fo.write(s)

fo.close();
