import json
from os import write
import requests
import time

rpc_user = ''
rpc_password = ''
rpc_url = 'http://127.0.0.1:YOURRPCPORT'

collat_address_label = 'mn-batch1-c'
owner_address_label = 'mn-batch1-o'

amountToCreate = int(input("How many mns to create?: "))


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


csv = str()
i = 1
while i < amountToCreate+1:
    collatAddress = str()
    ownerAddress = str()
    txid = str()
    vout = int()
    txIndex = int()
    com = ","

    # Get new address
    cAddress = instruct_wallet('getnewaddress', [collat_address_label+"-"+str(i)])
    if cAddress['error'] != None:
        print(cAddress['error'])
    else:
        collatAddress += cAddress['result']

    # Get new address
    oAddress = instruct_wallet('getnewaddress', [owner_address_label+"-"+ str(i)])
    if oAddress['error'] != None:
        print(oAddress['error'])
    else:
        ownerAddress += oAddress['result']
        csv += oAddress['result']+com

    # Send collat
    collat = instruct_wallet('sendtoaddress', [collatAddress, "100000"])
    if collat['error'] != None:
        print(collat['error'])
    else:
        txid += collat['result']
        csv += str(collat['result']+com)

    # get collat vout
    index = instruct_wallet('gettransaction', [txid])
    if index['error'] != None:
        print(index['error'])
    else:
        vout = int(index['result']['details'][1]['vout'])
        csv += str(index['result']['details'][1]['vout'])
        csv += "\n"

    # lock unspent
    lock = instruct_wallet('lockunspent', [bool(True), [
                           {"txid": txid, "vout": vout}]])
    if lock['error'] != None:
        print(lock['error'])

    time.sleep(10)

    if i == amountToCreate:
        print(csv)
        # check lockunspent work, won't be needed later.
        check = instruct_wallet('listlockunspent', [])
        if check['error'] != None:
            print(check['error'])
        #for debugging
        # else:
        #     print(check['result'])
    i += 1
