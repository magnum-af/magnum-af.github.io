#!/bin/sh -ex

# update source code to newest master:
git submodule foreach git pull origin master

# build html
mkdir build && (cd build && cmake ../magnum.af && make docu_html)

# replace files in docs/
mkdir tmp/ && mv docs/_config.yml tmp/ # 'stash' github generated theme file _config.yml
rm -r docs/ && cp -r build/docu/html/ docs/ # replace all docs
mv tmp/_config.yml docs/ && rmdir tmp/ # 'stash pop'

# cleanup and info
rm -r build/
git status

# release changes to github
is_release="false"
commit_message="update docs"
if [ "$is_release" = "true" ]; then
    git add docs/
    git commit -m "$commit_message"
    git push
fi
