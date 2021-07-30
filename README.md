# Swift Implementation of the LIFX Binary Protocol

This is the Swift implementation of the LIFX Binary Protocol, and supports serializing and deserializing all supported message types.

### Using This Library

The Messages class has simple tools for deserializing data received via the LAN.

```
let messages = Messages.read(data: data)
```

### Using with Xcode

Just open the swift folder with Xcode 11 or later and it will be handled as a SwiftPM project. The library also supports CocoaPods.
