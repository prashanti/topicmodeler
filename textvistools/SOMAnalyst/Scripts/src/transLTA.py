#Martin Lacayo-Emery
#10/19/2008

def transform(inName,outName,column=1,header1="Locus",header2="Attribute"):
    infile=open(inName,'r')
    outfile=open(outName,'w')
    table={}
    attributes=infile.readline().strip().split(',')[2:]
    locus=set([])
    time=set([])

    #read in table    
    for line in infile.readlines():
        l=line.strip().split(',')
        for id,n in enumerate(l[2:]):
            locus=locus.union(set([l[0]]))
            time=time.union(set([l[1]]))
            table[(l[0],l[1],attributes[id])]=n

    #create sorted list of values for each variable
    attributes.sort()
    locus=list(locus)
    locus.sort()
    time=list(time)
    time.sort()
    
    if (column==1):
        outfile.write(','.join([header1,header2]+list(time))+'\n')
        for l in locus:
            for a in attributes:
                row=[l,a]
                for t in time:
                    try:
                        row.append(table[(l,t,a)])
                    except KeyError:
                        row.append('')
                outfile.write(','.join(row)+"\n")
    else:
        outfile.write(','.join([header1,header2]+list(locus))+'\n')
        for t in time:
            for a in attributes:
                row=[a,t]
                for l in locus:
                    try:
                        row.append(table[(l,t,a)])
                    except KeyError:
                        row.append('')
                outfile.write(','.join(row)+"\n")
                    
    infile.close()
    outfile.close()
