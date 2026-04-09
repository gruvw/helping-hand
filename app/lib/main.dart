import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:helping_hand/state/persistence/kvs/providers.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:http/http.dart" as http;

void main() {
  runApp(ProviderScope(child: const Application()));
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(30),
            child: Column(
              children: [
                PnaIotTester(),
                DbTester(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PnaIotTester extends HookConsumerWidget {
  const PnaIotTester({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logState = useState<String>("Waiting...");
    final isLoading = useState<bool>(false);

    Future<void> testIoT() async {
      logState.value = "Sending request...";
      isLoading.value = true;

      try {
        final uri = Uri.parse("http://hh-0001.local/");

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

class DbTester extends HookConsumerWidget {
  const DbTester({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dbVal = ref.watch(kvsAccessibleUiProvider);
    return dbVal.maybeWhen(
      data: (data) => Column(
        children: [
          Text(data.toString()),
          ElevatedButton(
            onPressed: () {
              ref.read(kvsAccessibleUiProvider.notifier).set(!data);
            },
            child: Text("Change val"),
          ),
        ],
      ),
      error: (err, _) => SelectableText(err.toString()),
      orElse: () => CircularProgressIndicator(),
    );
  }
}
