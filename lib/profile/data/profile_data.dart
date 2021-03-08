import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:o/models/group.dart';
import 'package:o/models/user.dart';

class ProfileData {
  final FirebaseFirestore _store;

  ProfileData(this._store);

  Stream<User> getSelfUser() {
    return _user('niko').snapshots().map(
        (event) => User.from(event.data()..putIfAbsent('id', () => event.id)));
  }

  Future<List<Group>> getGroupsFor(User user) {
    return _groups.where('users', arrayContains: 'niko').get().then((value) {
      return value.docs
          .map((e) => Group.from(e.data()..putIfAbsent('id', () => e.id)))
          .toList();
    });
  }

  Future<User> createGroupFor(User user, Group newGroup) async {
    return _store.runTransaction((transaction) async {
      DocumentReference newGroupRef = await _groups
          .add(newGroup.toJson()..putIfAbsent('users', () => [user.id]));
      final newGroups = user.toJson()
        ..update('groups', (_) => user.groupIds..add(newGroupRef.id));
      await _user(user.id).set(newGroups);
      return user;
    });
  }

  DocumentReference _user(id) => _users.doc(id);

  CollectionReference get _groups => _store.collection('groups');

  CollectionReference get _users => _store.collection('users');
}
