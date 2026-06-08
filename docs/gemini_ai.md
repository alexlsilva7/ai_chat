```markdown
# Google Generative AI para Flutter - Documentação Completa

> SDK **oficial da Google** para usar modelos Gemini (1.0/1.5) em aplicações Flutter/Dart.

## 📦 Instalação

### Adicionar ao projeto

```bash
flutter pub add google_generative_ai
```

No `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_generative_ai: ^0.4.7
```

[web:11]

### Importar

```dart
import 'package:google_generative_ai/google_generative_ai.dart';
```

---

## 🎯 Obter API Key

### 1. Google AI Studio

```
https://ai.google.dev/
```

### 2. Criar API Key

1. Clique em **"Get API key in Google AI Studio"**
2. Menu lateral → **"Get API Key"**
3. **"Create API key"** → selecione projeto
4. Copie a API Key gerada

[web:11][web:19]

### 3. Plano e Limites

- Plano gratuito disponível com limitações
- Consultar preços: `https://ai.google.dev/pricing`

[web:11]

---

## 🚀 Configuração do Projeto

### Proteção da API Key (Recomendado)

**NÃO** expondr API key no código. Use `dart-define-from-file`:

#### 1. Criar arquivo `.env`

```json
{
  "GEMINI_API_KEY": "--- Sua API Key ---"
}
```

[web:12]

#### 2. Ao `.gitignore`

```gitignore
.env
```

#### 3. Executar

```bash
flutter run --dart-define-from-file=.env
```

Ou VSCode `launch.json`:

```json
{
  "dartDefineFromFile": ".env"
}
```

---

## 📱 Implementação

### 1. Instanciar o Modelo

```dart
final apiKey = String.fromEnvironment('GEMINI_API_KEY');

final model = GenerativeModel(
  model: 'gemini-1.5-flash', // ou 'gemini-1.0-pro'
  apiKey: apiKey,
);
```

**Modelos disponíveis:**

| Modelo | Uso |
|--------|-----|
| `gemini-1.5-flash` | Texto + Imagem (recomendado) |
| `gemini-1.0-pro` | Apenas texto |

[web:11][web:19]

---

### 2. Gerar Texto (Text-to-Text)

```dart
final content = Content.text('Write a story about a magic backpack');

final response = await model.generateContent([content]);

print(response.text);
```

**Exemplo completo:**

```dart
class GeminiService {
  final GenerativeModel model;
  
  GeminiService(String apiKey) {
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }
  
  Future<String> generateText(String prompt) async {
    final content = Content.text(prompt);
    final response = await model.generateContent([content]);
    return response.text ?? '';
  }
}
```

[web:11]

---

### 3. Chat com Contexto (Multi-turn)

```dart
// Criar chat
final chat = model.startChat();

// Primeira mensagem
final response1 = await chat.sendMessage(
  Content.text('Write the first line of a story about a magic backpack.'),
);
print(response1.text);

// Segunda mensagem (com contexto)
final response2 = await chat.sendMessage(
  Content.text('Can you set it in a quiet village in 1600s France?'),
);
print(response2.text);
```

[web:11]

**Exemplo com histórico:**

```dart
class ChatService {
  final GenerativeModel model;
  Chat? _chat;
  
  ChatService(String apiKey) {
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }
  
  Chat get chat {
    _chat ??= model.startChat();
    return _chat!;
  }
  
  Future<String> sendMessage(String message) async {
    final response = await chat.sendMessage(
      Content.text(message),
    );
    return response.text ?? '';
  }
  
  List<Content> get history => chat.history.toList();
}
```

[web:11]

---

### 4. Streaming (Resposta em Tempo Real)

```dart
final content = Content.text('Write a story about a magic backpack');

final stream = model.generateContentStream([content]);

await for (final response in stream) {
  print(response.text);
}
```

[web:11]

**Exemplo com UI:**

```dart
class StreamingWidget extends StatefulWidget {
  @override
  State<StreamingWidget> createState() => _StreamingWidgetState();
}

class _StreamingWidgetState extends State<StreamingWidget> {
  final GeminiService _gemini = GeminiService(apiKey);
  String _response = '';
  bool _isLoading = false;
  
  Future<void> _streamResponse(String prompt) async {
    setState(() {
      _isLoading = true;
      _response = '';
    });
    
    final content = Content.text(prompt);
    final stream = _gemini.model.generateContentStream([content]);
    
    await for (final response in stream) {
      setState(() {
        _response += response.text ?? '';
      });
    }
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading) CircularProgressIndicator(),
        Text(_response),
      ],
    );
  }
}
```

[web:11]

---

## 📸 Texto + Imagem (Multimodal)

```dart
import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();
final image = await picker.pickImage(source: ImageSource.gallery);

// Ler bytes
final bytes = await image!.readAsBytes();

// Criar conteúdo multimodal
final imagePart = Part.inline(
  inlineData: InlineData(
    mimeType: 'image/jpeg',
    data: bytes,
  ),
);

final textPart = Part.text('What is this picture?');

final content = Content([textPart, imagePart]);

final response = await model.generateContent([content]);

print(response.text);
```

[web:19]

**Exemplo completo:**

```dart
class MultimodalService {
  final GenerativeModel model;
  
  MultimodalService(String apiKey) {
    model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
  }
  
  Future<String> analyzeImage(String prompt, List<int> imageBytes) async {
    final imagePart = Part.inline(
      inlineData: InlineData(
        mimeType: 'image/jpeg',
        data: imageBytes,
      ),
    );
    
    final textPart = Part.text(prompt);
    final content = Content([textPart, imagePart]);
    
    final response = await model.generateContent([content]);
    return response.text ?? '';
  }
}
```

[web:19]

---

## ⚙️ Configurações Avançadas

### 1. Safety Settings (Conteúdo Seguro)

```dart
final content = Content.text('Utilizing Google Ads in Flutter');

final response = await model.generateContent([
  content,
], safetySettings: [
  SafetySetting(
    category: SafetyCategory.harassment,
    threshold: SafetyThreshold.blockLowAndAbove,
  ),
  SafetySetting(
    category: SafetyCategory.hateSpeech,
    threshold: SafetyThreshold.blockOnlyHigh,
  ),
]);
```

[web:11]

### 2. Generation Configuration (Parâmetros)

```dart
final content = Content.text('Utilizing Google Ads in Flutter');

final response = await model.generateContent([
  content,
], generationConfig: GenerationConfig(
  temperature: 0.75,        // 0.0 a 1.0 (criatividade)
  maxOutputTokens: 512,     // Máximo tokens na saída
  topP: 0.9,                // Top-p sampling
  topK: 40,                 // Top-k sampling
));
```

**Parâmetros:**

| Parâmetro | Descrição | Valores |
|-----------|-----------|---------|
| `temperature` | Criatividade | 0.0 (preciso) - 1.0 (criativo) |
| `maxOutputTokens` | Máximo tokens | 1 - 8192 |
| `topP` | Top-p sampling | 0.0 - 1.0 |
| `topK` | Top-k sampling | 1 - 40 |

[web:11]

### 3. Count Tokens

```dart
final content = Content.text('Write a story about a magic backpack.');

final tokenCount = await model.countTokens([content]);

print(tokenCount.totalTokens); // Ex: 6
```

[web:11]

### 4. Model Info

```dart
final info = await model.getModelInfo();

print(info.version);
print(info.displayName);
print(info.inputTokenLimit);
```

[web:11]

---

## ⚠️ Problemas Comuns

### API Key Inválida

**Solução:**
```bash
flutter run --dart-define-from-file=.env
```

Verificar formato `.env`:
```json
{
  "GEMINI_API_KEY": "sua-key-aqui"
}
```

[web:12]

### Modelo Não Encontrado

**Nomes corretos:**
- `gemini-1.5-flash` ✅
- `gemini-1.0-pro` ✅

[web:11][web:19]

### Conteúdo Bloqueado

**Ajustar threshold:**
```dart
SafetyThreshold.blockOnlyHigh // Mais permissivo
```

[web:11]

### Token Excedido

```dart
final tokenCount = await model.countTokens([content]);
if (tokenCount.totalTokens > 8000) {
  throw Exception('Prompt muito longo');
}
```

[web:11]

---

## 🔗 Recursos

- **Documentação Oficial:** [Tutorial primeiros passos](https://ai.google.dev/gemini-api/docs/get-started/tutorial?lang=dart) [web:13]
- **Pacote:** [google_generative_ai on Pub](https://pub.dev/packages/google_generative_ai) [web:11]
- **Exemplo:** [tosshiosa/gemini_flutter_example](https://github.com/tosshiosa/gemini_flutter_example) [web:11]
- **Artigo:** [SDK Oficial Gemini](https://medium.com/brasilflutter/oficial-gemini-google-ai-dart-flutter-sdk-integrando-flutter-com-o-gemini-90c46f8c2f7a) [web:11]

---

## 📝 Quick Start

```dart
// 1. Instalar
flutter pub add google_generative_ai

// 2. Importar
import 'package:google_generative_ai/google_generative_ai.dart';

// 3. Instanciar
final model = GenerativeModel(
  model: 'gemini-1.5-flash',
  apiKey: 'YOUR_API_KEY',
);

// 4. Gerar texto
final response = await model.generateContent([
  Content.text('Olá, Gemini!'),
]);

print(response.text);
```
```