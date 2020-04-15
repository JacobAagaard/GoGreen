import 'package:sembast/sembast.dart';
import 'package:gogreen/models/ReceiptModel.dart';
import 'databaseSetup.dart';

class ReceiptDao {
  static const String folderName = "Receipts";
  final _receiptFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future insertReceipt(Receipt receipt) async {
    await _receiptFolder.add(await _db, receipt.toMap());
    print('Receipt Inserted successfully !!');
  }

  Future updateReceipt(Receipt receipt) async {
    final finder = Finder(filter: Filter.byKey(receipt.id));
    await _receiptFolder.update(await _db, receipt.toMap(), finder: finder);
  }

  Future delete(Receipt receipt) async {
    final finder = Finder(filter: Filter.byKey(receipt.id));
    await _receiptFolder.delete(await _db, finder: finder);
  }

  Future<List<Receipt>> getAllReceipts() async {
    final recordSnapshot = await _receiptFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final receipt = Receipt.fromMap(snapshot.value);
      receipt.id = snapshot.key;
      return receipt;
    }).toList();
  }
}
