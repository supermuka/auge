// Copyright (c) 2018, Levius Tecnologia Ltda. All rights reserved.
// Author: Samuel C. Schwebel.

import 'package:angular/angular.dart';

import 'package:angular_components/focus/keyboard_only_focus_indicator.dart';
import 'package:angular_components/laminate/enums/alignment.dart';
import 'package:angular_components/material_tooltip/material_tooltip.dart';

import 'package:auge_shared/domain/work/work_stage.dart';

import 'package:auge_web/src/work/work_service.dart';

import 'package:auge_shared/message/messages.dart';

@Component(
    selector: 'auge-work-summary',
    templateUrl: 'work_summary_component.html',
    styleUrls: const [
      'work_summary_component.css'
    ],
    directives: const [
      coreDirectives,
      ClickableTooltipTargetDirective,
      KeyboardOnlyFocusIndicatorDirective,
      MaterialTooltipDirective,
      MaterialPaperTooltipComponent,
    ])
class WorkSummaryComponent {

  static final int progressBarWidth = 360;
  final preferredTooltipPositions = const [RelativePosition.OffsetBottomLeft, RelativePosition.OffsetBottomRight];

 // @Input()
 // Work work;

  @Input()
  int workItemsCount;

  @Input()
  int workItemsOverDueCount;

  @Input()
  Map<State, int> stateWorkItemsCount = {};

  @Input()
  Map<WorkStage, int> stageWorkItemsCount = {};

  // Define messages and labels
  static final String workItemsOverDueLabel =  WorkMsg.label(WorkMsg.workItemsOverDueLabel);
  static final String workItemsLabel = WorkItemMsg.label(WorkItemMsg.workItemsLabel);

  String circleColor()  {
    String color;

    if (workItemsOverDueCount == 0) {
      color =  '#0f9d58'; // $mat-green-500: #0f9d58; // 'hsl(120, 100%, 50%)';
    } else if (workItemsOverDueCount < workItemsCount)
      color = '#ffc107'; // $mat-amber-500: #ffc107; // 'hsl(45, 100%, 50%)';
    else {
      color = '#db4437'; // $mat-red-500: #db4437; // 'hsl(0, 100%, 50%)';
    }
    return color;
  }

  String widthState(int stateWorkItemsCount) {
    return (stateWorkItemsCount / workItemsCount * progressBarWidth).toString();
  }

  String stateHslColor(int stateIndex) => WorkService.getStateHslColor(stateIndex);

  String stateName(int stateIndex) => StateMsg.label(State.values[stateIndex].toString());

}