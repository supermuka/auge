// Copyright (c) 2018, Levius Tecnologia Ltda. All rights reserved.
// Author: Samuel C. Schwebel.

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import 'package:angular_components/material_slider/material_slider.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel_set.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_input/material_input.dart';
import 'package:angular_components/material_menu/material_menu.dart';
import 'package:angular_components/material_tooltip/material_tooltip.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/laminate/components/modal/modal.dart';
import 'package:angular_components/model/ui/icon.dart';
import 'package:angular_components/model/menu/menu.dart';
import 'package:angular_components/content/deferred_content.dart';

import 'package:auge_server/model/objective/objective.dart';
import 'package:auge_server/model/objective/measure.dart';

import 'package:auge_web/services/app_routes.dart';

import 'package:auge_web/message/messages.dart';
import 'package:auge_web/src/auth/auth_service.dart';
import 'package:auge_web/src/measure/measure_detail_component.dart';
import 'package:auge_web/src/measure/measure_progress_component.dart';
import 'package:auge_web/src/measure/measure_service.dart';
import 'package:auge_web/src/history_timeline/history_timeline_service.dart';
import 'package:auge_web/src/app_layout/app_layout_service.dart';

@Component(
    selector: 'auge-measures',
    providers: [MeasureService],
    templateUrl: 'measures_component.html',
    styleUrls: const [
      'measures_component.css'
    ],
    directives: const [
      coreDirectives,
      materialInputDirectives,
      MaterialSliderComponent,
      MaterialExpansionPanel,
      MaterialExpansionPanelSet,
      MaterialIconComponent,
      MaterialMenuComponent,
      MaterialTooltipDirective,
      MaterialButtonComponent,
      ModalComponent,
      NgModel,
      DeferredContentDirective,
      MeasureDetailComponent,
      MeasureProgressComponent,
    ],
    pipes: const [commonPipes])

class MeasuresComponent with CanReuse {

  final AppLayoutService _appLayoutService;
  final MeasureService _measureService;
  final HistoryTimelineService _historyTimelineService;
  final Router _router;

  @Input()
  Objective objective;

  @Input()
  TimelineParam timelineParam;

  Measure selectedMeasure;

  MenuModel<MenuItem> menuModel;
  MeasuresComponent(this._appLayoutService, this._measureService, this._historyTimelineService, this._router) {
    menuModel = new MenuModel([new MenuItemGroup(
        [new MenuItem(CommonMsg.buttonLabel('Edit'), icon: new Icon('edit') , action: () => goToDetail()),
        new MenuItem(CommonMsg.buttonLabel('Delete'), icon: new Icon('delete'), action: () => delete()),
        new MenuItem('Progress History', icon: new Icon('show_chart'), action: () => goToProgress(false)) ])], icon: new Icon('menu'));
    print('DEBUG MeasuresComponent - construtor');

  }

  // Define messages and labels
  static final String measuresLabel = MeasureMsg.label('Measures');
  static final String progressLabel =  MeasureMsg.label('Progress');
  static final String startValueLabel =  MeasureMsg.label('Start Value');
  static final String currentValueLabel =  MeasureMsg.label('Current Value');
  static final String endValueLabel =  MeasureMsg.label('End Value');

  void selectMeasure(Measure measure) {
    selectedMeasure = measure;
  }

  /// Call a soft (logic) delete
  void delete() async {
    try {

      await _measureService.deleteMeasure(selectedMeasure);
      objective.measures.remove(selectedMeasure);

      // This is necessary, because this component is not used with a router, where the refresh is mame into onActivate. It is uses into [objects_components]
      if (timelineParam != null && timelineParam.timelineVisible) _historyTimelineService.refreshHistory(SystemModule.objectives.index);

    } catch (e) {
      _appLayoutService.error = e.toString();
      rethrow;
    }
  }

  int progress(Measure measure) {
    return measure == null || measure.currentValue == null || measure.currentValue == 0 ? 0 :  (measure.currentValue ~/ (measure.startValue + measure.endValue) * 100);
  }

  void changeCurrentValue(Measure measure, num value) {
    // measure.currentValue = value;

    // Treat invert slider value, when applied;
    if (measure.startValue != null || measure?.endValue != null) {
      measure.startValue <= measure.endValue
          ? measure.currentValue = value
          : measure.currentValue =
          measure.startValue + measure.endValue - value;
     // _measureService.saveMeasure(objective.id, measure);
    }
  }

  toInt(double value) => value?.toInt();

  List<Measure> get measures {
    return objective?.measures;
  }

  void refreshMeasures() async {
      objective.measures = await _measureService.getMeasures(objective.id);
  }

  void closeProgress() async {
    // recovery the actual measure;
    if (selectedMeasure != null) {
      measures[measures.indexOf(selectedMeasure)] = await _measureService.getMeasure(selectedMeasure.id);
    }
  }

  void goToDetail() {
    if (selectedMeasure == null) {
      _router.navigate(AppRoutes.measureAddRoute.toUrl(parameters: { AppRoutesParam.objectiveIdParameter: objective.id }));
    } else {
      _router.navigate(AppRoutes.measureEditRoute.toUrl(parameters: { AppRoutesParam.objectiveIdParameter: objective.id, AppRoutesParam.measureIdParameter: selectedMeasure.id }));
    }
  }

  void goToProgress(bool add) {
    if (add) {
      _router.navigate(AppRoutes.measureProgressesAddRoute.toUrl(parameters: {
        AppRoutesParam.objectiveIdParameter: objective.id,
        AppRoutesParam.measureIdParameter: selectedMeasure.id }), NavigationParams(queryParameters: {
        AppRoutesQueryParam.measureCurrentValueQueryParameter: selectedMeasure.currentValue.toString() }));
    } else {
      _router.navigate(AppRoutes.measureProgressesAddRoute.toUrl(
          parameters: {
            AppRoutesParam.objectiveIdParameter: objective.id,
            AppRoutesParam.measureIdParameter: selectedMeasure.id },
          ));
    }
  }
}

/// Used just to pass by reference the parent [timelineVisible]
class TimelineParam {
  bool timelineVisible = false;
}