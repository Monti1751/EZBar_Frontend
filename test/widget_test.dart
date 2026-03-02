import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:log_in/main.dart';
import 'package:log_in/pantallas/pantalla_principal.dart';
import 'package:log_in/pantallas/carta_page.dart' as carta;
import 'package:log_in/widgets/top_bar.dart';
import 'package:log_in/widgets/add_zone_button.dart';
import 'package:log_in/widgets/add_zone_field.dart';
import 'package:log_in/widgets/zona_widget.dart';
import 'package:log_in/models/zona.dart';
import 'package:log_in/models/plato.dart';
import 'package:log_in/l10n/app_localizations.dart';
import 'package:log_in/services/localization_service.dart';
import 'package:log_in/widgets/top_bar.dart' as tb;
import 'package:log_in/providers/visual_settings_provider.dart';

void main() {
  setUpAll(() async {
    // Ensure localization files are loaded for widgets that rely on AppLocalizations
    TestWidgetsFlutterBinding.ensureInitialized();
    await LocalizationService().init();
  });

  testWidgets('LoginPage shows username, password and login button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.byIcon(Icons.person_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('LoginPage shows validation errors for invalid input', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    final usernameField = find.byIcon(Icons.person_outlined);
    final passwordField = find.byIcon(Icons.lock_outline);
    final loginButton = find.byType(ElevatedButton);

    await tester.enterText(find.byType(TextFormField).first, 'ab'); // invalid username
    await tester.enterText(find.byType(TextFormField).last, '123'); // invalid password

    await tester.tap(loginButton);
    await tester.pump();

    // Validators use localized strings (es.json). Assert those messages exist.
    expect(find.text('Usuario inválido (mín. 3 caracteres, solo letras, números y _)'), findsOneWidget);
    expect(find.text('La contraseña debe tener al menos 8 caracteres'), findsOneWidget);
  });

  testWidgets('LoginPage shows "Conectando..." SnackBar when form is valid', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.enterText(find.byType(TextFormField).first, 'user123');
    await tester.enterText(find.byType(TextFormField).last, 'password1');

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Conectando...'), findsOneWidget);
  });

  testWidgets('TopBar opens the drawer when menu icon is tapped', (WidgetTester tester) async {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        key: scaffoldKey,
        drawer: const Drawer(),
        body: ChangeNotifierProvider(
          create: (_) => VisualSettingsProvider(),
          child: Builder(builder: (context) {
            final settings = Provider.of<VisualSettingsProvider>(context);
            return TopBar(scaffoldKey: scaffoldKey, backgroundColor: Colors.green, settings: settings);
          }),
        ),
      ),
    ));

    expect(scaffoldKey.currentState?.isDrawerOpen, isFalse);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(scaffoldKey.currentState?.isDrawerOpen, isTrue);
  });

  test('loginInputDecoration returns correct hint and icon', () {
    final deco = carta.loginInputDecoration('Mi hint', Icons.search);
    expect(deco.hintText, 'Mi hint');
    expect((deco.prefixIcon as Icon).icon, Icons.search);
  });

  test('Seccion model default values', () {
    final s = carta.Seccion(nombre: 'Entrantes');
    expect(s.nombre, 'Entrantes');
    expect(s.isOpen, isFalse);
    expect(s.platos, isA<List<Plato>>());
  });

  testWidgets('PlatoEditorPage shows error icon for invalid imagenBlob', (WidgetTester tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => VisualSettingsProvider())],
      child: MaterialApp(
        home: PlatoEditorPage(plato: Plato(id: 1, nombre: 'X', precio: 0.0, imagenBlob: 'not_base64')),
      ),
    ));

    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.error), findsOneWidget);
  });

  testWidgets('AddZoneButton triggers onTap when tapped', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => VisualSettingsProvider(),
        child: Builder(builder: (context) {
          final settings = Provider.of<VisualSettingsProvider>(context);
          return AddZoneButton(
            onTap: () => tapped = true,
            backgroundColor: Colors.green,
            settings: settings,
          );
        }),
      ),
    ));

    await tester.tap(find.byType(AddZoneButton));
    await tester.pump();

    expect(tapped, isTrue);
  });


}
