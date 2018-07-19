// Copyright (c) 2018, Levius Tecnologia Ltda. All rights reserved.
// Author: Samuel C. Schwebel.

import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_router/angular_router.dart';

import 'package:auge_shared/model/organization.dart';
import 'package:auge_shared/message/messages.dart';

import 'package:auge_web/src/organization/organization_service.dart';
import 'package:auge_web/src/auth/auth_service.dart';

import 'package:auge_web/services/app_routes.dart';

@Component(
    selector: 'auge-organization-detail',
    providers: const <dynamic>[materialProviders, OrganizationService],
    directives: const [
      coreDirectives,
      routerDirectives,
      materialDirectives,
    ],
    templateUrl: 'organization_detail_component.html',
    styleUrls: const [
      'organization_detail_component.css'
    ])

  class OrganizationDetailComponent implements OnActivate {

    final OrganizationService _organizationService;
    final Location _location;
    final Router _router;
    final AuthService _authService;

    Organization organization = new Organization();

    OrganizationDetailComponent(this._organizationService,  this._router, this._location, this._authService);


    // Define messages and labels
    static final String requiredValueMsg = CommonMessage.requiredValueMsg();
    static final String addOrganizationLabel =  OrganizationMessage.label('Add Organization');
    static final String editOrganizationLabel =  OrganizationMessage.label('Edit Organization');

    static final String nameLabel =  OrganizationMessage.label('Name');
    static final String codeLabel =  OrganizationMessage.label('Code');

    static final String saveButtonLabel = CommonMessage.buttonLabel('Save');
    static final String backButtonLabel = CommonMessage.buttonLabel('Back');

    @override
    Future onActivate(routeStatePrevious, routeStateCurrent) async {

      if (this._authService.authenticatedUser == null) {
        _router.navigate(AppRoutes.authRoute.toUrl());
      }

      if (routeStateCurrent.parameters.isNotEmpty) {
        var uuid = routeStateCurrent.parameters[AppRoutes.organizationIdParameter];
        if (uuid != null && uuid.isNotEmpty) {
          organization = await _organizationService.getOrganizationById(uuid);
        }
      }
    }

    void saveOrganization() {
      _organizationService.saveOrganization(organization);
      goBack();
    }

    void goBack() {
      _location.back();
    }

    bool get validInput {
      return organization.name?.trim()?.isNotEmpty ?? false;
    }
}