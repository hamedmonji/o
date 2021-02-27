import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:o/colors.dart';
import 'package:o/models/group.dart';
import 'package:o/models/user.dart';

class Profile extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('failed to initilizing flutter'));
        }
        final firebase = FirebaseFirestore.instance;
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.doc('/users/niko').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('failed loading user data'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Text("Loading"));
              }
              final user = User.from(snapshot.data.data());
              return Scaffold(
                body: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: 42,
                      right: 42,
                      child: CircleAvatar(
                        radius: 68,
                        backgroundImage: NetworkImage(user.imageUrl),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user.groupIds.isEmpty)
                          Positioned(
                            top: 300,
                            left: 0,
                            right: 0,
                            child: _NoGroups(
                              onCreateGroup: (Group value) async {
                                DocumentReference newGroupRef =
                                    await FirebaseFirestore.instance
                                        .collection('groups')
                                        .add(value.toJson()
                                          ..putIfAbsent(
                                              'users', () => ['niko']));
                                final newGroups = snapshot.data.data()
                                  ..update(
                                      'groups',
                                      (_) =>
                                          user.groupIds..add(newGroupRef.id));
                                await FirebaseFirestore.instance
                                    .doc('/users/niko')
                                    .set(newGroups);
                              },
                              onJoinGroup: (String value) {},
                            ),
                          )
                        else
                          Center(
                            child: Container(
                                constraints: BoxConstraints(
                                    minHeight: 300,
                                    maxWidth: 300,
                                    maxHeight: 600),
                                child: _GroupsList(
                                    firebase: firebase, user: user)),
                          )
                      ],
                    )
                  ],
                ),
              );
            },
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _GroupsList extends StatelessWidget {
  const _GroupsList({
    Key key,
    @required this.firebase,
    @required this.user,
  }) : super(key: key);

  final FirebaseFirestore firebase;
  final User user;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: firebase
          .collection('groups')
          .where('users', arrayContains: user.name)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('failed loading user data'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text("Loading groups"));
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            final group = snapshot.data.docs[index].data();

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundImage: NetworkImage(group['image']),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group['name']),
                      SizedBox(
                        height: 32,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('13'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                  color: Colors.green, shape: BoxShape.circle),
                            ),
                          ),
                          Text('0 tasks')
                        ],
                      )
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _NoGroups extends StatefulWidget {
  final ValueChanged<String> onJoinGroup;
  final ValueChanged<Group> onCreateGroup;
  const _NoGroups({
    Key key,
    @required this.onJoinGroup,
    @required this.onCreateGroup,
  }) : super(key: key);

  @override
  __NoGroupsState createState() => __NoGroupsState();
}

class __NoGroupsState extends State<_NoGroups>
    with SingleTickerProviderStateMixin {
  bool _createExpanded = false;
  bool _joinExpanded = false;
  final _createController = TextEditingController();
  final _joinController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'You’re not in any group',
          style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 30),
        ),
        SizedBox(
          height: 50,
        ),
        IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      _createExpanded = !_createExpanded;
                      _joinExpanded = false;
                    });
                  },
                  child: Text('Create')),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 16),
                child: VerticalDivider(
                  width: 1,
                  color: AppColors.divider,
                ),
              ),
              TextButton(
                  onPressed: () {
                    setState(() {
                      _joinExpanded = !_joinExpanded;
                      _createExpanded = false;
                    });
                  },
                  child: Text('Join')),
            ],
          ),
        ),
        SizedBox(
          height: 32,
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          vsync: this,
          child: Column(
            children: [
              if (_createExpanded)
                CircleAvatar(
                  radius: 64,
                  backgroundColor: AppColors.divider,
                  child: Text(
                    'Choose an image',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              if (_joinExpanded || _createExpanded)
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller:
                        _joinExpanded ? _joinController : _createController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                        hintText: _joinExpanded
                            ? 'Enter groups link'
                            : 'Give this group a name'),
                  ),
                )
            ],
          ),
        ),
        SizedBox(
          height: 32,
        ),
        AnimatedOpacity(
          duration: Duration(milliseconds: 300),
          opacity: _showCreateOrJoinGroup() ? 1 : 0,
          child: TextButton(
              onPressed: () {
                if (_joinExpanded) {
                  widget.onJoinGroup(_joinController.text);
                } else {
                  widget.onCreateGroup(Group(_createController.text,
                      'https://images.unsplash.com/photo-1541701494587-cb58502866ab?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8YWJzdHJhY3R8ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'));
                }
              },
              child: Text(_joinExpanded ? 'Join Group' : 'Create group')),
        )
      ],
    );
  }

  bool _showCreateOrJoinGroup() {
    return (_joinExpanded && _joinController.text.isNotEmpty) ||
        (_createExpanded && _createController.text.isNotEmpty);
  }
}
