## Imports
import os
import sys

#import arcgisscripting
#gp = arcgisscripting.create()

data = {}
vals = []

#fo = open('questBasic.txt', 'w')
fo = open(sys.argv[2], 'w') #Open a specific file(s) designated by the user

#for fileName in os.listdir('./Quest/'):
for fileName in os.listdir(sys.argv[1]): #Folder opened by user designation
    if '.txt' in fileName.lower() and fileName.find("ONDCP ZIP") != -1:
        #f = open('./Quest/' + fileName, 'Ur')
        #fixing (weak) windows file n' path handling
        p = os.path.normpath(sys.argv[1])
        filePath = os.path.join(p, fileName)

        f = open(filePath, 'r') #Open file
        for line in f:
            l = line.split(',')#Split and strip out the commas
            if len(l) == 10:
                drug = l[6]
                vals = [l[0],l[1].strip('"'),l[8],l[9].strip('\n')]
            elif len(l) == 11:
                drug = l[7]
                vals = [l[0],l[1].strip('"'),l[9],l[10].strip('\n')]
            else:
                drug = l[5]
                vals = [l[0],l[1].strip('"'),l[7],l[8].strip('\n')]

            if vals[0] != '"Date"': #Aggregate by the date
                dt = vals[0].split()
                d = dt[0].split('/')
                m = d[0] #Month
                y = d[2] #Year

                if int(m) < 10:
                    m = '0' + m
                if sys.argv[3] == 'Month': #Aggregate by Month
                    date = y + m
                else:
                    date = y #Aggregate by Year

                if vals[2] != '': #Retrieve Zip Code
                    val = [m,y,vals[2],vals[3]]
                    zip3 = vals[1]
                    
                    if not zip3 in data: #Add data into dictionaries
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
         #'"Phencylidine"','"Oxycodones"'] #List for the drugs
#drugs = sys.argv[4].split(";") # This is for possible further aggregation

del data[' '] # Deletes empty zip3 codes
del data['.']

for zip3,d in data.iteritems():
    dates = d.keys()
    dates.sort() #Sort the dates per zip

    vals = []

    for i in range(len(dates)): #Append Zip and Date to a List
        vals.append(zip3)
        dt = dates[i]
        vals.append(dt)
           
        for i in range(len(drugs)): # Append all the drugs
            drug = drugs[i]
            if not drug in data[zip3][dt]:
                vals.append('0')
            else: #Opperate on counts
                vals.append((float(data[zip3][dt][drug][3]) / float(data[zip3][dt][drug][2]))*1000)
                
        aggdata.append(vals) #Append all data
        vals = []

        
## Write File
fo.write('ZIP3,DATE,Amphetamines,Cocaine,Marijuana,Opiates,Phencylidine,Oxycodones\n') #Header
##fo.write('ZIP3,DATE,')
##c=0
##for i in drugs:
##    c+=1
##    fo.write(i)
##    if c < len(drugs):
##        fo.write(',')
##fo.write('\n')

for l in aggdata: #Split lists into rows for output
    s = ''
    for i in range(len(l)-1):
        s += str(l[i]) + ','
    s += str(l[len(l)-1]) + '\n'
    fo.write(s)

fo.close(); #Close output

