import json
import os
import ssl
import sys
from collections import OrderedDict
from pprint import pprint as pp

def main():
    debug = False
    if len(sys.argv) == 2:
      if sys.argv[1] == "-d":
        debug = True

    if debug:
      print("Python {:s} on {:s}\n".format(sys.version, sys.platform))

    directory = os.path.dirname(__file__)
    results=[]
    for item in os.listdir(directory):
        f =os.path.join(directory, item) 
        if os.path.isfile(f):
            if f.endswith(".cer"):
                cert_file_name = f

                if debug:
                    print("cli arg1: {:s}\n".format(cert_file_name))

                try:
                    ordered_dict = OrderedDict()
                    ordered_dict = ssl._ssl._test_decode_cert(cert_file_name)
                    results.append(ordered_dict)
                    if debug: pp(ordered_dict)

                except Exception as e:
                    print("Error decoding certificate: {:s}\n".format(e))

                
    with open('results.json', 'w') as write_file:
        json.dump(obj=results,fp=write_file,indent=4)

if __name__ == "__main__":
    main()
    