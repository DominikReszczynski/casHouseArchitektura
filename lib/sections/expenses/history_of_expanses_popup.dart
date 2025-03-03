import 'package:cas_house/models/expanses.dart';
import 'package:cas_house/sections/expenses/expanse_tile.dart';
import 'package:cas_house/sections/expenses/summarize_expanse.dart';
import 'package:flutter/material.dart';
import 'package:cas_house/providers/expanses_provider.dart';

class HistoryOfExpensesPopup extends StatefulWidget {
  final ExpansesProvider expansesProvider;
  const HistoryOfExpensesPopup({
    super.key,
    required this.expansesProvider,
  });

  @override
  State<HistoryOfExpensesPopup> createState() => _HistoryOfExpensesPopupState();
}

class _HistoryOfExpensesPopupState extends State<HistoryOfExpensesPopup> {
  bool isLoading = false;
  void fun() async {
    await widget.expansesProvider.fetchExpansesByAuthorExcludingCurrentMonth();
    setState(() {});
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    fun();
    setState(() {
      isLoading = false;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense history'),
      ),
      body: widget.expansesProvider.expansesListHistory.isEmpty
          ? const Center(child: Text('No expenses found.'))
          : ListView.builder(
              itemCount: widget.expansesProvider.expansesListHistory.length,
              itemBuilder: (context, outerIndex) {
                final Map<String, List<Expanses>> historyExpanses =
                    widget.expansesProvider.expansesListHistory;
                final yearMonths = historyExpanses.keys;
                final expansesMap = historyExpanses.entries;
                final yearMonth = expansesMap.elementAt(outerIndex).key;
                final expanses = expansesMap.elementAt(outerIndex).value;

                return Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              yearMonth,
                              style:
                              Theme.of(context).textTheme.titleLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.summarize),
                              tooltip: 'Summarize',
                              onPressed: () => Navigator.push(
                                      
                                context,
                                MaterialPageRoute(
                                    builder: (_) => SummarizeExpensesPopup(
                                        expansesProvider:
                                        widget.expansesProvider,
                                        date:
                                        yearMonth)),
                              ),
                            ),
                          ],
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: expanses.length,
                          itemBuilder: (context, index) {
                            final Expanses expanse = expanses.elementAt(index);
                            return ExpenseTile(
                              provider: widget.expansesProvider,
                              expanse: expanse,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
    );
  }
}
