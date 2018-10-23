# LikeManager

## Overview
Like Manager is an iOS app that allows you to manage likes in Twitter.
You can download the complete app from [App Store](https://itunes.apple.com/jp/app/%E3%82%A2%E3%83%89%E3%82%BF%E3%82%B0/id1438481163?l=en&mt=8). 

These are the main function of the app

- Adding Tag: Drag and drop tags that you want to associate with any of your likes
- Categorising Likes: Tagged likes are categorised and easily organized
- Custom Tag: You can make your custom tags
- Searching Likes: You can search likes using the search bar

<img src="https://user-images.githubusercontent.com/32465018/47274681-a9a09a00-d5e2-11e8-9f9b-8e2867bb24b9.png" height="500px"> <img src="https://user-images.githubusercontent.com/32465018/47274691-d6ed4800-d5e2-11e8-961a-fc880ef36b9b.png" height="500px"> <img src="https://user-images.githubusercontent.com/32465018/47274698-f1272600-d5e2-11e8-937d-ac248a2b338d.png" height="500px">



## Requirement
Like Manager uses libraries below

- [Realm](https://realm.io/): An open-source object database management system that allows users to build engaging mobile applications with minimal development time
- [TwitterKit](https://github.com/twitter/twitter-kit-ios): Native SDK to include Twitter content in mobile apps, which i,s designed to make interacting with Twitter seamless and efficient.


Here is the requirement:
1. Register account in Twitter application management from the link below.
[Application Management](https://apps.twitter.com)

2. Get ```Consumer Key``` and ```Consumer Secret``` from the Application Management page and
  - Put them in ```AppDelegate.swift```
  - add your ```Consumer``` Key into ```info.plist```'s CFBundleURLTypes > CFBundleURLSchemes, after the string **twitterkit-**


## Demo
<img src="https://user-images.githubusercontent.com/32465018/47329931-6a8d4a00-d6b1-11e8-86b5-cf5f43de29b1.gif" >
