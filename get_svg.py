import urllib.request
import json

url = "https://raw.githubusercontent.com/Templarian/MaterialDesign/master/meta.json"
req = urllib.request.Request(url)
with urllib.request.urlopen(req) as response:
    data = json.loads(response.read().decode())

for icon in data:
    if 'drink' in icon['name'] or 'water' in icon['name'] or 'cup' in icon['name']:
        print(icon['name'])
