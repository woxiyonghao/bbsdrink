import re
import random

topics = ["优质睡眠", "低脂饮食", "规律运动", "心理健康", "科学护眼", "颈椎保养", "肠胃健康", "心血管养护", "健康减脂", "日常补水"]
images = [
  "https://images.unsplash.com/photo-1548839140-29a749e1bc81?w=400&q=80",
  "https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?w=400&q=80",
  "https://images.unsplash.com/photo-1523362628745-0c100150b504?w=400&q=80",
  "https://images.unsplash.com/photo-1616174620583-02685715975d?w=400&q=80",
  "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400&q=80",
  "https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400&q=80",
  "https://images.unsplash.com/photo-1495474472204-518605ec2187?w=400&q=80",
  "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&q=80",
  "https://images.unsplash.com/photo-1524749292158-7540c2494485?w=400&q=80",
  "https://images.unsplash.com/photo-1512438248247-f0f2a5a8b7f0?w=400&q=80"
]

templates = [
  ("关于{topic}的5个健康误区", "你以为正确的{topic}习惯，可能正在隐形地伤害身体，本文带你揭开真相。"),
  ("坚持{topic}，你的身体会发生什么改变？", "科学的{topic}不仅能改变外在体态，更能从内而外提升你的日常精力水平。"),
  ("职场人必看的{topic}黄金法则", "工作再忙也不能忽视身体。掌握这些{topic}微习惯，让你的健康事半功倍。"),
  ("打破传统认知：最新{topic}科学指南", "医学研究表明，许多传统的{topic}观念已经过时。快来看看前沿的科学建议。"),
  ("每天只需5分钟，轻松搞定{topic}", "不需要大块时间，通过碎片化的努力也能在{topic}方面取得显著成效。")
]

file_path = "entry/src/main/ets/store/MockArticles.ets"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Remove the closing bracket of the array
if content.endswith("];"):
    content = content[:-2]
elif content.endswith("];\n"):
    content = content[:-3]

new_articles = []
for i in range(11, 61):
    topic = topics[i % len(topics)]
    template = templates[random.randint(0, len(templates)-1)]
    title = template[0].replace("{topic}", topic)
    summary = template[1].replace("{topic}", topic)
    img = random.choice(images)
    text = f"在谈论{topic}时，很多人容易陷入思维定式。\\n\\n实际上，保持良好的{topic}习惯不仅需要毅力，更需要科学的方法指导。最新的健康研究显示，系统性地优化{topic}策略，能够显著降低患慢性疾病的风险。\\n\\n在日常生活中，我们可以通过以下三个简单的步骤来改善：\\n1. 循序渐进：不要试图一天之内改变所有坏习惯。\\n2. 规律作息：身体有一个内部生物钟，顺应它往往能事半功倍。\\n3. 定期评估：定期回顾自己的进展，听从身体的声音。\\n\\n记住，健康是一场马拉松，而不是百米冲刺。在{topic}这条路上，长期坚持比什么都重要。"
    
    article_str = f"  ,\n  {{\n    id: {i},\n    title: '{title}',\n    summary: '{summary}',\n    imageUrl: '{img}',\n    content: '{text}'\n  }}"
    new_articles.append(article_str)

content += "".join(new_articles) + "\n];\n"

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Generated 50 articles and appended successfully.")
