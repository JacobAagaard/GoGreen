import 'package:sembast/sembast.dart';
import 'package:gogreen/models/ReceiptModel.dart';
import 'package:sembast/timestamp.dart';
import 'databaseSetup.dart';

class ReceiptDao {
  static const String folderName = "Receipts";
  final _receiptFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future<int> insertReceipt(Receipt receipt) async {
    int result = await _receiptFolder.add(await _db, receipt.toMap());
    if (result != null) {
      print('Receipt Inserted successfully !!');
      return result;
    } else return null;
  }

  Future insertFakeReceipt() async {
    await _receiptFolder.addAll(
        await _db, fakeData.map((receipt) => receipt.toMap()).toList());
    print('Fake receipts Inserted successfully !!');
  }

  Future updateReceipt(Receipt receipt) async {
    final finder = Finder(filter: Filter.byKey(receipt.id));
    int result = await _receiptFolder.update(await _db, receipt.toMap(), finder: finder);
    if (result != null) {
      print('Receipt updated successfully !!');
      return result;
    } else return null;

  }

  Future delete(Receipt receipt) async {
    final finder = Finder(filter: Filter.byKey(receipt.id));
    await _receiptFolder.delete(await _db, finder: finder);
  }

  Future deleteAll() async {
    final finder = Finder(filter: Filter.notNull("timestamp"));
    int count = await _receiptFolder.delete(await _db, finder: finder);
    print("deleted $count lines");
  }

  Future<List<Receipt>> getAllReceipts() async {
    final recordSnapshot = await _receiptFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      Receipt receipt = Receipt.fromMap(snapshot.value);
      receipt.id = snapshot.key;
      return receipt;
    }).toList();
  }

  Future<List<Receipt>> getCurrentMonthReceipts() async {
    final now = DateTime.now();
    final finder = Finder(
        filter: Filter.greaterThanOrEquals("timestamp",
            Timestamp.fromDateTime(DateTime(now.year, now.month))));
    final recordSnapshot = await _receiptFolder.find(await _db, finder: finder);
    return recordSnapshot.map((snapshot) {
      Receipt receipt = Receipt.fromMap(snapshot.value);
      receipt.id = snapshot.key;
      return receipt;
    }).toList();
  }
}

final fakeBeef = new ReceiptItem(emission: 40, quantity: 1, foodType: "beef");
final fakeVegetables =
    new ReceiptItem(emission: 1, quantity: 2, foodType: "vegetables");
final fakeChicken =
    new ReceiptItem(emission: 5, quantity: 1, foodType: "chicken");
final fakeRice = new ReceiptItem(emission: 4, quantity: 1, foodType: "rice");
final fakeCoffee =
    new ReceiptItem(emission: 16, quantity: 1, foodType: "coffee");
final fakeMilk = new ReceiptItem(emission: 3, quantity: 1, foodType: "milk");

final fakeData = [
  new Receipt(
      timestamp: DateTime(2020, 4),
      items: [fakeBeef, fakeChicken, fakeRice, fakeVegetables],
      totalEmission: 50),
  new Receipt(
      timestamp: DateTime(2020, 4),
      items: [fakeBeef, fakeRice, fakeVegetables],
      totalEmission: 45),
  new Receipt(
      timestamp: DateTime(2020, 3),
      items: [fakeBeef, fakeChicken, fakeVegetables],
      totalEmission: 46),
  new Receipt(
      timestamp: DateTime(2020, 3),
      items: [fakeBeef, fakeRice, fakeVegetables],
      totalEmission: 45),
  new Receipt(
      timestamp: DateTime(2020, 2),
      items: [fakeChicken, fakeRice, fakeVegetables, fakeMilk],
      totalEmission: 13),
  new Receipt(
      timestamp: DateTime(2020, 2),
      items: [fakeBeef, fakeChicken],
      totalEmission: 45),
  new Receipt(
      timestamp: DateTime(2020, 1),
      items: [fakeChicken, fakeRice, fakeCoffee],
      totalEmission: 25),
  new Receipt(
      timestamp: DateTime(2020, 1),
      items: [fakeBeef, fakeRice],
      totalEmission: 44),
];
