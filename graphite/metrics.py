#!/home/hci/.local/bin/python3.5
import csv
import subprocess
import graphitesend
import sys
import os
from datetime import datetime
from pprint import pprint
import dotenv

config = {
    'graphite_server': 'graphite.example.com',
    'tempdir': '/home/hci/temp/'
}

status_map = {'closing': 1,
              'down': 0,
              'error': 1,
              'ineof': 1,
              'initializing': 1,
              'opening': 1,
              'up': 1}

sites = ['prodsite', 'prodclinical']

def send_site(site):
    env = os.environ.copy()

    # probably don't need to set this explicitly
    env['CL_INSTALL_DIR'] = '/quovadx/cis6.1/'
    env['HCISITEDIR'] = os.path.join(env['CL_INSTALL_DIR'], 'integrator', site)

    tcl = subprocess.Popen(['stats.tcl', 'pwim', site], env=env)
    tcl.communicate()
    today = datetime.now().strftime('%Y%m%d')

    statfile = os.path.join(config['tempdir'], 'pwim_{}_statsfile_{}.csv'.format(site,today))
    with open(statfile) as fh:
        csvfile = csv.DictReader(fh)

        g = graphitesend.init(graphite_server=config['graphite_server'], group='pwim.{}'.format(site))

        for record in csvfile:
            thread = record['THREADNAME']
            del record['THREADNAME']
            del record['SYSTEM']
            del record['SITENAME']


            for key,value in record.items():
                try:
                    if key == 'PSTATUS':
                        value = status_map[value]
                    g.send('{}.{}'.format(thread, key.lower()), float(value))
                except TypeError:
                    print('{}.{}'.format(thread, key), value)
                    pass

    os.remove(statfile)

def main():
    # create local.env by running `printenv > /home/hci/temp/local.env` from your regular login shell
    dotenv.load_dotenv('/home/hci/temp/local.env')
    

    for site in sites:
        send_site(site)


if __name__ == '__main__':
    main()
