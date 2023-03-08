import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

const names = [
  'alice',
  'sanskar',
  'nitesh',
  'binesh',
  'hero',
  'villan',
  'superman',
  'batman',
];
final tickerProvider = StreamProvider(
  (ref) => Stream.periodic(
    const Duration(
      seconds: 1,
    ),
    (i) => i + 1,
  ),
);

final namesProvider = FutureProvider(
  (ref) => ref.watch(tickerProvider.future).then(
        (count) => names.getRange(0, count),
      ),
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final names = ref.watch(namesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        // title: const Text('Stream provider'),
      ),
      // body: names.when(
      //   data: (names) {
      //     return ListView.builder(
      //       itemCount: names.length.bitLength,
      //       itemBuilder: (context, index) {
      //         return ListTile(
      //           title: Text(
      //             names.elementAt(index),
      //           ),
      //         );
      //       },
      //     );
      //   },
      //   error: (error, stackTrace) => const Text('Reached End of list '),
      //   loading: () => const Center(
      //     child: CircularProgressIndicator(),
      //   ),
      // ),
    );
  }
}
