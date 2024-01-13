import 'dart:async';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:login/home.dart';
import 'package:provider/provider.dart';
import 'package:login/card.dart';

void main() {
  // Desactivar cinta de depuración en modo de lanzamiento
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = Tween<double>(begin: 0, end: 100).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: _animation.value / 100),
            const SizedBox(height: 20),
            ///////////Icono en barra de carga//////////////
            /* Icon(
              Icons.ads_click_sharp,
              size: 48,
            ), */
            const SizedBox(height: 20),
            Text('Cargando... ${_animation.value.toInt()}%'),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = SettingsPage();
        break;
      case 3:
        page = HomePage();
        break;
      case 4:
        page = ModelPage(carList: carList);
        break;

      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.home),
                    label: const Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.favorite),
                    label: const Text('Favorites'),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.settings),
                    label: const Text('Settings'),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.amp_stories_sharp),
                    label: const Text('Animator'),
                  ),
                  NavigationRailDestination(
                    icon: const Icon(Icons.car_rental_sharp),
                    label: const Text('model'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: const Text('Like'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headline6!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: const Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: const Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Página de Ajustes'),
          const SizedBox(height: 100),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyHomePage()));
                },
                icon: const Icon(Icons.app_settings_alt_sharp),
                label: const Text('Ajustes'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {
                  // Lógica del botón
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyHomePage()));
                },
                icon: const Icon(Icons.app_shortcut_sharp),
                label: const Text('Personalizacion'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

///////////////
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/place13.jpg'),
                    fit: BoxFit.cover)),
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.3),
              ])),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      height: 250,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: <Widget>[
                          makeItem(image: 'assets/images/corel.png'),
                          makeItem(image: 'assets/images/pho.jpg'),
                          makeItem(image: 'assets/images/pr.png'),
                          makeItem(image: 'assets/images/ai.png'),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget makeItem({image}) {
    return AspectRatio(
      aspectRatio: 1.7 / 2,
      child: Container(
        margin: EdgeInsets.only(right: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white70,
        ),
        child: Column(
          /* crossAxisAlignment: CrossAxisAlignment.start, */
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    image: DecorationImage(
                        image: AssetImage(image), fit: BoxFit.cover),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.grey.shade400),
                  child: Text(
                    'Diseño',
                    style: TextStyle(color: Colors.black54),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Texto de Descripcion',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.star_border,
                color: Colors.blue,
              ),
            )
          ],
        ),
      ),
    );
  }
}

/////////////model/////////////////
///
class ModelPage extends StatelessWidget {
  final CarList carList;

  ModelPage({required this.carList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modelos de Automóviles'),
      ),
      body: ListView.builder(
        itemCount: carList.cars.length,
        itemBuilder: (context, index) {
          final car = carList.cars[index];
          return ListTile(
            title: Text(car.carName),
            subtitle: Text(car.companyName),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarDetailsPage(car: car),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

double iconSize = 30;

CarList carList = CarList(cars: [
  Car(
    companyName: "Chevrolet",
    carName: "Corvette",
    price: 2100,
    imgList: [
      "corvette_front.png",
      "corvette_back.png",
      "interior1.png",
      "interior2.png",
      "corvette_front2.png",
    ],
    offerDetails: [
      {Icon(Icons.bluetooth, size: iconSize): "Automatic"},
      {Icon(Icons.airline_seat_individual_suite, size: iconSize): "4 seats"},
      {Icon(Icons.pin_drop, size: iconSize): "6.4L"},
      {Icon(Icons.shutter_speed, size: iconSize): "5HP"},
      {Icon(Icons.invert_colors, size: iconSize): "Variant Colours"},
    ],
    specifications: [
      //Icon(Icons.av_timer, size: iconSize): {"Milegp(upto)": "14.2 kmpl"},
      //Icon(Icons.power, size: iconSize): {"Engine(upto)": "3996 cc"},
      //Icon(Icons.assignment_late, size: iconSize): {"BHP": "700"},
      //Icon(Icons.account_balance_wallet, size: iconSize): {"More Specs": "14.2 kmpl"},
      //Icon(Icons.cached, size: iconSize): {"More Specs": "14.2 kmpl"},
    ],
    features: [
      {Icon(Icons.bluetooth, size: iconSize): "Bluetooth"},
      {Icon(Icons.usb, size: iconSize): "USB Port"},
      {Icon(Icons.power_settings_new, size: iconSize): "Keyless"},
      {Icon(Icons.android, size: iconSize): "Android Auto"},
      {Icon(Icons.ac_unit, size: iconSize): "AC"},
    ],
  ),
  Car(
    companyName: "Lamborghini",
    carName: "Aventador",
    price: 3000,
    imgList: [
      "lambo_front.png",
      "interior_lambo.png",
      "lambo_back.png",
    ],
    offerDetails: [
      {Icon(Icons.bluetooth, size: iconSize): "Automatic"},
      {Icon(Icons.airline_seat_individual_suite, size: iconSize): "4 seats"},
      {Icon(Icons.pin_drop, size: iconSize): "6.4L"},
      {Icon(Icons.shutter_speed, size: iconSize): "5HP"},
      {Icon(Icons.invert_colors, size: iconSize): "Variant Colours"},
    ],
    specifications: [
      //{
      //  Icon(Icons.av_timer, size: iconSize): {"Milegp(upto)": "14.2 kmpl"}
      //},
      //{
      //  Icon(Icons.power, size: iconSize): {"Engine(upto)": "3996 cc"}
      //},
      //{
      //  Icon(Icons.assignment_late, size: iconSize): {"BHP": "700"}
      //},
      //{
      //  Icon(Icons.account_balance_wallet, size: iconSize): {
      //    "More Specs": "14.2 kmpl"
      //  }
      //},
      //{
      //  Icon(Icons.cached, size: iconSize): {"More Specs": "14.2 kmpl"}
      //},
    ],
    features: [
      {Icon(Icons.bluetooth, size: iconSize): "Bluetooth"},
      {Icon(Icons.usb, size: iconSize): "USB Port"},
      {Icon(Icons.power_settings_new, size: iconSize): "Keyless"},
      {Icon(Icons.android, size: iconSize): "Android Auto"},
      {Icon(Icons.ac_unit, size: iconSize): "AC"},
    ],
  ),
]);

class CarList {
  List<Car> cars;

  CarList({
    required this.cars,
  });
}

class Car {
  String companyName;
  String carName;
  int price;
  List<String> imgList;
  List<Map<Icon, String>> offerDetails;
  List<Map<Icon, String>> features;
  List<Map<Icon, Map<String, String>>> specifications;

  Car({
    required this.companyName,
    required this.carName,
    required this.price,
    required this.imgList,
    required this.offerDetails,
    required this.features,
    required this.specifications,
  });
}

class CarDetailsPage extends StatelessWidget {
  final Car car;

  CarDetailsPage({required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(car.carName),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Muestra información detallada del automóvil
            Text('Compañía: ${car.companyName}',
                style: TextStyle(fontSize: 18.0)),
            Text('Precio: \$${car.price}', style: TextStyle(fontSize: 18.0)),
            SizedBox(height: 16.0),

            // Agrega secciones para las imágenes, detalles de oferta, especificaciones y características
            Text('Imágenes del automóvil:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            buildImageSlider(car.imgList),

            SizedBox(height: 16.0),
            Text('Detalles de la oferta:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            buildDetailsList(car.offerDetails),

            SizedBox(height: 16.0),
            Text('Especificaciones:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            buildDetailsList(car.specifications.cast<Map<Icon, String>>()),

            SizedBox(height: 16.0),
            Text('Características:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            buildDetailsList(car.features),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares para construir widgets específicos

  Widget buildImageSlider(List<String> imgList) {
    // Implementa la lógica para construir un slider de imágenes
    // Puedes usar un Carousel, PageView, o cualquier otro widget según tus preferencias
    // Aquí un ejemplo simple con PageView:
    return Container(
      height: 200.0,
      child: PageView.builder(
        itemCount: imgList.length,
        itemBuilder: (context, index) {
          return Image.asset(
            imgList[index],
            width: 300.0,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  Widget buildDetailsList(List<Map<Icon, String>> details) {
    // Implementa la lógica para construir una lista de detalles
    // Puedes usar un ListView, Column, o cualquier otro widget según tus preferencias
    // Aquí un ejemplo simple con Column:
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.map((detail) {
        final icon = detail.keys.first;
        final value = detail.values.first;

        return Padding(
          padding: EdgeInsets.only(bottom: 4.0),
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: icon,
              ),
              Text(value),
            ],
          ),
        );
      }).toList(),
    );
  }
}
