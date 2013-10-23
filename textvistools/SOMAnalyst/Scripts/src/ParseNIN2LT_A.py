import csv
import string
import sys
import os
import arcgisscripting

gp = arcgisscripting.create()

inFile = sys.argv[1]
outFile = sys.argv[2]
smod = sys.argv[3]
tmod = sys.argv[4]
delblank = sys.argv[5]


# Boolean used to determine if zipagg has been run
zipcount = 0

def zipagg():
    global zipvar
    f=open('newnin.csv', 'w')
    reader = csv.reader(open(inFile))
    for row in reader:
        zipcount = 1
        row.insert(1,row[8])
        del row[9]
        del row[3]
        del row[2]
        for r in row:
            r = str(r)
            f.write(r + ',')
        f.write('\n')
    f.close()


def citagg():
    f=open('newnin.csv', 'w')
    reader = csv.reader(open(inFile))
    for row in reader:
        zipbool = 1
        row.insert(1,row[2])
        del row[3]
        for r in row:
            r = str(r)
            f.write(r + ',')
        f.write('\n')
    f.close()

def ziptest():
    global m
    m = 0
    p = 0
    logfile = open('test.txt', 'w')
    
    for a in data.keys():
        for b in data[a].keys():
            for c in data[a][b].keys():
                m+=1
                for d in data[a][b][c].keys():
                    for e in data[a][b][c][d].keys():
                        for f in data[a][b][c][d][e].keys():
                            for g in data[a][b][c][d][e][f].keys():
                                for h in data[a][b][c][d][e][f][g].keys():
                                    n = data[a][b][c][d][e][f][g].values()
                                    o = n[0]
                                    p = 0
                                    while p <= o:
                                        #print (str(m)) + ',' + a + ',' + c + ',' + b + ',' + d +',' + e + ',' + f
                                        statement = ((str(m)) + ',' + a + ',' + b + ',' + c + ',' + d + ',' + e + ',' + g + ',' + h)
                                        logfile.write(statement + '\n')
                                        p+=1

    logfile.close()

def cittest():
    m = 0
    p = 0
    logfile = open('test.txt', 'w')
    
    for a in data.keys():
        for b in data[a].keys():
            for c in data[a][b].keys():
                for d in data[a][b][c].keys():
                    m+=1
                    for e in data[a][b][c][d].keys():
                        for f in data[a][b][c][d][e].keys():
                            for g in data[a][b][c][d][e][f].keys():
                                for h in data[a][b][c][d][e][f][g].keys():
                                    zip = h[:-4]
                                    for i in data[a][b][c][d][e][f][g][h].keys():
                                        for j in data[a][b][c][d][e][f][g][h][i].keys():
                                            for k in data[a][b][c][d][e][f][g][h][i][j].keys():
                                                n = data[a][b][c][d][e][f][g][h][i][j].values()
                                                o = n[0]
                                                p = 0
                                                while p < o:
                                                    #print (str(m)) + ',' + a + ',' + c + ',' + b + ',' + d +',' + e + ',' + f
                                                    statement = (str(m)) + ',' + a + ',' + b + ',' + c + ',' + zip + ',' + d + ',' + e + ',' + f + ',' + i + ',' + k
                                                    logfile.write(statement + '\n')
                                                    p+=1
    logfile.close()


def delblankkeys():
    if smod == 4:
        del data['CA']['     ']
    elif smod == 6:
        del data['CA']['   ']

    
    



###### The below code uses variable Tmod for determining the aggregation by time.
###### It does this by modifying the dictionaries created by cutting off the input dates. IE. 20060618 - > 200606
###### First implementation in lines 194 to 202
##



if tmod == 'year':
    tmod = 4
elif tmod == 'month':
    tmod = 2
elif tmod == 'day':
    tmod = -8
else:
    tmod = -8


if smod == 'zip5':
    zipagg()
    smod = 4
elif smod == 'zip3':
    zipagg()
    smod = 6
else:
    smod = -9

xmod = 0


reader = csv.DictReader(open('newnin.csv'))
d={} # creates dictionary 'd'
d['STATE_CODE'] = [] #creates a key:value pair in dict 'd' where the value is a list
d['CITY'] = []
d['COUNTY'] = []
d['OPERATION_DATE_BEGIN'] = []
d['OPERATION_TIME_BEGIN'] = []
d['OPERATION_TYPE'] = []
d['OFFICE_NAME'] = []
d['OFFICE_COUNTY'] = []
d['ZIP'] = []
d['EVENT_CATEGORY'] = []
d['COMMODITY_CATEGORY'] = []
d['COMMODITY_TYPE'] = []
d['LATITUDE_DECIMAL'] = []
d['LONGITUDE_DECIMAL'] = []


reader = csv.DictReader(open('newnin.csv'))
for row in reader:
    d['STATE_CODE'].append(row['STATE_CODE'])
##    d['CITY'].append(row['CITY'])
##    d['COUNTY'].append(row['COUNTY'])
    d['OPERATION_DATE_BEGIN'].append(row['OPERATION_DATE_BEGIN'])
    d['OPERATION_TIME_BEGIN'].append(row['OPERATION_TIME_BEGIN'])
    d['OPERATION_TYPE'].append(row['OPERATION_TYPE'])
    d['OFFICE_NAME'].append(row['OFFICE_NAME'])
    d['OFFICE_COUNTY'].append(row['OFFICE_COUNTY'])
    d['ZIP'].append(row['ZIP'])
    d['EVENT_CATEGORY'].append(row['EVENT_CATEGORY'])
    d['COMMODITY_CATEGORY'].append(row['COMMODITY_CATEGORY'])
    d['COMMODITY_TYPE'].append(row['COMMODITY_TYPE'])
    d['LATITUDE_DECIMAL'].append(row['LATITUDE_DECIMAL'])
    d['LONGITUDE_DECIMAL'].append(row['LONGITUDE_DECIMAL'])


def citvar():
    v1 = 'STATE_CODE'
    v2 = 'COUNTY'
    v3 = 'CITY'
    v4 = 'OPERATION_DATE_BEGIN'
    v45 = 'OPERATION_TIME_BEGIN'
    v5 = 'OPERATION_TYPE'
    v6 = 'OFFICE_NAME'
    v7 = 'OFFICE_COUNTY'
    v8 = 'ZIP'
    v9 = 'EVENT_CATEGORY'
    v10 = 'COMMODITY_CATEGORY'
    v11 = 'COMMODITY_TYPE'
    v12 = 'LATITUDE_DECIMAL'
    v13 = 'LONGITUDE_DECIMAL'

def zipvar():
    global v1
    global v2
    global v3
    global v4
    global v5
    global v6
    global v7
    global v8
    global v9
    global v10
    global v11
    global v12
    global v13
    global oneset
    global twoset
    global threeset
    global fourset
    global fiveset
    global sixset
    global sevenset
    global eightset
    v1 = 'STATE_CODE'
    v2 = 'ZIP'
    v3 = 'OPERATION_DATE_BEGIN'
    v4 = 'OPERATION_TYPE'
    v5 = 'OFFICE_NAME'
    v6 = 'OFFICE_COUNTY'
    v7 = 'EVENT_CATEGORY'
    v8 = 'COMMODITY_TYPE'
    oneset = set(d['STATE_CODE'])
    twoset = set(d['ZIP'])
    threeset = set(d['OPERATION_DATE_BEGIN'])
    fourset = set(d['OPERATION_TYPE'])
    fiveset = set(d['OFFICE_NAME'])
    sixset = set(d['OFFICE_COUNTY'])
    sevenset = set(d['EVENT_CATEGORY'])
    comcatset = set(d['COMMODITY_CATEGORY'])
    eightset = set(d['COMMODITY_TYPE'])


if smod == 'zip3' or 'zip5':
    zipvar()
else:
    citvar()









# The below are sets of the unique values in each column of the input data
stateset = set(d['STATE_CODE'])
cityset = set(d['CITY'])
countyset = set(d['COUNTY'])
odbset = set(d['OPERATION_DATE_BEGIN'])
otbset = set(d['OPERATION_TIME_BEGIN'])
otset = set(d['OPERATION_TYPE'])
officeset = set(d['OFFICE_NAME'])
officecountyset = set(d['OFFICE_COUNTY'])
zipcodeset = set(d['ZIP'])
eventset = set(d['EVENT_CATEGORY'])
comcatset = set(d['COMMODITY_CATEGORY'])
comtypeset = set(d['COMMODITY_TYPE'])
latset = set(d['LATITUDE_DECIMAL'])
longitudeset = set(d['LONGITUDE_DECIMAL'])


p=0
zipagg()
####Smod first implemented below. Variable b creates dictionary entries of the proper date.
data = {}
for a in oneset:
    data[a] = {}
    for b in twoset:
        b = b[:-(smod)]
        data[a][b] = 0

reader = csv.DictReader(open('newnin.csv'))
for row in reader:
    data[row[v1]][row[v2][:-(smod)]]+= 1

for a in data.keys():
    for b in data[a].keys():
        if data[a][b] == 0:
            del data[a][b]

####Tmod first implemented below. Variable c creates dictionary entries of the proper date.
for a in data.keys():
    for b in data[a].keys():
        data[a][b] = {}
        for c in threeset:
            c = c[:-(tmod)]
            data[a][b][c] = 0

reader = csv.DictReader(open('newnin.csv'))
for row in reader:
    data[row[v1]][row[v2][:-(smod)]][row[v3][:-(tmod)]]+= 1

for a in data.keys():
    for b in data[a].keys():
        for c in data[a][b].keys():
            if data[a][b][c] == 0:
                del data[a][b][c]


for a in data.keys():
    for b in data[a].keys():
        for c in data[a][b].keys():
            data[a][b][c] = {}
            for d in fourset:
                #d = d[:-(tmod)]
                data[a][b][c][d] = 0


reader = csv.DictReader(open('newnin.csv'))
for row in reader:
    data[row[v1]][row[v2][:-(smod)]][row[v3][:-(tmod)]][row[v4] ]+=1

for a in data.keys():
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                if data[a][b][c][d] == 0:
                    del data[a][b][c][d]

##print
##print 'Output 5'
##print data

for a in data.keys():
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                data[a][b][c][d] = {}
                for e in fiveset:
                    data[a][b][c][d][e] = 0


reader = csv.DictReader(open('newnin.csv'))
for row in reader:
    data[row[v1]][row[v2][:-(smod)]][row[v3][:-(tmod)]][row[v4] ][row[v5]]+=1

for a in data.keys():
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                for e in data[a][b][c][d].keys():
                    if data[a][b][c][d][e] == 0:
                        del data[a][b][c][d][e]

##print
##print 'Output 6'
##print data

for a in data.keys():
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                for e in data[a][b][c][d].keys():
                    data[a][b][c][d][e] = {}
                    for f in sixset:
                        data[a][b][c][d][e][f] = 0


reader = csv.DictReader(open('newnin.csv'))
for row in reader:
    data[row[v1]][row[v2][:-(smod)]][row[v3][:-(tmod)]][row[v4] ][row[v5]][row[v6]]+=1

for a in data.keys():
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                for e in data[a][b][c][d].keys():
                    for f in data[a][b][c][d][e].keys():
                        if data[a][b][c][d][e][f] == 0:
                            del data[a][b][c][d][e][f]

##print
##print 'Output 7'
##print data

for a in data.keys():
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                for e in data[a][b][c][d].keys():
                    for f in data[a][b][c][d][e].keys():
                        data[a][b][c][d][e][f] = {}
                        for g in sevenset:
                            data[a][b][c][d][e][f][g] = 0


reader = csv.DictReader(open('newnin.csv'))
for row in reader:
    data[row[v1]][row[v2][:-(smod)]][row[v3][:-(tmod)]][row[v4] ][row[v5]][row[v6]][row[v7]]+=1

for a in data.keys():
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                for e in data[a][b][c][d].keys():
                    for f in data[a][b][c][d][e].keys():
                        for g in data[a][b][c][d][e][f].keys():
                            if data[a][b][c][d][e][f][g] == 0:
                                del data[a][b][c][d][e][f][g]

##print
##print 'Output 8'
##print data

for a in data.keys():
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                for e in data[a][b][c][d].keys():
                    for f in data[a][b][c][d][e].keys():
                        for g in data[a][b][c][d][e][f].keys():
                            data[a][b][c][d][e][f][g] = {}
                            for h in eightset:
                                data[a][b][c][d][e][f][g][h] = 0



reader = csv.DictReader(open('newnin.csv'))
for row in reader:
    data[row[v1]][row[v2][:-(smod)]][row[v3][:-(tmod)]][row[v4] ][row[v5]][row[v6]][row[v7]][row[v8]]+=1

for a in data.keys():
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                for e in data[a][b][c][d].keys():
                    for f in data[a][b][c][d][e].keys():
                        for g in data[a][b][c][d][e][f].keys():
                            for h in data[a][b][c][d][e][f][g].keys():
                                if data[a][b][c][d][e][f][g][h] == 0:
                                    del data[a][b][c][d][e][f][g][h]

##print
##print 'Output 8'
##print data

for a in data.keys():
    break
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                for e in data[a][b][c][d].keys():
                    for f in data[a][b][c][d][e].keys():
                        for g in data[a][b][c][d][e][f].keys():
                            for h in data[a][b][c][d][e][f][g].keys():
                                data[a][b][c][d][e][f][g][h] = {}
                                for i in nineset:
                                    data[a][b][c][d][e][f][g][h][i] = 0


reader = csv.DictReader(open('newnin.csv'))
for row in reader:
    break
    data[row[v1]][row[v2]][row[v3][:-(tmod)]][row[v4][:-(tmod)]][row[v5]][row[v6]][row[v7]][row[v8]][row[v9]]+=1

for a in data.keys():
    break
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                for e in data[a][b][c][d].keys():
                    for f in data[a][b][c][d][e].keys():
                        for g in data[a][b][c][d][e][f].keys():
                            for h in data[a][b][c][d][e][f][g].keys():
                                print h
                                for i in data[a][b][c][d][e][f][g][h].keys():
                                    if data[a][b][c][d][e][f][g][h][i] == 0:
                                        del data[a][b][c][d][e][f][g][h][i]

##print
##print 'Output 9'
##print data

for a in data.keys():
    break
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                for e in data[a][b][c][d].keys():
                    for f in data[a][b][c][d][e].keys():
                        for g in data[a][b][c][d][e][f].keys():
                            for h in data[a][b][c][d][e][f][g].keys():
                                for i in data[a][b][c][d][e][f][g][h].keys():
                                    data[a][b][c][d][e][f][g][h][i] = {}
                                    for j in tenset:
                                        data[a][b][c][d][e][f][g][h][i][j] = 0


reader = csv.DictReader(open('newnin.csv'))
for row in reader:
    break
    data[row[v1]][row[v2]][row[v3]][row[v4][:-(tmod)]][row[v5]][row[v6]][row[v7]][row[v8]][row[v9]][row[v10]]+=1

for a in data.keys():
    break
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                for e in data[a][b][c][d].keys():
                    for f in data[a][b][c][d][e].keys():
                        for g in data[a][b][c][d][e][f].keys():
                            for h in data[a][b][c][d][e][f][g].keys():
                                for i in data[a][b][c][d][e][f][g][h].keys():
                                    for j in data[a][b][c][d][e][f][g][h][i].keys():
                                        if data[a][b][c][d][e][f][g][h][i][j] == 0:
                                            del data[a][b][c][d][e][f][g][h][i][j]



for a in data.keys():
    break
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                for e in data[a][b][c][d].keys():
                    for f in data[a][b][c][d][e].keys():
                        for g in data[a][b][c][d][e][f].keys():
                            for h in data[a][b][c][d][e][f][g].keys():
                                for i in data[a][b][c][d][e][f][g][h].keys():
                                    for j in data[a][b][c][d][e][f][g][h][i].keys():
                                        data[a][b][c][d][e][f][g][h][i][j] = {}
                                        for k in elevenset:
                                            data[a][b][c][d][e][f][g][h][i][j][k] = 0


reader = csv.DictReader(open('newnin.csv'))
for row in reader:
    break
    data[row[v1]][row[v2]][row[v3]][row[v4][:-(tmod)]][row[v5]][row[v6]][row[v7]][row[v8]][row[v9]][row[v10]][row[v11]]+=1

for a in data.keys():
    break
    for b in data[a].keys():
        for c in data[a][b].keys():
            for d in data[a][b][c].keys():
                for e in data[a][b][c][d].keys():
                    for f in data[a][b][c][d][e].keys():
                        for g in data[a][b][c][d][e][f].keys():
                            for h in data[a][b][c][d][e][f][g].keys():
                                for i in data[a][b][c][d][e][f][g][h].keys():
                                    for j in data[a][b][c][d][e][f][g][h][i].keys():
                                        for k in data[a][b][c][d][e][f][g][h][i][j].keys():
                                            if data[a][b][c][d][e][f][g][h][i][j][k] == 0:
                                                del data[a][b][c][d][e][f][g][h][i][j][k]
if delblank == 'yes':
    delblankkeys()

otlist = list(otset)
eventlist = list(eventset)
comtypelist = list(comtypeset)


#### I create two headers
#### aggheader is just the attributes
#### header is time/locus IDs, and the attributes
aggheader = []
aggheader = aggheader + otlist + eventlist + comtypelist


header = []
header.append(v1)
header.append(v2)
header.append(v3)
header.append(v4)

header = header + otlist + eventlist + comtypelist

headcount = 0
for i in header:
    header[headcount] = i.strip()
    headcount+=1





#### The function below creates the file text.txt, which is where aggregation level is determined.
#### Later, a reader will go over test.txt and compile the final data file

ziptest()






#### Rowlist is a dictionary, where the key is the aggregation(time/locus) ID and the Key is a list which will become the output row
rowlist = {}
n = 1


x=0

#### Variable m is equal to the number of time/locus ID's, so this loop will create a key value pair for each time/locus
while n <= m:
    rowlist[n] = []
    for i in aggheader:
        rowlist[n].append(0)
    n+=1

#### This code loops over test.txt line by line and populates the arrays created above
rowcount=0
reader = csv.reader(open("test.txt"))
for row in reader:
    rowcount+=1
    y = row[0]
    y = int(y)
    for r in row:
        x = -1
        for i in aggheader:
            x+=1
            if r == i:
                rowlist[y][x] +=1



#### This loops strips blank spaces out of aggheader. Strictly aesthetic.
aggheadcount = 0
for i in aggheader:
    aggheader[aggheadcount] = i.strip()
    aggheadcount+=1

#### Here we open/create the final output file
f = open(outFile, 'w')

#### Variable headcount is equal to the number of attribute columns
headcount = str(len(aggheader))
rowcounter = 1

#### Here we write the header to the final output file
header = str(header)
f.write('ID'+ ',' + header[+1:][:-1] + '\n')

#### here we write all other rows but header to the final output file.
####
#### statement = ((str(m)) + ',' + a + ',' + c.strip() + ',' + b.strip() + ',' + d.strip()+', ' )
####                    f.write(statement)
####                    f.write(rowstatement + '\n')
#### m is the time/locus ID, a,c,b and d are the state, county, city and date, rowstatement is the attribute numbers


m=0
reader = csv.reader(open(outFile))
for a in data.keys():
    for b in data[a].keys():
        for c in data[a][b].keys():
            for i in rowlist:
                m+=1
                row = str(rowlist[rowcounter])
                rowstatement = row[+1:][:-1]
                rowcounter+=1
                statement = ('\'' + b.strip() + '\'' + ',' + c.strip() + ', ')
                f.write(statement)
                f.write(rowstatement + '\n')
                break

f.close()

os.remove('newnin.csv')







