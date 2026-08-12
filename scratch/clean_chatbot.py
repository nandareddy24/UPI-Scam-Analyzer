import glob
import re

templates = glob.glob('templates/*.html')

sidebar_pattern = re.compile(r'\s*<a href="/chatbot"[\s\S]*?</a>')
modal_pattern = re.compile(r'\s*<!-- Floating ScamShield AI Chatbot Widget Button & Modal -->[\s\S]*?(?=</body>)')

for path in templates:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = sidebar_pattern.sub('', content)
    new_content = modal_pattern.sub('\n\n', new_content)

    if new_content != content:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated: {path}")

print("Chatbot removal complete.")
