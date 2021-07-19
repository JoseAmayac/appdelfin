import 'package:flutter/cupertino.dart';
import 'package:mensajeriadelfin/src/models/group_model.dart';
// import 'package:mensajeriadelfin/src/services/auth_service.dart';
import 'package:mensajeriadelfin/src/services/group_service.dart';
import 'package:mensajeriadelfin/src/utils/preferencias_usuario.dart';


class GroupProvider with ChangeNotifier{

  late GroupService _groupService;

  // late AuthService _authService;
  
  final _prefs = new PreferenciasUsuario();

  List<Group> groups = [];

  GroupProvider(){
    this._groupService = new GroupService();
    // this._authService = new AuthService();
  }

  Future createGroup(String name) async{
    final authId = this._prefs.user;
    final response = await this._groupService.save(name, authId!);

    if (response["ok"]) {
      final Group group = response["group"];
      this.groups.add(group);
      notifyListeners();
    }

    return response;
  }

  Future getGroups() async{
    final idUser = this._prefs.user;
    final groupsUser = await this._groupService.allById(int.parse(idUser!));
    this.groups = [...groupsUser];
    notifyListeners();
  }

  Future members(Group group) async{
    return this._groupService.countMembers(group);
  }

  Future deleteGroup(int idGroup) async{
    await this._groupService.deleteGroup(idGroup);
    this.groups.removeWhere((group) => group.id == idGroup);
    notifyListeners();
  }
}