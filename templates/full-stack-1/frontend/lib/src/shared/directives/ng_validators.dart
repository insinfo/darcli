import 'package:ngdart/angular.dart';

///  Providers for validators to be used for [Control]s in a form.
///
///  Provide this using `ExistingProvider.forToken` to add validators.
const ngValidators = MultiToken<Object>('NgValidators');