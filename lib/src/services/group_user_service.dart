import 'package:mensajeriadelfin/src/models/group_user_model.dart';

class GroupUserService{

  Future save(int groupId, int userId) async{
    final groupUser = new GroupUser(groupId: groupId, userId: userId);
    return await groupUser.create();
  }

  Future leaveChat(int userId, int groupId) async{
    final groupUser = new GroupUser(groupId: groupId, userId: userId);
    return await groupUser.delete();
  }
  
}