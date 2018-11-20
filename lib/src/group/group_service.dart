import 'dart:async';

import 'dart:convert';
import 'package:auge_server/client/augeapi.dart';

import 'package:angular/core.dart';
import 'package:auge_web/services/augeapi_service.dart';

import 'package:auge_server/message/created_message.dart';
import 'package:auge_server/model/group.dart';
import 'package:auge_server/model/user.dart';



import 'package:auge_web/message/messages.dart';


@Injectable()
class GroupService {

  final AugeApiService _augeApiService;

  GroupService(this._augeApiService);

  /// Return a list of [Group]
  Future<List<Group>> getGroups(String organizationId) async {

   // return await _augeApiService.augeApi.getGroups(organizationId);
   return _augeApiService.augeApi.getGroups(organizationId);

  }

  /// Delete an [Group]
  Future deleteGroup(String id) async {
    try {
      await _augeApiService.augeApi.deleteGroup(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Save (create or update) an [Group]
  void saveGroup(Group group) async {
    try {

      if (group.id == null) {

        //print(GroupMessageFactory.toJson(GroupFacilities.messageFrom(group)));

        IdMessage idMessage = await _augeApiService.augeApi.createGroup(group);

        // ID - primary key generated on server-side.
        group.id = idMessage?.id;
      } else {
        await _augeApiService.augeApi.updateGroup(group);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Return a list of [GroupType]
  Future<List<GroupType>> getGroupTypes() async {
    List<GroupType> groupTypes = await _augeApiService.augeApi.getGroupTypes();

    // Translate
    groupTypes.forEach((f) => f.name = GroupMsg.groupTypeLabel(f.name));

    return groupTypes;
  }
}