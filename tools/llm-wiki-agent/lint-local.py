"""Run the upstream structural subset of lint without making model calls."""

import json

from tools._utils import REPO_ROOT, all_wiki_pages
from tools.lint import find_broken_links, find_orphans


def main():
    pages = all_wiki_pages()
    broken = [
        {"path": path.relative_to(REPO_ROOT).as_posix(), "target": target}
        for path, target in find_broken_links(pages)
    ]
    orphans = [path.relative_to(REPO_ROOT).as_posix() for path in find_orphans(pages)]
    print(json.dumps({"broken_links": broken, "orphans": orphans}, indent=2))
    return 1 if broken else 0


if __name__ == "__main__":
    raise SystemExit(main())
