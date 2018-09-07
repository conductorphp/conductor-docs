#!/usr/bin/env bash

for branch in $(git for-each-ref --format='%(refname)' refs/heads/); do
    branch=${branch:11}
    if [[ ! 'release-' = ${branch:0:8} ]]; then
      continue
    fi

    version=${branch:8}
    echo "Updating $version docs..."
    {
        git checkout $branch
        composer update

        if [[ -z $(git diff) ]]; then
            echo "No changes found in $version docs."
            continue
        fi

        ./install-module-docs.sh
        mike deploy $version -p
        git add .
        git commit -m "Updated module docs"
        git push
    }
    echo "$version docs deployed."
done
