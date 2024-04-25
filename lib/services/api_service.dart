import 'dart:async';
import 'dart:convert';
import 'package:kitt_plus/env/env.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';

Future generateGoogleAiResponse(String prompt) async {
  final geminiKey = Env.googleAiApiKey;
  final generationConfig = GenerationConfig(
    stopSequences: ["red"],
    maxOutputTokens: 2000,
    temperature: 0.9,
    topP: 0.1,
    topK: 16,
  );
  final model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: geminiKey,
    generationConfig: generationConfig,
  );
  final response = await model.generateContent([Content.text(prompt)]);
  // Extracting the text from the GenerateContentResponse object
  return response.text;
}

Future<String> generateOpenAiResponse(String prompt) async {
  final apiKey = Env.openAiApiKey;

  var url = Uri.https("api.openai.com", "/v1/completions");
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $apiKey"
    },
    body: json.encode({
      "model": "gpt-3.5-turbo",
      "prompt": prompt,
      'temperature': 0,
      'max_tokens': 200,
      'top_p': 1,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    }),
  );

  // Check if response status code is not 200
  if (response.statusCode == 200) {
    // Do something with the response
    String utf8Body = utf8.decode(response.bodyBytes);
    print(utf8Body);
    // Decode the JSON string
    Map<String, dynamic> newresponse = jsonDecode(utf8Body);

    return newresponse['choices'][0]['text'];
  } else {
    return '🤖 ERROR...beep boop burp';
  }
}
