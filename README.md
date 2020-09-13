# Paulonia Cache Image

Flutter package for download and store images in the cache. It supports in-memory and storage cache in Android, iOS and Web for network and Google Cloud Storage images.

![Gif](https://i.imgur.com/AsqxrUz.gif)

## Usage

To use this package add `paulonia_cache_image` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). 

You have to initialize the package in your `main()` function:

```dart
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await PCacheImage.init();
  runApp(MyApp());
}
```
In the `init()` function you can initialize the default values of the [Properties of ImageProvider](https://pub.dev/packages/paulonia_cache_image#properties). You can change a value in all Paulonia cache image widgets in your app.


Paulonia cache image extends `ImageProvider`, so you can use it with any widget that supports an `ImageProvider` only with the URL. By default, the image is cached in the platform storage:
```dart
Image(
  image: PCacheImage('https://i.imgur.com/jhRBVEp.jpg')
);
Image(
  image: PCacheImage(
    'gs://flutter-template-44674.appspot.com/images/user/0ooAw4dX5AeGhkH1JYkoWcdwvc72_big.jpg',
  )
);
```

### In-memory cache

With the default image cache in the platform storage there is a problem: when you make a `setState()` the package reads the storage and retrieve the image, this process causes the image to **flicker!**. With in-memory cache, this process is more quickly and there is no flicker. You can enable it as follows:


```dart
Image(
  image: PCacheImage('https://i.imgur.com/jhRBVEp.jpg', enableInMemory: true)
);
```
You can enable in-memory cache in all `PCacheImage` widgets in the `init()` function:
```dart
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await PCacheImage.init(enableInMemory: true);
  runApp(MyApp());
}
```
**Use only where your require**. The problem with this approach is the memory usage increase. We recommend use only with images in widgets that run `setState()`, to erase the flicker.

## CORS on web

On the web when you try to make a request and download an image, it can throw an error with the CORS. Depends on the image type there is a solution:

### Google Storage Images

You must to [enable CORS in your bucket](https://firebase.google.com/docs/storage/web/download-files#cors_configuration)

### Network Images

You can set a proxy in the `init()` function:

```dart
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await PCacheImage.init(proxy: "https://cors-anywhere.herokuapp.com/");
  runApp(MyApp());
}
```

The `proxy` property is only used with network image in the way: "https://cors-anywhere.herokuapp.com/http://image.jpg".

## Properties

`PCacheImage` has the follow properties:

Property | What does it do | Default
-------- | --------------- | --------
enableInMemory | Enable or disable the in-memory cache | false
enableCache | Enable or disable the cache | true
retryDuration | If the download fails, retry after this duration | 2s
maxRetryDuration | Max accumulated time of retries | 10s
imageScale | The image scale | 1.0

## Author

This packaged was made by [ChrisChV](https://github.com/ChrisChV) and is used in all Paulonia projects.


