#!/bin/bash -ex
# $1: optional commit message string

# update source code to newest master:
git submodule foreach git pull origin master

# backup magnum.af/README.md
cp magnum.af/README.md README.md.bak

# skip github/gitlab specific ' <\details> ' sections in magnum.af/README.md
sed -i '/<*details>/d' magnum.af/README.md

# replace soft github/gitlab links with hard github link for HTML docu
github_hard_link_prefix='https://github.com/magnum-af/magnum.af/blob/master/'
link_replace_patterns=('magnumaf' 'python' 'Dockerfile')
for pattern in "${link_replace_patterns[@]}"; do
    # append prefix to all links containing the listed patterns above ( matching the link pattern [.*](<pattern>.*) )
    sed -i '/\[.*\]('"$pattern"'.*)/ { s%'"$pattern"'/*%'"$github_hard_link_prefix"'&%g; }' magnum.af/README.md
done

# build html
mkdir build && (cd build && cmake ../magnum.af && make docu_html)

# reset magnum.af/README.md
cp magnum.af/README.md edited_README.md # retain copy of modified file
mv README.md.bak magnum.af/README.md # reset original file for clean git submodule

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
