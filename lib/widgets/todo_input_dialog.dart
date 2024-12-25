import 'package:flutter/cupertino.dart';

class TodoInputDialog extends StatefulWidget {
  final Function(String title, String? details, DateTime? dueDate) onSubmit;

  const TodoInputDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<TodoInputDialog> createState() => _TodoInputDialogState();
}

class _TodoInputDialogState extends State<TodoInputDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  DateTime? _selectedDate;

  void _handleSubmit() {
    if (_titleController.text.isNotEmpty) {
      widget.onSubmit(
        _titleController.text,
        _detailsController.text.isEmpty ? null : _detailsController.text,
        _selectedDate,
      );
      Navigator.of(context).pop();
    }
  }

  void _showDatePicker() {
    // Store initial date when opening picker
    final initialDate = _selectedDate ?? DateTime.now();
    
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => Center(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: initialDate,
                  mode: CupertinoDatePickerMode.dateAndTime,
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      _selectedDate = newDateTime;
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: const Text('جەزىملەشتۈرۈش'),
                onPressed: () {
                  // Ensure _selectedDate is set to initial date if no changes made
                  if (_selectedDate == null) {
                    setState(() {
                      _selectedDate = initialDate;
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'يېڭى ۋەزىپە',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'UKIJ',
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ماۋزۇ',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _titleController,
                      placeholder: 'ۋەزىپە ماۋزۇسى',
                      padding: const EdgeInsets.all(12),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'تەپسىلاتلار',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _detailsController,
                      placeholder: 'تەپسىلاتلارنى قوشۇش',
                      padding: const EdgeInsets.all(12),
                      minLines: 3,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'تاماملاش ۋاقتى',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showDatePicker,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground,
                          border: Border.all(
                            color: CupertinoColors.systemGrey4,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.calendar,
                              color: CupertinoColors.systemGrey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDate == null
                                  ? 'ۋاقىت تاللانمىدى'
                                  : _formatDate(_selectedDate!),
                              style: const TextStyle(
                                color: CupertinoColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.systemGrey5,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: const Text('ئەمەلدىن قالدۇرۇش'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton.filled(
                    child: const Text('ۋەزىپە قوشۇش'),
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${_formatTime(date)}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
