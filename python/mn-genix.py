import json
from os import write
import requests
import time
import csv

### Edit me! ### 
rpc_user = 'rpcuser' #rpc user you set in your genix.conf 
rpc_password = 'rpcpassword' #rpc password you set in your genix.conf 
rpc_port = 4444  #rpc port you set in your genix.conf 
batch_label = 'b2-fixed' # example output: batch-1-collat-n (n = collat id#)
### Dont edit below ###

fileName = batch_label+'.csv'
rpc_url = 'http://127.0.0.1:'+str(rpc_port)

def export_csv():
    with open(fileName, mode='w') as mn_file:
        listToStr = ' '.join(map(str, csvArray))
        mn_file.write(listToStr)

def instruct_wallet(method, params):
    url = rpc_url
    payload = json.dumps({"method": method, "params": params})
    headers = {'content-type': "application/json", 'cache-control': "no-cache"}
    try:
        response = requests.request(
            "POST", url, data=payload, headers=headers, auth=(rpc_user, rpc_password))
        return json.loads(response.text)
    except requests.exceptions.RequestException as e:
        print(e)
    except:
        print('No response from Wallet, check Bitcoin is running on this machine')

def export_csv():
    with open(fileName, mode='w') as mn_file:
        listToStr = ' '.join(map(str, csvArray))
        mn_file.write(listToStr)

def instruct_wallet(method, params):
    url = rpc_url
    payload = json.dumps({"method": method, "params": params})
    headers = {'content-type': "application/json", 'cache-control': "no-cache"}
    try:
        response = requests.request(
            "POST", url, data=payload, headers=headers, auth=(rpc_user, rpc_password))
        return json.loads(response.text)
    except requests.exceptions.RequestException as e:
        print(e)
    except:
        print('No response from Wallet, check Bitcoin is running on this machine')

csvArray = [];
amountToCreate = int(input("How many mns to create?: "))

i = 1 #start at 1 index. (starting at 0 would make n+1 collats.)
while i < amountToCreate+1:
    collatAddress = str()
    ownerAddress = str()
    txid = str()
    vout = int()
    txIndex = int()
    csvStr = str()
    com = ","

    # Get new address
    cAddress = instruct_wallet('getnewaddress', [batch_label+"-collat-"+str(i)])
    if cAddress['error'] != None:
        print(cAddress['error'])
    else:
        collatAddress += cAddress['result']

    # Get new address
    oAddress = instruct_wallet('getnewaddress', [batch_label+"-owner-"+ str(i)])
    if oAddress['error'] != None:
        print(oAddress['error'])
    else:
        ownerAddress += oAddress['result']
        csvStr += oAddress['result']+com

    # Send collat
    collat = instruct_wallet('sendtoaddress', [collatAddress, "100000"])
    if collat['error'] != None:
        print(collat['error'])
    else:
        txid += collat['result']
        csvStr += str(collat['result']+com)

    # get collat vout
    index = instruct_wallet('gettransaction', [txid])
    if index['error'] != None:
        print(index['error'])
    else:
        vout = int(index['result']['details'][1]['vout'])
        csvStr += str(index['result']['details'][1]['vout'])
        csvStr += "\n"
    csvArray.append(csvStr)
    # lock unspent
    lock = instruct_wallet('lockunspent', [bool(1 > 10), [
                           {"txid": txid, "vout": vout}]])
    if lock['error'] != None:
        print(lock['error'])

    time.sleep(30)

    if i == amountToCreate:
        print("Exporting data to file...")
        export_csv();
        print("Exported!")
        print("Done, Speak to twinky for next instructions")

        # check lockunspent work, won't be needed later.
        check = instruct_wallet('listlockunspent', [])
        if check['error'] != None:
            print(check['error'])
        #for debugging
        # else:
        #     print(check['result'])
    i += 1
