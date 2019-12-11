// Copyright (c) 2018, Levius Tecnologia Ltda. All rights reserved.
// Author: Samuel C. Schwebel.

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:angular/angular.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
//import 'package:angular_components/content/deferred_content.dart';

import 'package:auge_server/domain/general/user.dart';
import 'package:auge_server/domain/general/history_item.dart';
import 'package:auge_server/domain/general/authorization.dart';

import 'package:auge_web/services/common_service.dart' as common_service;
import 'package:auge_server/shared/message/messages.dart';
import 'package:auge_server/shared/message/domain_messages.dart';

import 'package:auge_web/src/history_timeline/history_item_timeline_detail_component.dart';

import 'package:auge_web/src/auth/auth_service.dart';
import 'package:auge_web/src/history_timeline/history_timeline_service.dart';
export 'package:auge_web/src/history_timeline/history_timeline_service.dart';

@Component(
    selector: 'auge-history-timeline',
    templateUrl: 'history_timeline_component.html',
    styleUrls: const [
      'history_timeline_component.css'
    ],
    providers: const [],
    directives: const [
      coreDirectives,
      MaterialExpansionPanel,
      MaterialButtonComponent,
      MaterialIconComponent,
    //  DeferredContentDirective,
      HistoryItemTimelineDetailComponent,
    ],
    pipes:   const [DatePipe],)

class HistoryTimelineComponent /* extends Object implements OnInit  */ {

  final HistoryTimelineService _historyTimelineService;

  Map<HistoryItem, bool> expandedControl = Map();

  HistoryTimelineComponent(this._historyTimelineService) {
    initializeDateFormatting(Intl.defaultLocale , null);
  }

  static final String timelineLabel = TimelineItemdMsg.label(TimelineItemdMsg.timelineLabel);
  static final String theLabel = TimelineItemdMsg.label(TimelineItemdMsg.theLabel);
  static final String dayAgoLabel =  TimelineItemdMsg.label(TimelineItemdMsg.dayAgoLabel);
  static final String daysAgoLabel =  TimelineItemdMsg.label(TimelineItemdMsg.daysAgoLabel);
  static final String hourAgoLabel =  TimelineItemdMsg.label(TimelineItemdMsg.hourAgoLabel);
  static final String hoursAgoLabel =  TimelineItemdMsg.label(TimelineItemdMsg.hoursAgoLabel);
  static final String minuteAgoLabel =  TimelineItemdMsg.label(TimelineItemdMsg.minuteAgoLabel);
  static final String minutesAgoLabel =  TimelineItemdMsg.label(TimelineItemdMsg.minutesAgoLabel);
  static final String secondAgoLabel =  TimelineItemdMsg.label(TimelineItemdMsg.secondAgoLabel);
  static final String secondsAgoLabel =  TimelineItemdMsg.label(TimelineItemdMsg.secondsAgoLabel);

  get history => _historyTimelineService.history;

  // List<TimelineItem> get timeline => objective.timeline;
  String userUrlImage(User user) {
    return common_service.userUrlImage(user.userProfile?.image);
  }

  String systemFunctionInPastLabel(int systemFunctionIndex) {
    return SystemFunctionMsg.inPastLabel(SystemFunction.values[systemFunctionIndex].toString());
  }

  String classNameLabel(String className) {
    return ClassNameMsg.label(className);
  }

  DateTime get currentDateTime => _historyTimelineService.currentDateTime;

  String elapsedTime(DateTime timelineItemDateTime, DateTime currentDateTime) {
    String elapsedTime;
    if (timelineItemDateTime != null && currentDateTime != null) {
      Duration duration = currentDateTime.difference(timelineItemDateTime);

      if (duration.inDays != 0) {
        if (duration.inDays == 1) {
          elapsedTime = '${duration.inDays.toString()} ${dayAgoLabel}';
        } else {
          elapsedTime = '${duration.inDays.toString()} ${daysAgoLabel}';
        }
      } else if (duration.inHours != 0) {
        if (duration.inHours == 1) {
          elapsedTime = '${duration.inHours.toString()} ${hourAgoLabel}';
        } else {
          elapsedTime = '${duration.inHours.toString()} ${hoursAgoLabel}';
        }
      } else if (duration.inMinutes != 0) {
        if (duration.inMinutes == 1) {
          elapsedTime = '${duration.inMinutes.toString()} ${minuteAgoLabel}';
        } else {
          elapsedTime = '${duration.inMinutes.toString()} ${minutesAgoLabel}';
        }
      } else  {
        if (duration.inSeconds <= 1) {
          elapsedTime = '${duration.inSeconds.toString()} ${secondAgoLabel}';
        } else {
          elapsedTime = '${duration.inSeconds.toString()} ${secondsAgoLabel}';
        }
      }
    }
    return elapsedTime;
  }

  void collapseExpandControl(HistoryItem historyItem) {
    expandedControl[historyItem] = expandedControl[historyItem] == null ? true :  !expandedControl[historyItem];
  }
}
