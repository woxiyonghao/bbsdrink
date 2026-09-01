import re

file_path = "/Users/mk10/Desktop/bbs/bbsdrink/entry/src/main/ets/store/MockArticles.ets"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

images = [
    "$r('app.media.run_static')",
    "$r('app.media.fruit_static')",
    "$r('app.media.stretch_static')",
    "$r('app.media.rest_static')",
    "$r('app.media.neck_static')"
]

def replacer(match):
    replacer.count += 1
    idx = replacer.count % len(images)
    return f"imageUrl: {images[idx]}"

replacer.count = -1

# Find any $r('app.media.article_something') or $r('app.media.startIcon')
new_content = re.sub(r"imageUrl:\s*\$r\('app\.media\.[^']+'\)", replacer, content)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(new_content)

print("MockArticles.ets updated with PNGs.")
