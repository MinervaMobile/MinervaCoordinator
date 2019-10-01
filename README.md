# Minerva

git tag 'version'
git push --tags
pod lib lint
pod trunk push

protoc --swift_out=../Generated *.proto

./Example/Pods/SwiftLint/swiftlint lint
