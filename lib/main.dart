import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// void testIt() {
//   const int int1 = 1;
//   const int int2 = 10;
//   const result = int1 + int2;
//   print(result);
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.dark,
      theme: ThemeData(primaryColor: Colors.blue),
      home: const HomePage(),
    );
  }
}

// final currentTime = Provider<DateTime>((ref) => DateTime.now());

// extension OptionalInfixAddition<T extends num> on T? {
//   T? operator +(T? other) {
//     final shadow = this;
//     if (shadow != null) {
//       return shadow + (other ?? 0) as T;
//     } else {
//       return null;
//     }
//   }
// }

// class Counter extends StateNotifier<int?> {
//   Counter() : super(null);
//   void increment() => state = state == null ? 1 : state + 1;
// }

// final counterProvider = StateNotifierProvider<Counter, int?>(
//   (ref) => Counter(),
// );

enum City {
  paris,
  kathmandu,
  newYork,
  dhaka,
  mumbai,
}

typedef WeatherEmoji = String;
const unKnownWeather = '🤷';
Future<WeatherEmoji> getWeather(City city) {
  return Future.delayed(
    const Duration(seconds: 1),
    () =>
        {
          City.kathmandu: '🌦️🌦️',
          City.paris: '❄️❄️',
        }[city] ??
        unKnownWeather,
  );
}

final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);

final weatherProvider = FutureProvider<WeatherEmoji>(
  (ref) {
    final city = ref.watch(currentCityProvider);
    if (city != null) {
      return getWeather(city);
    } else {
      return unKnownWeather;
    }
  },
);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(
      weatherProvider,
    );
    // final date = ref.watch(currentTime);
    // testIt();
    return Scaffold(
        appBar: AppBar(
            title: const Text(
          'Weather',
          textAlign: TextAlign.center,
        )
            //  Consumer(
            //   builder: (context, ref, child) {
            //     final count = ref.watch(counterProvider);
            //     final text = count == null ? 'Press the Button' : count.toString();
            //     return Text(text);
            //   },
            // ),
            ),
        body: Column(
          children: [
            currentWeather.when(
              data: (data) => Text(
                data,
                style: const TextStyle(fontSize: 40),
              ),
              error: (_, __) => const Text('Error'),
              loading: () => const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ),
            Expanded(
                child: ListView.builder(
              itemCount: City.values.length,
              itemBuilder: (context, index) {
                final city = City.values[index];
                final isSelected = city == ref.watch(currentCityProvider);
                return ListTile(
                  title: Text(
                    city.toString(),
                  ),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    ref
                        .read(
                          currentCityProvider.notifier,
                        )
                        .state = city;
                  },
                );
              },
            ))
          ],
        )
        //Column(
        //   children: [
        //     // Center(
        //     //   child: Text(
        //     //     date.toIso8601String(),
        //     //     style: Theme.of(context).textTheme.headlineMedium,
        //     //   ),
        //     // ),
        //     TextButton(
        //       onPressed: ref.read(counterProvider.notifier).increment,
        //       child: const Text("nextPage"),
        //     ),
        //     const Icon(Icons.sign_language)
        //   ],
        // ),
        );
  }
}
