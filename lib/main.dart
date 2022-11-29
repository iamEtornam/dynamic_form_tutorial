import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<MultiFormWidget> pages = []; // <---- add this
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Students',
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
                textStyle: const TextStyle(
              color: Colors.white,
            )),
            onPressed: onSaveForm,
            child: Text(
              'Submit',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: Colors.white, fontSize: 18),
            ),
          )
        ],
      ),
      body: Container(
        child: pages.isEmpty
            ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text('Tap on button to add'),
                    TextButton.icon(
                        onPressed: onAddForm,
                        icon: const Icon(Icons.add),
                        label: const Text('Add new')),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(24),
                addAutomaticKeepAlives: true,
                shrinkWrap: true,
                separatorBuilder: (_, index) => const Divider(
                      color: Colors.white,
                    ),
                itemCount: pages.isEmpty ? 0 : pages.length,
                itemBuilder: (_, index) => pages[index]),
      ),
      floatingActionButton: Visibility(
        visible: pages.isNotEmpty,
        child: FloatingActionButton(
          onPressed: onAddForm,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  ///on form user deleted
  void onDelete(Student student) {
    setState(() {
      final find = pages.firstWhereOrNull(
        (it) => it.student == student,
      );
      if (find != null) pages.removeAt(pages.indexOf(find));
    });
  }

  ///on add form
  void onAddForm() {
    setState(() {
      final student = Student();
      pages.add(MultiFormWidget(
        student: student,
        onDelete: () => onDelete(student),
      ));
    });
  }

  /// on save form
  void onSaveForm() {
    if (pages.isNotEmpty) {
      bool allValid = true;
      for (final multiFormWidget in pages) {
        // loop and check if all input fields a validated
        allValid = allValid && multiFormWidget.isValid();
      }
      if (allValid) {
        // all input fields is valid, get values
        final data = pages.map((it) => it.student).toList();

        /// you can go ahead and furthur manipulate the data or make a network call to your API
        print('data: $data');
        ScaffoldMessenger.of(context)
            .showMaterialBanner(MaterialBanner(content: Text('$data'), actions: [
          TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text('ok'))
        ]));
      }
    }
  }
}

class Student {
  String? name;
  String? age;

  Student({this.name, this.age});
}

typedef OnDelete = Function();

/// MultiFormWidget
class MultiFormWidget extends StatefulWidget {
  const MultiFormWidget({super.key, this.onDelete, this.student});

  final OnDelete? onDelete;
  final Student? student;

  @override
  State<MultiFormWidget> createState() => _MultiFormWidgetState();

  bool isValid() => _MultiFormWidgetState().validate();
}

class _MultiFormWidgetState extends State<MultiFormWidget> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final form = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.verified_user, color: Colors.white),
          elevation: 0,
          title: const Text('Student Form'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: widget.onDelete,
            )
          ],
        ),
        body: Form(
            key: form,
            child: Column(
              children: [
                const SizedBox(height: 5),
                TextFormField(
                  controller: _nameController,
                  onSaved: (val) => widget.student?.name = val,
                  style: Theme.of(context).textTheme.bodyText1,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                  maxLines: 1,
                  enableInteractiveSelection: true,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    alignLabelWithHint: true,
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                    contentPadding: const EdgeInsets.all(10.0),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Name cannot be Empty.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ageController,
                  onSaved: (val) => widget.student?.age = val,
                  style: Theme.of(context).textTheme.bodyText1,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  enableInteractiveSelection: true,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    alignLabelWithHint: true,
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                    contentPadding: const EdgeInsets.all(10.0),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Age cannot be Empty.';
                    }
                    return null;
                  },
                ),
              ],
            )),
      ),
    );
  }

  bool validate() {
    final valid = form.currentState!.validate();
    if (valid) form.currentState!.save();
    return valid;
  }
}
