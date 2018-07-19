// Copyright (c) 2018, Levius Tecnologia Ltda. All rights reserved.
// Author: Samuel C. Schwebel.

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_forms/angular_forms.dart';
import 'package:angular_components/material_datepicker/module.dart';
import 'package:angular_components/model/date/date.dart';
import 'package:angular_components/utils/browser/window/module.dart';

import 'package:angular_components/model/selection/selection_model.dart';
import 'package:angular_components/model/selection/selection_options.dart';
import 'package:angular_components/model/selection/string_selection_options.dart';
import 'package:angular_components/model/ui/has_factory.dart';

import 'package:auge_shared/model/initiative/initiative.dart';
import 'package:auge_shared/model/initiative/work_item.dart';
import 'package:auge_shared/model/initiative/work_item_check_item.dart';
import 'package:auge_shared/model/user.dart';
import 'package:auge_shared/message/messages.dart';

import 'package:auge_web/services/common_service.dart' as common_service;
import 'package:auge_web/src/auth/auth_service.dart';
import 'package:auge_web/src/initiative/initiative_service.dart';
import 'package:auge_web/src/work_item/work_item_service.dart';
import 'package:auge_web/src/user/user_service.dart';

import 'package:auge_web/services/app_routes.dart';

// ignore_for_file: uri_has_not_been_generated
import 'work_item_detail_component.template.dart' as work_item_detail_component;

@Component(
    selector: 'auge-work-item-detail',
    providers: const [WorkItemService, UserService, windowBindings, datepickerBindings],
    directives: const [
      coreDirectives,
      routerDirectives,
      materialDirectives,
      formDirectives,
    ],
    templateUrl: 'work_item_detail_component.html',
    styleUrls: const [
      'work_item_detail_component.css'
    ])

class WorkItemDetailComponent implements OnActivate  {

  final AuthService _authService;
  final UserService _userService;
  final InitiativeService _initiativeService;
  final WorkItemService _workItemService;
  final Router _router;
  final Location _location;

  Initiative initiative;
  WorkItem workItem = new WorkItem();

  String memberInputText = '';
  SelectionOptions memberOptions;
  SelectionOptions stageOptions;
  SelectionModel memberSingleSelectModel;
  SelectionModel stageSingleSelectModel;

  String leadingGlyph = 'search';

  String emptyPlaceholder = 'No match';

  List<User> memberUsers = new List();

  String errorCompleted;

  DateRange limitToDueDateRange =
  new DateRange(new Date.today().add(years: -1), new Date.today().add(years: 1));

  WorkItemCheckItem selectedCheckItem;
  String checkItemEntry;

  WorkItemDetailComponent(this._authService, this._userService, this._initiativeService, this._workItemService, this._router, this._location)  {

    initializeDateFormatting(Intl.defaultLocale , null);

  }

  // Define messages and labels
  static final String requiredValueMsg =  CommonMessage.requiredValueMsg();
  static final String addWorkItemLabel =  WorkItemMessage.label('Add Work Item');
  static final String editWorkItemLabel =  WorkItemMessage.label('Edit Work Item');

  static final String nameLabel =  WorkItemMessage.label('Name');
  static final String descriptionLabel =  WorkItemMessage.label('Description');
  static final String dueDateLabel =  WorkItemMessage.label('Due Date');
  static final String completedLabel =  WorkItemMessage.label('Completed');
  static final String stageLabel =  WorkItemMessage.label('Stage');
  static final String noMatchLabel =  WorkItemMessage.label('No Match');
  static final String assignedToLabel =  WorkItemMessage.label('Assigned To');
  static final String checkItemLabel =  WorkItemMessage.label('Check Item');

  static final String saveButtonLabel = CommonMessage.buttonLabel('Save');
  static final String backButtonLabel = CommonMessage.buttonLabel('Back');


  @override
  Future onActivate(RouterState previous, RouterState current) async {
    if (this._authService.authenticatedUser == null) {
      _router.navigate(AppRoutes.authRoute.toUrl());
    }


    String initiativeId = _router.current.parameters[AppRoutes
        .initiativeIdParameter];

    if (initiativeId != null) {
      initiative = await _initiativeService.getInitiativeById(initiativeId, withWorkItems: false);
    }

    String id = _router.current.parameters[AppRoutes.workItemIdParameter];
    if (id != null) {
      workItem = await _workItemService.getWorkItemById(id);
    }

    List<User> users = await _userService.getUsersByOrganizationId(_authService.selectedOrganization?.id, withProfile: true);

    memberOptions = new StringSelectionOptions<User>(
        users, toFilterableString: (User user) => user.name);

    memberSingleSelectModel =
    new SelectionModel.single()
      ..selectionChanges.listen((member) {

        if (member.isNotEmpty && member.first.added != null && member.first.added.length != 0 && member.first.added?.first != null) {
          if (!workItem.assignedTo.contains(member.first.added.first)) {
            workItem.assignedTo.add(member.first.added.first);
          }
        }
      });


    if (initiative.stages != null && initiative.stages.isNotEmpty) {
      stageOptions = new SelectionOptions.fromList( initiative.stages );

      stageSingleSelectModel =
      new SelectionModel.single()
        ..selectionChanges.listen((es) {
          if (es.isNotEmpty && es.first.added != null &&
              es.first.added.length != 0 && es.first.added.first != null) {
            workItem.stage = es.first.added.first;
          }
        });

      if  (workItem.stage == null) {
        workItem.stage = initiative.stages.first;
        stageSingleSelectModel.select(workItem.stage);
      }
    }
  }

  removeMember(User user) {
    workItem.assignedTo.remove(user);
  }

  Future<Null> save() async {
    await _workItemService.saveWorkItem(initiative.id, workItem);
    goBack();
  }


  void goBack() {
    _location.back();
  }

  String get memberLabelRenderer {
    String nameLabel;
    if ((memberSingleSelectModel != null &&
        memberSingleSelectModel.selectedValues != null &&
        memberSingleSelectModel.selectedValues.length != null)) {

      nameLabel = memberSingleSelectModel.selectedValues.first?.name;
    }

    return nameLabel;
  }

  ItemRenderer get memberItemRenderer => (dynamic user) => user.name;

  Date get dueDate {
    Date _dueDate;
    if (workItem.dueDate != null) {
      _dueDate = new Date.fromTime(workItem.dueDate);
    }
    return _dueDate;
  }

  set dueDate(Date _dueDate) {
    workItem.dueDate = _dueDate.asUtcTime();
  }

  int get completed {
    return workItem.completed;
  }

  void set completed(int completed) {
    if (completed != null && !(completed >= 0 && completed <= 100)) {
      errorCompleted = 'O percentual deve ficar entre 0 e 100';
    } else {
      errorCompleted = null;
      workItem.completed = completed;
    }
  }

  FactoryRenderer get factoryRenderer => (_) => work_item_detail_component.MemberRendererComponentNgFactory;

  // Label for the button for single selection.
  String get stageSingleSelectLabel {
    String nameLabel;
    if ((stageSingleSelectModel != null) &&
        (stageSingleSelectModel.selectedValues != null) &&
        (stageSingleSelectModel.selectedValues.length > 0)) {

        nameLabel = stageSingleSelectModel.selectedValues.first?.name;
    } else {
      nameLabel = WorkItemMessage.label('Select a value');
    }
    return nameLabel ;
  }

  ItemRenderer get stageItemRenderer => (dynamic stage) => stage.name;

  String userUrlImage(User userMember) {
    return common_service.userUrlImage(userMember);
  }

  void selectCheckItem(WorkItemCheckItem checkItem) {
    selectedCheckItem = checkItem;
    checkItemEntry = checkItem.name;

  }

  void addCheckItem() {

    workItem.checkItems.add(new WorkItemCheckItem()
      ..name = checkItemEntry
      ..index = workItem.checkItems.length);
    workItem.checkItems.sort((a, b) =>
        a?.index?.compareTo(b?.index));

    checkItemEntry = '';
  }

  void removeCheckItem(WorkItemCheckItem checkItem) {
    workItem.checkItems.remove(checkItem);
  }

  void updateCheckItem(WorkItemCheckItem checkItem) {

    workItem.checkItems.elementAt(workItem.checkItems.indexOf(checkItem))
        ..name = checkItemEntry;
  }

  bool get validInput {
    return workItem.name?.trim()?.isNotEmpty ?? false;
  }
}

@Component(
    selector: 'member-renderer',
    template: '<div left-icon class="avatar-icon" [style.background-image]="disPlayurl"></div>{{disPlayName}}',

    styles: const [
      ''
    ],
    directives: const [
      MaterialIconComponent
    ])

class MemberRendererComponent implements RendersValue {
  String disPlayName = '';
  String disPlayurl;

  @override
  set value(newValue) {
    disPlayName = (newValue as User).name;
    disPlayurl = 'url(' + common_service.userUrlImage((newValue as User))  + ')';
  }
}