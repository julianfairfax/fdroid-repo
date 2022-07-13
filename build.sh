declare -a repos=("Simple-Commons")

for repo in ${repos[@]}; do
    if [[ ! $(gh repo list | grep $repo | sed "s/$repo.*/$repo/") == julianfairfax/$repo ]]; then
        gh repo fork SimpleMobileTools/$repo --clone=false
    fi

    git clone https://github.com/SimpleMobileTools/$repo
done

declare -a repos=("Simple-App-Launcher" "Simple-Calculator" "Simple-Calendar" "Simple-Camera" "Simple-Clock" "Simple-Contacts" "Simple-Dialer" "Simple-Draw" "Simple-File-Manager" "Simple-Flashlight" "Simple-Gallery" "Simple-Keyboard" "Simple-Music-Player" "Simple-Notes" "Simple-SMS-Messenger" "Simple-Thank-You" "Simple-Voice-Recorder")

for repo in ${repos[@]}; do
    if [[ ! $(gh repo list | grep $repo | sed "s/$repo.*/$repo/") == julianfairfax/$repo ]]; then
        gh repo fork SimpleMobileTools/$repo --clone=false
    fi

    if [[ ! $(gh secret list --repo julianfairfax/$repo | grep KEYSTORE | grep -v KEYSTORE_PROPERTIES | sed 's/KEYSTORE.*/KEYSTORE/') ]]; then
        echo "$KEYSTORE" | gh secret set KEYSTORE --repo julianfairfax/$repo
    fi

    if [[ ! $(gh secret list --repo julianfairfax/$repo | grep KEYSTORE_PROPERTIES | sed 's/KEYSTORE_PROPERTIES.*/KEYSTORE_PROPERTIES/') ]]; then
        echo "$KEYSTORE_PROPERTIES" | gh secret set KEYSTORE_PROPERTIES --repo julianfairfax/$repo
    fi

    if [[ ! $(gh secret list --repo julianfairfax/$repo | grep GH_ACCESS_TOKEN | sed 's/GH_ACCESS_TOKEN.*/GH_ACCESS_TOKEN/') ]]; then
        echo "$GH_ACCESS_TOKEN" | gh secret set GH_ACCESS_TOKEN --repo julianfairfax/$repo
    fi

    branch=$(gh release list --repo SimpleMobileTools/$repo | grep Latest | sed 's/\	Latest.*//')

    if [[ ! $branch == $(gh release list --repo julianfairfax/$repo | grep Latest | sed 's/\	Latest.*//') ]]; then        
        git clone https://github.com/SimpleMobileTools/$repo

        cd $repo

        if [[ $repo == Simple-Camera ]]; then
            git checkout -b $branch
        else
            git fetch --all --tags
        
            git checkout tags/$branch -b $branch
        fi

        branch=$(cat app/build.gradle | grep Simple-Commons | sed "s/    implementation 'com.github.SimpleMobileTools:Simple-Commons://" | sed "s/'//")
        
        cd ../Simple-Commons

        git clone https://github.com/julianfairfax/Simple-Commons

        cd Simple-Commons

        git_branch=$(git branch -a | grep $branch)

        if [[ $git_branch == "" ]]; then
            cd ../

            rm -rf Simple-Commons

            git checkout $branch -b $branch

            sed -i "s/18 -> getColors(R.array.md_greys)/18 -> getColors(R.array.md_greys)\n        19 -> getColors(R.array.md_greys)/" commons/src/main/kotlin/com/simplemobiletools/commons/dialogs/LineColorPickerDialog.kt

            sed -i "s/\".Grey_black\"/\".Grey_black\",\n    \".Grey_white\"/" commons/src/main/kotlin/com/simplemobiletools/commons/helpers/Constants.kt

            sed -i "0,/<item>@color\/md_grey_black<\/item>/s//<item>@color\/md_grey_black<\/item>\n        <item>@color\/md_grey_white<\/item>/" commons/src/main/res/values/arrays.xml

            git remote set-url origin https://github.com/julianfairfax/Simple-Commons

            git config --global user.name 'github-actions'

            git config --global user.email '41898282+github-actions[bot]@users.noreply.github.com'

            git add .

            git commit -m "Automated update"

            git push https://$GH_ACCESS_TOKEN@github.com/julianfairfax/Simple-Commons.git

            export commit=$(git log -n 1 --pretty=format:"%H" | cut -c 1-10)
        else
            git checkout remotes/origin/$branch

            export commit=$(git log -n 1 --pretty=format:"%H" | cut -c 1-10)

            cd ../

            rm -rf Simple-Commons
        fi

        cd ../

        cd $repo

        sed -i "s/implementation 'com.github.SimpleMobileTools:Simple-Commons:.*'/implementation 'com.github.julianfairfax:Simple-Commons:$commit'/" app/build.gradle

        sed -i '0,/android:icon="@mipmap\/ic_launcher"/s//android:icon="@mipmap\/ic_launcher_grey_white"/' app/src/main/AndroidManifest.xml

        sed -i '0,/android:roundIcon="@mipmap\/ic_launcher"/s//android:roundIcon="@mipmap\/ic_launcher_grey_white"/' app/src/main/AndroidManifest.xml

        sed -i -z "s/<activity-alias\n            android:name=\".activities.SplashActivity.Grey_black\"\n            android:enabled=\"false\"\n            android:exported=\"true\"\n            android:icon=\"@mipmap\/ic_launcher_grey_black\"\n            android:roundIcon=\"@mipmap\/ic_launcher_grey_black\"\n            android:targetActivity=\".activities.SplashActivity\">\n\n            <intent-filter>\n                <action android:name=\"android.intent.action.MAIN\" \/>\n                <category android:name=\"android.intent.category.LAUNCHER\" \/>\n            <\/intent-filter>\n        <\/activity-alias>/<activity-alias\n            android:name=\".activities.SplashActivity.Grey_black\"\n            android:enabled=\"false\"\n            android:exported=\"true\"\n            android:icon=\"@mipmap\/ic_launcher_grey_black\"\n            android:roundIcon=\"@mipmap\/ic_launcher_grey_black\"\n            android:targetActivity=\".activities.SplashActivity\">\n\n            <intent-filter>\n                <action android:name=\"android.intent.action.MAIN\" \/>\n                <category android:name=\"android.intent.category.LAUNCHER\" \/>\n            <\/intent-filter>\n        <\/activity-alias>\n\n        <activity-alias\n            android:name=\".activities.SplashActivity.Grey_white\"\n            android:enabled=\"false\"\n            android:exported=\"true\"\n            android:icon=\"@mipmap\/ic_launcher_grey_white\"\n            android:roundIcon=\"@mipmap\/ic_launcher_grey_white\"\n            android:targetActivity=\".activities.SplashActivity\">\n\n            <intent-filter>\n                <action android:name=\"android.intent.action.MAIN\" \/>\n                <category android:name=\"android.intent.category.LAUNCHER\" \/>\n            <\/intent-filter>\n        <\/activity-alias>/" app/src/main/AndroidManifest.xml

        if [[ "$(cat "$(find -name SimpleActivity.kt)" | grep "            R.mipmap.ic_launcher_grey_black")" == "            R.mipmap.ic_launcher_grey_black" ]]; then
            sed -i "s/            R.mipmap.ic_launcher_grey_black/            R.mipmap.ic_launcher_grey_black,\n            R.mipmap.ic_launcher_grey_white/" "$(find -name SimpleActivity.kt)"
        elif [[ "$(cat "$(find -name SimpleActivity.kt)" | grep "        R.mipmap.ic_launcher_grey_black")" == "        R.mipmap.ic_launcher_grey_black" ]]; then
            sed -i "s/        R.mipmap.ic_launcher_grey_black/        R.mipmap.ic_launcher_grey_black,\n        R.mipmap.ic_launcher_grey_white/" "$(find -name SimpleActivity.kt)"
        fi

        cp app/src/main/res/mipmap-anydpi-v26/ic_launcher_grey_black.xml app/src/main/res/mipmap-anydpi-v26/ic_launcher_grey_white.xml

        sed -i 's/grey_black/grey_white/' app/src/main/res/mipmap-anydpi-v26/ic_launcher_grey_white.xml

        sed -i 's/ic_launcher_foreground/ic_launcher_foreground_white/' app/src/main/res/mipmap-anydpi-v26/ic_launcher_grey_white.xml

        for mipmap in app/src/main/res/*; do
            if [[ $mipmap == *mipmap* && ! $mipmap == *anydpi-v26 ]]; then
                convert $mipmap/ic_launcher_foreground.png -channel RGB -negate $mipmap/ic_launcher_foreground_white.png

                convert $mipmap/ic_launcher_grey_black.png -channel RGB -negate $mipmap/ic_launcher_grey_white.png
            fi
        done

        sed -i -z "s/\n        proprietary {}//" app/build.gradle

        mkdir .github/workflows

        echo "name: Build

on:
  push:

jobs:
  apps:
    name: \"Build\"
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: set up JDK 11
      uses: actions/setup-java@v1
      with:
        java-version: 11

    - name: Run build script
      run: bash build.sh 2>&1
      env:
        GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
        GH_ACCESS_TOKEN: \${{ secrets.GH_ACCESS_TOKEN }}
        KEYSTORE_PROPERTIES: \${{ secrets.KEYSTORE_PROPERTIES }}
        KEYSTORE: \${{ secrets.KEYSTORE }}

    - name: Get version
      id: get-version
      run: echo ::set-output name=VERSION::\${GITHUB_REF#refs/heads/}

    - name: Create Release
      id: create_release
      uses: actions/create-release@v1
      env:
        GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
      with:
        tag_name: \"\${{ steps.get-version.outputs.VERSION }}\"
        release_name: \"\${{ steps.get-version.outputs.VERSION }}\"
        draft: false
        prerelease: false

    - name: Get Universal APK path
      id: get-universal-path
      run: |
        if [[ -d app/build/outputs/apk/fdroid/release ]]; then
          echo ::set-output name=PATH::\$(ls -1 app/build/outputs/apk/fdroid/release/*-fdroid-release.apk)
        elif [[ -d app/build/outputs/apk/foss/release ]]; then
          echo ::set-output name=PATH::\$(ls -1 app/build/outputs/apk/foss/release/*-foss-release.apk)
        fi
      
    - name: Get Universal APK Filename
      id: get-universal-filename
      run: |
        if [[ -d app/build/outputs/apk/fdroid/release ]]; then
          echo ::set-output name=FILENAME::\$(basename \$(ls -1 app/build/outputs/apk/fdroid/release/*-fdroid-release.apk) )
        elif [[ -d app/build/outputs/apk/foss/release ]]; then
          echo ::set-output name=FILENAME::\$(basename \$(ls -1 app/build/outputs/apk/foss/release/*-foss-release.apk) )
        fi

    - name: Upload Universal APK
      uses: actions/upload-release-asset@v1
      env:
        GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
      with:
        upload_url: \${{ steps.create_release.outputs.upload_url }}
        asset_path: \"\${{ steps.get-universal-path.outputs.PATH }}\"
        asset_name: \${{ steps.get-universal-filename.outputs.FILENAME }}
        asset_content_type: application/vnd.android.package-archive" | tee .github/workflows/build.yml

        echo "echo \"\$KEYSTORE_PROPERTIES\" | base64 -d - > keystore.properties

echo \"\$KEYSTORE\" | base64 -d - > keystore.keystore

./gradlew assembleRelease

while [[ ! -d app/build/outputs/apk/fdroid/release && ! -d app/build/outputs/apk/foss/release ]]; do
    ./gradlew assembleRelease
done" | tee build.sh

        git remote set-url origin https://github.com/julianfairfax/$repo

        git config --global user.name 'github-actions'

        git config --global user.email '41898282+github-actions[bot]@users.noreply.github.com'

        git add .

        git commit -m "Automated update"

        git push https://$GH_ACCESS_TOKEN@github.com/julianfairfax/$repo.git --tags

        git push https://$GH_ACCESS_TOKEN@github.com/julianfairfax/$repo.git
        
        cd ../

        rm -rf $repo
    fi
done

rm -rf Simple-Commons

built=0

while [[ $built == *0* ]]; do
    built=""

    for repo in ${repos[@]}; do
        if [[ ! $(gh release list --repo SimpleMobileTools/$repo | grep Latest | sed 's/\	Latest.*//') == $(gh release list --repo julianfairfax/$repo | grep Latest | sed 's/\	Latest.*//') ]]; then
            built="$built 0"
        fi
    done

    sleep 1m
done