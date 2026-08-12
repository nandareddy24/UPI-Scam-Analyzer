import glob
import re

templates = glob.glob('templates/*.html')
pattern = re.compile(r'\s*<a href="/android"[\s\S]*?</a>')

for path in templates:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = pattern.sub('', content)

    if new_content != content:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated: {path}")

print("Android web feature links removal complete.")
