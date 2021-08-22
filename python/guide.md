# How to use genix mn script. 

1.) Install python 3.8.4 https://www.python.org/downloads/release/python-384/  
2.) install requests package.  
    ```
    python -m pip install requests
    ```  
3.) Edit `mn-genix.py`  
3.a) replace rpc_user, rpc_password & `YOURRPCPORT` with your genix.conf rpc values.  
3.b) replace address labels with your desired label.  
    Note: an additional number will be placed at the end of the label IE:
    collat_address_label = 'mn-batch1-c' label will end up being: `mn-batch1-c-1`