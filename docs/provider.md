# Provider para Flutter - Documentação Completa

> O `provider` é um wrapper around `InheritedWidget` para tornar mais fácil o uso e mais reutilizável o gerenciamento de estado em Flutter.

## 📦 O que é Provider?

O **Provider** é um pacote lightweight e versátil que integra-se diretamente com o framework reativo do Flutter. Ele simplifica o gerenciamento de estado ao:

- Desacoplar UI da lógica de negócios
- Permitir compartilhamento fácil de estado entre widgets
- Supportar atualizações contextuais para melhor performance
- Minimalizar código boilerplate
- Oferecer suporte nativo para **dependency injection**

[web:3][web:11]

### Por que usar Provider?

| Benefício | Descrição |
|-----------|-----------|
| Simplificado | Wrapper sobre `InheritedWidget` mais fácil de usar |
| Lazy-loading | Valores criados apenas quando solicitados |
| Boilerplate reduzido | Não precisa criar nova classe para cada tipo |
| Devtool friendly | Estado visível no Flutter DevTool |
| Escalável | O(N) para dispatch de notifications em `ChangeNotifier` |

[web:11]

---

## 🔧 Instalação

### Adicionar ao projeto

No arquivo `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.5+1
```

Ou execute:

```bash
flutter pub add provider
```

[web:3][web:11]

### Importar

```dart
import 'package:provider/provider.dart';
```

---

## 🎯 Conceitos Fundamentais

O Provider trabalha com 3 conceitos principais:

### 1. ChangeNotifier

 Classe incluída no Flutter SDK que fornece notificação de mudanças para listeners:

```dart
import 'package:flutter/foundation.dart';

class Counter with ChangeNotifier {
  int _count = 0;
  
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();
  }
  
  void decrement() {
    _count--;
    notifyListeners();
  }
}
```

**Pontos chave:**
- `notifyListeners()` é chamado quando o estado muda
- Parte de `flutter:foundation` (não depende de Flutter higher-level)
- Facilmente testável (unit testing sem widget testing)

[web:3][web:6]

### 2. ChangeNotifierProvider

 Widget que fornece uma instância de `ChangeNotifier` para seus descendentes:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'counter.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Counter(),
      child: MyApp(),
    ),
  );
}
```

**Características:**
- Cria instância apenas quando necessária (lazy-loading)
- Não rebuilda o `ChangeNotifier` sem necessidade
- Automaticamente chama `dispose()` quando não mais necessário

[web:3][web:6]

### 3. Consumer

 Widget para consumir e atualizar UI quando o estado muda:

```dart
Consumer<Counter>(
  builder: (context, counter, child) {
    return Text('Count: ${counter.count}');
  },
)
```

**Argumentos do builder:**
1. `context` - BuildContext padrão
2. `counter` - Instância do `ChangeNotifier`
3. `child` - Otimização para subtree que não muda

[web:3][web:6]

---

## 🚀 Uso Básico

### Expondo um valor novo

```dart
// ✅ CORRETO: Criar novo objeto dentro de create
Provider(
  create: (_) => MyModel(),
  child: ...,
)

// ❌ INCORRETO: Não usar .value para criar objetos
ChangeNotifierProvider.value(
  value: MyModel(),
  child: ...,
)
```

[web:11]

### Reusando objeto existente

```dart
// ✅ CORRETO: Usar .value para objeto existente
MyChangeNotifier variable;

ChangeNotifierProvider.value(
  value: variable,
  child: ...,
)
```

[web:11]

### Reading valores (extension methods)

```dart
class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      context.watch<String>(),  // Listen to changes
    );
  }
}

// Sem listen (para métodos que não precisam rebuild)
context.read<Foo>().value;

// Select para ouvir apenas parte do objeto
context.select((Person p) => p.name);
```

**Diferenças:**

| Método | Listen | Build Method | Rebuild |
|--------|--------|--------------|---------|
| `watch<T>()` | ✅ | ✅ | Yes |
| `read<T>()` | ❌ | ❌ | No |
| `select<T,R>()` | ✅ (parcial) | ✅ | Only when changed |

[web:11]

---

## 📊 Exemplo Completo: App de Counter

### 1. Modelo de Estado

```dart
import 'package:flutter/foundation.dart';

class CounterModel extends ChangeNotifier {
  int _count = 0;
  
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();
  }
  
  void decrement() {
    _count--;
    notifyListeners();
  }
  
  void reset() {
    _count = 0;
    notifyListeners();
  }
}
```

[web:3]

### 2. Configuração do Provider

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'counter_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CounterModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CounterScreen(),
    );
  }
}
```

[web:3]

### 3. Consumindo o Estado

```dart
class CounterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Counter App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Usando Consumer
            Consumer<CounterModel>(
              builder: (context, counter, child) {
                return Text(
                  'Count: ${counter.count}',
                  style: TextStyle(fontSize: 24),
                );
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.read<CounterModel>().increment(),
                  child: Text('Increment'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => context.read<CounterModel>().decrement(),
                  child: Text('Decrement'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => context.read<CounterModel>().reset(),
                  child: Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

[web:3]

---

## 🎨 Providers Avançados

### MultiProvider

Para gerenciar múltiplos estados:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (context) => Counter()),
    ChangeNotifierProvider(create: (context) => AnotherState()),
    Provider(create: (context) => SomeConfig()),
  ],
  child: MyApp(),
)
```

[web:3][web:11]

### Selector (Otimização de Performance)

Selecionar campos específicos para evitar rebuilds desnecessários:

```dart
Selector<CounterModel, int>(
  selector: (context, counter) => counter.count,
  builder: (context, count, child) {
    return Text('Count: $count');
  },
)
```

Ou usando `context.select`:

```dart
Widget build(BuildContext context) {
  final name = context.select((Person p) => p.name);
  return Text(name);
}
```

[web:3][web:11]

### Provider.of (alternativa)

```dart
// With listen (default)
Provider.of<CounterModel>(context);

// Without listen (para métodos)
Provider.of<CounterModel>(context, listen: false).reset();
```

Equivalente:
- `Provider.of<T>(context)` ≈ `context.watch<T>()`
- `Provider.of<T>(context, listen: false)` ≈ `context.read<T>()`

[web:3][web:6]

### StreamProvider

Para streams:

```dart
StreamProvider<List<Item>>(
  create: (context) => itemService.getItems(),
  initialData: [],
  child: MyApp(),
)
```

[web:11]

### FutureProvider

Para futures:

```dart
FutureProvider<String>(
  create: (context) => api.fetchData(),
  initialValue: 'Loading...',
  child: MyApp(),
)
```

[web:11]

### ProxyProvider

Combina múltiplos providers em um novo objeto:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => Counter()),
    ProxyProvider<Counter, Translations>(
      update: (_, counter, __) => Translations(counter.value),
    ),
  ],
  child: Foo(),
)

class Translations {
  const Translations(this._value);
  final int _value;
  String get title => 'You clicked $_value times';
}
```

[web:11]

---

## ✅ Best Practices

### 1. Posicionamento do Consumer

**❌ NÃO FAÇA** (Consumer muito alto = rebuild excessivo):

```dart
Consumer<CartModel>(
  builder: (context, cart, child) {
    return HumongousWidget(
      child: AnotherMonstrousWidget(
        child: Text('Total: ${cart.totalPrice}'),
      ),
    );
  },
)
```

**✅ FAÇA** (Consumer profundo = rebuild mínimo):

```dart
HumongousWidget(
  child: AnotherMonstrousWidget(
    child: Consumer<CartModel>(
      builder: (context, cart, child) {
        return Text('Total: ${cart.totalPrice}');
      },
    ),
  ),
)
```

[web:3][web:6]

### 2. Use Read vs Listen Inteligentemente

```dart
// ✅ Para chamadas de método (não precisa rebuild)
onPressed: () => context.read<CounterModel>().increment();

// ✅ Para mostrar dados (precisa rebuild)
Text(context.watch<CounterModel>().count.toString());
```

[web:3]

### 3. Organize o Código

```dart
// estrutura feature-first
src/
  features/
    counter/
      models/
        counter_model.dart
      providers/
        counter_provider.dart
      screens/
        counter_screen.dart
      widgets/
        counter_widget.dart
```

- Separe lógica de estado da UI
- Grup classes de estado relacionadas

[web:2][web:3]

### 4. Minimize Rebuilds

```dart
// Use Selector para campos específicos
Selector<User, String>(
  selector: (_, user) => user.name,
  builder: (_, name, child) => Text(name),
)

// Ou context.select
final name = context.select((User u) => u.name);
```

[web:3][web:11]

### 5. Dependent Injection com Interface

```dart
abstract class ProviderInterface with ChangeNotifier {
  // ...
}

class ProviderImplementation with ChangeNotifier implements ProviderInterface {
  // ...
}

ChangeNotifierProvider<ProviderInterface>(
  create: (_) => ProviderImplementation(),
  child: Foo(),
)
```

[web:11]

---

## ⚠️ Problemas Comuns e Soluções

### StackOverflowError com muitos providers

**Solução 1:** Mount providers gradualmente

```dart
MultiProvider(
  providers: [
    if (step1) ...[<lots of providers>],
    if (step2) ...[<some more providers>],
  ],
)
```

**Solução 2:** Omita `MultiProvider` para aumentar limite

[web:11]

### Exception em initState

**❌ INCORRETO:**

```dart
initState() {
  super.initState();
  print(context.watch<Foo>().value); // Exception!
}
```

**✅ CORRETO:**

```dart
// Opção 1: Use read
initState() {
  super.initState();
  print(context.read<Foo>().value);
}

// Opção 2: Use build
Widget build(BuildContext context) {
  final value = context.watch<Foo>().value;
  if (value != this.value) {
    this.value = value;
    print(value);
  }
}
```

[web:11]

### ChangeNotifier atualizado durante build

**Causa:** Modificar `ChangeNotifier` de descendant durante build da tree

**Solução 1:** No create/constructor

```dart
class MyNotifier with ChangeNotifier {
  MyNotifier() {
    _fetchSomething();
  }
  Future<void> _fetchSomething() async {}
}
```

**Solução 2:** Microtask async

```dart
initState() {
  super.initState();
  Future.microtask(() =>
    context.read<MyNotifier>().fetchSomething(someValue)
  );
}
```

[web:11]

### Hot-reload

Implemente `ReassembleHandler`:

```dart
class Example extends ChangeNotifier implements ReassembleHandler {
  @override
  void reassemble() {
    print('Did hot-reload');
  }
}
```

[web:11]

---

## 🧪 Testando

### Unit Test

```dart
test('adding item increases total cost', () {
  final cart = CartModel();
  final startingPrice = cart.totalPrice;
  var i = 0;
  
  cart.addListener(() {
    expect(cart.totalPrice, greaterThan(startingPrice));
    i++;
  });
  
  cart.add(Item('Dash'));
  expect(i, 1);
});
```

[web:6]

### Widget Test com Provider

```dart
testWidgets('Counter increments', (tester) async {
  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => CounterModel(),
      child: MyApp(),
    ),
  );
  
  // Test interactions
});
```

---

## 📚 Comparação com Outras Abordagens

| Approach | Quando usar |
|----------|-------------|
| `setState` | Estado ephemeral específico de widget |
| `Provider` | Apps small/medium, simplicidade |
| `BLoC` | Apps complexos, business logic separada |
| `GetX` | Apps complexos, performance |
| `Redux` | Estado muito complexo, predictability |

[web:2][web:6]

---

## 🔗 Recursos Adicionais

- **Documentação Oficial Flutter:** [Simple app state management](https://docs.flutter.dev/data-and-backend/state-mgmt/simple) [web:6]
- **Package Pub.dev:** [provider](https://pub.dev/packages/provider) [web:11]
- **Exemplo GitHub:** [Flutter-Provider](https://github.com/Felipebb/Flutter-Provider) [web:1]
- **Best Practices 2025:** [Flutter App Development](https://www.zynapte.com/blog/flutter-app-development-best-practices) [web:2]

---

## 📝 Summary

O **Provider** é ideal para:
- ✅ Apps small a medium-sized
- ✅ Desenvolvedores começando com state management
- ✅ Projetos que precisam de simplicidade + performance
- ✅ dependency injection nativo

Comece com Provider se não tem razão forte para escolher outra abordagem (Redux, Rx, hooks, etc.) [web:6].