![jazz](http://vignette2.wikia.nocookie.net/transformers/images/c/cf/MovieJazz_promorender.jpg/revision/latest?cb=20080410230836)

Jazz is an view animation library in Swift for iOS. It provides custom controls that can provide easy animations.

## Features

- Animatable controls
- Button
- LoadingView/ProgressView
- Shape
- Simple concise codebase at just a few hundred LOC.

## Example

First thing is to import the framework. See the Installation instructions on how to add the framework to your project.

```swift
import Jazz
```

See the examples directory for pretty example projects.

![](https://raw.githubusercontent.com/daltoniam/Jazz/assets/shapedemo.gif)

The code:

```swift
//Shape is a view in a view controller

//add a shape view to the view controller 
let shape = Shape(frame: CGRectMake(10, 80, 250, 50))
shape.color = UIColor(red: 253/255.0, green: 56/255.0, blue: 105/255.0, alpha: 1)
shape.cornerRadius = 25
shape.corners = UIRectCorner.AllCorners
shape.autoresizingMask = .FlexibleHeight | .FlexibleWidth
self.view.addSubview(shape)

//play those animations!
Jazz(0.25, delay: 2.00, {
    let width: CGFloat = 300
    self.shape.frame = CGRectMake((self.view.frame.size.width-width)/2, 80, width, 50)
    self.shape.borderWidth = 3
    self.shape.borderColor = UIColor.orangeColor()
    self.shape.color = UIColor.redColor()
    return [self.shape]
}).play(0.25, delay: 2.00, {
    let width: CGFloat = 100
    self.shape.frame = CGRectMake((self.view.frame.size.width-width)/2, 80, width, 50)
    self.shape.color = UIColor.purpleColor()
    return [self.shape]
}).play(0.25, delay: 4.00, {
    self.shape.borderWidth = 0
    self.shape.borderColor = nil
    self.shape.cornerRadius = 0
    self.shape.color = UIColor.yellowColor()
    self.shape.frame = CGRectMake(10, 80, 250, 100)
    return [self.shape]
}).play(0.25, delay: 2.00, {
    self.shape.cornerRadius = 50
    self.shape.frame = CGRectMake(10, 80, 100, 100)
    self.shape.color = UIColor.blueColor()
    return [self.shape]
})
```

## Requirements

Jazz works with iOS 7 or above. It is recommended to use iOS 8/10.10 or above for Cocoapods/framework support.

## Installation

### Cocoapods

Check out [Get Started](http://cocoapods.org/) tab on [cocoapods.org](http://cocoapods.org/).

To use SwiftHTTP in your project add the following 'Podfile' to your project

	source 'https://github.com/CocoaPods/Specs.git'
	platform :ios, '8.0'
	use_frameworks!

	pod 'Jazz', '~> 0.9.1'

Then run:

    pod install

### Carthage

Check out the [Carthage](https://github.com/Carthage/Carthage) docs on how to add a install. The `Jazz` framework is already setup with shared schemes.

[Carthage Install](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application)

### Rogue

First see the [installation docs](https://github.com/acmacalister/Rogue) for how to install Rogue.

To install Jazz run the command below in the directory you created the rogue file.

```
rogue add https://github.com/daltoniam/jazz
```

Next open the `libs` folder and add the `Jazz.xcodeproj` to your Xcode project. Once that is complete, in your "Build Phases" add the `Jazz.framework` to your "Link Binary with Libraries" phase. Make sure to add the `libs` folder to your `.gitignore` file.

### Other

Simply grab the framework (either via git submodule or another package manager).

Add the `Jazz.xcodeproj` to your Xcode project. Once that is complete, in your "Build Phases" add the `Jazz.framework` to your "Link Binary with Libraries" phase.

### Add Copy Frameworks Phase

If you are running this in on a physical iOS device you will need to make sure you add the `Jazz.framework` to be included in your app bundle. To do this, in Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar. In the tab bar at the top of that window, open the "Build Phases" panel. Expand the "Link Binary with Libraries" group, and add `Jazz.framework`. Click on the + button at the top left of the panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add the `Jazz.framework`.

## TODOs

- [ ] Add extra convenience animation tools.
- [ ] Add example project
- [ ] Complete Docs
- [ ] Add Unit Tests

## License

Jazz is licensed under the Apache v2 License.

## Contact

### Dalton Cherry
* https://github.com/daltoniam
* http://twitter.com/daltoniam
* http://daltoniam.com