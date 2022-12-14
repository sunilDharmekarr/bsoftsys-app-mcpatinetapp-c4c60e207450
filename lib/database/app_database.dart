import 'dart:math';

import 'package:mumbaiclinic/model/family_member_model.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  AppDatabase._();

  static AppDatabase db = AppDatabase._();

  Database _database;

  //table name
  static const String USER_TABLE = 'users';

  //COLUMN NAME
  static const String ID = 'id';
  static const String PATID = 'patid';
  static const String FULL_NAME = 'full_name';
  static const String FIRST_NAME = 'first_name';
  static const String MIDDLE_NAME = 'middle_name';
  static const String LAST_NAME = 'last_name';
  static const String SEX = 'sex';
  static const String DOB = 'dob';
  static const String MOBILE = 'mobile';
  static const String EMAIL = 'email';
  static const String profile_pic = 'profile_pic';
  static const String fhead = 'fhead';
  static const String relation_id = 'relation_id';
  static const String height = 'height';
  static const String weight = 'weight';
  static const String bg_id = 'bg_id';
  static const String address1 = "address1";
  static const String address2 = "address2";
  static const String country = "country";
  static const String state = "state";
  static const String city = "city";
  static const String pincode = "pincode";

  //create table query

  static const CREATE_USER_TABLE = '''CREATE TABLE $USER_TABLE
  ( 
  $ID INTEGER,
  $PATID INTEGER UNIQUE,
  $FULL_NAME TEXT,
  $FIRST_NAME TEXT,
  $MIDDLE_NAME TEXT,
  $LAST_NAME TEXT,
  $profile_pic TEXT,
  $SEX TEXT,
  $fhead TEXT,
  $DOB TEXT,
  $MOBILE TEXT,
  $EMAIL TEXT,
  $relation_id INTEGER,
  $bg_id INTEGER,
  $weight TEXT,
  $height TEXT,
  $address1 TEXT,
  $address2 TEXT,
  $country TEXT,
  $state TEXT,
  $city TEXT,
  $pincode TEXT
  )
  ''';

  static const DROP_TABLE = '''
  DROP TABLE IF EXISTS $USER_TABLE
  ''';

  /* static const ALTER_TABLE='''
  ALTER TABLE $USER_TABLE ADD COLUMN $profile_pic TEXT;
  ''';*/

  /* static const ALTER_TABLE_FH ='''
   ALTER TABLE $USER_TABLE ADD COLUMN  $fhead Text;
  ''';*/

  //INIT DATABASE
  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'mumbai.db'),
      onCreate: (db, version) async {
        var batch = db.batch();
        batch.execute(DROP_TABLE);
        batch.execute(CREATE_USER_TABLE);
        await batch.commit();
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        var batch = db.batch();
        /* if  (oldVersion==1 ){
          batch.execute(ALTER_TABLE);
          batch.execute(ALTER_TABLE_FH);
        }
        if(oldVersion==2)
          batch.execute(ALTER_TABLE_FH);*/
        if (oldVersion < 2 && newVersion >= 2) {
          batch.execute('''
            ALTER TABLE $USER_TABLE ADD $address1 TEXT;
            ''');
          batch.execute('''
            ALTER TABLE $USER_TABLE ADD $address2 TEXT;
            ''');
          batch.execute('''
            ALTER TABLE $USER_TABLE ADD $country TEXT;
            ''');
          batch.execute('''
            ALTER TABLE $USER_TABLE ADD $city TEXT;
            ''');
          batch.execute('''
            ALTER TABLE $USER_TABLE ADD $state TEXT;
            ''');
          batch.execute('''
            ALTER TABLE $USER_TABLE ADD $pincode TEXT;
            ''');
        }
        await batch.commit();
      },
      version: 2,
    );
  }

  //ADDING USER INTO TABLE;

  addUser(Map<String, dynamic> data) async {
    final db = await database;
    try {
      var result = await db.insert(USER_TABLE, data,
          conflictAlgorithm: ConflictAlgorithm.replace);
      return result;
    } catch (e) {
      return 0;
    }
  }

  addBatchUsers(List<FamilyMember> data) async {
    final db = await database;
    try {
      Batch batch = db.batch();
      batch.delete(USER_TABLE);
      data.forEach((element) {
        batch.insert(USER_TABLE, element.toDatabase(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
      var result = await batch.commit();
      print(result.toString());
      return result;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  updateUser(String pid, Map<String, dynamic> data) async {
    final db = await database;
    try {
      var result = await db
          .update(USER_TABLE, data, where: "$PATID=?", whereArgs: [pid]);
      return result;
    } catch (e) {
      return 0;
    }
  }

  getUser(String PID) async {
    final db = await database;
    try {
      var result =
          await db.query(USER_TABLE, where: '$PATID=?', whereArgs: [PID]);
      if (result.length > 0) {
        var data = result.first;
        return Datum.fromDatabaseJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  getUsers() async {
    final db = await database;
    try {
      var result = await db.query(USER_TABLE);
      if (result.length > 0) {
        return result.map((data) => Datum.fromDatabaseJson(data)).toList();
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  deleteUserTable() async {
    final db = await database;
    try {
      await db.delete(USER_TABLE);
    } catch (e) {
      print(e);
    }
  }
}
