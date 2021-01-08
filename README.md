# Aprendiendo el nuevo sistema de navegación y enrutamiento de Flutter

> Artículo original: [Learning Flutter’s new navigation and routing system](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade)

Este artículo explica cómo funciona la nueva API de `Navigator` y `Router` en Flutter. Si sigues los [documentos de diseño](https://docs.google.com/document/d/139AXLIeY_PTPW1ETpSlJRiCZIJWERN_UTuQM9XwrBCk/edit?usp=sharing) de Flutter, puede que hayas visto estas nuevas funciones denominadas **Navigator 2.0** y **Router**. Exploraremos cómo estas API permiten un control más preciso de las pantallas de tu aplicación y cómo puedes utilizarlas para parsear las rutas.

Estas nuevas APIs no son *breaking changes*, simplemente añaden una nueva [API declarativa](https://flutter.dev/docs/get-started/flutter-for/declarative). Antes de Navigator 2.0, [era difícil *pushear* o *poppear* múltiples páginas](https://github.com/flutter/flutter/issues/12146), o eliminar una página debajo de la actual. Sin embargo, si estás contento con el funcionamiento actual de `Navigator`, puedes seguir usándolo de la misma manera (imperativa).

El `Router` proporciona la capacidad de manejar las rutas desde la plataforma subyacente y mostrar las páginas apropiadas. En este artículo, el `Router` está configurado para parsear la URL del navegador para mostrar la página apropiada.

Este artículo te ayuda a elegir qué patrón de `Navigator` funciona mejor para tu aplicación, y explica cómo usar Navigator 2.0 para parsear los URLs del navegador y tomar el control total sobre el stack de las páginas que están activas. El ejercicio de este artículo muestra cómo construir una aplicación que maneja rutas entrantes de la plataforma y administra las páginas de su aplicación. El siguiente GIF muestra la aplicación de ejemplo en acción:

[Demo](https://miro.medium.com/max/2400/1*PYHrYurwAGyQC8vsnAaWiA.gif)
## Navigator 1.0

Si estás usando Flutter, probablemente estás usando el `Navigator` y estás familiarizado con los siguientes conceptos:

`Navigator` - un widget que gestiona un stack de objetos de tipo `Route`.

`Route` - un objeto gestionado por un `Navigator` que representa una pantalla, típicamente implementado por clases como `MaterialPageRoute`.

Antes de Navigator 2.0, las rutas eran *pusheadas* y *poppedas* en el stack del `Navigator` con rutas nombradas o anónimas. Las siguientes secciones son un breve resumen de estos dos enfoques.

### Rutas anónimas

La mayoría de las aplicaciones para móviles muestran las pantallas una encima de la otra, como un stack. En Flutter, esto es fácil de lograr usando el `Navigator`.

`MaterialApp` y `CupertinoApp` ya utilizan un `Navigator` por debajo. Puede acceder al navegador utilizando `Navigator.of()` o mostrar una nueva pantalla utilizando `Navigator.push()`, y volver a la pantalla anterior con `Navigator.pop()`:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(Nav2App());
}

class Nav2App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text('View Details'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return DetailScreen();
              }),
            );
          },
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text('Pop!'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
```

Cuando se llama a `push()`, el widget `DetailScreen` se coloca encima del widget `HomeScreen` de esta manera:

![alt](https://miro.medium.com/max/412/1*v77nG0BRIWrOghj8fCq_EA.png)

La pantalla anterior (`HomeScreen`) sigue siendo parte del árbol de widgets, por lo que cualquier objeto `State` asociado a él permanece activo mientras `DetailScreen` es visible.

### Rutas nombradas

Flutter también soporta rutas con nombre, que se definen en el parámetro `routes` en `MaterialApp` o `CupertinoApp`:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(Nav2App());
}

class Nav2App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => HomeScreen(),
        '/details': (context) => DetailScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text('View Details'),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/details',
            );
          },
        ),
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          child: Text('Pop!'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
```

Estas rutas deben ser predefinidas. Aunque se pueden pasar argumentos a una ruta con nombre, no se pueden parsear los argumentos de la propia ruta. Por ejemplo, si la aplicación se ejecuta en la web, no puedes parsear el ID de una ruta como `/details/:id`.

### Rutas con nombre avanzadas con onGenerateRoute

Una forma más flexible de manejar las rutas con nombre es usando `onGenerateRoute`. Esta API te da la capacidad de manejar todas las rutas:

```dart
onGenerateRoute: (settings) {
  // Handle '/'
  if (settings.name == '/') {
    return MaterialPageRoute(builder: (context) => HomeScreen());
  }
  
  // Handle '/details/:id'
  var uri = Uri.parse(settings.name);
  if (uri.pathSegments.length == 2 &&
      uri.pathSegments.first == 'details') {
    var id = uri.pathSegments[1];
    return MaterialPageRoute(builder: (context) => DetailScreen(id: id));
  }
  
  return MaterialPageRoute(builder: (context) => UnknownScreen());
},
```

Aquí, la configuración es una instancia de `RouteSetings`. Los campos `name` y `arguments` son los valores que se proporcionaron cuando se llamó `Navigator.pushNamed`, o lo que `initialRute` establece.

## Navigator 2.0

La API de Navigator 2.0 añade nuevas clases al famework para hacer que las pantallas de la aplicación sean una función del estado de la aplicación y para proporcionar la capacidad de parsear las rutas desde la plataforma subyacente (como las URL de la web). Aquí hay una visión general de las novedades:

- `Page` - un objeto inmutable usado para establecer el stack del `Navigator`.

- `Router` - configura la lista de pages a ser mostradas por el `Navigator`. Normalmente esta lista de páginas cambia según la plataforma subyacente, o según el estado de la aplicación.

- `RouteInformationParser`, que toma el `RouteInformation` de `RouteInformationProvider` y lo parsea en un tipo de datos definido por el usuario.

- `RouterDelegate` - define el comportamiento específico de la aplicación de cómo `Router` aprende sobre los cambios en el estado de la aplicación y cómo responde a ellos. Su trabajo es escuchar al `RouteInformationParser` y el estado de las aplicaciones y construir el `Navigator` con la lista actual de `Page`.

- `BackButtonDispatcher` - informa de las pulsaciones del botón de retorno al `Router`.

El siguiente diagrama muestra cómo interactua `RouterDelegate`, `Router`, `RouteInformationParser`, y el estado de la aplicación:

Aquí hay un ejemplo de cómo estas piezas interactúan:

1. Cuando la plataforma emite una nueva ruta (por ejemplo, "`books/2`") , el `RouteInformationParser` lo convierte en un tipo de datos abstractos `T` que define en su aplicación (por ejemplo, una clase llamada `BooksRoutePath`).

2. El método `setNewRoutePath` de `RouterDelegate` se llama con este tipo de datos, y debe actualizar el estado de la aplicación para reflejar el cambio (por ejemplo, configurando el `selectedBookId`) y llamar a `notifyListeners`.

3. Cuando se llama a `notifyListeners`, le dice a `Router` que reconstruya el `RouterDelegate` (usando su método `build()`)

4. `RouterDelegate.build()` devuelve un nuevo `Navigator`, cuyas páginas reflejan ahora el cambio de estado de la aplicación (por ejemplo, el `selectedBookId`).

## Ejercicio Navigator 2.0

Esta sección te lleva a través de un ejercicio que utiliza la API Navigator 2.0. Terminaremos con una aplicación que puede estar sincronizada con la barra de URL, y manejar las pulsaciones del botón de regreso desde la aplicación y el navegador, como se muestra en el siguiente GIF:

Para continuar, cambia a master channel, crea un nuevo proyecto Fluter con soporte web, y reemplaza el contenido de `lib/main.dart` con lo siguiente:

```dart
import 'package:flutter/material.dart';

void main() {
    runApp(BooksApp());
}

class Book {
    final String title;
    final String author;

    Book(this.title, this.author);
}

class BooksApp extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
    void initState() {
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Books App',
        home: Navigator(
            pages: [
                MaterialPage(
                    key: ValueKey('BooksListPage'),
                    child: Scaffold(),
                )
            ],
            onPopPage: (route, result) => route.didPop(result),
        ),
    );
    }
}
```

## Pages

El `Navigator` tiene un nuevo argumento pages en su constructor. Si la lista de objetos `Page` cambia, `Navigator` actualiza el stack de las rutas para que coincidan. Para ver cómo funciona esto, vamos a construir una aplicación que muestra una lista de libros.

En `_BooksAppState`, guarda dos piezas de estado: una lista de libros y el libro seleccionado:

```dart
class _BooksAppState extends State<BooksApp> {
    // New:
    Book _selectedBook;
    bool show404 = false;
    List<Book> books = [
        Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
        Book('Foundation', 'Isaac Asimov'),
        Book('Fahrenheit 451', 'Ray Bradbury'),
    ];

    // ...
```

Luego en `_BooksAppState`, devuelva un `Navigator` con una lista de objetos `Page`:

```dart
@override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Books App',
            home: Navigator(
            pages: [
                MaterialPage(
                    key: ValueKey('BooksListPage'),
                    child: BooksListScreen(
                        books: books,
                        onTapped: _handleBookTapped,
                    ),
                ),
            ],
            ),
        );
    }

void _handleBookTapped(Book book) {
    setState(() {
        _selectedBook = book;
    });
}

// ...
class BooksListScreen extends StatelessWidget {
    final List<Book> books;
    final ValueChanged<Book> onTapped;

    BooksListScreen({
        @required this.books,
        @required this.onTapped,
    });

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(),
            body: ListView(
                children: [
                for (var book in books)
                    ListTile(
                        title: Text(book.title),
                        subtitle: Text(book.author),
                        onTap: () => onTapped(book),
                    )
                ],
            ),
        );
    }
}
```

Como esta aplicación tiene dos pantallas, una lista de libros y una pantalla que muestra los detalles, añada una segunda página (`details`) si se selecciona un libro (usando `collection if`):

```dart
pages: [
    MaterialPage(
        key: ValueKey('BooksListPage'),
        child: BooksListScreen(
            books: books,
            onTapped: _handleBookTapped,
        ),
    ),
    // New:
    if (show404)
        MaterialPage(key: ValueKey('UnknownPage'), child: UnknownScreen())
    else if (_selectedBook != null)
        MaterialPage(
            key: ValueKey(_selectedBook),
            child: BookDetailsScreen(book: _selectedBook)
        )
],
```

Tenga en cuenta que la key de la página está definido por el valor del objeto `Book`. Esto le dice al `Navigator` que este objeto `MaterialPage` es diferente de otro cuando el objeto `Book` es diferente. Sin un `key` único, el framework no puede determinar cuándo mostrar una animación de transición entre diferentes `Page`.

Nota: Si lo prefiere, también puede extender `Page` para personalizar el comportamiento. Por ejemplo, esta página agrega una animación de transición personalizada:

```dart
class BookDetailsPage extends Page {
    final Book book;
  
    BookDetailsPage({
        this.book,
    }) : super(key: ValueKey(book));

    Route createRoute(BuildContext context) {
        return PageRouteBuilder(
            settings: this,
            pageBuilder: (context, animation, animation2) {
                final tween = Tween(begin: Offset(0.0, 1.0), end: Offset.zero);
                final curveTween = CurveTween(curve: Curves.easeInOut);
                return SlideTransition(
                    position: animation.drive(curveTween).drive(tween),
                    child: BookDetailsScreen(
                        key: ValueKey(book),
                        book: book,
                    ),
                );
            },
        );
    }
}
```

Finalmente, es un error proporcionar un argumento `page` sin proporcionar también un callback `onPopPage`. Esta función se llama siempre que se llama `Navigator.pop()`. Debe utilizarse para actualizar el estado (que determina la lista de páginas), y debe llamar a `didPop` en la ruta para determinar si el pop tuvo éxito:

```dart
onPopPage: (route, result) {
    if (!route.didPop(result)) {
        return false;
    }

    // Update the list of pages by setting _selectedBook to null
    setState(() {
        _selectedBook = null;
    });

    return true;
},
```

Es importante comprobar si `didPop` falla antes de actualizar el estado de la aplicación.

Usando `setState` notifica al framework que llame al método `build()`, que devuelve una lista con una sola página cuando `_selectedbook` es nulo.

Aquí está el ejemplo completo:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(BooksApp());
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  Book _selectedBook;

  List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Books App',
      home: Navigator(
        pages: [
          MaterialPage(
            key: ValueKey('BooksListPage'),
            child: BooksListScreen(
              books: books,
              onTapped: _handleBookTapped,
            ),
          ),
          if (_selectedBook != null) BookDetailsPage(book: _selectedBook)
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          // Update the list of pages by setting _selectedBook to null
          setState(() {
            _selectedBook = null;
          });

          return true;
        },
      ),
    );
  }

  void _handleBookTapped(Book book) {
    setState(() {
      _selectedBook = book;
    });
  }
}

class BookDetailsPage extends Page {
  final Book book;

  BookDetailsPage({
    this.book,
  }) : super(key: ValueKey(book));

  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return BookDetailsScreen(book: book);
      },
    );
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book> onTapped;

  BooksListScreen({
    @required this.books,
    @required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () => onTapped(book),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({
    @required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book != null) ...[
              Text(book.title, style: Theme.of(context).textTheme.headline6),
              Text(book.author, style: Theme.of(context).textTheme.subtitle1),
            ],
          ],
        ),
      ),
    );
  }
}
```

Tal como está, esta aplicación sólo nos permite definir el stack de las páginas de forma declarativa. No somos capaces de manejar el botón de regreso de la plataforma, y la URL del navegador no cambia a medida que navegamos.

## Router

Hasta ahora, la aplicación puede mostrar diferentes páginas, pero no puede manejar las rutas de la plataforma subyacente, por ejemplo si el usuario actualiza la URL en el navegador.

Esta sección muestra cómo implementar el `RouteInformationParser`, `RouterDelegate`, y actualizar el estado de la aplicación. Una vez configurada, la aplicación se mantiene sincronizada con la URL del navegador.

### Tipos de datos

El `RouteInformationParser` parsea la información de la ruta en un tipo de datos definido por el usuario, así que definiremos eso primero:

```dart
class BookRoutePath {
  final int id;
  final bool isUnknown;

  BookRoutePath.home()
      : id = null,
        isUnknown = false;

  BookRoutePath.details(this.id) : isUnknown = false;

  BookRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == null;

  bool get isDetailsPage => id != null;
}
```

En esta aplicación, todas las rutas pueden ser representadas usando una sola clase. En su lugar, se puede optar por utilizar diferentes clases que implementen una superclase, o gestionar la información de la ruta de otra manera.

### RouterDelegate

A continuación, agregue una clase que extienda `RouterDelegate`:

```dart

class BookRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  @override
  Widget build(BuildContext context) {
    // TODO
    throw UnimplementedError();
  }

  @override
  // TODO
  GlobalKey<NavigatorState> get navigatorKey => throw UnimplementedError();

  @override
  Future<void> setNewRoutePath(BookRoutePath configuration) {
    // TODO
    throw UnimplementedError();
  }
}
```

El tipo genérico definido en `RouterDelegate` es `BookRoutePath`, que contiene todos los estados necesarios para decidir qué páginas mostrar.

Necesitaremos mover algo de lógica de `_BooksAppState` a `BookRouterDelegate`, y crear un `GlobalKey`. En este ejemplo, el estado de la aplicación se almacena directamente en el `RouterDelegate`, pero también podría separarse en otra clase.

```dart
class BookRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;

  Book _selectedBook;
  bool show404 = false;

  List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();
  // ...
```

Para mostrar la ruta correcta en la URL, necesitamos devolver un `BookRoutePath` basado en el estado actual de la aplicación:

```dart
BookRoutePath get currentConfiguration {
    if (show404) {
        return BookRoutePath.unknown();
    }

    return _selectedBook == null
        ? BookRoutePath.home()
        : BookRoutePath.details(books.indexOf(_selectedBook));
}
```

A continuación, el método `build()` en un `RouterDelegate` necesita devolver un `Navigator`:

```dart
@override
Widget build(BuildContext context) {
  return Navigator(
    key: navigatorKey,
    pages: [
      MaterialPage(
        key: ValueKey('BooksListPage'),
        child: BooksListScreen(
          books: books,
          onTapped: _handleBookTapped,
        ),
      ),
      if (show404)
        MaterialPage(key: ValueKey('UnknownPage'), child: UnknownScreen())
      else if (_selectedBook != null)
        BookDetailsPage(book: _selectedBook)
    ],
    onPopPage: (route, result) {
      if (!route.didPop(result)) {
        return false;
      }

      // Update the list of pages by setting _selectedBook to null
      _selectedBook = null;
      show404 = false;
      notifyListeners();

      return true;
    },
  );
}
```

El callback `onPopPage` ahora utiliza `notifyListeners` en lugar de `setState`, ya que esta clase es ahora una `ChageNotifier`, no un widget. Cuando el `RouterDelegate` notifica a sus listeners, se le notifica al widget `Router` que el `RuterDelegate` del `currentConfiguration` ha cambiado y que su método `build()` necesita ser llamado nuevamente para construir un nuevo `Navigator`.

El método `_handleBookTapped` también necesita usar `notifyListers` en lugar de `setState`:

```dart
void _handleBookTapped(Book book) {
    _selectedBook = book;
    notifyListeners();
}
```

Cuando una nueva ruta ha sido *pusheada* en la aplicación, `Router` llama a `setNewRoutePath`, lo que le da a nuestra aplicación la oportunidad para actualizar el estado de la aplicación basado en los cambios de la ruta:

```dart
@override
Future<void> setNewRoutePath(BookRoutePath path) async {
    if (path.isUnknown) {
        _selectedBook = null;
        show404 = true;
        return;
    }

    if (path.isDetailsPage) {
        if (path.id < 0 || path.id > books.length - 1) {
        show404 = true;
        return;
        }

        _selectedBook = books[path.id];
    } else {
        _selectedBook = null;
    }

    show404 = false;
}
```

### RouteInformationParser

El `RouteInformationParser` proporciona un hook para parsear las rutas de entrada (`RouteInformation`) y convertirlas en un tipo definido por el usuario (`BookRoutePath`). Usa la clase `Uri` para encargarte del parseo:

```dart
class BookRouteInformationParser extends RouteInformationParser<BookRoutePath> {
  @override
  Future<BookRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);
    // Handle '/'
    if (uri.pathSegments.length == 0) {
      return BookRoutePath.home();
    }

    // Handle '/book/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != 'book') return BookRoutePath.unknown();
      var remaining = uri.pathSegments[1];
      var id = int.tryParse(remaining);
      if (id == null) return BookRoutePath.unknown();
      return BookRoutePath.details(id);
    }

    // Handle unknown routes
    return BookRoutePath.unknown();
  }

  @override
  RouteInformation restoreRouteInformation(BookRoutePath path) {
    if (path.isUnknown) {
      return RouteInformation(location: '/404');
    }
    if (path.isHomePage) {
      return RouteInformation(location: '/');
    }
    if (path.isDetailsPage) {
      return RouteInformation(location: '/book/${path.id}');
    }
    return null;
  }
}
```

Esta implementación es específica de esta aplicación, no una solución de parseo general de rutas. Más sobre eso más adelante.

Para usar estas nuevas clases, usamos el nuevo constructor `MaterialApp.router` y pasamos nuestras implementaciones personalizadas:

```dart
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
```

Aquí está el ejemplo completo:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(BooksApp());
}

class Book {
  final String title;
  final String author;

  Book(this.title, this.author);
}

class BooksApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BooksAppState();
}

class _BooksAppState extends State<BooksApp> {
  BookRouterDelegate _routerDelegate = BookRouterDelegate();
  BookRouteInformationParser _routeInformationParser =
      BookRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Books App',
      routerDelegate: _routerDelegate,
      routeInformationParser: _routeInformationParser,
    );
  }
}

class BookRouteInformationParser extends RouteInformationParser<BookRoutePath> {
  @override
  Future<BookRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);
    // Handle '/'
    if (uri.pathSegments.length == 0) {
      return BookRoutePath.home();
    }

    // Handle '/book/:id'
    if (uri.pathSegments.length == 2) {
      if (uri.pathSegments[0] != 'book') return BookRoutePath.unknown();
      var remaining = uri.pathSegments[1];
      var id = int.tryParse(remaining);
      if (id == null) return BookRoutePath.unknown();
      return BookRoutePath.details(id);
    }

    // Handle unknown routes
    return BookRoutePath.unknown();
  }

  @override
  RouteInformation restoreRouteInformation(BookRoutePath path) {
    if (path.isUnknown) {
      return RouteInformation(location: '/404');
    }
    if (path.isHomePage) {
      return RouteInformation(location: '/');
    }
    if (path.isDetailsPage) {
      return RouteInformation(location: '/book/${path.id}');
    }
    return null;
  }
}

class BookRouterDelegate extends RouterDelegate<BookRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;

  Book _selectedBook;
  bool show404 = false;

  List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  BookRoutePath get currentConfiguration {
    if (show404) {
      return BookRoutePath.unknown();
    }
    return _selectedBook == null
        ? BookRoutePath.home()
        : BookRoutePath.details(books.indexOf(_selectedBook));
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey('BooksListPage'),
          child: BooksListScreen(
            books: books,
            onTapped: _handleBookTapped,
          ),
        ),
        if (show404)
          MaterialPage(key: ValueKey('UnknownPage'), child: UnknownScreen())
        else if (_selectedBook != null)
          BookDetailsPage(book: _selectedBook)
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        // Update the list of pages by setting _selectedBook to null
        _selectedBook = null;
        show404 = false;
        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(BookRoutePath path) async {
    if (path.isUnknown) {
      _selectedBook = null;
      show404 = true;
      return;
    }

    if (path.isDetailsPage) {
      if (path.id < 0 || path.id > books.length - 1) {
        show404 = true;
        return;
      }

      _selectedBook = books[path.id];
    } else {
      _selectedBook = null;
    }

    show404 = false;
  }

  void _handleBookTapped(Book book) {
    _selectedBook = book;
    notifyListeners();
  }
}

class BookDetailsPage extends Page {
  final Book book;

  BookDetailsPage({
    this.book,
  }) : super(key: ValueKey(book));

  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return BookDetailsScreen(book: book);
      },
    );
  }
}

class BookRoutePath {
  final int id;
  final bool isUnknown;

  BookRoutePath.home()
      : id = null,
        isUnknown = false;

  BookRoutePath.details(this.id) : isUnknown = false;

  BookRoutePath.unknown()
      : id = null,
        isUnknown = true;

  bool get isHomePage => id == null;

  bool get isDetailsPage => id != null;
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  final ValueChanged<Book> onTapped;

  BooksListScreen({
    @required this.books,
    @required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        children: [
          for (var book in books)
            ListTile(
              title: Text(book.title),
              subtitle: Text(book.author),
              onTap: () => onTapped(book),
            )
        ],
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({
    @required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book != null) ...[
              Text(book.title, style: Theme.of(context).textTheme.headline6),
              Text(book.author, style: Theme.of(context).textTheme.subtitle1),
            ],
          ],
        ),
      ),
    );
  }
}

class UnknownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('404!'),
      ),
    );
  }
}
```

Ejecutando este ejemplo en Chrome ahora muestra las rutas a medida que se navega por ellas, y navega a la página correcta cuando la URL se edita manualmente.

### TransitionDelegate

Puede proporcionar una implementación personalizada de `TransitionDelegate` que personalice la forma en que las rutas aparecen (o desaparecen) de la pantalla cuando la lista de páginas cambia. Si necesitas personalizar esto, sigue leyendo, pero si estás contento con el comportamiento predeterminado puedes saltarte esta sección.

Proporcione un `TransitionDelegate` a un `Navigator` que defina el comportamiento deseado:

```dart
// New:
TransitionDelegate transitionDelegate = NoAnimationTransitionDelegate();

    child: Navigator(
        key: navigatorKey,
        // New:
        transitionDelegate: transitionDelegate,
```

Por ejemplo, la siguiente implementación desactiva todas las animaciones de transición:

```dart
class NoAnimationTransitionDelegate extends TransitionDelegate<void> {
  @override
  Iterable<RouteTransitionRecord> resolve({
    List<RouteTransitionRecord> newPageRouteHistory,
    Map<RouteTransitionRecord, RouteTransitionRecord>
        locationToExitingPageRoute,
    Map<RouteTransitionRecord, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    final results = <RouteTransitionRecord>[];

    for (final pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);
    }

    for (final exitingPageRoute in locationToExitingPageRoute.values) {
      if (exitingPageRoute.isWaitingForExitingDecision) {
        exitingPageRoute.markForRemove();
        final pagelessRoutes = pageRouteToPagelessRoutes[exitingPageRoute];
        if (pagelessRoutes != null) {
          for (final pagelessRoute in pagelessRoutes) {
            pagelessRoute.markForRemove();
          }
        }
      }

      results.add(exitingPageRoute);
    }
    return results;
  }
}
```

Esta implementación personalizada hace *override* de `resolve()`, que se encarga de marcar las distintas rutas como *pushed*, *popped*, *added*, *completed*, o *removed*:

- `markForPush` - muestra la ruta con una transición animada

- `markForAdd` - muestra la ruta sin una transición animada

- `markForPop` - elimina la ruta con una transición animada y la completa con un resultado. "*Completing*" en este contexto significa que el objeto resultante se pasa al callback `onPopPage` en `AppRouterDelegate`.

- `markForComplete` - elimina la ruta sin una transición y la completa con un resultado

- `markForRemove` - elimina la ruta sin transición animada y sin completar.

Esta clase sólo afecta a la API declarativa, por lo que el botón *back* sigue mostrando una animación de transición.

**Cómo funciona este ejemplo**: Este ejemplo mira tanto las nuevas rutas como las rutas que salen de la pantalla. Pasa por todos los objetos de `newPageRouteHistory` y los marca como added sin una animación de transición usando `markForAdd`. Luego, hace un bucle a través de los valores del mapa `locationToExitingPageRoute`. Si encuentra una ruta marcada como `isWaitingForExitingDecision`, entonces llama a `markForRemove` para indicar que la ruta debe ser removed sin una transición y sin completar.

Aquí está la muestra completa(Gist).

### Rutas anidadas

Esta demostración más grande muestra cómo agregar un `Router` dentro de otro `Router`. Muchas aplicaciones requieren rutas para los destinos en un `BotomAppBar`, y rutas para un stack de vistas por encima de él, lo que requiere dos `Navigator`. Para ello, la aplicación utiliza un objeto de estado de aplicación para almacenar el estado de navegación específico de la aplicación (el menu index y el objeto `Book` seleccionados). Este ejemplo también muestra cómo configurar qué `Router` maneje el botón de retorno.

Ejemplo de enrutador anidado(Gist)

## ¿Qué es lo siguiente?

Este artículo exploró cómo utilizar estas API para una aplicación específica, pero también podría utilizarse para contruir un paquete de API de nivel superior. Esperamos que te unas a nosotros para explorar lo que una API de nivel superior construida sobre estas características puede hacer por los usuarios.