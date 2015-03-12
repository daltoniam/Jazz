# Jazz
Simple and clean animation handling in Swift.


## Example

See the examples directory for pretty example projects.

![](gif here)

```swift
//Create a view in a view controller

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