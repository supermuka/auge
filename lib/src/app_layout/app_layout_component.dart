// Copyright (c) 2018, Levius Tecnologia Ltda. All rights reserved.
// Author: Samuel C. Schwebel.

import 'dart:html' as html;

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_forms/angular_forms.dart';

//import 'package:angular_components/app_layout/material_persistent_drawer.dart';
import 'package:angular_components/app_layout/material_temporary_drawer.dart';
import 'package:angular_components/content/deferred_content.dart';

import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';

import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';

import 'package:angular_components/material_select/material_dropdown_select.dart';
import 'package:angular_components/material_select/material_dropdown_select_accessor.dart';
import 'package:angular_components/model/selection/selection_model.dart';
import 'package:angular_components/model/selection/selection_options.dart';
import 'package:angular_components/model/ui/has_factory.dart';
import 'package:auge_web/src/history_timeline/history_component.dart';

import 'package:auge_web/src/search_filter/search_filter_component.dart';

import 'package:auge_web/src/auth/auth_service.dart';
import 'package:auge_web/src/app_layout/app_layout_service.dart';
import 'package:auge_web/src/search_filter/search_filter_service.dart';

import 'package:auge_web/src/user/user_detail_component.dart';

import 'package:auge_web/route/app_routes.dart';
import 'package:auge_web/src/history_timeline/history_timeline_service.dart';
import 'package:auge_web/services/common_service.dart' as common_service;

import 'package:auge_shared/message/messages.dart';

import 'package:auge_shared/domain/general/authorization.dart';
import 'package:auge_shared/domain/general/user.dart';
import 'package:auge_shared/domain/general/organization.dart';

// ignore_for_file: uri_has_not_been_generated
import 'package:auge_web/src/app_layout/app_layout_component.template.dart' as app_layout_component;
import 'package:auge_web/src/insight/insights_component.template.dart' as insights_component;
import 'package:auge_web/src/user/user_detail_component.template.dart' as user_detail_component;
import 'package:auge_web/src/user/users_component.template.dart' as users_component;
import 'package:auge_web/src/work/works_component.template.dart' as works_component;
import 'package:auge_web/src/map/objectives_map_component.template.dart' as objectives_map_component;
import 'package:auge_web/src/gantt/objectives_gantt_component.template.dart' as objectives_gantt_component;
import 'package:auge_web/src/objective/objectives_component.template.dart' as objectives_component;
import 'package:auge_web/src/group/groups_component.template.dart' as groups_component;
import 'package:auge_web/src/organization/organization_component.template.dart' as organization_component;
import 'package:auge_web/src/work_item/work_items_kanban_component.template.dart' as work_items_kanban_component;
//import 'package:auge_web/src/work_item/work_items_component.template.dart' as work_items_component;
import 'package:auge_web/src/gantt/work_items_gantt_component.template.dart' as work_items_gantt_component;
import 'package:auge_web/src/history_timeline/history_timeline_component.template.dart' as history_timeline_component;

@Component(
    selector: 'auge-layout',
    providers: const <dynamic>[AppLayoutService, SearchFilterService, HistoryTimelineService],
    templateUrl: 'app_layout_component.html',
    styleUrls: [
      'package:angular_components/app_layout/layout.scss.css',
      'app_layout_component.css',
    ],
    directives: const [
      coreDirectives,
      routerDirectives,
      formDirectives,
      DeferredContentDirective,
      MaterialButtonComponent,
      MaterialIconComponent,
     // MaterialPersistentDrawerDirective,
      MaterialTemporaryDrawerComponent,
      MaterialListComponent,
      MaterialListItemComponent,
      MaterialDropdownSelectComponent,
      DropdownSelectValueAccessor,
     /* SearchComponent,*/
      UserDetailComponent,
      SearchFilterComponent,
      HistoryComponent,
    ])

class AppLayoutComponent with CanReuse implements OnActivate {


  final AppLayoutService _appLayoutService;
  final AuthService _authService;
  final HistoryTimelineService _historyTimelineService;
  final Router _router;

  String insightsRouteUrl;
  String objectivesMapRouteUrl;
  String objectivesGanttRouteUrl;
  String objectivesRouteUrl;
  String worksRouteUrl;
  String workItemsGanttRouteUrl;
  String workItemsRouteUrl;
  String usersRouteUrl;
  String groupsRouteUrl;
  String organizationRouteUrl;

  final List<RouteDefinition> routes = [
    RouteDefinition(
      routePath: AppRoutes.appLayoutRoute,
      component: app_layout_component.AppLayoutComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.insightsRoute,
      component: insights_component.InsightsComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.userEditWithAppLayoutParentRoute,
      component: user_detail_component.UserDetailComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.usersRoute,
      component: users_component.UsersComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.worksRoute,
      component: works_component.WorksComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.worksByObjectiveRoute,
      component: works_component.WorksComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.objectivesMapRoute,
      component: objectives_map_component.ObjectivesMapComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.objectivesGanttRoute,
      component: objectives_gantt_component.ObjectivesGanttComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.objectivesRoute,
      component: objectives_component.ObjectivesComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.groupsRoute,
      component: groups_component.GroupsComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.organizationRoute,
      component: organization_component.OrganizationComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.workItemsKanbanRoute,
      component: work_items_kanban_component.WorkItemsKanbanComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.workItemsKanbanViaObjectiveRoute,
      component: work_items_kanban_component.WorkItemsKanbanComponentNgFactory,
    ),
/*
    RouteDefinition(
      routePath: AppRoutes.workItemsRoute,
      component: work_items_component.WorkItemsComponentNgFactory,
    ),
 */
    RouteDefinition(
      routePath: AppRoutes.workItemsGanttRoute,
      component: work_items_gantt_component.WorkItemsGanttComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.historyTimelineRoute,
      component: history_timeline_component.HistoryTimelineComponentNgFactory,
    ),
  ];

  @ViewChild(MaterialTemporaryDrawerComponent)
  MaterialTemporaryDrawerComponent materialTemporaryDrawerComponent;

  // Dropdown Select to User Profile and Logout
  List<OptionGroup<AppLayoutSettingSelectOption>> userProfileLogoutGroupOptions = new List();
  SelectionOptions userProfileLogoutOptions;
  SelectionModel userProfileLogoutSingleSelectModel;

  /// Return [true] is authenticated role can access Users
  bool isAuthorizedToAccessUsers;

  /// Return [true] is authenticated role can access Groups
  bool isAuthorizedToAccessGroups;

  /// Return [true] is authenticated role can access Organizations
  bool isAuthorizedToAccessOrganization;

  /// Return [true] is authenticated role can access configuratoin
  bool isAuthorizedToAccessConfiguration;


  AppLayoutComponent(this._appLayoutService, this._authService, this._historyTimelineService, this._router) {

  }

  /// Messages and labels
  static final String insightsLabel =  AppLayoutMsg.label(AppLayoutMsg.ingightsLabel);
  static final String objectivesMapLabel = AppLayoutMsg.label(AppLayoutMsg.objectivesMapLabel);
  static final String objectivesGanttLabel = AppLayoutMsg.label(AppLayoutMsg.objectivesGanttLabel);
  static final String objectivesLabel = AppLayoutMsg.label(AppLayoutMsg.objectivesLabel);
  static final String worksLabel = AppLayoutMsg.label(AppLayoutMsg.worksLabel);
  static final String organizationLabel = AppLayoutMsg.label(AppLayoutMsg.organizationLabel);
  static final String configurationLabel = AppLayoutMsg.label(AppLayoutMsg.configurationLabel);
  static final String usersLabel = AppLayoutMsg.label(AppLayoutMsg.usersLabel);
  static final String adminLabel = AppLayoutMsg.label(AppLayoutMsg.adminLabel);
  static final String superAdminLabel = AppLayoutMsg.label(AppLayoutMsg.superAdminLabel);
  static final String groupsLabel = AppLayoutMsg.label(AppLayoutMsg.groupsLabel);
  static final String workItemsLabel = AppLayoutMsg.label(AppLayoutMsg.workItemsLabel);
  static final String workItemsGanttLabel = AppLayoutMsg.label(AppLayoutMsg.workItemsGanttLabel);

  void onActivate(RouterState previous, RouterState current) async {

    if (_authService.authorizedOrganization == null || _authService.authenticatedUser == null) {
      _router.navigate(AppRoutes.authRoute.toUrl());
      return;
    }

    insightsRouteUrl = AppRoutes.insightsRoute.toUrl();
    objectivesMapRouteUrl = AppRoutes.objectivesMapRoute.toUrl();
    objectivesGanttRouteUrl = AppRoutes.objectivesGanttRoute.toUrl();
    objectivesRouteUrl = AppRoutes.objectivesRoute.toUrl();
    worksRouteUrl = AppRoutes.worksRoute.toUrl();
    workItemsRouteUrl = AppRoutes.workItemsRoute.toUrl();
    workItemsGanttRouteUrl = AppRoutes.workItemsGanttRoute.toUrl();
    usersRouteUrl = AppRoutes.usersRoute.toUrl();
    groupsRouteUrl = AppRoutes.groupsRoute.toUrl();
    organizationRouteUrl =  AppRoutes.organizationRoute.toUrl(parameters: { AppRoutesParam.organizationIdParameter: _authService.authorizedOrganization.id });
  //  historyTimelineRouteUrl = AppRoutes.historyTimelineRoute.toUrl();

    isAuthorizedToAccessUsers =_authService.isAuthorizedForAccessRole(SystemModule.users);
    isAuthorizedToAccessGroups = _authService.isAuthorizedForAccessRole(SystemModule.groups);
    isAuthorizedToAccessOrganization =_authService.isAuthorizedForAccessRole(SystemModule.organization);

    // RIGHT - SETTINGS *** Dropdown select to User Profile and Logout ***
    userProfileLogoutGroupOptions.clear();

    // User Options
    List<AppLayoutSettingSelectOption> userDetailOptions = new List();
    userDetailOptions.add(AppLayoutSettingSelectOption()
      ..group = null
      ..name = AppLayoutMsg.label(AppLayoutMsg.userDetailLabel)
      //..viewComponent = (bool userDetailVisible) { this.userDetailVisible = userDetailVisible; }
      ..routeUrl = AppRoutes.userEditWithAppLayoutParentRoute.toUrl(parameters: {AppRoutesParam.userIdParameter:  _authService.authenticatedUser.id}));
      //TODO incluir paramet user profile ..routeUrl =  AppRoutes.userEditWithAppLayoutParentRoute.toUrl(parameters: _authService.ser);

    userProfileLogoutGroupOptions.add(new OptionGroup.withLabel(userDetailOptions, null));

    // User Logout
    List<AppLayoutSettingSelectOption> logout = new List();
    logout.add(new AppLayoutSettingSelectOption()
      ..group = null
      ..name = AppLayoutMsg.label(AppLayoutMsg.logoutLabel)
      ..routeUrl = AppRoutes.authRoute.toUrl());

    userProfileLogoutGroupOptions.add(OptionGroup.withLabel(logout, null));

    userProfileLogoutOptions = SelectionOptions.withOptionGroups(userProfileLogoutGroupOptions);

    // Model Listening
    userProfileLogoutSingleSelectModel =
    SelectionModel.single()..selectionChanges.listen((d) async {
      if (d != null && d.isNotEmpty && d.first.added.isNotEmpty) {
        if (d.first?.added?.first?.routeUrl != null) {
          await goTo(d.first.added.first.routeUrl, reload: true);
        }
      }
      userProfileLogoutSingleSelectModel.clear();
    });

    // Refresh/update timeline count
    try {
      _historyTimelineService.refreshHistoryCount();
    } catch (e) {
      _appLayoutService.error = e.toString();
      throw e;
    }
  }

  bool get isAdmin {
    return _authService?.isAdmin;
  }

  bool get isSuperAdmin {
    return _authService?.isSuperAdmin;
  }

  String get headerTitle {
    return _appLayoutService.headerTitle;
  }

  String get error {
    return _appLayoutService.error;
  }

  bool isAuthenticated() {
    return (_authService.authenticatedUser != null);
  }

  void goTo(String url, {bool toggle = false, bool reload = false}) {
    if (toggle) drawerToggle();

    if (url != null) {
      if (reload) {
        _router.navigate(url, NavigationParams(reload: reload));
      } else {
        _router.navigate(url);
      }
    }
  }


  bool get hasAuthorizedOrganization {
    return _authService.authorizedOrganization != null;
  }

  ItemRenderer get itemRenderer => (dynamic item) => item.name;
/*
  bool get enabledSearch {
    return _appLayoutService.enabledSearch;
  }
*/
   userUrlImage() {
    return common_service.userUrlImage(_authService.authenticatedUser?.userProfile?.image);
  }

  User get authenticatedUser {
    return _authService.authenticatedUser;
  }

  Organization get authorizedOrganization {
    return _authService.authorizedOrganization;
  }

  void drawerToggle() {
    materialTemporaryDrawerComponent.toggle();
  }
}

class AppLayoutSettingSelectOption {
  String group;
  String name;
  // Organization organization;
  String routeUrl;
 // Function viewComponent;
}