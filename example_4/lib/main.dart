import 'dart:collection';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

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

// const names = [
//   'alice',
//   'sanskar',
//   'nitesh',
//   'binesh',
//   'hero',
//   'villan',
//   'superman',
//   'batman',
// ];
// final tickerProvider = StreamProvider(
//   (ref) => Stream.periodic(
//     const Duration(
//       seconds: 1,
//     ),
//     (i) => i + 1,
//   ),
// );

// final namesProvider = FutureProvider(
//   (ref) => ref.watch(tickerProvider.future).then(
//         (count) => names.getRange(0, count),
//       ),
// );

@immutable
class Person {
  final String name;
  final int age;
  final String uuid;

  Person({
    required this.name,
    required this.age,
    String? uuid,
  }) : uuid = uuid ?? const Uuid().v4();

  Person updated([String? name, int? age]) => Person(
        name: name ?? this.name,
        age: age ?? this.age,
        uuid: uuid,
      );

  String get displayName => '$name ($age years old)';
  @override
  bool operator ==(covariant Person other) => uuid == other.uuid;

  @override
  int get hashCode => uuid.hashCode;
  @override
  String toString() => 'Person(name:$name,age:$age,uuid:$uuid)';
}

class DataModel extends ChangeNotifier {
  final List<Person> _people = [];
  int get count => _people.length;

  UnmodifiableListView<Person> get people => UnmodifiableListView(_people);

  void add(Person person) {
    _people.add(person);

    log("olaa ${people.length}");
    notifyListeners();
  }

  void remove(Person person) {
    _people.remove(person);
    notifyListeners();
  }

  void update(Person updatedPreson) {
    final index = _people.indexOf(updatedPreson);
    final oldPerson = _people[index];
    if (oldPerson.name != updatedPreson.name ||
        oldPerson.age != updatedPreson.age) {
      _people[index] = oldPerson.updated(
        updatedPreson.name,
        updatedPreson.age,
      );
      notifyListeners();
    }
  }
}

final peopleProvider = ChangeNotifierProvider((_) => DataModel());
final nameController = TextEditingController();
final ageController = TextEditingController();

Future<Person?> createORupdatePersonDialog(
  BuildContext context, [
  Person? existingPerson,
]) {
  String? name = existingPerson?.name;
  int? age = existingPerson?.age;

  nameController.text = name ?? '';
  ageController.text = age?.toString() ?? '';

  return showDialog<Person?>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Create or Update Person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Enter the name..',
              ),
              onChanged: (value) => name = value,
            ),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(
                labelText: 'Enter the age..',
              ),
              onChanged: (value) => age = int.tryParse(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('cancel'),
          ),
          TextButton(
              onPressed: () {
                if (name != null && age != null) {
                  if (existingPerson != null) {
                    //have existing person
                    final newPerson = existingPerson.updated(
                      name,
                      age,
                    );
                    Navigator.of(context).pop(
                      newPerson,
                    );
                  } else {
                    //if no existing person crate one
                    Navigator.of(context).pop(
                      Person(
                        name: name!,
                        age: age!,
                      ),
                    );
                  }
                } else {
                  //no name or is totally empty
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'))
        ],
      );
    },
  );
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final names = ref.watch(namesProvider);
    final dataModel = ref.watch(peopleProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page ${dataModel.count}'),
        // title: const Text('Stream provider'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          return ListView.builder(
            itemCount: dataModel.count,
            itemBuilder: (context, index) {
              final person = dataModel.people[index];
              return ListTile(
                onTap: () async {
                  final updatedPerson = await createORupdatePersonDialog(
                    context,
                    person,
                  );
                  if (updatedPerson != null) {
                    dataModel.update(updatedPerson);
                  }
                },
                title: Text(person.name),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final person = await createORupdatePersonDialog(
            context,
          );
          if (person != null) {
            final dataModel = ref.read(peopleProvider);
            dataModel.add(person);
          }
        },
        child: const Icon(Icons.add),
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
