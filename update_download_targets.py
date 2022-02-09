import glob

for makefile in glob.glob('src*/makefile'):
    print('Processing', makefile)
    download_target = 'download: '
    clean_target = 'clean: '
    with open(makefile, 'r+') as f:
        lines = f.readlines()
        replace = False
        for i in range(len(lines)):
            if not lines[i].strip().startswith('#') and 'curl' in lines[i].lower() and ':' in lines[i-1]:
                download_target += lines[i-1].partition(':')[0] + ' '
            if lines[i].lower().startswith('clean-') and ':' in lines[i]:
                clean_target += lines[i].partition(':')[0] + ' '                
            if 'clean:' in lines[i]:
                download_line = i+2
                clean_line = i
            if 'check:' in lines[i]:
                download_line = i+1
            if 'download:' in lines[i]:
                download_line = i
                download_replace = True
        if download_replace:
            lines[download_line] = download_target+'\n'
        else:
            lines.insert(download_line, download_target+'\n')
        lines[clean_line] = clean_target+'\n'
        f.seek(0)
        f.writelines(lines)
