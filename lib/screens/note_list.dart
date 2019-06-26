import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/note.dart';
import 'package:flutter_app/utils/database_helper.dart';
import 'package:flutter_app/screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';


class NoteList extends StatefulWidget {

	@override
  State<StatefulWidget> createState() {

    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {

	DatabaseHelper databaseHelper = DatabaseHelper();
	List<Note> noteList;
	int count = 0;
  var r = Random();

  List randomLightColors = [
    Color(0x77ffeaa7),
    Color(0x77b2bec3),
    Color(0x77ffbe76),
    Color(0x77D6A2E8),
    Color(0x7734ace0)
  ];

	@override
  Widget build(BuildContext context) {

		if (noteList == null) {
			noteList = List<Note>();
			updateListView();
		}

    return Scaffold(
      backgroundColor: Colors.white,
	    appBar: AppBar(
        backgroundColor: Color(0xFF8e44ad),
        elevation: 10.0,
		    title: Text('To Do List'),
	    ),

	    body: getNoteListView(),

	    floatingActionButton: FloatingActionButton(
		    onPressed: () {
		      debugPrint('FAB clicked');
		      navigateToDetail(Note('', '', 2), 'Add Note');
		    },

		    tooltip: 'Add Note',

		    child: Icon(Icons.add),

	    ),
    );
  }

  ListView getNoteListView() {

		TextStyle titleStyle = Theme.of(context).textTheme.subhead;

		return ListView.builder(
			itemCount: count,
			itemBuilder: (BuildContext context, int position) {
				return Card(
					color: randomLightColors[r.nextInt(4)],
					elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
          ),
					child: ListTile(

						leading: CircleAvatar(
							backgroundColor: getPriorityColor(this.noteList[position].priority),
							child: getPriorityIcon(this.noteList[position].priority),
						),

						title: Text(this.noteList[position].title, 
              style: TextStyle(fontFamily: 'Childhood Memories', fontWeight: FontWeight.bold)
            ),

						subtitle: Text(this.noteList[position].date,
              style: TextStyle(fontSize: 13.0),
            ),

						trailing: GestureDetector(
							child: Icon(Icons.delete, color: Colors.black),
							onTap: () {
								_delete(context, noteList[position]);
							},
						),


						onTap: () {
							debugPrint("ListTile Tapped");
							navigateToDetail(this.noteList[position],'Edit Note');
						},

					),
				);
			},
		);
  }

  // Returns the priority color
	Color getPriorityColor(int priority) {
		switch (priority) {
			case 1:
				return Colors.red;
				break;
			case 2:
				return Colors.yellow;
				break;

			default:
				return Colors.yellow;
		}
	}

	// Returns the priority icon
	Icon getPriorityIcon(int priority) {
		switch (priority) {
			case 1:
				return Icon(Icons.play_arrow);
				break;
			case 2:
				return Icon(Icons.keyboard_arrow_right);
				break;

			default:
				return Icon(Icons.keyboard_arrow_right);
		}
	}

	void _delete(BuildContext context, Note note) async {

		int result = await databaseHelper.deleteNote(note.id);
		if (result != 0) {
			_showSnackBar(context, 'Note Deleted Successfully');
			updateListView();
		}
	}

	void _showSnackBar(BuildContext context, String message) {

		final snackBar = SnackBar(content: Text(message));
		Scaffold.of(context).showSnackBar(snackBar);
	}

  void navigateToDetail(Note note, String title) async {
	  bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
		  return NoteDetail(note, title);
	  }));

	  if (result == true) {
	  	updateListView();
	  }
  }

  void updateListView() {

		final Future<Database> dbFuture = databaseHelper.initializeDatabase();
		dbFuture.then((database) {

			Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
			noteListFuture.then((noteList) {
				setState(() {
				  this.noteList = noteList;
				  this.count = noteList.length;
				});
			});
		});
  }
}







