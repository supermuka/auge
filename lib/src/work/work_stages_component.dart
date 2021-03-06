// Copyright (c) 2018, Levius Tecnologia Ltda. All rights reserved.
// Author: Samuel C. Schwebel.

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:auge_web/route/app_routes.dart';

import 'package:angular_components/focus/focus.dart';
import 'package:angular_components/laminate/components/modal/modal.dart';
import 'package:angular_components/laminate/overlay/module.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel_set.dart';
import 'package:angular_components/material_input/material_input.dart';

import 'package:angular_components/model/menu/menu.dart';
import 'package:angular_components/material_menu/material_menu.dart';
import 'package:angular_components/material_dialog/material_dialog.dart';
import 'package:angular_components/model/action/async_action.dart';
import 'package:angular_components/material_select/material_dropdown_select.dart';
import 'package:angular_components/material_select/dropdown_button.dart';
import 'package:angular_components/material_select/material_dropdown_select_accessor.dart';
import 'package:angular_components/model/selection/selection_model.dart';
import 'package:angular_components/model/selection/selection_options.dart';
import 'package:angular_components/model/selection/string_selection_options.dart';
import 'package:angular_components/model/ui/has_factory.dart';

import 'package:auge_shared/domain/work/work.dart';
import 'package:auge_shared/domain/work/work_stage.dart';

import 'package:auge_web/services/common_service.dart';
import 'package:auge_web/src/work/work_service.dart';

import 'package:auge_shared/message/messages.dart';
import 'package:auge_shared/message/domain_messages.dart';

// ignore_for_file: uri_has_not_been_generated
import 'work_stages_component.template.dart' as work_stages_component;

@Component(
    selector: 'auge-work-stages',
    providers: [overlayBindings, WorkService],
    templateUrl: 'work_stages_component.html',
    styleUrls: const [
      'work_stages_component.css'
    ],
    directives: const [
      coreDirectives,
      materialInputDirectives,
      AutoFocusDirective,
      ModalComponent,
      MaterialDialogComponent,
      MaterialExpansionPanel,
      MaterialExpansionPanelSet,
      MaterialIconComponent,
      MaterialButtonComponent,
      MaterialMenuComponent,
      MaterialDropdownSelectComponent,
      DropdownSelectValueAccessor,
      DropdownButtonComponent,
    ],
  /*  pipes: const [commonPipes], */
   )

class WorkStagesComponent implements /* OnInit, */ OnActivate, OnDeactivate {

  final WorkService _workService;
  final Location _location;

  bool modalVisible = false;

  Work work;
  List<WorkStage> workStages;

  bool editable;

  WorkStage selectedWorkStage;

  String showStartValueErrorMsg;
  String showCurrentValueErrorMsg;
  String showEndValueErrorMsg;

  MenuModel<MenuItem> menuModel;

  SelectionOptions stateOptions;
  SelectionModel<State> stateSingleSelectModel;

  List<State> _states;

  WorkStagesComponent(this._workService, this._location) {

    stateSingleSelectModel = SelectionModel.single()
      ..selectionChanges.listen((es) {
        if (selectedWorkStage != null && es.isNotEmpty && es.first.added != null &&
            es.first.added.length != 0 && es.first.added.first != null) {
          selectedWorkStage.stateIndex = es.first.added.first.index;
        }
      });
  }

  // Define messages and labels
  static final String workStagesLabel = StageMsg.label(StageMsg.workStagesLabel);
  static final String stageLabel =  StageMsg.label(StageMsg.stageLabel);

  static final String saveButtonLabel = CommonMsg.buttonLabel(CommonMsg.saveButtonLabel);
  static final String cancelButtonLabel = CommonMsg.buttonLabel(CommonMsg.cancelButtonLabel);
  static final String closeButtonLabel = CommonMsg.buttonLabel(CommonMsg.closeButtonLabel);
  static final String selectLabel =  CommonMsg.label(CommonMsg.selectLabel);

  static final String nameLabel =  WorkStageDomainMsg.fieldLabel(WorkStage.nameField);
  static final String stateLabel =  WorkStageDomainMsg.fieldLabel(WorkStage.stateIndexField);

  static final String stateNotInfomedMsg =  StageMsg.stateNotInfomedMsg();

  @override
  void onActivate(RouterState previous, RouterState current) async {
    modalVisible = true;

    String workId;
    if (current.parameters.containsKey(AppRoutesParam.workIdParameter)) {
      workId = current.parameters[AppRoutesParam.workIdParameter];
    }

    if (workId != null) {
      work = await _workService.getWorkOnlySpecification(workId);
      workStages = await _workService.getWorkStages(workId);
    } else {
      throw Exception('Work Id not found.');
    }

    // _states =  await _workService.getStates();
    _states = State.values;

    // List<State> states =  await _workService.getStates();

    stateOptions = new StringSelectionOptions<State>(
        _states, toFilterableString: (State state) => StateMsg.label(state.toString()));

    if (stateOptions.optionsList.isNotEmpty) {
      stateSingleSelectModel.select(stateOptions.optionsList.first);
    }
  }

  @override
  void onDeactivate(RouterState current, RouterState next) {
    modalVisible = false;
  }

  // Label for the button for single selection.
  String get stateSingleSelectLabel {
    String nameLabel;
    if ((stateSingleSelectModel != null) &&
        (stateSingleSelectModel.selectedValues != null) &&
        (stateSingleSelectModel.selectedValues.length > 0)) {
      nameLabel = StateMsg.label(stateSingleSelectModel.selectedValues.first?.toString());
    } else {
      nameLabel = selectLabel;
    }
    return nameLabel;
  }
/*
  void selectionChangeState(Stream<State> stream) async {
    print ((await stream.first).name);
  }
*/
  void cancelWorkStage(WorkStage workStage, AsyncAction event) async {

    try {
      if (workStage.id == null) {
        workStages.remove(workStage);
      } else {
        workStages[workStages.indexOf(workStage)] = await _workService.getWorkStage(workStage.id);
      }
     // _sortMeasurePregressesOrderByDate(measureProgresses);
    } on Exception {
      event.cancel();
      rethrow;
    }
  }

  void saveWorkStage(WorkStage workStage, AsyncAction event) async {

    if (workStage.stateIndex == null) {
      dialogError = stateNotInfomedMsg;
      event.cancel();
    } else {
      try {

        if (workStage.index == null) {
          int lastIndexIntoStage = 0;
          for (int i = 0;i < workStages.length;i++) {
            if (workStage.stateIndex == workStages[i].stateIndex && workStages[i].index != null && lastIndexIntoStage < workStages[i].index) {
              lastIndexIntoStage = workStages[i].index;
            }
          }
          workStage.index = lastIndexIntoStage + 1;
        }

        String stageId = await _workService.saveStage(/*
            work, */ workStage);
        // Returns a new instance to get the generated data on the server side as well as having the last update.
        WorkStage newWorkStage = await _workService.getWorkStage(stageId);
        //  }

        int index = workStages.indexWhere((t) => t.id == newWorkStage.id);
        if (index != -1) {
          workStages[index] = newWorkStage;
        } else {
          workStages.add(newWorkStage);
        }
        // stages = await _workService.getStages(selectedWork.id);
        _sortStages();

      } catch (e) {
        dialogError = e.toString();
        event.cancel();
        rethrow;
      }
    }
  }

  void selectWorkStage(WorkStage workStage) async {
    if (workStage == null) {
      workStages.insert(0, WorkStage()..stateIndex = State.notStarted.index..work = Work()..work.id = work.id);
      selectedWorkStage = workStages.first;
  //    selectedStage.index = stages.length;
   //   selectedMeasureProgress.date = DateTime.now();
    } else {
      // Get a new instance to doesn't referenced the other.
      selectedWorkStage = workStage;
    }

  }

  /// Call a delete
  void deleteWorkStage(WorkStage workStage) async {
    try {
      await _workService.deleteWorkStage(workStage);

      workStages = await _workService.getWorkStages(work.id);

      // stages.remove(stage);

    } catch (e) {
      rethrow;
    }
  }


  set dialogError(String errorMsg) {
    error = errorMsg;
  }

  String get dialogError {
    return error;
  }

  // Order by State.index and Stage.index
  void _sortStages() {
    // measureProgresses.sort((a, b) => a?.date == null || b?.date == null ? -1 : a.date.compareTo(b.date));
    workStages.sort((a, b) => a.index.compareTo(b.index));
    workStages.sort((a, b) => a.stateIndex.compareTo(b.stateIndex));
  }

/*
  bool get validStageInput {
    return (selectedWorkStage.name.isNotEmpty && stateSingleSelectModel != null && stateSingleSelectModel.selectedValues.isNotEmpty && stateSingleSelectModel.selectedValues.first.index != null);
  }
*/
  void moveUpWorkStage(WorkStage workStage) async {
    int i = workStages.indexOf(workStage);

    if (i > 0 && workStage.stateIndex == workStages[i-1].stateIndex ) {
      // Receive state equals previous stage, because can be different that the actual
   //   stage.state = stages[i-1].state;

      ++workStages[i-1].index;
      await _workService.saveStage(/* work, */workStages[i-1]);

      --workStages[i].index;
      await _workService.saveStage(/* work, */ workStages[i]);

      workStages = await _workService.getWorkStages(work.id);
      //stages.removeAt(i);
      //stages.insert(i-1, stage);
      //_sortStages();

    }
  }

  void moveDownWorkStage(WorkStage workStage) async {
    int i = workStages.indexOf(workStage);
    if (i < workStages.length-1 && workStage.stateIndex == workStages[i+1].stateIndex) {

      // Receive state equals previous stage, because can be different that the actual
      --workStages[i+1].index;
      await _workService.saveStage(/* work, */ workStages[i+1]);

      ++workStages[i].index;
      await _workService.saveStage(/* work, */ workStages[i]);

      workStages = await _workService.getWorkStages(work.id);
      //stages.removeAt(i);
      //stages.insert(i+1, stage);
    }
  }

  bool disableUpWorkStage(WorkStage workStage) {
    int firstIndexIntoWorkStage = -1;
    for (int i = 0;i < workStages.length;i++) {
      if (workStage.stateIndex != null && workStage.stateIndex == workStages[i].stateIndex && workStages[i].index != null && ( firstIndexIntoWorkStage == -1 || firstIndexIntoWorkStage > workStages[i].index )) {
        firstIndexIntoWorkStage = workStages[i].index;
      }
    }
    return (firstIndexIntoWorkStage == workStage.index);
  }

  bool disableDownWorkStage(WorkStage workStage) {
    int lastIndexIntoStage = 0;
    for (int i = 0;i < workStages.length;i++) {
      if (workStage.stateIndex != null && workStage.stateIndex == workStages[i].stateIndex && workStages[i].index != null && ( lastIndexIntoStage < workStages[i].index )) {
        lastIndexIntoStage = workStages[i].index;
      }
    }
    return (lastIndexIntoStage == workStage.index);
  }

  void close() {
    _location.back();
  }

  ItemRenderer get stateItemRenderer => (dynamic state) => StateMsg.label(state.toString());

  FactoryRenderer get stateFactoryRenderer => (_) => work_stages_component.StateRendererComponentNgFactory;

  String stateHslColor(int stateIndex) => WorkService.getStateHslColor(stateIndex);

  String stateName(int stateIndex) => StateMsg.label(State.values[stateIndex].toString());

}

@Component(
    selector: 'state-renderer',
    //  template: '<material-icon icon="language"></material-icon>{{disPlayName}}',
    template: '<div><span [style.background-color]="disPlayCor">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;{{disPlayName}}</div>',
    styles: const [
      ''
    ],
    directives: const [
      MaterialIconComponent
    ])
class StateRendererComponent implements RendersValue {
  String disPlayName = '';
  String disPlayCor;

  @override
  set value(newValue) {
    disPlayName = StateMsg.label((newValue as State).toString());
    disPlayCor = 'hsl(${WorkService.getStateHslColor((newValue as State).index)})';
  }
}