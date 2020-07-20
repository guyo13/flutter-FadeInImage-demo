import 'dart:math';
import 'package:flutter/material.dart';

const List<String> images = [
  'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Eopsaltria_australis_-_Mogo_Campground.jpg/1200px-Eopsaltria_australis_-_Mogo_Campground.jpg',
  'https://www.chamonix.net/sites/default/files/golf-chamonix.jpg',
  'https://i.ytimg.com/vi/Ib_5LQmNVGk/maxresdefault.jpg',
];

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String placeholderImagePath = 'images/placeholder.png';
  final String defaultImagePath = 'images/default.jpg';

  Future<FadeInImage> _loadRandomImage() async {
    final String imagePath = images[Random().nextInt(images.length)];
    ImageProvider headerImage;

    try {
      headerImage = NetworkImage(imagePath);
    } catch (e) {
      print('Error loading Image!');
      print(e);
    }
    return FadeInImage(
      image: headerImage,
      placeholder: AssetImage(placeholderImagePath),
      height: 150.0,
      fit: BoxFit.fitWidth,
      imageErrorBuilder: (BuildContext context, Object obj, StackTrace e) {
        print('imageErrorBuilder - error occured');
        print(e);
        return Image.asset(
          defaultImagePath,
          fit: BoxFit.fitWidth,
          height: 150.0,
        );
      },
      placeholderErrorBuilder:
          (BuildContext context, Object obj, StackTrace e) {
        print('placeholderErrorBuilder - error occured');
        print(e);
        return SizedBox(
            height: 150.0,
            child: Container(
              color: Colors.red,
            ));
      },
      fadeInDuration: Duration(milliseconds: 300),
      fadeOutDuration: Duration(milliseconds: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(imageLoadFn: _loadRandomImage),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  final Function imageLoadFn;
  final Future<FadeInImage> imageFuture;

  HomePage({Key key, this.imageLoadFn}) : imageFuture = imageLoadFn(), super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FadeInImage>(
        future: imageFuture,
        builder: (BuildContext context, AsyncSnapshot<FadeInImage> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            default:
              if (snapshot.hasError)
                return new Text('Error: ${snapshot.error}');
              else {
                return SafeArea(
                  child: Scaffold(
                    appBar: PreferredSize(
                      preferredSize: Size.fromHeight(40.0),
                      child: AppBar(
                        title: const Text('FadeInImage Demo'),
                      ),
                    ),
                    body: _buildBody(context, snapshot.data),
                  ),
                );
              }
          }
        });
  }

  Widget _buildBody(BuildContext context, FadeInImage image) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: _buildHeader(context, image),
        ),
      ],
    );
  }
  Widget _buildHeader(BuildContext context, FadeInImage image) {
    return Stack(
      alignment: Alignment.bottomLeft,
      fit: StackFit.loose,
      children: [
        FractionallySizedBox(
          child: Container(
            color: const Color(0xff212121),
            child: image,
          ),
          widthFactor: 1.0,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          color: Color(0x40000000),
        ),
      ],
    );
  }
}

