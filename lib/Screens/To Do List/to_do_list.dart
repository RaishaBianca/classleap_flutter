import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../Models/user.dart';
import '../../Services/auth.dart';
import '../../Services/database.dart';
import '../../Utils/widget_utils.dart';


class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();

}

class _ToDoListState extends State<ToDoList> {
  List<Map<String, dynamic>> _toDoItems = [];
  String title = '';
  String categories = '';
  DateTime? _selectedDeadline;
  String? _selectedCategory;
  List<String> _categories = []; 
  DateTime? _editedDeadline;
  bool isFinished = false;
  final _formKey = GlobalKey<FormState>();
  DatabaseService? dbService;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<User?>(context, listen: false);
    if (user != null) {
      dbService = DatabaseService.create(uid: user.uid);
    }
    _fetchToDoItems();
    _fetchToDoItemsCategory();
     _fetchCategories();
  }

  Future<void> _fetchToDoItemsCategory({String? category}) async {
    try {
      var fetchedItems = await dbService?.fetchAllToDoItemsCategories(category: category);
      print('fetched items : $fetchedItems');
      setState(() {
        _toDoItems = fetchedItems ?? [];
      });
    } catch (e) {
      print("Error fetching to-do items: $e");
    }
  }

  Future<void> _fetchCategories() async {
    var fetchedCategories = await dbService?.fetchCategories();
    setState(() {
      _categories = fetchedCategories ?? [];
      print('categories : $_categories');
    });
  }

  Future<void> _fetchToDoItems() async {
    try {
      var fetchedItems = await dbService?.fetchAllToDoItems();
      setState(() {
       _toDoItems = fetchedItems!;
        _toDoItems.sort((a, b) {
          if (a['isFinished'] && !b['isFinished']) {
            return 1;
          } else if (!a['isFinished'] && b['isFinished']) {
            return -1;
          } else {
            return 0;
          }
        });
      });
    } catch (e) {
      print("Error fetching to-do items: $e");
    }
  }

  Future<void> _selectDeadline(BuildContext context, {bool isEditing = false}) async {
    print(isEditing);
    // Customizing the date picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isEditing ? _editedDeadline ?? DateTime.now() : _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.deepOrangeAccent, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            dialogBackgroundColor: Colors.white, // Background color
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // Customizing the time picker
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime( isEditing ? _editedDeadline ?? DateTime.now() : _selectedDeadline ?? DateTime.now()),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.deepOrangeAccent, // Header background color
                onPrimary: Colors.white, // Header text color
                onSurface: Colors.black, // Body text color
              ),
              dialogBackgroundColor: Colors.white, // Background color
            ),
            child: child!,
          );
        },
      );

      print('picked time 1 :  $pickedTime');
      print('edited deadline 1 :  $_editedDeadline');

      if (pickedTime != null) {
        final DateTime pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        print('picked datetime 2 : $pickedDateTime');
        print('edited deadline 2 :  $_editedDeadline');

        // Update the state with the selected DateTime
        if (pickedDateTime != _selectedDeadline || pickedDateTime != _editedDeadline) {
          print('picked datetime 3 : $pickedDateTime');
          print('edited deadline 3 :  $_editedDeadline');
           setState(() {
            if (isEditing) {
              print('Editing deadline');
              _editedDeadline = pickedDateTime;
              print('edited deadline 4 :  $_editedDeadline');
            } else {
              _selectedDeadline = pickedDateTime;
            }
          });
        }
      }
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> item) async {
    print(item);
    String editedTitle = item['title'];
    print(editedTitle);
    String editedCategory = item['categories'];
    print(editedCategory);
    _editedDeadline = item['deadline'].toDate();

    // Show dialog with pre-populated values
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.white70, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            dialogBackgroundColor: Colors.white, // Background color
          ),
          child: AlertDialog(
            title:  Text(
              "Edit To-Do Item",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16.0,
              ),
            ),
            content: Form(
              key: _formKey, // You might need a separate form key for edit form
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: editedTitle,
                    onChanged: (val) => editedTitle = val,
                    decoration: textInputDecoration('$editedTitle'),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    initialValue: editedCategory,
                    onChanged: (val) => editedCategory = val,
                    decoration: textInputDecoration('$editedCategory'),
                  ),
                  SizedBox(height: 20.0),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.deepOrangeAccent,
                    ),
                    onPressed: () => {
                      _selectDeadline(context, isEditing: true)
                    },
                    child: Text(
                     'Select Deadline',
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel',
                style: TextStyle(
                  color: Colors.deepOrangeAccent
                )),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Save',
                    style: TextStyle(
                        color: Colors.deepOrangeAccent
                    )),
                onPressed: () async {
                  print('edited deadline 5 :  $_editedDeadline');
                  await dbService?.updateToDoListItem(item['id'], editedTitle, _editedDeadline!, editedCategory, item['isFinished']);
                  await _fetchToDoItems();
                  await _fetchCategories();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
        'Class Leap',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 20.0,
      ),
      body: Container(
        child:
        Column(
          children: <Widget>[
            const SizedBox(height: 38.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Text(
                    'My To Do List',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 38.0),
            DropdownButton<String>(
              value: _selectedCategory,
              hint: Text("Select Category"),
              items: [
                DropdownMenuItem<String>(
                  value: null, // null value for the reset option
                  child: Text("Show All"),
                ),
              ]..addAll(_categories.map<DropdownMenuItem<String>>((String value) {
                print(value);
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList()),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
                _fetchToDoItemsCategory(category: _selectedCategory); // This will fetch all items if _selectedCategory is null
              },
            ),
            SizedBox(height: 20.0),
            Expanded(  // Use Expanded here
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: ListView.builder(
                    itemCount: _toDoItems.length,
                    itemBuilder: (context, index) {
                      var item = _toDoItems[index];
                      bool isFinished = item['isFinished'];
                      return Card(
                        color: isFinished ? Colors.grey[200] : Colors.white,
                        child: ListTile(
                          title: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start of the column
                              children: <Widget>[
                                Text(
                                  item['title'],
                                  style: TextStyle(
                                    fontSize: 16.0, // Set the font size
                                    fontWeight: FontWeight.bold, // Make the text bold
                                    color: Colors.orange[800], // Set the text color
                                  ),
                                ),
                                SizedBox(height: 4.0), // Adds a little space between the title and the categories
                                Text(
                                  item['categories'], // Assuming 'categories' is a field in your item map
                                  style: TextStyle(
                                    fontSize: 14.0, // Set the font size for the categories
                                    color: Colors.grey, // Set the text color for the categories
                                  ),
                                ),
                              ],
                            )
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text('${DateFormat('dd MMMM yyyy, HH:mm').format(item['deadline'].toDate())}'),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min, // This is needed to keep the Row's width to a minimum
                            children: [
                              Transform.scale(
                                scale: 1.1,
                                child: IconButton(
                                  icon: Icon(isFinished ? Icons.check_circle : Icons.check_circle_outline),
                                  onPressed: () async {
                                    await dbService?.updateToDoListItemStatus(item['id'], !isFinished);
                                    setState(() {
                                      _toDoItems[index]['isFinished'] = !isFinished;
                                      _toDoItems.sort((a, b) {
                                        if (a['isFinished'] && !b['isFinished']) {
                                          return 1;
                                        } else if (!a['isFinished'] && b['isFinished']) {
                                          return -1;
                                        } else {
                                          return 0;
                                        }
                                      });
                                    });
                                  },
                                ),
                              ),
                              PopupMenuButton(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      print(item);
                                      _showEditDialog(item);
                                      break;
                                    case 'delete':
                                      if (dbService != null) {
                                        try {
                                          dbService!.deleteToDoListItem(item['id']);
                                          print('Item deleted successfully!');
                                          _fetchToDoItems();
                                        } catch (e) {
                                          print(e.toString());
                                        }
                                      }
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                                icon: const Icon(Icons.more_horiz),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: FloatingActionButton(
          onPressed: () {
            _selectedDeadline= DateTime.now();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Theme(
                  data: ThemeData.light().copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Colors.white70, // Header background color
                      onPrimary: Colors.white, // Header text color
                      onSurface: Colors.black, // Body text color
                    ),
                    dialogBackgroundColor: Colors.white, // Background color
                  ),
                  child: AlertDialog(
                    title: Text(
                      "Add To-Do Item",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16.0,
                      ),
                    ),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            decoration: textInputDecoration('Title'),
                            onChanged: (val) {
                              setState(() => title = val);
                            },
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            decoration: textInputDecoration('Category'),
                            onChanged: (val) {
                              setState(() => categories = val);
                            },
                          ),
                          SizedBox(height: 20.0),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.deepOrangeAccent,
                            ),
                            onPressed: () => _selectDeadline(context),
                            child: Text(
                              'Select Deadline',
                            ),
                          ),
                          // Add more form fields if needed
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepOrangeAccent,
                        ),
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepOrangeAccent,
                        ),
                        child: Text('Add'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Check if dbService is not null before calling the method
                            if (dbService != null) {
                              try {
                                await dbService!.addToDoListItem(title,  _selectedDeadline!, categories, isFinished);
                                print('Item added successfully!');
                                await _fetchToDoItems();
                                await _fetchCategories();
                                Navigator.of(context).pop(); // Close the dialog if the item is added successfully
                              } catch (e) {
                                SnackBar(
                                  //show error
                                  content: Text('Failed to add item. Please try again.'),
                                );
                                print(e.toString());
                              }
                            } else {
                              // Handle the case where dbService is null, e.g., show an error message
                              print("Database service is not initialized.");
                            }
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: const Icon(
            Icons.add_task,
            color: Colors.white,),
          backgroundColor: Colors.deepOrangeAccent,
        ),
        ),
    );
  }
}
