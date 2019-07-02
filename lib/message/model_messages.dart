import 'package:intl/intl.dart';

import 'package:auge_server/model/general/user.dart';
import 'package:auge_server/model/general/user_profile_organization.dart';
import 'package:auge_server/model/general/group.dart';
import 'package:auge_server/model/general/organization.dart';
import 'package:auge_server/model/general/configuration.dart';
import 'package:auge_server/model/objective/objective.dart';
import 'package:auge_server/model/objective/measure.dart';
import 'package:auge_server/model/initiative/initiative.dart';
import 'package:auge_server/model/initiative/stage.dart';
import 'package:auge_server/model/initiative/work_item.dart';


/// Specific messages and label for [User] class field
class CommonFieldAndValuesMsg {

  /// Label for Field User
  static labelAndValue(dynamic fieldName) => Intl.message(
    "${Intl.select(fieldName, {
      true: 'Yes',
      false: 'No',
      'other': 'Not Defined'})}",
    name: "commonFieldAndValuesLabel",
    args: [fieldName],
    // locale: "en",
    desc: "Common form field labels and values",
  );
}

class ClassNameMsg {

  /// Label for Field User
  static label(String className) => Intl.message(
    "${Intl.select(className, {
      User.className: 'User',
      UserProfile.className: 'User Profile',
      UserProfileOrganization.className: 'User and Profiles',
      Group.className: 'Group',
      Objective.className: 'Objective',
      Measure.className: 'Measure',
      MeasureProgress.className: 'Measure Progress',
      Initiative.className: 'Initiative',
      Stage.className: 'Stage',
      WorkItem.className: 'Work Item',
      'other': 'Not Defined'})}",
    name: "classNameLabel",
    args: [className],
    // locale: "en",
    desc: "Model class name labels",
  );
}

/// Specific messages and label for [User] class field
class FieldMsg {

  /// Label for Field User
  static label(String classAndFieldName) => Intl.message(
    "${Intl.select(classAndFieldName, {
       //USER
      '${User.className}.${User.nameField}': 'Name',
      '${User.className}.${User.eMailField}': 'e-Mail',
      '${User.className}.${User.passwordField}': 'Password',
      //USERPROFILE
      '${UserProfile.className}.${UserProfile.isSuperAdminField}':'Super Admin',
      '${UserProfile.className}.${UserProfile.imageField}':'Image',
      '${UserProfile.className}.${UserProfile.idiomLocaleField}':'Idioma',
      //USERPROFILEORGANIZATION
      '${UserProfileOrganization.className}.${UserProfileOrganization.authorizationRoleField}':'Authorization',

      //GROUP
      '${Group.className}.${Group.nameField}':'Name',
      '${Group.className}.${Group.activeField}':'Active',
      '${Group.className}.${Group.leaderField}':'Leader',
      '${Group.className}.${Group.groupTypeField}':'Group Type',
      '${Group.className}.${Group.superGroupField}':'Super Group',
      '${Group.className}.${Group.leaderField}':'Leader',
      '${Group.className}.${Group.membersField}':'Members',
      //OBJECTIVE
      '${Objective.className}.${Objective.nameField}':'Name',
      '${Objective.className}.${Objective.descriptionField}':'Description',
      '${Objective.className}.${Objective.groupField}':'Group',
      '${Objective.className}.${Objective.alignedToField}':'Aligned To',
      '${Objective.className}.${Objective.leaderField}':'Leader',
      '${Objective.className}.${Objective.startDateField}':'Start Date',
      '${Objective.className}.${Objective.endDateField}':'End Date',
      '${Objective.className}.${Objective.archivedField}':'Archived',
      //MEASURE
      '${Measure.className}.${Measure.nameField}':'Name',
      '${Measure.className}.${Measure.descriptionField}':'Description',
      '${Measure.className}.${Measure.endValueField}':'End Value',
      '${Measure.className}.${Measure.startValueField}':'Start Value',
      '${Measure.className}.${Measure.currentValueField}':'Current Value',
      '${Measure.className}.${Measure.decimalsNumberField}':'Decimals Number',
      '${Measure.className}.${Measure.measureUnitField}':'Unit',
      '${Measure.className}.${Measure.metricField}':'Metric',
      //MEASURE PROGRESS
      '${MeasureProgress.className}.${MeasureProgress.dateField}':'Date',
      '${MeasureProgress.className}.${MeasureProgress.currentValueField}':'Current Value',
      '${MeasureProgress.className}.${MeasureProgress.commentField}':'Comment',
      //ORGANIZATION
      '${Organization.className}.${Organization.nameField}':'Name',
      '${Organization.className}.${Organization.codeField}':'EIN',
      //INITIATIVE
      '${Initiative.className}.${Initiative.nameField}':'Name',
      '${Initiative.className}.${Initiative.descriptionField}':'Description',
      '${Initiative.className}.${Initiative.groupField}':'Group',
      '${Initiative.className}.${Initiative.leaderField}':'Leader',
      '${Initiative.className}.${Initiative.stagesField}':'Stages',
      '${Initiative.className}.${Initiative.objectiveField}':'Objective',
      //STAGE
      '${Stage.className}.${Stage.nameField}':'Name',
      '${Stage.className}.${Stage.stateField}':'State',
      //WORK ITEMS
      '${WorkItem.className}.${WorkItem.nameField}':'Name',
      '${WorkItem.className}.${WorkItem.descriptionField}':'Description',
      '${WorkItem.className}.${WorkItem.dueDateField}':'Due Date',
      '${WorkItem.className}.${WorkItem.completedField}':'Completed',
      '${WorkItem.className}.${WorkItem.stageField}':'Stage',
      '${WorkItem.className}.${WorkItem.assignedToField}':'Assigned To',
      '${WorkItem.className}.${WorkItem.checkItemsField}':'Check Items',
      //LDAP CONFIGURATION
      '${DirectoryService.className}.${DirectoryService.enabledField}':'Ldap Enabled',
      '${DirectoryService.className}.${DirectoryService.hostAddressField}':'Host Address',
      '${DirectoryService.className}.${DirectoryService.portField}':'Port',
      '${DirectoryService.className}.${DirectoryService.sslTlsField}':'SSL/TLS Enabled',
      '${DirectoryService.className}.${DirectoryService.adminBindDNField}':'Admin Bind DN',
      '${DirectoryService.className}.${DirectoryService.adminPasswordField}':'Admin Password',

      '${DirectoryService.className}.${DirectoryService.groupSearchDNField}':'Group Search DN',
      '${DirectoryService.className}.${DirectoryService.groupSearchScopeField}':'Group Search Scope',
      '${DirectoryService.className}.${DirectoryService.groupSearchFilterField}':'Group Search Filter',
      '${DirectoryService.className}.${DirectoryService.groupMemberAttributeField}':'Group Member Attribute',

      '${DirectoryService.className}.${DirectoryService.userSearchDNField}':'User Search DN',
      '${DirectoryService.className}.${DirectoryService.userSearchScopeField}':'User Search Scope',
      '${DirectoryService.className}.${DirectoryService.userSearchFilterField}':'User Search Filter',
      '${DirectoryService.className}.${DirectoryService.userLoginAttributeField}':'User Login Attribute',
      '${DirectoryService.className}.${DirectoryService.userFirstNameAttributeField}':'User First Attribute',
      '${DirectoryService.className}.${DirectoryService.userLastNameAttributeField}':'User Last Attribute',
      '${DirectoryService.className}.${DirectoryService.userEmailAttributeField}':'User Email Attribute',

      'other': 'Not Defined'})}",
    name: "FieldLabel",
    args: [classAndFieldName],
    // locale: "en",
    desc: "User form field labels",
  );
}

/// Specific messages and label for [UserProfile] model field and class
class UserProfileValueMsg {

  /// Static value for User
  static label(String valueName) => Intl.message(
    "${Intl.select(valueName, {
      'pt_BR': 'Português - Brasil',
      'en_US': 'English - USA',
      'es_ES': 'Espanhol - España',
      'other': 'Not Defined'})}",
    name: "userProfileFieldLabel",
    args: [valueName],
    // locale: "en",
    desc: "User Profile values labels",
  );
}