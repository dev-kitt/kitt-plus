**<h1> kitt.plus | chat-gpt</h1>**
![Kitt.Plus](/assets/kittplus_readme.png "Kitt.Plus by Kitt, LLC")



## <span style="color:#555555"><u> **OVERVIEW** </u></span>
[kitt.plus](https://kitt.plus) [`Flutter Google AI Gemini Chatbot`]
by Kitt, LLC
- Flutter & Dart
  - Google AI Stuff
  - Gemini Pro Stuff
  - :taco: Stuff


## <span style="color:#555555"><u> **POINTS OF CONTACT** </u></span>
If any issues arise for any of the below mentioned areas, please draft a strongly worded email and never send it to: **dev@kitt.llc** 



## <span style="color:#555555"><u> **CORE SOLUTIONS** </u></span>
| Stack  | Versions |
| ------------- |:-------------:|
| Flutter | ^0.13.5 |
| Firebase Core | ^2.4.1 |
| GoogleAI | v1 |
| Learning Model | gemini-pro |
| Image Model | gemini-pro-vision |



## <span style="color:#555555"><u> **CORE DEVELPOMENT** </u></span>
:peach::chipmunk: Developed by Kitt + OpenAI


``` dart
// GENERATE RESPONSE FROM OPENAI [dart]
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

Future<String> generateResponse(String prompt) async {
  const apiKey = apiSecretKey;

  var url = Uri.https("api.openai.com", "/v1/completions");
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $apiKey"
    },
    body: json.encode({
      "model": "text-davinci-003",
      "prompt": prompt,
      'temperature': 0,
      'max_tokens': 2000,
      'top_p': 1,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    }),
  );

  // Do something with the response
  String utf8Body = utf8.decode(response.bodyBytes);

  // Decode the JSON string
  Map<String, dynamic> newresponse = jsonDecode(utf8Body);

  return newresponse['choices'][0]['text'];
}
```

:doughnut::chipmunk: Developed by Kitt + GoogleAI
``` dart
// GENERATE RESPONSE FROM GOOGLEAI [dart]
Future generateResponse(String prompt) async {
  final apiKey = Env.googleAiApiKey;
  final generationConfig = GenerationConfig(
    stopSequences: ["red"],
    maxOutputTokens: 200,
    temperature: 0.9,
    topP: 0.1,
    topK: 16,
  );
  final model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: apiKey,
    generationConfig: generationConfig,
  );
  final response = await model.generateContent([Content.text(prompt)]);
  // Extracting the text from the GenerateContentResponse object
  return response.text;
}
```
:taco::taco::taco:
</details>