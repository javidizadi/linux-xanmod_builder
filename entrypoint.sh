#!/bin/bash
commit_hash="47e03e6bd1dbaa44f9371788bf838633fdb3c038"
repo=`printenv REPO`
cd /home/xanmod_builder
git clone https://aur.archlinux.org/linux-xanmod.git &&
cd linux-xanmod
echo "Checkout specified commit..."
git checkout $commit_hash &&
echo "Compiling kernel..."
env MAKEFLAGS="-s -j$(nproc)" _microarchitecture=34 use_numa=n use_tracers=n makepkg --skippgpcheck &&
echo "Logining in to GitHub..."
printenv GITHUB_KEY | gh auth login --with-token
version=`git log --format=%B -n 1 $commit_hash | awk -F '-' 'NR==1{print "v"$1}'`
gh release view "$version" --repo "$repo"
tag_exists=$?
if test $tag_exists -eq 0; then
    echo "Tag already exists!"
    echo "Removing previous release..."
    gh release delete "$version" -y --cleanup-tag --repo "$repo"
else
    echo "Tag does not exist!"
fi
echo "Releasing $version binaries into $repo"
gh release create "$version" ./*.pkg.tar.zst --repo "$repo" &&
echo "Released!"
echo "Loging out from Github..."
gh auth logout -h github.com
