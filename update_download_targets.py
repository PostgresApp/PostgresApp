import glob

for makefile in glob.glob('src*/makefile'):
    print('Processing', makefile)
    download_target = 'download: '
    with open(makefile, 'r+') as f:
        lines = f.readlines()
        replace = False
        for i in range(len(lines)):
            if 'curl' in lines[i].lower() and ':' in lines[i-1]:
                download_target += lines[i-1].partition(':')[0] + ' '
            if 'clean:' in lines[i]:
                insert_index = i+2
            if 'check:' in lines[i]:
                insert_index = i+1
            if 'download:' in lines[i]:
                insert_index = i
                replace = True
        if replace:
            lines[insert_index] = download_target+'\n'
        else:
            lines.insert(insert_index, download_target+'\n')
        f.seek(0)
        f.writelines(lines)
