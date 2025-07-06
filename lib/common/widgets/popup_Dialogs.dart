part of '../common.dart';

Future<bool?> _confirmationDialog(BuildContext context,
    {required String title,required String msg}){
  return showDialog(
      context: context,
      builder: (ctx)=>AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(onPressed: ()=> Navigator.of(context).pop(false),
              child: const Text("No")),
          ElevatedButton(onPressed: ()=>Navigator.of(context).pop(true),
              child: const Text("Yes"))
        ],
      )
  );
}

void _bottomNotifier(
    {required BuildContext context,required String message, VoidCallback? undo}){

  ScaffoldMessenger.of(context).removeCurrentSnackBar();

   ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(message),

      // duration: const Duration(seconds: 3),
      action: undo != null
          ? SnackBarAction(label: "UNDO", onPressed: undo)
          : null
    ),);
}