import 'dart:convert';

import 'package:cas_house/api_service.dart';
import 'package:cas_house/models/expanses.dart';
import 'package:http/http.dart' as http;

import '../database/database_helper.dart';

class ExpansesServices {
  final String _urlPrefix = ApiService.baseUrl;
  final DatabaseHelper dbHelper = DatabaseHelper();

  // addExpanse(Expanses expanse) async {
  //   print('test');
  //   Map<String, dynamic> body = {
  //     'expanse': expanse,
  //   };
  //   print("JSON:");
  //   print(jsonEncode(body));
  //   print(_urlPrefix);
  //   final http.Response res = await http.post(
  //     Uri.parse('$_urlPrefix/expanse/add'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(body),
  //   );
  //   print(res.toString());
  //   Map<String, dynamic> decodedBody = json.decode(res.body);
  //   print(decodedBody);
  //   if (decodedBody['success']) {
  //     Expanses expanse = Expanses.fromJson(decodedBody['expanse']);
  //     return expanse;
  //   }
  // }

  addExpanse(Expanses expanse) async {
    print('ExpansesServices.addExpanse');
    try {
      Map<String, dynamic> body = {'expanse': expanse.toJson()};
      final response = await http.post(
        Uri.parse('$_urlPrefix/expanse/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> decodedBody = json.decode(response.body);
        if (decodedBody['success']) {
          Expanses syncedExpanse = Expanses.fromJson(decodedBody['expanse']);
          await dbHelper.markAsSynced(expanse.id!);
          return syncedExpanse;
        }
      } else {
        throw Exception("Failed to sync with server");
      }
    } catch (e) {
      // Store locally if offline
      print('saving to local DB');
      await dbHelper.insertExpanse(expanse);
      return expanse;
    }
  }

  // getAllExpansesByAuthor() async {
  //   print('test getExpansesByAuthor');
  //
  //   final http.Response res = await http.post(
  //     Uri.parse('$_urlPrefix/expanse/getAnyExpansesByUserId'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //   );
  //   Map<String, dynamic> decodedBody = json.decode(res.body);
  //   print("decodebody" + decodedBody['expanses'].toString());
  //   if (decodedBody['success']) {
  //     List<Expanses> expanses =
  //         (decodedBody['expanses'] as List<dynamic>).map((item) {
  //       return Expanses.fromJson(item);
  //     }).toList();
  //     return expanses;
  //   }
  // }

  Future<List<Expanses>> getAllExpansesByAuthor(String authorId) async {
    print('ExpansesServices.getAllExpansesByAuthor');
    print('Fetching all expenses by author : $authorId ...');

    try {
      final http.Response res = await http.post(
        Uri.parse('$_urlPrefix/expanse/getAnyExpansesByUserId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: <String, String>{
          'authorId': authorId,
        }
        //TODO add logic in backend
      );

      if (res.statusCode == 200) {
        Map<String, dynamic> decodedBody = json.decode(res.body);
        print("Decoded Body: ${decodedBody['expanses']}");

        if (decodedBody['success']) {
          List<Expanses> expanses =
          (decodedBody['expanses'] as List<dynamic>).map((item) {
            return Expanses.fromJson(item);
          }).toList();

          // Save expenses to SQLite for offline mode
          await dbHelper.saveExpensesToLocalDB(expanses);

          return expanses;
        }
      }
    } catch (e) {
      print("Error fetching from server: $e");
    }

    // If fetching from server fails, load from local SQLite DB
    print('getting from local DB');
    return await dbHelper.getExpensesFromLocalDB();
  }

  // getAllExpansesByAuthorExcludingCurrentMonth() async {
  //   print('test getExpansesByAuthor');
  //
  //   final http.Response res = await http.post(
  //     Uri.parse(
  //         '$_urlPrefix/expanse/getAllExpansesByAuthorExcludingCurrentMonth'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //   );
  //   Map<String, dynamic> decodedBody = json.decode(res.body);
  //   // print("decodebody" + decodedBody.toString());
  //   if (decodedBody['success']) {
  //     // List<Expanses> expanses = decodedBody['groupedExpanses'].map((item) {
  //     //   return Expanses.fromJson(item);
  //     // }).toList();
  //     return decodedBody['groupedExpanses'];
  //   }
  // }

  Future<Map<String, List<Expanses>>> getAllExpansesByAuthorExcludingCurrentMonth() async {
    print('ExpansesServices.getAllExpansesByAuthorExcludingCurrentMonth');
    print('Fetching all expenses by author excluding current month...');

    try {
      final http.Response res = await http.post(
        Uri.parse('$_urlPrefix/expanse/getAllExpansesByAuthorExcludingCurrentMonth'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        Map<String, dynamic> decodedBody = json.decode(res.body);
        print("Full decoded body: $decodedBody");
        print("Decoded Body: ${decodedBody['groupedExpanses']}");

        if (decodedBody['success']) {
          final Map<String, List<Expanses>> monthlyExpensesMap = {};
          for (var group in decodedBody['groupedExpanses']) {
            final String monthYear = group['monthYear'];
            final List<Expanses> expensesList = (group['expanses'] as List<dynamic>)
                .map<Expanses>((item) => Expanses.fromJson(item))
                .toList();

            monthlyExpensesMap[monthYear] = expensesList;
          }

          // Save expenses to SQLite for offline mode
          // await dbHelper.saveExpensesToLocalDB(expanses);

          return monthlyExpensesMap;
        }
      }
    } catch (e) {
      print("Error fetching from server: $e");
    }

    // If fetching from server fails, load from local SQLite DB
    print('getting from local DB');
    return await dbHelper.getExpensesGroupedByMonth();
  }

  // getExpansesByAuthorForCurrentMonth() async {
  //   print('test getExpansesByAuthor');
  //
  //   final http.Response res = await http.post(
  //     Uri.parse('$_urlPrefix/expanse/getExpansesByAuthorForCurrentMonth'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //   );
  //   Map<String, dynamic> decodedBody = json.decode(res.body);
  //   print("decodebody" + decodedBody['expanses'].toString());
  //   if (decodedBody['success']) {
  //     List<Expanses> expanses =
  //         (decodedBody['expanses'] as List<dynamic>).map((item) {
  //       return Expanses.fromJson(item);
  //     }).toList();
  //     return expanses;
  //   }
  // }

  Future<List<Expanses>> getExpansesByAuthorForCurrentMonth() async {
    print('ExpansesServices.getExpansesByAuthorForCurrentMonth');
    print('Fetching all expenses by author for current month...');

    try {
      final http.Response res = await http.post(
        Uri.parse('$_urlPrefix/expanse/getExpansesByAuthorForCurrentMonth'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (res.statusCode == 200) {
        Map<String, dynamic> decodedBody = json.decode(res.body);
        print("Decoded Body: ${decodedBody['expanses']}");

        if (decodedBody['success']) {
          List<Expanses> expanses =
          (decodedBody['expanses'] as List<dynamic>)
              .map<Expanses>((item) => Expanses.fromJson(item))
              .toList();

          // Save expenses to SQLite for offline mode
          await dbHelper.saveExpensesToLocalDB(expanses);

          return expanses;
        }
      }
    } catch (e) {
      print("Error fetching from server: $e");
    }

    // If fetching from server fails, load from local SQLite DB
    print('getting from local DB');
    return await dbHelper.getExpensesFromLocalDB();
  }

  // getExpensesGroupedByCategory(String date, String userId) async {
  //   print('test getExpensesGroupedByCategory');
  //
  //   Map<String, dynamic> body = {
  //     'authorId': userId,
  //     'monthYear': date, //2024-12
  //   };
  //
  //   final http.Response res = await http.post(
  //     Uri.parse('$_urlPrefix/expanse/getExpensesGroupedByCategory'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(body),
  //   );
  //   Map<String, dynamic> decodedBody = json.decode(res.body);
  //   // print("decodebody" + decodedBody['expanses'].toString());
  //   if (decodedBody['success']) {
  //     return decodedBody['groupedByCategory'];
  //   }
  // }

  // Future<List<Expanses>>
  getExpensesGroupedByCategory(String date, String userId) async {
    print('ExpansesServices.getExpensesGroupedByCategory');
    print('Fetching all expenses by category ...');

    Map<String, dynamic> body = {
      'authorId': userId,
      'monthYear': date, //2024-12
    };

    try {
      final http.Response res = await http.post(
        Uri.parse('$_urlPrefix/expanse/getExpensesGroupedByCategory'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body)
      );

      if (res.statusCode == 200) {
        Map<String, dynamic> decodedBody = json.decode(res.body);
        print("Decoded Body: ${decodedBody['expanses']}");

        if (decodedBody['success']) {
          List<Expanses> expanses =
          (decodedBody['expanses'] as List<dynamic>).map((item) {
            return Expanses.fromJson(item);
          }).toList();
          // Save expenses to SQLite for offline mode
          await dbHelper.saveExpensesToLocalDB(expanses);

          return decodedBody['groupedByCategory'];
        }
      }
    } catch (e) {
      print("Error fetching from server: $e");
    }

    // If fetching from server fails, load from local SQLite DB
    print('getting from local DB');
    return await dbHelper.getExpensesGroupedByCategory();
  }

  removeExpanse(String expanseId) async {
    print('ExpansesServices.removeExpanse');
    print(1);
    Map<String, dynamic> body = {
      'expanseId': expanseId,
    };
    print(2);
    final http.Response res = await http.delete(
      Uri.parse('$_urlPrefix/expanse/removeExpanse'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    print(3);
    Map<String, dynamic> decodedBody = json.decode(res.body);
    print(decodedBody);
    if (decodedBody['success']) {
      return true;
    } else {
      return false;
    }
  }
}
