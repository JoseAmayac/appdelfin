
import 'package:mensajeriadelfin/src/models/group_model.dart';

class GroupService{

  Future save(String name, String authId) async{
    final group = new Group(name: name, owner: int.parse(authId));
    return await group.create();
  }

  Future<List<Group>> allById(int idUser) async{
    final group = new Group(name: '', owner: -1);
    return await group.getGroupsByUser(idUser);
  }

  Future countMembers(Group group) async{
    return await group.getNumberParticipants();
  }

  Future deleteGroup(int groupId) async{
    final group = new Group(name: '', owner: -1);
    group.id = groupId;

    return await group.delete();
  }
}