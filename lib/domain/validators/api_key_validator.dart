import 'package:lucid_validation/lucid_validation.dart';

class ApiKeyValidator extends LucidValidator<String> {
  ApiKeyValidator() {
    ruleFor((key) => key, key: 'apiKey')
      .notEmpty(message: 'A chave de API não pode estar vazia')
      .minLength(15, message: 'A chave de API deve ter no mínimo 15 caracteres');
  }
}
