#!/usr/bin/env python3

import glob

for makefile in glob.glob('src*/makefile'):
    print('Processing', makefile)
    download_target = 'download: '
    check_target = 'check: '
    clean_target = 'clean: '
    download_line = None
    check_line = None
    clean_line = None
    with open(makefile, 'r+') as f:
        lines = f.readlines()
        for i in range(len(lines)):
            if not lines[i].strip().startswith('#') and 'curl' in lines[i].lower() and ':' in lines[i-1]:
                download_target += lines[i-1].partition(':')[0] + ' '
            if lines[i].lower().startswith('check-') and ':' in lines[i]:
                check_target += lines[i].partition(':')[0] + ' '
            if lines[i].lower().startswith('clean-') and ':' in lines[i]:
                clean_target += lines[i].partition(':')[0] + ' '
            if 'check:' in lines[i]:
                check_line = i
            if 'clean:' in lines[i]:
                clean_line = i
            if 'download:' in lines[i]:
                download_line = i
        if download_line:
            lines[download_line] = download_target.rstrip() + '\n'
        if check_line:
            lines[check_line] = check_target.rstrip() + '\n'
        if clean_line:
            lines[clean_line] = clean_target.rstrip() + '\n'
        f.seek(0)
        f.writelines(lines)
        f.truncate()
