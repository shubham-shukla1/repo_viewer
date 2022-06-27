import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class SembastDatabase {
  //this is the object returned when we open the database
  //late- non nullable and no value
  late Database _instance;
  Database get instance => _instance;

  //cant always open dbPath, so flag
  bool hasBeenInitialized = false;
  //init method of this class
  Future<void> init() async {
    //Path to a directory where the application may place data that is user-generated, or that cannot otherwise be recreated by your application.
    if (hasBeenInitialized) return;
    hasBeenInitialized = true;
    final dbDirectory = await getApplicationDocumentsDirectory();
    dbDirectory.create(recursive: true);
    final dbPath = join(dbDirectory.path, 'db.sembast');
    _instance = await databaseFactoryIo.openDatabase(dbPath);
  }
}
