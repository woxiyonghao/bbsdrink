import re

file_path = "/Users/mk10/Desktop/bbs/bbsdrink/entry/src/main/ets/store/MockArticles.ets"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

images = [
    "$r('app.media.article_water')",
    "$r('app.media.article_sport')",
    "$r('app.media.article_sleep')",
    "$r('app.media.article_diet')",
    "$r('app.media.article_mind')"
]

# We need to replace all instances of imageUrl: $r('app.media.startIcon') with the images cyclically.
# Let's find all occurrences and replace them.

def replacer(match):
    replacer.count += 1
    idx = replacer.count % len(images)
    return f"imageUrl: {images[idx]}"

replacer.count = -1

new_content = re.sub(r"imageUrl:\s*\$r\('app\.media\.startIcon'\)", replacer, content)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(new_content)

print("MockArticles.ets updated.")
