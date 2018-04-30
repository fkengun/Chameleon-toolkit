#!/usr/bin/env python

import os
import argparse
import subprocess
import email
import smtplib
from email.mime.text import MIMEText

climate_path = "~/blazarclient/bin/climate"
my_email = "fkengun@hotmail.com"
my_password = "7s4^uMegAaR9RU"
lease_info_map = dict()

def usage():
  print "Usage: update_lease [-l|--lease] lease_name [-p|--prolong] time_length"
  exit()

def parse_cmd_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-l", "--lease_name", type=str, help="lease_name")
    parser.add_argument("-p", "--prolong_time", type=str, help="prolonged time length, in format of d,h,m")
    args = parser.parse_args()
    return args.lease_name, args.prolong_time

def run_cmd(command):
    process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
    output, error = process.communicate()
    exit = process.wait()
    return output.splitlines(), error

def get_lease_names():
    return lease_info_map.keys()

def get_lease_ids():
    return lease_info_map.values()

def get_lease_info(keyword):
    cmd = "%s lease-list | grep -i %s | awk '{print $4}'" % (climate_path, keyword)
    lease_names, error = run_cmd(cmd)
    cmd = "%s lease-list | grep -i %s | awk '{print $2}'" % (climate_path, keyword)
    lease_ids, error = run_cmd(cmd)
    if len(lease_names) != len(lease_ids):
        print "Something is wrong"
        exit()
    else:
        lease_info_map = dict(zip(lease_names, lease_ids))
    return lease_info_map

def update_lease(lease_name, prolong_time, id):
    cmd = "%s lease-update -l %s -p %s %s" % (climate_path, lease_name, prolong_time, id)
    output, error = run_cmd(cmd)

def email_notification(lease_name):
    server = smtplib.SMTP('smtp.live.com', 587)
    server.ehlo()
    server.starttls()
    server.ehlo()
    msg = email.message_from_string('warning')
    msg['From'] = my_email
    msg['To'] = my_email
    msg['Subject'] = "Lease %s expires today" % lease_name
    server.login(my_email, my_password)
    server.sendmail(my_email, my_email, msg.as_string())
    server.quit()

if __name__ == "__main__":
    keyword, prolong_time = parse_cmd_args()

    if not keyword:
        usage()
        exit()
    else:
        lease_info_map = get_lease_info(keyword)
        print lease_info_map
        if not len(lease_info_map):
            print "No matched lease found"
            exit()
        if not prolong_time:
            # check lease and email notification, if necessary
            lease_names = get_lease_names()
            content = ""
            for id in lease_names:
                if content:
                    content = "%s, " % content
                content = "%s%s" % (content, id)
            email_notification(content)
        else:
            # update lease
            for lease_name in lease_info_map.keys():
                update_lease(lease_name, prolong_time, lease_info_map.get(lease_name))
