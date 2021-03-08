import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:o/colors.dart';
import 'package:o/models/group.dart';
import 'package:o/models/user.dart';
import 'package:o/profile/data/profile_data.dart';

class Profile extends StatelessWidget {
  final ProfileData profileData;

  const Profile({Key key, @required this.profileData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: profileData.getSelfUser(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('failed loading user data'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text("Loading"));
        }
        final user = snapshot.data;
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
              Align(
                alignment:
                    FractionalOffset(0.5, user.groupIds.isEmpty ? 0.45 : 1),
                child: user.groupIds.isEmpty
                    ? _NoGroups(
                        onCreateGroup: (Group newGroup) async {
                          await profileData.createGroupFor(user, newGroup);
                        },
                        onJoinGroup: (String value) {},
                      )
                    : Container(
                        constraints:
                            BoxConstraints(maxHeight: 300, minHeight: 300),
                        child:
                            _GroupsList(profileData: profileData, user: user)),
              )
            ],
          ),
        );
      },
    );
  }
}

class _GroupsList extends StatelessWidget {
  const _GroupsList({
    Key key,
    @required this.profileData,
    @required this.user,
  }) : super(key: key);

  final ProfileData profileData;
  final User user;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Group>>(
      future: profileData.getGroupsFor(user),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('failed loading group data'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Text("Loading groups"));
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            final group = snapshot.data[index];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  BorderdCircleImage(image: group.image),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: TextStyle(fontSize: 32),
                      ),
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
                          Text('${group.tasks.length} tasks')
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

class BorderdCircleImage extends StatelessWidget {
  const BorderdCircleImage({
    Key key,
    @required this.image,
  }) : super(key: key);

  final String image;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: AppColors.divider),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: CircleAvatar(
          radius: 54,
          backgroundImage: NetworkImage(image),
        ),
      ),
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
                  // widget.onCreateGroup(Group(_createController.text,
                  //     'https://images.unsplash.com/photo-1541701494587-cb58502866ab?ixid=MXwxMjA3fDB8MHxzZWFyY2h8MXx8YWJzdHJhY3R8ZW58MHx8MHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'));
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
