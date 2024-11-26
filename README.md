MyAppListKit
===

Encapsulation of My Personal App List

```swift
import MyAppListKit
    
List {
    ForEach(MyAppList.apps(), id: \.appId) { app in
        Button(app.name, action: {
            MyAppList.openApp(appId: app.appId, appstoreId: app.appstoreId)
        })
    }
}
```


## License

Licensed under the MIT License.