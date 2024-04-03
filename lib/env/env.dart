import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'GOOGLEAI_API_KEY', obfuscate: true)
  static final String googleAiApiKey = _Env.googleAiApiKey;
}
