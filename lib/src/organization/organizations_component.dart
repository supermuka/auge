// Copyright (c) 2018, Levius Tecnologia Ltda. All rights reserved.
// Author: Samuel C. Schwebel.

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_components/material_button/material_fab.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_menu/material_menu.dart';
import 'package:angular_components/model/ui/icon.dart';
import 'package:angular_components/model/menu/menu.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel_set.dart';
import 'package:angular_components/material_tooltip/material_tooltip.dart';

import 'package:auge_server/model/general/organization.dart';

import 'package:auge_web/message/messages.dart';
import 'package:auge_web/src/organization/organization_service.dart';
import 'package:auge_web/services/app_routes.dart';
import 'package:auge_web/src/auth/auth_service.dart';
import 'package:auge_web/src/app_layout/app_layout_service.dart';
import 'package:auge_web/src/search/search_service.dart';

// ignore_for_file: uri_has_not_been_generated
import 'package:auge_web/src/organization/organization_detail_component.template.dart' as organization_detail_component;

@Component(
    selector: 'auge-organizations',
    providers: const <dynamic>[OrganizationService],
    templateUrl: 'organizations_component.html',
    styleUrls: const [
      'organizations_component.css'
    ],
    directives: const [
      coreDirectives,
      routerDirectives,
      MaterialExpansionPanel,
      MaterialExpansionPanelSet,
      MaterialTooltipDirective,
      MaterialFabComponent,
      MaterialIconComponent,
      MaterialMenuComponent,
    ])

class OrganizationsComponent extends Object implements OnActivate, OnDestroy  {

  final AuthService _authService;
  final AppLayoutService _appLayoutService;
  final OrganizationService _organizationService;
  final SearchService _searchService;
  final Router _router;

  final List<RouteDefinition> routes = [
    new RouteDefinition(
      routePath: AppRoutes.groupAddRoute,
      component: organization_detail_component.OrganizationDetailComponentNgFactory,
    ),
    new RouteDefinition(
      routePath: AppRoutes.groupEditRoute,
      component: organization_detail_component.OrganizationDetailComponentNgFactory,
    ),
  ];

  /// When it exists, the error/exception message presented into view.
  String error;

  bool detailVisible = false;

  List<Organization> _organizations;

  Organization selectedOrganization;

  MenuModel<MenuItem> menuModel;

  OrganizationsComponent(this._authService, this._appLayoutService, this._organizationService, this._searchService, this._router) {

    menuModel = new MenuModel([new MenuItemGroup([new MenuItem(CommonMsg.buttonLabel('Edit'), icon: new Icon('edit') , action: () => goToDetail()), new MenuItem(CommonMsg.buttonLabel('Delete'), icon: new Icon('delete'), action: () => delete())])], icon: new Icon('menu'));
  }

  void onActivate(RouterState previous, RouterState current) async {

    if (_authService.authorizedOrganization == null || _authService.authenticatedUser == null) {
      _router.navigate(AppRoutes.authRoute.toUrl());
      return;
    }

    _appLayoutService.headerTitle =
         OrganizationMsg.label('Organizations');

    try {
      _organizations = await _organizationService.getOrganizations();

    } catch (e) {
      _appLayoutService.error = e.toString();
      rethrow;
    }

    // Enable Input Search on Header App
    _appLayoutService.enabledSearch = true;
  }

  @override
  void ngOnDestroy() {
    _appLayoutService.enabledSearch = false;
  }

  /// Return [Organizations] that corresponds to Search Term
  List<Organization> get organizations {
    return _searchService?.searchTerm.toString().isEmpty ? _organizations : _organizations.where((t) => t.name.contains(_searchService.searchTerm)).toList();
  }

  void selectOrganization(Organization organization) {
    selectedOrganization = organization;
  }

  void delete() {
    try {
      _organizationService.deleteOrganization(selectedOrganization);
      _organizations.remove(selectedOrganization);
    } catch (e) {
      _appLayoutService.error = e.toString();
      rethrow;
    }
  }

  void goToDetail() {
    if (selectedOrganization == null) {
      _router.navigate(AppRoutes.organizationAddRoute.toUrl());

    } else {
      _router.navigate(AppRoutes.organizationEditRoute.toUrl(parameters: { AppRoutesParam.organizationIdParameter: selectedOrganization.id }));
    }
  }

}