import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harcama Takip Uygulaması',
      home: ExpenseTracker(),
    );
  }
}

class ExpenseTracker extends StatefulWidget {
  @override
  _ExpenseTrackerState createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker> {
  Map<String, List<Map<String, dynamic>>> expenses = {};

  void addExpense(String category, double amount) {
    setState(() {
      if (!expenses.containsKey(category)) {
        expenses[category] = [];
      }
      expenses[category]!.add({'amount': amount, 'date': DateTime.now()});
    });
  }

  void deleteExpense(String category, int index) {
    setState(() {
      expenses[category]!.removeAt(index);
      if (expenses[category]!.isEmpty) {
        expenses.remove(category);
      }
    });
  }

  double getTotalExpense(String category) {
    double total = 0;
    if (expenses.containsKey(category)) {
      for (var expense in expenses[category]!) {
        total += expense['amount'];
      }
    }
    return total;
  }

  double getTotalAllExpenses() {
    double total = 0;
    expenses.values.forEach((categoryExpenses) {
      categoryExpenses.forEach((expense) {
        total += expense['amount'];
      });
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Harcama Takip - Toplam: ${getTotalAllExpenses().toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.red,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          var category = expenses.keys.toList()[index];
          return ListTile(
            leading: Icon(
              Icons.circle,
              color: Colors.red,
            ),
            title: Text(
              category,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Toplam Harcama: ${getTotalExpense(category).toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteExpense(category, 0); 
                  },
                ),
                IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpenseDetails(category: category, expenses: expenses[category]!),
                      ),
                    );
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseDetails(category: category, expenses: expenses[category]!),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (BuildContext context) {
              String category = '';
              String amount = '';
              return AlertDialog(
                title: Text('Yeni Harcama Ekle'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Kategori'),
                      onChanged: (value) {
                        category = value;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Miktar'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        amount = value;
                      },
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('İptal'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, {'category': category, 'amount': double.tryParse(amount) ?? 0});
                    },
                    child: Text('Ekle'),
                  ),
                ],
              );
            },
          );
          if (result != null && result['category'] != null && result['amount'] != null) {
            addExpense(result['category'], result['amount']);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class ExpenseDetails extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> expenses;

  ExpenseDetails({required this.category, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Harcamaları'),
      ),
      body: ListView.builder(
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          var expense = expenses[index];
          var formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(expense['date']); 
          return ListTile(
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Tarih: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red), 
                ),
                TextSpan(
                  text: formattedDate,
                  style: TextStyle(color: Colors.black), 
                ),
              ],
            ),
          ),
          subtitle: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Miktar: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
                TextSpan(
                  text: '${expense['amount']}',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );
        },
      ),
    );
  }
}
