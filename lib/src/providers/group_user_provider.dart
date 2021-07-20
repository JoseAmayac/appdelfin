import 'package:mensajeriadelfin/src/services/group_user_service.dart';
import 'package:mensajeriadelfin/src/utils/preferencias_usuario.dart';

class GroupUserProvider{

  late GroupUserService _groupUserService;
  final _prefs = new PreferenciasUsuario();

  GroupUserProvider(){
    this._groupUserService = new GroupUserService();
  }

  Future createGroupUser(int groupId, List<int> userIds) async{
    userIds.add(int.parse(this._prefs.user!));
    for (int userId in userIds) {
      await this._groupUserService.save(groupId, userId);
    }

    return {
      "ok": true
    };
  }

  Future leaveGroup(int groupId) async{
    final userId = int.parse(this._prefs.user!);
    return await this._groupUserService.leaveChat(userId, groupId);
  }

  Future findOne(int groupId, int userId) async{
    return await this._groupUserService.findOne(groupId, userId);
  }

  Future createOne(int groupId, int userId) async{
    return await this._groupUserService.save(groupId, userId);
  }
}