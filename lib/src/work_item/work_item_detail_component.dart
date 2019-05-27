// Copyright (c) 2018, Levius Tecnologia Ltda. All rights reserved.
// Author: Samuel C. Schwebel.

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_components/focus/focus.dart';
import 'package:angular_components/laminate/components/modal/modal.dart';
import 'package:angular_components/laminate/popup/module.dart';
import 'package:angular_components/laminate/overlay/module.dart';
import 'package:angular_components/material_dialog/material_dialog.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_button/material_fab.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_select/material_dropdown_select.dart';
import 'package:angular_components/model/selection/selection_model.dart';
import 'package:angular_components/model/selection/selection_options.dart';
import 'package:angular_components/model/selection/string_selection_options.dart';
import 'package:angular_components/model/ui/has_factory.dart';
import 'package:angular_components/material_select/dropdown_button.dart';
import 'package:angular_components/material_select/material_dropdown_select_accessor.dart';
import 'package:angular_components/material_datepicker/module.dart';
import 'package:angular_components/model/date/date.dart';
import 'package:angular_components/utils/browser/window/module.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_input/material_auto_suggest_input.dart';
import 'package:angular_components/material_input/material_number_accessor.dart';
import 'package:angular_components/focus/focus_item.dart';
import 'package:angular_components/focus/focus_list.dart';
import 'package:angular_components/material_list/material_list.dart';
import 'package:angular_components/material_list/material_list_item.dart';
import 'package:angular_components/material_select/material_select_item.dart';
import 'package:angular_components/material_checkbox/material_checkbox.dart';
import 'package:angular_components/material_chips/material_chip.dart';
import 'package:angular_components/material_chips/material_chips.dart';
import 'package:angular_components/material_datepicker/material_datepicker.dart';

import 'package:auge_server/model/initiative/initiative.dart';
import 'package:auge_server/model/initiative/work_item.dart';
import 'package:auge_server/model/general/user.dart';

import 'package:auge_web/message/messages.dart';
import 'package:auge_web/message/model_messages.dart';

import 'package:auge_web/services/common_service.dart' as common_service;
import 'package:auge_web/src/work_item/work_item_service.dart';
import 'package:auge_web/src/user/user_service.dart';

// ignore_for_file: uri_has_not_been_generated
import 'work_item_detail_component.template.dart' as work_item_detail_component;

@Component(
    selector: 'auge-work-item-detail',
    providers: const [popupBindings, overlayBindings, windowBindings, datepickerBindings, WorkItemService, UserService],
    directives: const [
      coreDirectives,
      routerDirectives,
      materialInputDirectives,
      materialNumberInputDirectives,
      MaterialAutoSuggestInputComponent,
      AutoFocusDirective,
      MaterialDialogComponent,
      ModalComponent,
      MaterialButtonComponent,
      MaterialFabComponent,
      MaterialIconComponent,
      MaterialDropdownSelectComponent,
      DropdownSelectValueAccessor,
      DropdownButtonComponent,
      FocusItemDirective,
      FocusListDirective,
      MaterialListComponent,
      MaterialListItemComponent,
      MaterialSelectItemComponent,
      MaterialCheckboxComponent,
      MaterialChipsComponent,
      MaterialChipComponent,
      MaterialDatepickerComponent,
    ],
    templateUrl: 'work_item_detail_component.html',
    styleUrls: const [
      'work_item_detail_component.css'
    ])

class WorkItemDetailComponent implements OnInit  {

  final UserService _userService;
  final WorkItemService _workItemService;

  @Input()
  Initiative initiative;

  @Input()
  String selectedWorkItemId;

  final _closeController = new StreamController<void>.broadcast(sync: true);

  /// Publishes events when close.
  @Output()
  Stream<void> get close => _closeController.stream;

  final _saveController = new StreamController<WorkItem>.broadcast(sync: true);

  /// Publishes events when save.
  @Output()
  Stream<WorkItem> get save => _saveController.stream;

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
  new DateRange(new Date.today().add(years: -1), new Date.today().add(years: 10));

  WorkItemCheckItem selectedCheckItem;
  String checkItemEntry;

  List<User> _users;

  /// When it exists, the error/exception message presented into dialog view.
  String dialogError;

  WorkItemDetailComponent(this._userService, this._workItemService)  {

    initializeDateFormatting(Intl.defaultLocale , null);
    memberSingleSelectModel = SelectionModel.single();

  }

  // Define messages and labels
  static final String requiredValueMsg =  CommonMsg.requiredValueMsg();
  static final String saveButtonLabel = CommonMsg.buttonLabel('Save');
  static final String closeButtonLabel = CommonMsg.buttonLabel('Close');
  static final String addWorkItemLabel =  WorkItemMsg.label('Add Work Item');
  static final String editWorkItemLabel =  WorkItemMsg.label('Edit Work Item');
  static final String noMatchLabel =  WorkItemMsg.label('No Match');

  static final String nameLabel =  FieldMsg.label('${WorkItem.className}.${WorkItem.nameField}');
  static final String descriptionLabel =  FieldMsg.label('${WorkItem.className}.${WorkItem.descriptionField}');
  static final String dueDateLabel =  FieldMsg.label('${WorkItem.className}.${WorkItem.dueDateField}');
  static final String completedLabel =  FieldMsg.label('${WorkItem.className}.${WorkItem.completedField}');
  static final String stageLabel =  FieldMsg.label('${WorkItem.className}.${WorkItem.stageField}');
  static final String assignedToLabel =  FieldMsg.label('${WorkItem.className}.${WorkItem.assignedToField}');
  static final String checkItemLabel =  FieldMsg.label('${WorkItem.className}.${WorkItem.checkItemsField}');

  @override
  void ngOnInit() async {

    // Clone the object to have an intermediate
    workItem = WorkItem(); // need to create, because the angular throws a exception if the query delay.
    if (selectedWorkItemId != null) {
      workItem = await _workItemService.getWorkItem(selectedWorkItemId);
    }

    //List<User> users = await _userService.getUsers(_authService.selectedOrganization?.id, withProfile: true);
    try {
      _users = await _userService.getUsers(_userService.authService.authorizedOrganization.id, withProfile: true);
    } catch (e) {
      dialogError = e.toString();
      rethrow;
    }

    memberOptions = new StringSelectionOptions<User>(
        _users, toFilterableString: (User user) => user.name);


    memberSingleSelectModel.selectionChanges.listen((member) {

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

      if (workItem.stage == null) {
        workItem.stage = initiative.stages.first;
      }
      stageSingleSelectModel.select(workItem.stage);
    }
  }

  removeMember(User user) {
    workItem.assignedTo.remove(user);
  }

  void saveWorkItem() {
    try {
      _workItemService.saveWorkItem(initiative.id, workItem);
      _saveController.add(workItem);

      closeDetail();
    } catch (e) {
      dialogError = e.toString();
      rethrow;
    }
  }

  void closeDetail() {
    _closeController.add(null);
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
    if (_dueDate == null) {
      workItem.dueDate = null;
    } else {
      workItem.dueDate = _dueDate.asUtcTime();
    }
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
      nameLabel = WorkItemMsg.label('Select a value');
    }
    return nameLabel ;
  }

  ItemRenderer get stageItemRenderer => (dynamic stage) => stage.name;

  String userUrlImage(User userMember) {
    return common_service.userUrlImage(userMember?.userProfile?.image);
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

  bool get validCheckItemInput {
    return (checkItemEntry != null && checkItemEntry.isNotEmpty);
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
    disPlayurl = 'url(' + common_service.userUrlImage((newValue as User)?.userProfile?.image)  + ')';
  }
}