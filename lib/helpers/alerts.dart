part of 'helpers.dart';

showLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const AlertDialog(
      title: Text('Wait...'),
      content: LinearProgressIndicator(),
    ),
  );
}

showAlert(BuildContext context, String title, String message) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        MaterialButton(
          child: const Text('Ok'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
