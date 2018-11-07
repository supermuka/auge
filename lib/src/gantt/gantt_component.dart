import 'dart:async';


import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_tooltip/material_tooltip.dart';
import 'package:angular_components/focus/keyboard_only_focus_indicator.dart';
import 'package:angular_components/laminate/enums/alignment.dart';

import 'package:auge_server/model/objective/objective.dart';
import 'package:auge_server/model/user.dart';

import 'package:auge_web/message/messages.dart';

import 'package:auge_web/src/auth/auth_service.dart';
import 'package:auge_web/src/app_layout/app_layout_service.dart';
import 'package:auge_web/src/objective/objective_service.dart';

import 'package:auge_web/services/common_service.dart' as common_service;
import 'package:auge_web/src/gantt/gantt_service.dart';

import 'package:auge_web/services/app_routes.dart';

@Component(
  selector: 'auge-gantt',
  providers: const [GanttService, ObjectiveService],



  directives: const [
    coreDirectives,
    routerDirectives,
    MaterialButtonComponent,
    MaterialTooltipDirective,
    ClickableTooltipTargetDirective,
    KeyboardOnlyFocusIndicatorDirective,
    MaterialTooltipDirective,
    MaterialPaperTooltipComponent,

    /* materialDirectives, */
  ],
  styleUrls: const ['gantt_component.css'],
  templateUrl: 'gantt_component.html',
  pipes: const [commonPipes],
)

class GanttComponent implements OnActivate {

  final preferredTooltipPositions = const [RelativePosition.OffsetBottomLeft, RelativePosition.OffsetBottomRight];

  final AuthService _authService;
  final AppLayoutService _appLayoutService;
  final GanttService _ganttService;
  final Router _router;

  List<Objective> objectives = new List();
  List<int> yearsInterval;
  List<YearMonth> yearsMonthsInterval;
  Map<String, List<Objective>> objectivesByGroup;

  String selectedYear;

  GanttComponent(this._authService, this._appLayoutService, this._ganttService, this._router) {
    initializeDateFormatting(Intl.defaultLocale , null);
  }

  // Define messages and labels
  static final String groupLabel =  GanttMsg.label('Group');

  @override
  Future onActivate(RouterState routerStatePrevious, RouterState routerStateCurrent) async {
    if (this._authService.authenticatedUser == null) {
      _router.navigate(AppRoutes.authRoute.toUrl());
    }

    _appLayoutService.headerTitle = ObjectiveViewsMsg.label('Objectives Gantt');

    _appLayoutService.enabledSearch = false;

    try {
       objectives = await _ganttService.getObjectivesGantt(_authService.selectedOrganization.id);

       yearsInterval = getYearsInterval();
       yearsMonthsInterval = getYearsMonthsInterval();
       objectivesByGroup = getObjectivesByGroup();

    } catch (e) {
      _appLayoutService.error = e.toString();
      rethrow;
    }

  }

  String userUrlImage(User userMember) {
    return common_service.userUrlImage(userMember?.userProfile?.image);
  }

  void goToObjectives(Objective objective) async {
    _router.navigateByUrl(AppRoutes.objectivesRoute.toUrl(queryParameters: { AppRoutes.objectiveIdParameter: objective.id }));

  }

  getYearsInterval() {
    // Scan for min and max date
    DateTime minStartDateTime, maxEndDateTime;
    for (int i = 0; i<objectives.length; i++) {
      if (objectives[i].startDate != null && (minStartDateTime == null || objectives[i].startDate.compareTo(minStartDateTime) < 0)) {
        minStartDateTime = objectives[i].startDate;
      }
      if (objectives[i].endDate != null && (maxEndDateTime == null || objectives[i].endDate.compareTo(maxEndDateTime) > 0)) {
        maxEndDateTime = objectives[i].endDate;
      }
    }

    int yearsCount = 1;
    if (minStartDateTime != null && maxEndDateTime != null && minStartDateTime?.year != maxEndDateTime?.year)
      yearsCount = yearsCount + maxEndDateTime?.year - minStartDateTime?.year;

    int firstYear = minStartDateTime?.year ?? minStartDateTime?.year ?? DateTime.now().year;

    List<int> _yearsInterval = [];
    for (int iYear = 0;iYear<yearsCount;iYear++) {
      _yearsInterval.add((firstYear + iYear));
    }

    return _yearsInterval;
  }

  getYearsMonthsInterval() {

    List<YearMonth> _yearsMonthsInterval = [];

    DateTime currentDateTime = DateTime.now();
    int currentYear = currentDateTime.year;
    int currentMonth = currentDateTime.month;


    for (int iYear = 0;iYear<yearsInterval.length;iYear++) {
      for (int iMonth = 0; iMonth < DateTime.monthsPerYear; iMonth++) {
        _yearsMonthsInterval.add(YearMonth()..year = yearsInterval[iYear]
            ..month =  iMonth+1
            ..monthName = DateFormat.MMM().format(DateTime(yearsInterval[iYear], iMonth + 1))
            ..isCurrent =  yearsInterval[iYear] == currentYear && iMonth+1 == currentMonth);
      }
    }

    return _yearsMonthsInterval;
  }

  Map<String, List<Objective>> getObjectivesByGroup() {
    Map<String, List<Objective>> _objectivesByGroup = {};
    for (int i = 0;i<objectives.length;i++) {
      if (!_objectivesByGroup.containsKey(objectives[i].group.id)) {
        _objectivesByGroup[objectives[i].group.id] = List();
      }
      _objectivesByGroup[objectives[i].group.id].add(objectives[i]);
    }
    return _objectivesByGroup;
  }

  String gridColumnFromStartAndEndDate(Objective objective) {
    int startMonth = 1;
    if (objective.startDate != null) {
      int startYearDiff = objective.startDate.year -
          yearsMonthsInterval.first.year;
      int startMonthDiff = objective.startDate.month -
          yearsMonthsInterval.first.month;

      startMonth = startYearDiff * 12 + startMonthDiff;
    }
    int endMonth = 1;
    if (objective.endDate != null) {
      int endYearDiff = objective.endDate.year - yearsMonthsInterval.first.year;
      int endMonthDiff = objective.endDate.month -
          yearsMonthsInterval.first.month;

      endMonth = endYearDiff * 12 + endMonthDiff;
    }

    const int initOffset = 1;
    const int finalOffset = 2;

    return '${startMonth+initOffset}/${endMonth+finalOffset}';

  }

  String barColor(Objective objective) {
    return objective.progress < 30 ? '#db4437' : '#0f9d58'; // Material Color - $mat-red / $mat-green

  }

  String colorFromUuid(String id) {
    return common_service.colorFromUuid(id);
  }

  String firstLetter(String name) {
    return common_service.firstLetter(name);
  }

}

class YearMonth {
  int year;
  int month;
  String monthName;
  bool isCurrent;
}