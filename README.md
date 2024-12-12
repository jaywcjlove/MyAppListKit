MyAppListKit
===

Encapsulation of My Personal App List

## Installation

You can add MyAppListKit to an Xcode project by adding it as a package dependency.

1. From the File menu, select Add Packages…
2. Enter https://github.com/jaywcjlove/MyAppListKit in the Search or Enter Package URL search field
3. Link `MyAppListKit` to your application target

Or add the following to `Package.swift`:

```swift
.package(url: "https://github.com/jaywcjlove/MyAppListKit", branch: "main")
```

Or [add the package in Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Usage

```swift
import MyAppListKit
    
List {
    ForEach(MyAppList.apps(), id: \.appId) { app in
        Button(app.name, action: {
            app.openApp()
            // or
            MyAppList.openApp(appId: app.appId, appstoreId: app.appstoreId)
        })
    }
}

Button("More Apps by Me") {
    MyAppList.openURL(url: URL(string: MyAppList.appsByMe)!)
    // or
    MyAppList.openAppsByMe()
}

MyAppList.appDevHub           // -> AppData
MyAppList.appDevHub.storeURL  // -> URL: macappstore://apps.apple.com/app/id6476452351
MyAppList.appDevHub.openURL() // Open in browser
MyAppList.appDevHub.openApp() // Open the app or its store download page

// Returns the URL of the default app associated with the given bundle identifier.
MyAppList.appDevHub.appURL()
```

## License

Licensed under the MIT License.
