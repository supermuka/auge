// Copyright (c) 2019, Levius Tecnologia Ltda. All rights reserved.
// Author: Samuel C. Schwebel.ExampleSelectionOptions

import 'dart:async';

import 'package:angular/angular.dart';

import 'package:angular_components/material_icon/material_icon.dart';
import 'package:angular_components/material_select/material_dropdown_select.dart';
import 'package:angular_components/material_select/dropdown_button.dart';
import 'package:angular_components/material_select/material_dropdown_select_accessor.dart';
import 'package:angular_components/material_select/material_select_searchbox.dart';
import 'package:angular_components/material_select/material_select_dropdown_item.dart';

import 'package:angular_components/model/selection/select.dart';
import 'package:angular_components/model/selection/string_selection_options.dart';
import 'package:angular_components/model/selection/selection_model.dart';
import 'package:angular_components/model/ui/has_factory.dart';

import 'package:auge_server/model/general/user.dart';

import 'package:auge_web/src/app_layout/app_layout_service.dart';
import 'package:auge_web/src/auth/auth_service.dart';
import 'package:auge_web/src/user/user_service.dart';

@Component(
  selector: 'auge-user-filter',
  providers: const [UserService],
    styleUrls: const ['user_filter_component.css'],
    templateUrl: 'user_filter_component.html',
  directives: const [
    coreDirectives,
    MaterialDropdownSelectComponent,
    DropdownSelectValueAccessor,
    MultiDropdownSelectValueAccessor,
    DropdownButtonComponent,
    MaterialSelectDropdownItemComponent,
    MaterialSelectSearchboxComponent,
    MaterialIconComponent,
  ])

class UserFilterComponent implements OnInit  {

  final AppLayoutService _appLayoutService;
  final AuthService _authService;
  final UserService _userService;

  List<User> _users = [];

  StringSelectionOptions<User> userOptions;
  SelectionModel<User> userMultiSelectModel;

  final _userSelection = StreamController<List<User>>();
  @Output()
  Stream<List<User>> get changeSelection => _userSelection.stream;

  UserFilterComponent(this._appLayoutService, this._authService, this._userService) {

    userMultiSelectModel = SelectionModel<User>.multi();

    userMultiSelectModel.selectionChanges.listen((_) {

      _userSelection.add(userMultiSelectModel.selectedValues.toList());

    });

  }

  // Define messages and labels
  @override
  void ngOnInit() async {

    //TODO remove this with another implementation. If is necessary because Service Injector (_authService.authorizedOrganization.id) is get null
    await Future.delayed(Duration(seconds: 0));

    if (_authService.authorizedOrganization == null) return;

    try {

      // TODO: Avoid using Timer.run.
      /*
      Timer.run(() {
      });
       */

      _users = await _userService.getUsers(_authService.authorizedOrganization.id);

      userOptions = UserSelectionOptions(_users);

      selectAllUsers();

    } catch (e) {
      _appLayoutService.error = e.toString();
      rethrow;
    }
  }

  /// Label for the button for multi selection.
  String get multiSelectUserLabel {
    var selectedValues = userMultiSelectModel?.selectedValues;
    if (selectedValues == null || selectedValues.isEmpty) {
      return "Select User";
    } else if (selectedValues.length == 1) {
      return userItemRenderer(selectedValues.first);
    } else {
      return "${userItemRenderer(selectedValues.first)} + ${selectedValues.length - 1} more";
    }
  }

  ItemRenderer get userItemRenderer => (dynamic user) => user.name;

  @ViewChild(MaterialSelectSearchboxComponent)
  MaterialSelectSearchboxComponent searchbox;

  void onDropdownVisibleChange(bool visible) {
    if (visible) {
      // TODO(google): Avoid using Timer.run.
      Timer.run(() {
        searchbox.focus();
      });
    }
  }

  void selectAllUsers() {
    for (User user in _users) {
      userMultiSelectModel.select(user);
    }
  }

  void clearAllUsers() {
    for (User user in _users) {
      userMultiSelectModel.deselect(user);
    }
  }

}

/// If the option does not support toString() that shows the label, the
/// toFilterableString parameter must be passed to StringSelectionOptions.
class UserSelectionOptions extends StringSelectionOptions<User>
    implements Selectable<User> {
  UserSelectionOptions(List<User> options)
      : super(options,
      toFilterableString: (User option) => option.name.toString());

  @override
  SelectableOption getSelectable(User item) => SelectableOption.Selectable;
}