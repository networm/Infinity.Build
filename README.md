# Infinity.Build

Build Unity3d project to ios, android, osx, win64 platforms.

## Install

First, you need to clone this outside your project.

```
git clone git@github.com:networm/Infinity.Build.git
```

Second, you need install Infinity.BuildInUnity3d in Unity3d.

```
cd YourUnity3dProject
git submodule add git@github.com:networm/Infinity.BuildInUnity3d.git Assets/Editor/BuildInUnity3d
```

## Usage

```
cd Infinity.Build
ruby build.rb --platform ios --type release --unity3d-project "YOUR_UNITY3D_PROJECT_DIR" --deployment app-store --build 1.0.0.0 --p12 "YOUR_P12_PATH" --p12-password "YOUR_P12_PASSWORD" --provision "YOUR_PROVISION_PATH"
```

## Help

```
cd Infinity.Build
ruby build.rb --help
```

## Introduction

[Introduction (Chinese Simplified)](https://github.com/networm/Infinity.Build/wiki/Introduction)

## Environment

```
Unity3d 5.3.1f1
Xcode 7.2(7C68)
OS X 10.11.2 (15C50)
```

## LICENSE

MIT LICENSE
