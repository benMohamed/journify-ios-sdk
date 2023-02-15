
# Journify
[![License](https://img.shields.io/cocoapods/l/Analytics.svg?style=flat)](http://cocoapods.org/pods/Analytics)
[![SwiftPM Compatible](https://img.shields.io/badge/SwiftPM-Compatible-F05138.svg)](https://swift.org/package-manager/)


JournifySDK is a Swift library for integrating event tracking and analytics into your iOS application. It provides an easy-to-use interface for developers to add Segment-like functionality to their projects.



## Installation

Analytics is available through SPM

### Swift Package Manager (SPM)

To add analytics-ios via Swift Package Mangaer, it is possible to add it one of two ways:

#### Xcode
![Xcode Add SPM Package](https://user-images.githubusercontent.com/917994/119199146-69765200-ba3f-11eb-9173-93cfb5f3cabd.png)

<img width="1093" alt="Screenshot 2023-02-09 at 5 14 10 PM" src="https://user-images.githubusercontent.com/8136464/217872243-9bc4a114-1807-46c4-9d7b-acbc9d7ba686.png">

<img width="1100" alt="Screenshot 2023-02-09 at 5 14 37 PM" src="https://user-images.githubusercontent.com/8136464/217872395-52dfbff2-f71b-4c5b-b0d2-e880de581ad3.png">

Note: Journify recommends that you use Xcode to add your package.

## Usage/Examples

```Swift
 let configuration = Configuration(writeKey: "Your Key")
            .trackApplicationLifecycleEvents(true)
            .flushInterval(10)

Analytics.setup(with: configuration)

Analytics.shared().track(name: "New Event", properties: ["Name": "Custom"], externalId: ["testKey": "test"])
Analytics.shared().screen(title: "New Screen", properties: ["title": "Growth as a service", "url": "https://journify.io", "path": "/"])

```


## License

[MIT](https://choosealicense.com/licenses/mit/)

