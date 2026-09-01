import os

svg_dir = "/Users/mk10/Desktop/bbs/bbsdrink/entry/src/main/resources/base/media"
os.makedirs(svg_dir, exist_ok=True)

svg_templates = [
    {
        "name": "article_water.svg",
        "color": "#4A90E2",
        "text": "科学饮水"
    },
    {
        "name": "article_sport.svg",
        "color": "#F5A623",
        "text": "适量运动"
    },
    {
        "name": "article_sleep.svg",
        "color": "#9013FE",
        "text": "充足睡眠"
    },
    {
        "name": "article_diet.svg",
        "color": "#7ED321",
        "text": "健康饮食"
    },
    {
        "name": "article_mind.svg",
        "color": "#F5A623",
        "text": "心理健康"
    }
]

svg_content = """<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300" viewBox="0 0 400 300">
  <rect width="400" height="300" fill="{color}" rx="20"/>
  <text x="50%" y="50%" dominant-baseline="middle" text-anchor="middle" fill="#ffffff" font-size="48" font-weight="bold" font-family="sans-serif">{text}</text>
  <circle cx="200" cy="80" r="40" fill="#ffffff" opacity="0.3"/>
  <path d="M100 250 Q 200 150 300 250" stroke="#ffffff" stroke-width="8" fill="none" opacity="0.3"/>
</svg>"""

for t in svg_templates:
    path = os.path.join(svg_dir, t["name"])
    with open(path, "w", encoding="utf-8") as f:
        f.write(svg_content.format(color=t["color"], text=t["text"]))

print("SVGs generated.")
