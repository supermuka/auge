// Copyright (c) 2018, Levius Tecnologia Ltda. All rights reserved.
// Author: Samuel C. Schwebel.

import 'dart:html' as html;

import 'package:auge_web/src/app_layout/app_layout_service.dart';

import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';
import 'package:angular_forms/angular_forms.dart';

import 'package:angular_components/material_expansionpanel/material_expansionpanel_set.dart';
import 'package:angular_components/material_expansionpanel/material_expansionpanel.dart';
import 'package:angular_components/material_tooltip/material_tooltip.dart';
import 'package:angular_components/material_slider/material_slider.dart';
import 'package:angular_components/material_checkbox/material_checkbox.dart';
import 'package:angular_components/material_toggle/material_toggle.dart';
import 'package:angular_components/material_button/material_button.dart';
import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_menu/material_menu.dart';
import 'package:angular_components/model/menu/menu.dart';
import 'package:angular_components/model/ui/icon.dart';
import 'package:angular_components/model/action/async_action.dart';

import 'package:angular_components/content/deferred_content.dart';


import 'package:auge_web/src/work/work_summary_component.dart';

//import 'package:auge_shared/domain/general/authorization.dart';
import 'package:auge_shared/domain/general/user.dart';
import 'package:auge_shared/domain/work/work.dart';
import 'package:auge_shared/domain/work/work_item.dart';
import 'package:auge_shared/domain/work/work_stage.dart';

import 'package:auge_shared/message/messages.dart';
import 'package:auge_shared/message/domain_messages.dart';

import 'package:auge_web/src/search_filter/search_filter_service.dart';
import 'package:auge_web/services/common_service.dart' as common_service;
import 'package:auge_web/src/work_item/work_item_service.dart';
import 'package:auge_web/src/work/work_service.dart';
import 'package:auge_web/src/work_item/work_item_detail_component.dart';

import 'package:auge_web/route/app_routes.dart';

// ignore_for_file: uri_has_not_been_generated
import 'package:auge_web/src/work_item/work_items_filter_component.template.dart' as work_items_filter_component;
import 'package:auge_web/src/work_item/work_item_detail_component.template.dart' as work_item_detail_component;
import 'package:auge_web/src/work_item/work_item_values_component.template.dart' as work_item_values_component;
import 'package:auge_web/src/work/work_stages_component.template.dart' as work_stages_component;

@Component(
    selector: 'auge-work-items-kanban',
    providers: const [WorkService, WorkItemService],
      templateUrl: 'work_items_kanban_component.html',
      styleUrls: const [
      'work_items_kanban_component.css'
    ],
    directives: const [
      coreDirectives,
      routerDirectives,
      MaterialExpansionPanelSet,
      MaterialExpansionPanel,
      MaterialToggleComponent,
      MaterialTooltipDirective,
      MaterialSliderComponent,
      MaterialCheckboxComponent,
      DeferredContentDirective,
      MaterialMenuComponent,
      WorkItemDetailComponent,
      NgModel,
      WorkSummaryComponent,
      MaterialButtonComponent,
      MaterialIconComponent,
    ],
    pipes: const [commonPipes])

class WorkItemsKanbanComponent with CanReuse implements OnInit, OnActivate, OnDeactivate /*, OnDestroy */ {

  final AppLayoutService _appLayoutService;
  final WorkService _workService;
  final WorkItemService _workItemService;
  final SearchFilterService _searchFilterService;
  final Router _router;

  Work work;
 // String workId;

  WorkItem selectedWorkItem;
  List<KanbanColumn> kanbanColumns;

  WorkItem workItemDnD;

  KanbanColumn kanbanColumnDnD;

  MenuModel<MenuItem> menuModel;

  Map<String, bool> expandedControl = {};
  Map<String, bool> checkItemsExpandedControl = {};

  bool whileUpdatingDisabled = false;

  static final String editButtonLabel = CommonMsg.buttonLabel(CommonMsg.editButtonLabel);
  static final String deleteButtonLabel = CommonMsg.buttonLabel(CommonMsg.deleteButtonLabel);

  static final String cancelButtonLabel = CommonMsg.buttonLabel(CommonMsg.cancelButtonLabel);
  static final String saveButtonLabel = CommonMsg.buttonLabel(CommonMsg.saveButtonLabel);

  static final String groupLabel = WorkDomainMsg.fieldLabel(Work.groupField);
  static final String leaderLabel =  WorkDomainMsg.fieldLabel(Work.leaderField);

  static final String nameLabel = WorkItemDomainMsg.fieldLabel(WorkItem.nameField);
  static final String dueDateLabel =  WorkItemDomainMsg.fieldLabel(WorkItem.dueDateField);
  static final String plannedValueLabel = WorkItemDomainMsg.fieldLabel(WorkItem.plannedValueField);
 // static final String plannedActualLabel = WorkItemMsg.label(WorkItemMsg.plannedActualLabel);
  static final String remainingValueLabel = WorkItemMsg.label(WorkItemMsg.remainingValueLabel);
  static final String actualValueLabel =  WorkItemDomainMsg.fieldLabel(WorkItem.actualValueField);
  static final String checkItemsLabel =  WorkItemDomainMsg.fieldLabel(WorkItem.checkItemsField);

  static final String headerTitle = WorkItemMsg.label(WorkItemMsg.workKanbanLabel);
  static final String workStagesLabel = StageMsg.label(StageMsg.workStagesLabel);
  static final String addWorkItemLabel =  WorkItemMsg.label(WorkItemMsg.addWorkItemLabel);



  final List<RouteDefinition> routes = [
    RouteDefinition(
      routePath: AppRoutes.workItemKanbanAddRoute,
      component: work_item_detail_component.WorkItemDetailComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.workItemKanbanEditRoute,
      component: work_item_detail_component.WorkItemDetailComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.workItemKanbanValuesRoute,
      component: work_item_values_component.WorkItemValuesComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.workItemsKanbanFilterRoute,
      component: work_items_filter_component.WorkItemsFilterComponentNgFactory,
    ),
    RouteDefinition(
      routePath: AppRoutes.workStagesRouteViaKanbanRoute,
      component: work_stages_component.WorkStagesComponentNgFactory,
    ),
  ];

  String _searchTerm = '';

  WorkItemsKanbanComponent(this._appLayoutService, this._searchFilterService, this._workService, this._workItemService, this._router) {
    // initializeDateFormatting(Intl.defaultLocale);
    menuModel = MenuModel([MenuItemGroup([MenuItem(editButtonLabel, icon: Icon('edit') , actionWithContext: (_) => goToDetail()), MenuItem(deleteButtonLabel, icon: Icon('delete'), actionWithContext: (_) => delete()), MenuItem(actualValueLabel, icon: Icon('show_chart'), actionWithContext: (_) => goToValues())])], icon: Icon('menu'));
  }

  @override
  void ngOnInit() {
    work = Work();
  }

  @override
  void onActivate(RouterState routerStatePrevious, RouterState routerStateCurrent) async {
    if (_workItemService.authService.authorizedOrganization == null ||
        _workItemService.authService.authenticatedUser == null) {
      _router.navigate(AppRoutes.authRoute.toUrl());
      return;
    }

    //Work work;
    try {

      if (routerStateCurrent.parameters.containsKey(AppRoutesParam.workIdParameter)) {

        String workId = routerStateCurrent.parameters[AppRoutesParam
            .workIdParameter];

          // work = await _workService.getWork(workId, workItemAssignedToIds: _workItemService.workItemsFilterOrder.assignedToUserIds, workItemWithArchived: _workItemService.workItemsFilterOrder.archived,  );
        work = await _workService.getWorkWithWorkItemsAndStages(workId, workItemAssignedToIds: _workItemService.workItemsFilterOrder.assignedToUserIds, workItemWithArchived: _workItemService.workItemsFilterOrder.archived,  );

        _orderWorkItems(work.workItems, _workItemService.workItemsFilterOrder.orderedBy);

      } else {
        throw Exception('Work Id does not informed.');
      }

      if (routerStateCurrent.queryParameters.containsKey(AppRoutesQueryParam.workItemIdQueryParameter)) {
        String workItemId = routerStateCurrent.queryParameters[AppRoutesQueryParam
            .workItemIdQueryParameter];

        expandedControl[workItemId] = true;
        
        //TODO encontrar outra forma de retirar o queryparam.
        _router.navigateByUrl(routerStateCurrent.path, replace: true);

      }

      _appLayoutService.headerTitle = headerTitle;
   //   _appLayoutService.systemModuleIndex = SystemModule.works.index;
      _searchFilterService.searchTerm = _searchTerm;
      _searchFilterService.enableSearch = true;
      _searchFilterService.enableFilter = true;
      _searchFilterService.filterRouteUrl = AppRoutes.workItemsKanbanFilterRoute.toUrl(parameters: {AppRoutesParam.workIdParameter: work.id});
      _searchFilterService.enableExport = false;

      _searchFilterService.filteredItems = _workItemService.workItemsFilterOrder.filteredItems;
//      _appLayoutService.enabledSearch = true;

    } catch (e) {
      _appLayoutService.error = e.toString();
      rethrow;
    }

    kanbanColumns = List();

    // Define os estados com base no que está na iniciativa
    work.workStages.forEach((es) {
      kanbanColumns.add(KanbanColumn(_searchFilterService)..workStage = es);
    } );

    // Distribui os itens de trabalho para cada coluna (estágio)
    work.workItems.forEach((it) {
      if (it.workStage != null)
        kanbanColumns.singleWhere((ik) => ik.workStage.id == it.workStage.id).columnWorkItems.add(it);
    });
  }

  void onDeactivate(RouterState current, RouterState next) {

    _searchTerm = _searchFilterService.searchTerm;

  }


  void drag(html.MouseEvent ev, KanbanColumn kanbanColumn, WorkItem workItem) {
    kanbanColumnDnD = kanbanColumn;
    workItemDnD = workItem;
  }

  void allowDrop(html.MouseEvent  ev) {
    ev.preventDefault();
  }

  drop(ev, KanbanColumn kanbanColumnDrop) async {
    ev.preventDefault();

    kanbanColumnDnD.columnWorkItems.remove(workItemDnD);
    workItemDnD.workStage = kanbanColumnDrop.workStage;

    await _workItemService.saveWorkItem(workItemDnD);

    _router.navigateByUrl(_router.current.toUrl(), reload: true);

    /*
    //TODO, por causa de performance, talvez o save precisaria retornar o ID + Version
    WorkItem workItemUpdated = await _workItemService.getWorkItem(workItemDnD.id);
    if (workItemUpdated != null) kanbanColumnDrop.columnWorkItems.add(workItemUpdated);

    kanbanColumnDnD = null;
    workItemDnD = null;

    _orderWorkItems(kanbanColumnDrop.columnWorkItems, _workItemService.workItemsFilterOrder.orderedBy);
  */
  }


  void delete() async {
    try {
      await _workItemService.deleteWorkItem(selectedWorkItem);

     // work.workItems.remove(selectedWorkItem);
      _router.navigateByUrl(_router.current.toUrl(), reload: true);
      /*
      KanbanColumn kanbanColumnDelete;
      WorkItem workItemKanban;
      for (var kcStage in kanbanColumns) {
        for (var cWI in kcStage.columnWorkItems) {
          if (cWI.id == selectedWorkItem.id) {
            kanbanColumnDelete = kcStage;
            workItemKanban = cWI;
            break;
          }
        }
        if (kanbanColumnDelete != null) break;
      }

      kanbanColumnDelete.columnWorkItems.remove(workItemKanban);
*/
    } catch (e) {
      _appLayoutService.error = e.toString();
      rethrow;
    }
  }

  void selectWorkItem(WorkItem workItem) {

    this.selectedWorkItem = workItem;

    disEnableItemMenuActual();
  }

  String dueDateColor(WorkItem workItem) {
    return workItem.isOverdue ? 'hsl(0, 100%, 50%)' : null;
  }

  String userUrlImage(User userMember) {
    return common_service.userUrlImage(userMember?.userProfile?.image);
  }

  void goToDetail([String stageId, bool withselectedWorkItem = true]) {
    if (!withselectedWorkItem || selectedWorkItem == null) {
      _router.navigate(AppRoutes.workItemKanbanAddRoute.toUrl(parameters: {
        AppRoutesParam.workIdParameter: work.id }), NavigationParams(replace:  true));

    } else {
      _router.navigate(AppRoutes.workItemKanbanEditRoute.toUrl(parameters: {AppRoutesParam.workIdParameter: work.id,
        AppRoutesParam.workItemIdParameter: selectedWorkItem.id }), NavigationParams(replace:  true));
    }
  }

  void goToValues([workItem, num value]) {

    if (workItem != null) selectWorkItem(workItem);

    if (!hasPlannedOrActual(selectedWorkItem)) return;

    num incrementalValue = (value != null && selectedWorkItem.actualValue != null) ? value - selectedWorkItem.actualValue : 0;

   // if (incrementalValue < 0) incrementalValue = 0;

    _router.navigateByUrl(AppRoutes.workItemKanbanValuesRoute.toUrl(parameters: {
      AppRoutesParam.workIdParameter: work.id, AppRoutesParam.workItemIdParameter: selectedWorkItem.id }, queryParameters: {AppRoutesQueryParam.workItemActualValueQueryParameter: incrementalValue.toString()} ) /*, NavigationParams(replace:  true) */);
  }

  void goToStages() {

    _router.navigate(AppRoutes.workStagesRouteViaKanbanRoute.toUrl(parameters: {
      AppRoutesParam.workIdParameter: work.id}) /*, NavigationParams(replace:  true) */);
  }

  String stateHslColor(int stateIndex) => WorkService.getStateHslColor(stateIndex);

  String composeTooltip(String label, String name) {
    return  '${label} ${name}';
  }

  String colorFromUuid(String id) {
    return common_service.colorFromUuid(id);
  }

  String firstLetter(String name) {
    return common_service.firstLetter(name);
  }

  double remainingValue(double planned, double actual) {
    return planned == null || actual == null ? null : planned - actual;
  }

  bool hasPlannedOrActual(WorkItem workItem) {
    return workItem != null && (workItem.plannedValue != null ||  workItem.actualValue != null);
  }

  void disEnableItemMenuActual() {
      menuModel.itemGroups.last.last.enabled = hasPlannedOrActual(selectedWorkItem);
  }

  // Order by
  void _orderWorkItems(List<WorkItem> workItemsToOrder, String orderBy) {
    if (orderBy == nameLabel) {
      workItemsToOrder.sort((a, b) => a?.name == null || b?.name == null ? -1 : a.name.compareTo(b.name));
      // if orderBy == null, default order.
    } else if (orderBy == null || orderBy == dueDateLabel) {
      workItemsToOrder.sort((a, b) => a?.dueDate == null || b?.dueDate == null ? -1 : a.dueDate.compareTo(b.dueDate));
    }
  }

  bool isUpdatingOrArchived(bool archived)  => (whileUpdatingDisabled || archived) ?? true;



/*
  void updateWorkItem(WorkItem workItem) async {

    if (whileUpdatingDisabled) return;

    whileUpdatingDisabled = true;

    try {

      await _workItemService.saveWorkItem(work.id, workItem);

      _router.navigateByUrl(_router.current.toUrl(), reload: true);

    } catch (e) {
      _appLayoutService.error = e.toString();
      rethrow;
    } finally {
      whileUpdatingDisabled = false;
    }
  }

*/

  void cancelWorkItem(WorkItem workItem, AsyncAction event) async {
    try {
      _router.navigateByUrl(_router.current.toUrl(), reload: true);
    } catch (e) {
      event.cancel();
      rethrow;
    }
  }

  void saveWorkItem(WorkItem workItem, AsyncAction event) async {

    if (whileUpdatingDisabled) return;

    whileUpdatingDisabled = true;

    try {

      await _workItemService.saveWorkItem(workItem);

      _router.navigateByUrl(_router.current.toUrl(), reload: true);

    } catch (e) {
      _appLayoutService.error = e.toString();
      event.cancel();
      rethrow;
    } finally {
      whileUpdatingDisabled = false;
    }
  }

  bool actualValueLimitOverflow(WorkItem workItem) {
    return (workItem != null && workItem.actualValue != null && workItem.plannedValue != null && (workItem.plannedValue - workItem.actualValue < 0) ) ? true : false;
  }

  num actualValueCalculated(WorkItem workItem)  {
    return (workItem != null && workItem.actualValue != null && workItem.plannedValue != null && (workItem.plannedValue - workItem.actualValue < 0)) ? workItem.plannedValue : workItem.actualValue;
  }

}

class KanbanColumn {

  SearchFilterService _searchFilterService;
  WorkStage workStage;
  List<WorkItem> _columnWorkItems;


  KanbanColumn(this._searchFilterService) {
    _columnWorkItems = List();
  }

  List<WorkItem> get columnWorkItems {
    return (_searchFilterService.searchTerm == null || _searchFilterService.searchTerm.isEmpty) ? _columnWorkItems : _columnWorkItems.where((test) => test.name.contains(_searchFilterService.searchTerm)).toList();
  }

  set columnWorkItems(List<WorkItem> kc) {
    _columnWorkItems = kc;
  }


}