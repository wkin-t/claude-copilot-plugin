#!/usr/bin/env bash
# release.sh — 版本同步、提交、推送
# 用法: ./release.sh <version>  例: ./release.sh 1.0.4

set -e

VERSION="$1"

if [ -z "$VERSION" ]; then
  echo "用法: ./release.sh <version>"
  echo "例:   ./release.sh 1.0.4"
  exit 1
fi

# 验证版本格式 x.y.z
if ! echo "$VERSION" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  echo "错误: 版本号格式须为 x.y.z（如 1.0.4）"
  exit 1
fi

echo "发布 v$VERSION ..."

# 更新 plugin.json
python -c "
import json, sys
path = 'plugins/copilot-cli/.claude-plugin/plugin.json'
with open(path, 'r', encoding='utf-8') as f:
    d = json.load(f)
d['version'] = sys.argv[1]
with open(path, 'w', encoding='utf-8') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
    f.write('\n')
print('  plugin.json ->',  sys.argv[1])
" "$VERSION"

# 更新 marketplace.json（metadata.version 和 plugins[0].version）
python -c "
import json, sys
path = '.claude-plugin/marketplace.json'
with open(path, 'r', encoding='utf-8') as f:
    d = json.load(f)
d['metadata']['version'] = sys.argv[1]
d['plugins'][0]['version'] = sys.argv[1]
with open(path, 'w', encoding='utf-8') as f:
    json.dump(d, f, indent=2, ensure_ascii=False)
    f.write('\n')
print('  marketplace.json ->', sys.argv[1])
" "$VERSION"

git add plugins/copilot-cli/.claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "release: v$VERSION"
git push origin master

echo "已发布 v$VERSION"
echo "同事执行以下命令即可升级:"
echo "  claude plugin marketplace update"
echo "  claude plugin update copilot-cli@copilot-cli-plugins --scope user"
