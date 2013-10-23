import sys, os

#supports executables in long path names
#does not support output into long path names

def visual(cin,din,dout,noskip="#",buffer="#"):
    #get local path for visual
    local = sys.argv[0]
    exe = "\""+"\\".join(local.split("\\")[:-2])+"\\exe\\SOM_PAK\\Euclidean\\visual.exe"+"\""

    visual =""    
    #add parametes to the system call
    visual+=" -cin "+cin
    visual+=" -din "+din
    visual+=" -dout "+dout

    if noskip != '#':
        visual+=" -noskip "+noskip
    if buffer != '#':
        visual+=" -buffer "+buffer
    #execute command
    if len(visual)>120:
        raise SystemError, "This command is "+str(len(visual)-120)+" characters too long. Please use shorter file path."

    visual=exe+visual
    if os.system(visual):
        raise SystemError, "There was a problem executing the command: "+visual

if __name__=="__main__":
    #codebook file
    cin = sys.argv[1]
    #input data
    din = sys.argv[2]
    #output filename
    dout = sys.argv[3]

##    ##optional parameters
##    noskip = '#'
##    buffer = '#'
    
    #do not skip masked vectors
    noskip = sys.argv[4]
    #buffer reading of data
    buffer = sys.argv[5]
    
    visual(cin,din,dout,noskip,buffer)