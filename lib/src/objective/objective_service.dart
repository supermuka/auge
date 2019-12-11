import 'dart:async';

import 'package:angular/core.dart';
import 'package:auge_web/src/auth/auth_service.dart';
import 'package:auge_server/domain/objective/objective.dart';

import 'package:auge_web/services/auge_api_service.dart';

import 'package:auge_server/src/protos/generated/google/protobuf/wrappers.pb.dart' as wrappers_pb;
import 'package:auge_server/src/protos/generated/objective/objective_measure.pbgrpc.dart' as objective_measure_pbgrpc;

import 'package:grpc/grpc_web.dart';

@Injectable()
class ObjectiveService {
  final AuthService _authService;
  final AugeApiService _augeApiService;
  objective_measure_pbgrpc.ObjectiveServiceClient _objectiveServiceClient;

  DateTime currentDateTime;

  ObjectiveService(this._authService, this._augeApiService) {
    _objectiveServiceClient = objective_measure_pbgrpc.ObjectiveServiceClient(_augeApiService.channel);
  }

  get authService => _authService;


  /// Return a list of [Objective]
  Future<List<Objective>> getObjectives(String organizationId, {String objectiveId, bool withMeasures = false, bool withProfile = false}) async {
    objective_measure_pbgrpc.ObjectiveGetRequest objectiveGetRequest = objective_measure_pbgrpc.ObjectiveGetRequest();
    objectiveGetRequest.organizationId = organizationId;
    if (objectiveId != null)  objectiveGetRequest.id = objectiveId;
    objectiveGetRequest.withMeasures = withMeasures;
    objectiveGetRequest.withUserProfile = withProfile;

    Map<String, dynamic> cache = {};
    return (await _objectiveServiceClient.getObjectives(
        objectiveGetRequest)).objectives.map((m) =>
    Objective()
      ..readFromProtoBuf(m, cache)).toList();

  }

  /// Return an [Objective] by Id
  Future<Objective> getObjective(String id, {bool withMeasures = false, bool withUserProfile = false}) async {
    try {

      // Objective objective = await _augeApiService.objectiveAugeApi.getObjectiveById(id, withMeasures: withMeasures, withProfile: withProfile, withHistory: withHistory);

      objective_measure_pbgrpc.Objective objective = await _objectiveServiceClient.getObjective(
          objective_measure_pbgrpc.ObjectiveGetRequest()
            ..id = id
            ..withMeasures = withMeasures
            ..withUserProfile = withUserProfile);

      return Objective()..readFromProtoBuf(objective, {});

     // currentDateTime ??= await getDateTime();

      // return objective;

    } on GrpcError catch (e) {
      /*TODO melhorar tratamento, se necessário
      if (e.status == 204 && e.errors.firstWhere((ed) => ed.reason == RpcErrorDetailMessage.objectiveDataNotFoundReason, orElse: null ) != null)
        return null;
      else {
        rethrow;
      }

       */
      print(e);
      rethrow;
    }
  }

  /// Save (create or update) an [Objective]
  Future<String> saveObjective(Objective objective) async {

    objective_measure_pbgrpc.ObjectiveRequest objectiveRequest = (objective_measure_pbgrpc.ObjectiveRequest()
      ..objective = objective.writeToProtoBuf()
      ..authOrganizationId = _authService.authorizedOrganization.id
      ..authUserId = _authService.authenticatedUser.id);

    try {
      if (objective.id == null) {

        wrappers_pb.StringValue idResponse= await _objectiveServiceClient
            .createObjective(objectiveRequest);

        // ID - primary key generated on server-side.
        objective.id = idResponse?.value;

      } else {
        await _objectiveServiceClient.updateObjective(objectiveRequest);
      }

    } catch (e) {
      print('${e.runtimeType}, ${e}');
      rethrow;
    }
    return objective.id;
  }


  /// Delete an [Objective]
  void deleteObjective(Objective objective) async {
    try {
      await _objectiveServiceClient.deleteObjective(objective_measure_pbgrpc.ObjectiveDeleteRequest()
        ..objectiveId = objective.id
        ..objectiveVersion = objective.version
        ..authUserId = _authService.authenticatedUser.id
        ..authOrganizationId = _authService.authorizedOrganization.id);
    } catch (e) {
      rethrow;
    }
  }
}