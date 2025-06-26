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