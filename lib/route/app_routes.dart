// Copyright (c) 2020, Levius.

import 'package:auge_shared/route/app_routes_definition.dart';
export 'package:auge_shared/route/app_routes_definition.dart';
import 'package:angular_router/angular_router.dart' show RoutePath;

class AppRoutes {

  static final authRoute = RoutePath(
    path: AppRoutesPath.authRoutePath,
  );
  static final appLayoutRoute = RoutePath(
    path: AppRoutesPath.appLayoutRoutePath,
  );
  static final insightsRoute = RoutePath(
    path: AppRoutesPath.insightsRoutePath,
    parent: appLayoutRoute,
    useAsDefault: true,
  );
  static final insightsFilterRoute = RoutePath(
      path: AppRoutesPath.insightsFilterRoutePath,
      parent: insightsRoute
  );
  static final usersRoute = RoutePath(
      path: AppRoutesPath.usersRoutePath,
      parent: appLayoutRoute
  );
  static final objectivesMapRoute = RoutePath(
      path: AppRoutesPath.objectivesMapRoutePath,
      parent: appLayoutRoute
  );
  static final objectivesGanttRoute = RoutePath(
      path: AppRoutesPath.objectivesGanttRoutePath,
      parent: appLayoutRoute
  );
  static final worksRoute = RoutePath(
      path: AppRoutesPath.worksRoutePath,
      parent: appLayoutRoute
  );
  static final worksFilterRoute = RoutePath(
      path: AppRoutesPath.worksFilterRoutePath,
      parent: worksRoute
  );
  static final workAddRoute = RoutePath(
      path: AppRoutesPath.workAddRoutePath,
      parent: worksRoute
  );
  static final workEditRoute = RoutePath(
      path: AppRoutesPath.workEditRoutePath, // ':${AppRoutesParam.workIdParameter}/edit',
      parent: worksRoute
  );
  static final workItemsKanbanRoute = RoutePath(
      path:  AppRoutesPath.workItemsKanbanRoutePath, // 'works/:${AppRoutesParam.workIdParameter}/kanban_work_items',
      parent: appLayoutRoute
  );
  static final workItemsKanbanFilterRoute = RoutePath(
      path: AppRoutesPath.workItemsKanbanFilterRoutePath,
      parent: workItemsKanbanRoute
  );
  static final workItemsFilterRoute = RoutePath(
      path: AppRoutesPath.workItemsFilterRoutePath,
      parent: workItemsRoute
  );
  static final workItemsGanttFilterRoute = RoutePath(
      path: AppRoutesPath.workItemsFilterRoutePath,
      parent: workItemsGanttRoute
  );
  static final workItemsKanbanViaObjectiveRoute = RoutePath(
      path:  AppRoutesPath.workItemsKanbanViaObjectivePath, // 'works/:${AppRoutesParam.workIdParameter}/kanban_work_items',
      parent: appLayoutRoute
  );
  static final workItemsRoute = RoutePath(
      path:  AppRoutesPath.workItemsRoutePath,
      parent: appLayoutRoute
  );
  static final workItemsGanttRoute = RoutePath(
      path: AppRoutesPath.workItemsGanttRoutePath,
      parent: appLayoutRoute
  );
  static final workStagesRoute = RoutePath(
      path: AppRoutesPath.workStagesRoutePath, // ':${AppRoutesParam.workIdParameter}/stages',
      parent: worksRoute
  );
  static final workStagesRouteViaKanbanRoute = RoutePath(
      path: AppRoutesPath.workStagesViaKanbanRoutePath, // ':${AppRoutesParam.workIdParameter}/stages',
      parent: workItemsKanbanRoute
  );
  static final worksByObjectiveRoute = RoutePath(
      path: AppRoutesPath.worksByObjectiveRoutePath, // 'works/:${AppRoutesParam.objectiveIdParameter}',
      parent: appLayoutRoute
  );
  static final objectivesRoute = RoutePath(
      path: AppRoutesPath.objectivesRoutePath, // 'objectives',
      parent: appLayoutRoute
  );
  static final objectivesFilterRoute = RoutePath(
      path: AppRoutesPath.objectivesFilterRoutePath,
      parent: objectivesRoute
  );
  static final objectivesGanttFilterRoute = RoutePath(
      path: AppRoutesPath.objectivesFilterRoutePath,
      parent: objectivesGanttRoute
  );

  static final measuresRoute = RoutePath(
      path: AppRoutesPath.objectivesRoutePath, // 'objectives/:${AppRoutesParam.objectiveIdParameter}/measures',
      parent: objectivesRoute
  );
  static final organizationRoute = RoutePath(
      path: AppRoutesPath.organizationRoutePath, //'organizations/:${AppRoutesParam.organizationIdParameter}',
      parent: appLayoutRoute
  );
  static final groupsRoute = RoutePath(
      path: AppRoutesPath.groupsRoutePath,  //'groups',
      parent: appLayoutRoute
  );
  static final groupAddRoute = RoutePath(
      path: AppRoutesPath.groupAddRoutePath, //'add',
      parent: groupsRoute
  );
  static final groupEditRoute = RoutePath(
      path: AppRoutesPath.groupEditRoutePath, // ':${AppRoutesParam.groupIdParameter}/edit',
      parent: groupsRoute
  );
  static final measureAddRoute = RoutePath(
      path: ':${AppRoutesParam.objectiveIdParameter}/measures/add',
      parent: objectivesRoute
  );
  static final measureEditRoute = RoutePath(
      path: ':${AppRoutesParam.objectiveIdParameter}/measures/:${AppRoutesParam.measureIdParameter}/edit',
      parent: objectivesRoute
  );
  static final measureProgressesRoute = RoutePath(
      path: ':${AppRoutesParam.objectiveIdParameter}/measures/:${AppRoutesParam.measureIdParameter}/progresses',
      parent: objectivesRoute
  );
  static final measureProgressesAddRoute = RoutePath(
      path: ':${AppRoutesParam.objectiveIdParameter}/measures/:${AppRoutesParam.measureIdParameter}/progresses/add',
      parent: objectivesRoute
  );
  static final objectiveAddRoute = RoutePath(
      path: 'add',
      parent: objectivesRoute
  );
  static final objectiveEditRoute = RoutePath(
      path: ':${AppRoutesParam.objectiveIdParameter}/edit',
      parent: objectivesRoute
  );
  static final workItemAddRoute = RoutePath(
      path: ':${AppRoutesParam.workIdParameter}/work_items/add',
      parent: worksRoute
  );
  static final workItemEditRoute = RoutePath(
      path: ':${AppRoutesParam.workIdParameter}/work_items/:${AppRoutesParam.workItemIdParameter}/edit',
      parent: worksRoute
  );
  static final workItemKanbanAddRoute = RoutePath(
      path: 'add',
      parent: workItemsKanbanRoute
  );
  static final workItemKanbanEditRoute = RoutePath(
      path: ':${AppRoutesParam.workItemIdParameter}/edit',
      parent: workItemsKanbanRoute
  );
  static final workItemKanbanValuesRoute = RoutePath(
      path: ':${AppRoutesParam.workItemIdParameter}/values',
      parent: workItemsKanbanRoute
  );
  static final userAddRoute = RoutePath(
      path: 'add',
      parent: usersRoute
  );
  static final userEditRoute = RoutePath(
      path: ':${AppRoutesParam.userIdParameter}/edit',
      parent: usersRoute
  );
  static final userEditWithAppLayoutParentRoute = RoutePath(
      path: 'users/:${AppRoutesParam.userIdParameter}/auth/edit',
      parent: appLayoutRoute
  );
  static final historyTimelineRoute = RoutePath(
      path: 'history',
      parent: appLayoutRoute
  );
}