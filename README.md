# Jazz
Simple and clean animation handling in Swift.


## Example

```swift
//Create a view in a view controller
let view = UIView(frame: CGRectMake(65, 65, 100, 100))
view.backgroundColor = UIColor.redColor()
self.view.addSubview(view)

//play those animations!
Jazz(0.25, delay: 1.0, animation: {
    view.frame = CGRectMake(165, 165, 100, 100)
}).play(0.25, delay: 0,animation: {
    view.frame = CGRectMake(115, 115, 200, 200)
}).play(0.25, delay: 0,animation: {
    view.frame = CGRectMake(65, 65, 100, 100)
}).done({
    println("just proving things can be done inbetween animations...")
}).play(0.25, delay: 0,animation: {
    view.frame = CGRectMake(85, 85, 100, 100)
}).done({
    println("or after they finish")
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