// import 'package:flutter/material.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'dart:io';

// class ResultScreen extends StatefulWidget {
//   final File imageFile;

//   const ResultScreen({Key? key, required this.imageFile}) : super(key: key);

//   @override
//   _ResultScreenState createState() => _ResultScreenState();
// }

// class _ResultScreenState extends State<ResultScreen> {
//   late String analyzedText = "";
//   final textRecognizer = TextRecognizer();

//   @override
//   void initState() {
//     super.initState();
//     _analyzeText();
//   }

//   Future<void> _analyzeText() async {
//     try {
//       final inputImage = InputImage.fromFile(widget.imageFile);
//       final recognizedText = await textRecognizer.processImage(inputImage);
//       // Récupérer le texte extrait
//       final String extractedText = recognizedText.text;

//       // Mettre à jour l'état pour afficher le texte
//       if (mounted) {
//         setState(() {
//           analyzedText = extractedText;
//         });
//       }
//     } catch (e) {
//       print('Erreur lors de l\'analyse du texte : $e');
//     }
//   }

//   @override
//   void dispose() {
//     // Fermer le recognizer pour libérer les ressources
//     textRecognizer.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Result'),
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(30.0),
//         child: ListView(
//           children: [
//             SelectableText(
//               analyzedText,
//               style: TextStyle(fontSize: 18.0),
//             ),
//             Image.file(widget.imageFile),
//             const SizedBox(height: 20.0),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:translator/translator.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class ResultScreen extends StatefulWidget {
  final File imageFile;

  const ResultScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String analyzedText = "";
  final textRecognizer = TextRecognizer();
  final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final translator = GoogleTranslator();
  @override
  void initState() {
    super.initState();
    _analyzeText();
  }

  Future<void> _analyzeText() async {
    try {
      final inputImage = InputImage.fromFile(widget.imageFile);
      final recognizedText = await textRecognizer.processImage(inputImage);
      // Récupérer le texte extrait
      final String extractedText = recognizedText.text;
      final String detectedLanguage =
          await languageIdentifier.identifyLanguage(extractedText);

      // Mettre à jour l'état pour afficher le texte
      if (mounted) {
        setState(() {
          analyzedText = extractedText;
        });
      }
      await _translateTextIfNeeded(detectedLanguage);
    } catch (e) {
      print('Erreur lors de l\'analyse du texte : $e');
    }
  }

  Future<void> _translateTextIfNeeded(String detectedLanguage) async {
    final currentLocale = Platform.localeName.split('_').first;
    if (detectedLanguage != currentLocale) {
      // Traduire le texte dans la langue du téléphone
      final translatedText = await translator.translate(analyzedText,
          from: detectedLanguage, to: currentLocale);
      if (mounted) {
        setState(() {
          analyzedText = translatedText.text;
        });
      }
    }
  }

  @override
  void dispose() {
    // Fermer le recognizer pour libérer les ressources
    textRecognizer.close();
    languageIdentifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: ListView(
          children: [
            SelectableText(
              analyzedText,
              style: TextStyle(fontSize: 18.0),
            ),
            Image.file(
              widget.imageFile,
              height: 400,
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
