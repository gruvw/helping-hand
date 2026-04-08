import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:http/http.dart" as http;

void main() {
  runApp(ProviderScope(child: const Application()));
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: PnaIotTester(),
        ),
      ),
    );
  }
}

class PnaIotTester extends HookConsumerWidget {
  const PnaIotTester({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // useState mimics the DOM element text manipulation in your JS snippet
    final logState = useState<String>("Waiting...");
    final isLoading = useState<bool>(false);

    Future<void> testIoT() async {
      logState.value = "Sending request...";
      isLoading.value = true;

      try {
        final uri = Uri.parse("http://hh-0001.local/");

        // Standard HTTP GET request.
        // On Web, the browser handles the underlying fetch and PNA preflight.
        final response = await http
            .get(uri)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw Exception("Connection timed out"),
            );

        if (response.statusCode == 200) {
          logState.value = "Success: ${response.body}";
        } else {
          logState.value = "Error: HTTP Status ${response.statusCode}";
        }
      } catch (err) {
        logState.value =
            "Error: $err\n\n(If on Web, check DevTools Network tab for PNA/CORS blocks. On mobile, ensure cleartext HTTP is allowed.)";
      } finally {
        isLoading.value = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: isLoading.value ? null : testIoT,
          child: const Text("Fetch IoT Device"),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Text(logState.value),
        ),
      ],
    );
  }
}
