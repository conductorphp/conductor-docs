#!/usr/bin/env bash

for branch in $(git for-each-ref --format='%(refname)' refs/heads/); do
    branch=${branch:11}
    if [[ ! 'release-' = ${branch:0:8} ]]; then
      continue
    fi

    version=${branch:8}
    echo "Updating $version docs..."
    {
        currentBranch=$(git symbolic-ref HEAD --short)
        if [[ ! $currentBranch == $branch ]]; then
            git checkout $branch > /dev/null
        fi
        composer update --quiet > /dev/null

        if [[ -z $(git diff) ]]; then
            echo "No changes found in $version docs."
            continue
        fi

        echo "Changes found. Deploying..."
        deploy-module-docs.sh
        mike deploy $version -p

        echo "Pushing changes back to repo..."
        git add .
        git push -u origin $branch
    }
    echo "$version docs deployed."
done
