import csv
import json
from pytrends.request import TrendReq
import re

#load the data from the geonames cities 15k file

with open('cities15000.txt') as csvFile:
    csvreader = csv.reader(csvFile, delimiter='\t')

    queryList = [];

    #Build the list of queries

    for row in csvreader:
        if row[8]=="FR": #Filter by country
            queryNames = [];
            queryNames.append(row[1]) #Get the main placename
            row[3] = row[3].split(",") #Turn the comma-delimited list into a py list
            finalFourNames = row[3][-4:] #Get the last four elements (since sorted alphabetically, these will almost always be Arabic, Japanese, Korean, and Chinese)
            #We're limited to a query of five terms by google
            queryNames.extend(finalFourNames);
            if len(queryNames) == 5: #Towns with less than five names are not useful to us
                queryList.append(queryNames)
    QUERY_LIMITER = 500;
    queryList = queryList[-QUERY_LIMITER:];
    print(queryList) #Has everything gone well so far?

    #Initialize the results lists

    listOfInterestResults = [];
    surprisingListOfInterestResults = [];

    print("Initialize the google trends python API")

    pytrends = TrendReq(hl='en-US', tz=360)

    apiErrCounter = 0;

    for query in queryList:

        print("Building Payload")
        try:
            payload = pytrends.build_payload(query, cat=0, timeframe='today 5-y', geo='', gprop='')
            apiErrCounter = 0
        except Exception as e:
            print(e)
            apiErrCounter += 1
            if apiErrCounter >= 5:
                print("Too many errors, probably rate-limited or disconnected, finalizing.")
                break
            else:
                continue

        #Try to get the data from google trends, deal with errors by skipping this one

        try:
            queryDataframe = pytrends.interest_over_time()
        except ValueError as e:
            #less than 5 unique names, not useful to us
            print("Error, probably duplicate name, continuing.")
            continue
        except Exception as e:
            #sometimes google will return us HTTP400 errors, which we need to handle
            print(e)
            continue

        arithmeticMeanDict = {}

        for column in queryDataframe:
            if column=='isPartial':
                continue

            #calculate the arithmetic mean of the interest that we got from google trends

            sumOfValues = 0
            divisor = 0

            for seriesTuple in queryDataframe[column].iteritems():
                try:
                    sumOfValues += seriesTuple[1]
                except TypeError as e:
                    pass
                divisor += 1

            arithmeticMean = sumOfValues/divisor
            arithmeticMeanDict[column] = arithmeticMean

        #for Japanese: sort dictionary
        #arithmeticMeanDict = {k: arithmeticMeanDict[k] for k in sorted(arithmeticMeanDict.keys(), key=arithmeticMeanDict.__getitem__, reverse=True)}
        #print(arithmeticMeanDict)

        try:
            valueOfDefaultName = arithmeticMeanDict[list(arithmeticMeanDict)[0]]

            #Interesting values get their own Filter

            #Japanese
            #interesting = False
            #if re.match(r"^[A-z]", list(arithmeticMeanDict)[0]):
            #    print("I'm Japanese and interesting")
            #    interesting = True

            interesting = False
            for arithmeticMeanItem in arithmeticMeanDict.items():
                if arithmeticMeanItem[1]>valueOfDefaultName:
                    interesting = True
                    break


            listOfInterestResults.append(arithmeticMeanDict)
            if interesting:
                surprisingListOfInterestResults.append(arithmeticMeanDict)
        except Exception as e:
            print("An unexpected error has occurred while assembling this arithmeticMeanDict.")
            print(e)

    #write these to a json file

    with open('interestCityNames.txt', 'w') as json_file:
        json.dump(listOfInterestResults, json_file, ensure_ascii=False)
    with open('surprisingInterestCityNames.txt', 'w') as json_file:
        json.dump(surprisingListOfInterestResults, json_file, ensure_ascii=False)
