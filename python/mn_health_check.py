import json
import requests
import socket
import time

rpc_user = ''
rpc_password = ''
rpc_url = ''

checked = [];
loop = 999999;
i = 0;
checkCount = 0;
bad = 0;
good = 0;

def check_availability(element, collection: iter):
    return element in collection
    

def check_port(ip, port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    result = sock.connect_ex((ip,port))
    if result == 0:
        return bool(True)
    else:
        return bool(False)

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

while (i < loop):
    test = instruct_wallet("masternode", ["current", ""])
    if test['error'] != None:
        print(test['error'])
    else:
        ptx = test["result"]["proTxHash"]
        if check_availability(ptx, checked):
            print()
        else:
            ip = test["result"]["IP:port"]
            splitIp = ip.split(":")
            justIp = splitIp[0]
            port = splitIp[1]
            print("checking: ", justIp)
            online = check_port(justIp, int(port))
            if online:
                good += 1
                print("node online")
            else:
                bad += 1
                print("node offline!!! :(")
            checked.append(ptx);
            #print(str(online));
            #print(checked)
            checkCount += 1
    i += 1
    print(
        "Iteration: ", i, "\n",
        "Checked: ", checkCount, "\n",
        "Good: ", good, "\n",
        "Bad: ", bad, "\n")
    time.sleep(15)