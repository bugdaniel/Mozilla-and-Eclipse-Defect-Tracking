#Script:    Read.py
#Author:    Luca Gaegauf & Daniel Salamanca
#Date:      14 December 2015

""" What this script does:
    1. opens the necessary CSV files from the Eclipse and Mozilla Defect Tracking Dataset
        and stores into lists named respecitvely
    2. create the dependent dummy variable indicating whether a bug was fixed or not.
    3. create the following features:
        a) a dummy variable indicating whether a bus was reopened or not.
        b) the success rates of bug reporters.
        c) the success rates of bug assignees.
        d) the time during which the bug was opened.
        e) the number of times the bug was assigned.
        f) the number of times the bug was edited.
        g) a dummy variable for all types of production, version, component, severity
           priority and operating system.
    4. creates the relevant output file by:
        a) converting all dictionaries to lists.
        b) writing and storing list in an output file."""

#Import the necessary modules.
import os
import csv
#Change to the appropriate directory.
os.chdir('/home/daniel/Dropbox/UZH2015/BusinessAnalytics/Project/RPICase/Eclipse/')

######################################### PART 1.
def OpenFileCSV(fileName):
    """This function opens a CSV file containing a bug attribute and stores it
    in a list without the header."""
    storeList=[]
    column0 = []
    column1 = []
    column2 = []
    column3 = []
    with open(fileName, 'r') as infile:
        csv_reader=csv.reader(infile, delimiter=',')
        next(csv_reader, None)
        for line in csv_reader:
            column0.append(line[0])
            column1.append(line[1])
            column2.append(line[2])
            column3.append(line[3])
        infile.close()
    storeList.append(column0)
    storeList.append(column1)
    storeList.append(column2)
    storeList.append(column3)
    return storeList

#Create the list storing the "reports" CSV file
#in a similar fashion as above.
reportId = []
reportResolution = []
reportStatus = []
reportOpening = []
reportReporter = []

with open('reports.csv', 'r') as infile:
    csv_reader = csv.reader(infile, delimiter=',')
    next(csv_reader, None)
    for line in csv_reader:
        reportId.append(line[0])
        reportResolution.append(line[1])
        reportStatus.append(line[2])
        reportOpening.append(line[3])
        reportReporter.append(line[4])
infile.close()

report=[]
report.append(reportId)
report.append(reportResolution)
report.append(reportStatus)
report.append(reportOpening)
report.append(reportReporter)

#Check if reportId is unique.
print len(set(report[0])) == len(report[0])

#Store all the necessary CSV files into lists
resolution=OpenFileCSV('resolution.csv')
assignedTo=OpenFileCSV('assigned_to.csv')
bugStatus=OpenFileCSV('bug_status.csv')
version=OpenFileCSV('version.csv')
opSys=OpenFileCSV('op_sys.csv')
product=OpenFileCSV('product.csv')
version=OpenFileCSV('version.csv')
component=OpenFileCSV('component.csv')
priority=OpenFileCSV('priority.csv')
severity=OpenFileCSV('severity.csv')

################################################## Part 2.

#Create a dummy variable if the bug is fixed.
#Create a dictionary which contains the dummy variables.
fixedBugDummy={}
#Attribute the bug identification number as a key
#and a dummy variable 1 or 0 when the bug is fixed or not.
for i in range(0,len(report[1])):
    if report[1][i] == "FIXED":
        fixedBugDummy[report[0][i]] = 1
    else:
        fixedBugDummy[report[0][i]] = 0

################################################## Part 3.
        
###Part 3. a)

#Create a dummy variable if the bug was reopened.
#Create a dictionary which contains the dummy variables.
reopenedBugDummy={}
#Attribute the bug identification numbers as keys
# and 0 as default values.
for i in report[0]:
    reopenedBugDummy[i]=0
#Change the dictionary value to 1 if the bug was reopened.
for i in range(0,len(bugStatus[1])):
    if bugStatus[1][i] == "REOPENED":
        reopenedBugDummy[bugStatus[0][i]] = 1

###Part 3. b)

#Calculate the success rate of the bug reporter
#Create a dictionary which contains the reporter identification number as its keys and
#his/her total number of bugs reported as its values.
totalBugReported={}
reporterSet=set(report[4])
for i in reporterSet:
    totalBugReported[i]=0.
for i in range(0,len(report[0])):
    totalBugReported[report[4][i]]=totalBugReported[report[4][i]] + 1
#Create a dictionary which contains the reporter identification number as its keys
#and his/her number of bugs reported which turned out to be fixed.
fixedBugReported={}
for i in reporterSet:
    fixedBugReported[i]=0.
for i in range(0,len(report[0])):
    if report[1][i] == "FIXED":
        fixedBugReported[report[4][i]]=fixedBugReported[report[4][i]] + 1
#Create a dictionary which contains the reporter identification number as its keys
#and his success rate.
successRateReporter={}
for i in reporterSet:
    successRateReporter[i]=fixedBugReported[i]/totalBugReported[i]
#Create a dictionary which contains the bug identification number as its keys and
#its reporter's success rate.
successRateReporterBug={}
for i in range(0,len(report[0])):
    successRateReporterBug[report[0][i]]=successRateReporter[report[4][i]]

###Part 3. c)    

#Calculate the success rate of an assignee.
#Create a dictionary which contains the number of bugs fixed
#for each assignee.
bugFixedAssignee={}
#Create a set of unique identification numbers of assignees.
assigneeSet = set(resolution[3])
#Attribute the bug identification numbers as keys
# and 0. as default values.
for i in assigneeSet:
    bugFixedAssignee[i]= 0.
#Count the number of bugs fixed for each assignee and store it as the dictionary
#value corresponding to the particular assignee identification number.
for i in range(0,len(resolution[1])):
    if resolution[1][i] == "FIXED":
        bugFixedAssignee[resolution[3][i]] = bugFixedAssignee[resolution[3][i]] + 1

#Create a dictionary which contains the total number of bugs treated
#by each assignee.
bugTotalAssignee={}
#Attribute the bug identification numbers as keys
# and 0. as default values.
for i in assigneeSet:
    bugTotalAssignee[i]= 0.
#Count the total number of bugs treated by each assignee and store it as the
#dictionary value corresponding to the particular assignee identification number.
for i in range(0,len(resolution[1])):
    bugTotalAssignee[resolution[3][i]]=bugTotalAssignee[resolution[3][i]] + 1

#Create a dictionary which contains the success rate for each assignee.
successRateAssignee={}
for i in assigneeSet:
    successRateAssignee[i]=bugFixedAssignee[i]/bugTotalAssignee[i]

#Create a dictionary which contains the bug identification number as
#the keys for the primary dictionary, the time when it was modified as its keys
#of the secondary dictionary inside the primary dictionary and as its value which
#assignee executed this modification.
lastModification={}
for i in report[0]:
    lastModification[i]={}
for i in range(0,len(resolution[0])):
    lastModification[resolution[0][i]][resolution[2][i]]= resolution[3][i]

#Create a dictionary which contains the bug identification number as
# the keysand the assignee who executed its last modification as its values.
bugAssignment={}
for i in report[0]:
    bugAssignment[i]=lastModification[i][max(lastModification[i].keys())]
#Create a dictionary which contains the bug identification numbers as the
#keys and the success rate of its last modifying assignee.
successRateAssigneeBug={}
for i in bugAssignment.keys():
    successRateAssigneeBug[i]=successRateAssignee[bugAssignment[i]]
    
###Part 3. d)

#Calculate the time during which the bug was opened.
#Check if all bug reports are included in the resolution list.   
print len(report[0]) == len(set(resolution[0]))
#Create a dictionary which contains the the bug identification number as its keys
#and its opening time as its values.
openingTime={}
for i in range(0,len(report[0])):
    openingTime[report[0][i]]=report[3][i]
#Create a dictionary which contains the the bug identification number as its keys
#and its closing time as its values.
closingTime={}
for i in range(0,len(report[0])):
    closingTime[report[0][i]]= 0
for i in range(0,len(resolution[0])):
    closingTime[resolution[0][i]]=max(closingTime[resolution[0][i]],resolution[2][i])
#Create a dictionary which contains the the bug identification number as its keys
#and its time opened as its values.
openedTime={}
for i in report[0]:
    openedTime[i]=int(closingTime[i])-int(openingTime[i])

###Part 3. e)

#Calculate the number of times that a bug was assigned.
#Create a dictionary which contains the bug identification number as its keys
#and the the number of assignments as its values. 
numberAssignment={}
for i in report[0]:
    numberAssignment[i]=0
for i in range(0,len(assignedTo[0])):
    numberAssignment[assignedTo[0][i]]=numberAssignment[assignedTo[0][i]] + 1

###Part 3. f)

#Calculate the number of times that a bug was edited.
#Create a dictionary which contains the bug identification number as its keys and
#the number of editions as its values. 
editionNumber={}
for i in report[0]:
    editionNumber[i]=0
for i in range(0, len(bugStatus[0])):
    editionNumber[bugStatus[0][i]]=editionNumber[bugStatus[0][i]] + 1


#####Part 3. g)
    
def CreateDummy(table):
    """ This function creates a dictionary containing many dictionaries which
    contain the dummy variables for each instance of of the second column of
    the input table. In other words it creates a dictionary for each type of categorical
    variables in the column and stores it all within one dictionary.
    """
    outputDictionary={}
    for i in set(table[1]):
        outputDictionary[i]={}
    for i in outputDictionary.keys():
        for j in set(report[0]):
            outputDictionary[i][j]=0
        for j in range(0, len(table[0])):
            if table[1][j] == i:
                outputDictionary[i][table[0][j]] = 1
    return outputDictionary

#Create a dictionary containing a dictionary for each type of values of
#priority, severity, version, component, product and operating system
priorityType=CreateDummy(priority)
severityType=CreateDummy(severity)
versionType=CreateDummy(version)
componentType=CreateDummy(component)
productType=CreateDummy(product)
opSysType=CreateDummy(opSys)

#To avoid dependency between features we need to remove one dummy per type.
del priorityType['None']
del severityType['normal']
del versionType['DEVELOPMENT']
del componentType['Other']
del productType['Examples']
del opSysType['']


################################################## Part 4.

###Part 4. a)

def WriteOutput(outputList,fileName='outputFile.dat'):
    """This function takes in a list and stores it in an output file.
    """
    lines=[]
    for j in range(0,len(outputList[0])):
        for i in range(0,len(outputList)):
            lines.append(str(outputList[i][j])+" ")
        lines.append("\n")
    outputFile = open(fileName, 'w')
    for n in range(0, len(lines)): outputFile.write(lines[n])
    outputFile.close()
    return

#Convert the list containing all the relevant variables to a ".dat" file.
WriteOutput(cleanedOutput)

def ConvertDictionaryToList(dictionaryName):
    """This function verifies the length of a dictionary,
    orders it and stores it as a list.
    """
    listName=list()
    if len(dictionaryName.keys()) == len(report[0]):
        listName=sorted(dictionaryName.iteritems())
        for i in range(0, len(listName)):
            listName[i]=list(listName[i])
        vector1=[]
        vector2=[]
        for i in range(0,len(listName)):
            vector1.append(listName[i][0])
            vector2.append(listName[i][1])
        listName=[vector1,vector2]
    else:
        print "please integrate all bugs"   
    return listName

#Convert all dictionaries to lists and stores them in a single list
uncleanedOutput=[]
for i in [fixedBugDummy,reopenedBugDummy,successRateAssigneeBug,openedTime,\
          successRateReporterBug,numberAssignment, editionNumber]:
    uncleanedOutput.append(ConvertDictionaryToList(i))

for i in sorted(priorityType.keys()):
    uncleanedOutput.append(ConvertDictionaryToList(priorityType[i]))
for i in sorted(severityType.keys()):
    uncleanedOutput.append(ConvertDictionaryToList(severityType[i]))
for i in sorted(versionType.keys()):
    uncleanedOutput.append(ConvertDictionaryToList(versionType[i]))
for i in sorted(componentType.keys()):
    uncleanedOutput.append(ConvertDictionaryToList(componentType[i]))
for i in sorted(productType.keys()):
    uncleanedOutput.append(ConvertDictionaryToList(productType[i]))
for i in sorted(opSysType.keys()):
    uncleanedOutput.append(ConvertDictionaryToList(opSysType[i]))

#Create a list which contains only the variables necessary for the later analysis.
cleanedOutput=[]
cleanedOutput.append(uncleanedOutput[0][0])
for i in uncleanedOutput:
    cleanedOutput.append(i[1])

###Part 4. b)

def WriteOutput(outputList,fileName='outputFile.dat'):
    """This function takes in a list and stores it in an output file.
    """
    lines=[]
    for j in range(0,len(outputList[0])):
        for i in range(0,len(outputList)):
            lines.append(str(outputList[i][j])+" ")
        lines.append("\n")
    outputFile = open(fileName, 'w')
    for n in range(0, len(lines)): outputFile.write(lines[n])
    outputFile.close()
    return

#Convert the list containing all the relevant variables to a ".dat" file.
WriteOutput(cleanedOutput)#############################################

def WriteOutput(outputList,fileName='outputFile.dat'):
    """This function takes in a list and stores it in an output CSV file.
    """
    lines=[]
    for j in range(0,len(outputList[0])):
        for i in range(0,len(outputList)):
            lines.append(str(outputList[i][j])+"")
        lines.append("\n")
    outputFile = open(fileName, 'w')
    for n in range(0, len(lines)): outputFile.write(lines[n])
    outputFile.close()
    return

#Convert the list containing all the relevant variables to a CSV file.
WriteOutput(cleanedOutput)
