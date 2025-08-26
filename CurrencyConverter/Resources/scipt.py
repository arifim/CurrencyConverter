import re

with open("world_currencies.json", "r") as f:
    text = f.read()

# Lowercase all "code" values
text = re.sub(r'("code":\s*")([A-Z]+)(")', lambda m: m.group(1) + m.group(2).lower() + m.group(3), text)

with open("file.json", "w") as f:
    f.write(text)
