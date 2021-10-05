#!/bin/bash -ex
# $1: optional commit message string

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

# release changes to github if $1 is set
commit_message="$1"
if [ -n "$commit_message" ]; then
    echo "argument \$1='$commit_message' interpreted as commit message"
    git add -u
    git add docs/
    git status
    read -r -p 'are you sure you want to commit and push all changes listed above? (y/n) ' is_release
    if [ "$is_release" = "y" ]; then
        git commit -m "$commit_message"
        git push
    else
        echo "aborting release..."
    fi

else
    git status
fi
