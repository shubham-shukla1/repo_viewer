import 'package:oauth2/oauth2.dart';

abstract class CredentialsStorage {
  Future<Credentials?> read();
//Nullable credential because  possibly user is not authenticated
  Future<void> save(Credentials credentials);

  //when user sign out delete the credential
  Future<void> clear();
}
