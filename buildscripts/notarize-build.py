#! /usr/bin/env python3

import argparse
import getpass
import os
import platform
import re
import socket
import subprocess
import sys
import time
import zipfile
import plistlib
import requests
import threading

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def read_plist_from_zip(zipPath):
    with zipfile.ZipFile(zipPath) as zip:
        for name in zip.namelist():
            if "Contents/Info.plist" in name and not "parkle" in name:
                with zip.open(name) as plistFile:
                    return plistFile.read()
    return None

def parse_args():
    parser = argparse.ArgumentParser(description="Notarization service tool for releases")
    parser.add_argument('-u', '--username', dest='username', action='store', type=str, default=None, required=False, help='Apple Notarization Service User')
    parser.add_argument('-p', '--password', dest='password', action='store', type=str, default=None, required=False, help='Apple Notarization Service Password')
    parser.add_argument('-n', '--notarize-zip', dest='zip_path', action='store', type=str, default=None, required=False, help='Local released ZIP file')
    parser.add_argument('-d', '--notarize-dmg', dest='dmg_path', action='store', type=str, default=None, required=False, help='Local released DMG file')
    parser.add_argument('-b', '--bundle-id', dest='bundle_id', action='store', type=str, default=None, required=False, help='Bundle ID (read from ZIP)')   
    parser.add_argument('-l', '--log', dest='log_path', action='store', type=str, default=None, required=False, help='Notarization log output path')
    parser.add_argument('-s', '--staple-app', dest='stapleApp', action='store', type=str, default=None, required=False, help='Notarization log output path')

    args = parser.parse_args()

    if args.stapleApp == None:
        if args.username == None or args.password == None:
            eprint("ERROR: the following arguments are required: --username, --password")
            sys.exit(1)
    
    eprint("Args: ",args)
   
    return args

def toolPathAndVerifyExistence(toolName):
    print("Testing for " + toolName + ':')
    if "DEVELOPER_DIR" in os.environ:
        print("\tEnvironment variable DEVELOPER_DIR =",os.environ["DEVELOPER_DIR"])
    else:
        print("\tEnvironment variable DEVELOPER_DIR is not set!")
    
    toolPath = subprocess.check_output(["xcrun", "--find", "xcodebuild"]).strip()
    print("\tXcodebuild Path:",toolPath)

    process = subprocess.Popen(["xcrun", "--find", toolName],
                               stdout=subprocess.PIPE,
                               stderr=subprocess.STDOUT)
    stdout,stderr = process.communicate()
    stdoutString = stdout.decode(encoding="UTF-8")
    if process.returncode == 0:
        print("\tSUCCESS: Found " + toolName + " at:",stdoutString)
        return stdoutString.strip()
    else:
        potentialToolPath = toolPath.replace("xcodebuild", toolName)
        if os.path.exists(potentialToolPath):
            print("\tSUCCESS: Strangely, xcrun does not find " + toolName + ", but we found it in the same directory as xcodebuild")
            return potentialToolPath
        else:
            print("\tERROR: ", stdoutString)
            sys.exit(process.returncode)

def launchTool(toolPath, args):
        cmd = [toolPath] + args
        quotedArgs = []
        for arg in cmd:
           quotedArgs.append('"' + arg + '"')
        print("Launching command: " + " ".join(quotedArgs))
        env = None
        if "DEVELOPER_DIR" in os.environ:
            env = {"DEVELOPER_DIR": os.environ['DEVELOPER_DIR']}
        process = subprocess.Popen(cmd, 
                                   stdout=subprocess.PIPE, 
                                   stderr=subprocess.PIPE,
                                   env=env)
        stdout,stderr = process.communicate()
        return process,stdout,stderr

def beginNotarizationSession(args, altoolPath):
    filePath = None
    if args.zip_path != None:
       filePath = args.zip_path
    elif args.dmg_path != None:
       filePath = args.dmg_path
    else:
       eprint("No file path given, please set --notarize-dmg or --notarize-zip argument")
       sys.exit(1)
    
    if args.bundle_id == None:
        if args.zip_path == None:
            eprint("Can't automatically determine bundle ID from DMG, please set --bundle-id argument")
            sys.exit(1)
        
        plistXML = read_plist_from_zip(args.zip_path)
        if plistXML == None:
            eprint("Unable to parse extract Plist from ZIP archive")
            sys.exit(1)
    
        plist = plistlib.loads(plistXML)
            
        args.bundle_id = plist['CFBundleIdentifier']

    if args.bundle_id == None:
        eprint("Can't automatically determine bundle ID, please set --bundle-id argument")
        sys.exit(1)
    
    print("Detected bundle ID", args.bundle_id)

    shallTest = False
    if shallTest:
#        plist = plistlib.readPlist("sample-altool-plists/response.plist")
        plist = plistlib.readPlist("sample-altool-plists/error.plist")
    else:
        process, stdout, stderr = launchTool(altoolPath, 
                                             [ "--notarize-app", 
                                               "--primary-bundle-id", args.bundle_id,
                                               "--username", args.username,
                                               "--password", args.password,
                                               "--file", filePath,
                                               "--output-format", "xml" ])
        
        print("STDOUT\n",stdout)
        print("STDERR\n",stderr)
        
        print("RETURN_CODE: ", process.returncode)
        
        plist = plistlib.loads(stdout)
    
    # <?xml version="1.0" encoding="UTF-8"?>
    #<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    #<plist version="1.0">
    #<dict>
    #	<key>notarization-upload</key>
    #	<dict>
    #		<key>RequestUUID</key>
    #		<string>07aec867-4426-45be-86f0-417724300504</string>
    #	</dict>
    #	<key>os-version</key>
    #	<string>10.14.5</string>
    #	<key>success-message</key>
    #	<string>No errors uploading '/Users/martin/Source/output/release/build/postico-5026.zip'.</string>
    #	<key>tool-path</key>
    #	<string>/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework</string>
    #	<key>tool-version</key>
    #	<string>1.1.1138</string>
    # </dict>
    #</plist>
    
#     <plist version="1.0">
# <dict>
# 	<key>os-version</key>
# 	<string>10.14.5</string>
# 	<key>product-errors</key>
# 	<array>
# 		<dict>
# 			<key>code</key>
# 			<integer>-18000</integer>
# 			<key>message</key>
# 			<string>ERROR ITMS-90732: "The software asset has already been uploaded. The upload ID is 5e2fe207-e916-4180-a512-fdd22494ce60" at SoftwareAssets/EnigmaSoftwareAsset</string>
# 			<key>userInfo</key>
# 			<dict>
# 				<key>NSLocalizedDescription</key>
# 				<string>ERROR ITMS-90732: "The software asset has already been uploaded. The upload ID is 5e2fe207-e916-4180-a512-fdd22494ce60" at SoftwareAssets/EnigmaSoftwareAsset</string>
# 				<key>NSLocalizedFailureReason</key>
# 				<string>ERROR ITMS-90732: "The software asset has already been uploaded. The upload ID is 5e2fe207-e916-4180-a512-fdd22494ce60" at SoftwareAssets/EnigmaSoftwareAsset</string>
# 				<key>NSLocalizedRecoverySuggestion</key>
# 				<string>ERROR ITMS-90732: "The software asset has already been uploaded. The upload ID is 5e2fe207-e916-4180-a512-fdd22494ce60" at SoftwareAssets/EnigmaSoftwareAsset</string>
# 			</dict>
# 		</dict>
# 	</array>
# 	<key>tool-path</key>
# 	<string>/Applications/Xcode-10.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework</string>
# 	<key>tool-version</key>
# 	<string>1.1.1138</string>
# </dict>
# </plist>

    if 'process' in locals() and process.returncode == 0:
        requestID = plist["notarization-upload"]["RequestUUID"]
        print("Successfully uploaded zip, requestID is", requestID)
        return requestID, True
    else:
        if "product-errors" in plist:
            pattern = re.compile("ERROR ITMS-90732:.+The upload ID is ([a-f0-9\-]+)\" at")
            for error in plist["product-errors"]:
                msg = error["message"]
                match = pattern.match(msg)
                if match != None:
                    requestID = match.group(1)
                    print("Discovered already uploaded, reusing request ID",requestID)
                    return requestID, False
        if 'process' in locals():
            sys.exit(process.returncode)
        sys.exit(1)

def notificationInfo(args, altoolPath, requestID):
     process, stdout, stderr = launchTool(altoolPath, 
                                          [ "--notarization-info", requestID,
                                            "--username", args.username,
                                            "--password", args.password,
                                            "--output-format", "xml" ])
     print("STDOUT\n",stdout)
     print("STDERR\n",stderr)
     
     print("RETURN_CODE: ", process.returncode)
     
     if process.returncode == 0:
         print("SUCCESS!")
         plist = plistlib.loads(stdout)
         return plist
     else:
         sys.exit(process.returncode)

def pollRequest(args, altoolPath, requestID):
    print("Poll notification info for request ID", requestID)
    plist = notificationInfo(args, altoolPath, requestID)
    print(plist)
    
    info = plist["notarization-info"]
    status = info["Status"]
    code = None
    if "Status Code" in info:
        code = info["Status Code"]
    message = None
    if "Status Message" in info:
        message = info["Status Message"]
    log = None
    logFileURL = None
    if "LogFileURL" in info:
        logFileURL = info["LogFileURL"]
        log = requests.get(logFileURL).content
        if args.log_path != None:
            logFile = open(args.log_path, "wb")
            logFile.write(log)
            logFile.close()
        
        print("\nContents of " + logFileURL + " :")
        print(log)
#		<key>Status</key>
#		<string>invalid</string>
#		<key>Status Code</key>
#		<integer>2</integer>
#		<key>Status Message</key>
#		<string>Package Invalid</string>

    print("Obtained status",status)
    
    lowercasedStatus = status.lower()
    
    if lowercasedStatus == 'success':
        eprint("SUCCESS: obtained status '"+status+"':",message)
        sys.exit(0)
    elif lowercasedStatus == 'invalid':
        eprint("ERROR "+str(code)+" : obtained status '"+status+"':",message)
        sys.exit(2)
    elif lowercasedStatus == 'in progress':
        return True # still busy
    else:
        eprint("ERROR "+str(code)+" : obtained unknown status '"+status+"':",message)
        sys.exit(-1)

def main():
    global start_time

    args = parse_args()

    if args.stapleApp == None:
        altoolPath = toolPathAndVerifyExistence('altool')
        
        requestID, isUploadInProgress = beginNotarizationSession(args, altoolPath)
        
        print("Notarization request ID is #"+requestID+"#")
        
        if isUploadInProgress:
            print("Sleeping 20s...")
            time.sleep(20)
            
        while pollRequest(args, altoolPath, requestID):
            eprint("Still in progress, retry in 10s ...\n")
            time.sleep(10)
    
    else:
        staplerPath = toolPathAndVerifyExistence('stapler')
        
        process, stdout, stderr = launchTool(staplerPath, 
                                             [ "staple", 
                                               "-v",
                                               args.stapleApp ])
        
        print("STDOUT\n",stdout)
        print("STDERR\n",stderr)
        
        print("RETURN_CODE: ", process.returncode)
        if process.returncode == 0:
            print("SUCCESS!")
        sys.exit(process.returncode) 
 
main()
