import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/src/credentials.dart';

import 'credential_storage.dart';

class SecureCredentialsStorage implements CredentialsStorage {
  final FlutterSecureStorage _storage;

  SecureCredentialsStorage(this._storage);
  static const _key = "oauth2_credentials";

  Credentials? _cachedCredentials;

  @override
  Future<Credentials?> read() async {
    if (_cachedCredentials != null) {
      // the user is successfully signed in
      return _cachedCredentials;
    }
    // storage.read return a string , which is  json representation of credential
    final json = await _storage.read(key: _key);

    if (json == null) {
      return null;
    }
    //also need to cached the cached credential in read , if credential is null in case of already signed in

    //aware of exceptions
    /// Throws a [FormatException] if the JSON is incorrectly formatted. fromJsonMethod
    /// if malformed json, we are going to take as the  user was not authenticated
    /// so
    try {
      _cachedCredentials = Credentials.fromJson(json);
      return _cachedCredentials;
    } on FormatException {
      return null;
    }
  }

//save method will run only when the user is sign in
//but if the user has already signed in and it will open read method
  @override
  Future<void> save(Credentials credentials) {
    //if we cached the credentials, it is faster, whenever save them
    _cachedCredentials = credentials;
    return _storage.write(key: _key, value: credentials.toJson());
  }

  @override
  Future<void> clear() {
    _cachedCredentials = null;
    return _storage.delete(key: _key);
  }
}
