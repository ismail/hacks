#!/usr/bin/env python3

from clint.textui import progress
import os
import re
import requests
import sys

def download(url):
    r = requests.get(url)
    m = re.search("(http:\/\/dizipub.com\/player\S+)|(http:\/\/play.dizibox.(net|org)\/dbx.php\S+)", r.text)
    if m:
        video_url = m.group(0)[:-1].replace('#038;','')
    else:
        print("Not using Dizipub player.")
        return

    r = requests.get(video_url)
    r.close()
    m = re.search('sources:(.|\n)*?]', r.text).group(0).replace("sources:", "sources =")

    code = compile(m, '<string>', 'exec')
    ns = {}
    exec(code, ns)

    for src in ns['sources']:
        if src['label'].startswith('720'):
            target_url=src['file'].replace("\\","")
            output="%s.mp4" % url.split("/")[-2]
            output=output.replace("-izle","").replace("-bolum","").replace("-","_")
            r = requests.get(target_url, stream=True)
            with open("%s.part" % output, "wb") as f:
                total_length = int(r.headers.get('content-length'))
                for chunk in progress.bar(r.iter_content(chunk_size=1024), expected_size=(total_length/1024) + 1):
                    if chunk:
                        f.write(chunk)
                        f.flush()
            r.close()
            os.rename("%s.part" % output, output)
            return

    print("Failed to find a HD source.")
    return

if __name__ == "__main__":
    for url in sys.argv[1:]:
        try:
            if not url.endswith("/"):
                url.append("/")
            download(url)
        except KeyboardInterrupt:
            pass
