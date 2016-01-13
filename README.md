# Infinity.Build

Build Unity3d project to ios, android, osx, win64 platforms.

## Install

### Infinity.Build

First, you need to install this.

```
git submodule add git@bitbucket.org:networm/infinity.build.git Infinity.Build
```

### Infinity.BuildInUnity3d

Second, you need install helper in Unity3d.

```
cd YourUnity3dProject
git submodule add git@github.com:networm/Infinity.BuildInUnity3d.git Assets/Editor/BuildInUnity3d
```

## Usage

### Standard usage

```
cd Infinity.Build
ruby build.rb --platform ios --type develop --p12 YOUR_P12_PATH --p12-password "YOUR_P12_PASSWORD" --profile "YOUR_MOBILEPROFILE_PATH"
```

### Simple usage

If you have installed your mobile provision and placed your P12 file at "~/Documents/Develop/Develop.p12" and your P12 password is empty, then you could omit all these three option.

If you omit platform and type then default platform is ios and default type is release.

```
cd Infinity.Build
ruby build.rb # build ios release by default
```

## Help

```
cd Infinity.Build
ruby build.rb --help
```

## Environment

```
Unity3d 5.3.1f1
Xcode 7.2(7C68)
OS X 10.11.2 (15C50)
```

## LICENSE

MIT LICENSE
