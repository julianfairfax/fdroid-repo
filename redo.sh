export GH_ACCESS_TOKEN=$(cat "${0%/*}"/token.txt)

declare -a repos=("fdroid-repo" "Simple-Commons" "Simple-App-Launcher" "Simple-Calculator" "Simple-Calendar" "Simple-Camera" "Simple-Clock" "Simple-Contacts" "Simple-Dialer" "Simple-Draw" "Simple-File-Manager" "Simple-Flashlight" "Simple-Gallery" "Simple-Keyboard" "Simple-Music-Player" "Simple-Notes" "Simple-SMS-Messenger" "Simple-Thank-You" "Simple-Voice-Recorder")

for repo in ${repos[@]}; do
    if [[ $(gh repo list | grep $repo | sed "s/$repo.*/$repo/") == julianfairfax/$repo ]]; then
        gh repo delete $repo --confirm
    fi

    if [[ $repo == fdroid-repo ]]; then
        gh repo create $repo  --public

        base64 "${0%/*}"/fdroid/config.yml | gh secret set CONFIG_YML --repo julianfairfax/fdroid-repo

        base64 "${0%/*}"/fdroid/keystore.p12 | gh secret set KEYSTORE_P12 --repo julianfairfax/fdroid-repo

        base64 "${0%/*}"/keystore.keystore | gh secret set KEYSTORE --repo julianfairfax/$repo

        base64 "${0%/*}"/keystore.properties | gh secret set KEYSTORE_PROPERTIES --repo julianfairfax/$repo

        echo "$GH_ACCESS_TOKEN" | gh secret set GH_ACCESS_TOKEN --repo julianfairfax/$repo
    fi
done

cd "${0%/*}"

rm -rf .git

rm -rf fdroid/metadata

rm -rf fdroid/repo

sed -i -z "s/<\!-- This table is auto-generated. Do not edit -->.*<\!-- end apps table -->/<\!-- This table is auto-generated. Do not edit -->\n<\!-- end apps table -->/" README.md

git init

git add .github/workflows

git commit -m "Update"

git remote add origin https://github.com/julianfairfax/fdroid-repo

git push --set-upstream origin main

git add .

git commit -m "Update"

git push --set-upstream origin main