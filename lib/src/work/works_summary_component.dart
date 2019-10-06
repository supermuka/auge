// Copyright (c) 2018, Levius Tecnologia Ltda. All rights reserved.
// Author: Samuel C. Schwebel.

import 'package:angular/angular.dart';

import 'package:angular_router/angular_router.dart';

import 'package:angular_components/content/deferred_content.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel_set.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_tooltip/material_tooltip.dart';

import 'package:auge_server/model/work/work.dart';

import 'package:auge_server/shared/message/messages.dart';
// import 'package:auge_web/src/auth/auth_service.dart';
import 'package:auge_web/src/app_layout/app_layout_service.dart';
import 'package:auge_web/src/work/work_service.dart';
import 'package:auge_web/services/common_service.dart' as common_service;
import 'package:auge_web/src/work/work_summary_component.dart';
import 'package:auge_web/services/app_routes.dart';

@Component(
    selector: 'auge-works-summary',
    providers: const [WorkService],
    templateUrl: 'works_summary_component.html',
    styleUrls: const [
      'works_summary_component.css'
    ],
    directives: const [
      coreDirectives,
      routerDirectives,
      DeferredContentDirective,
      MaterialButtonComponent,
      MaterialIconComponent,
      MaterialTooltipDirective,
      MaterialExpansionPanelSet,
      MaterialExpansionPanel,
      WorkSummaryComponent,
    ])

class WorksSummaryComponent with CanReuse implements OnInit {

  final WorkService _workService;
  final Router _router;
 // final AuthService _authService;
  final AppLayoutService _appLayoutService;

  @Input()
  String objectiveId;

  List<Work> works = [];

  WorksSummaryComponent(this._appLayoutService, this._workService,  this._router);

  static final String worksLabel =  WorkMsg.label('Works');
  static final String groupLabel =  WorkMsg.label('Group');
  static final String leaderLabel =  WorkMsg.label('Leader');

  @override
  ngOnInit() async {
    try {
      if (objectiveId != null) {
        works = await _workService.getWorks(
            this._workService.authService.authorizedOrganization.id, objectiveId: objectiveId,
            withWorkItems: true, withProfile: true);
      }
    } catch (e) {
      _appLayoutService.error = e.toString();
      rethrow;
    }
  }

  void goToWorks() {
    _router.navigate(AppRoutes.worksByObjectiveRoute.toUrl(parameters: { AppRoutesParam.objectiveIdParameter:objectiveId}));
  }

  String userUrlImage(String userProfileImage) {
    return common_service.userUrlImage(userProfileImage);
  }
}