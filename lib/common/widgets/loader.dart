part of '../common.dart';

const _circularLoader = Center(child: CircularProgressIndicator());

Widget _nullScreenMessage(String message){
  return Center(
    child :Text(message,
      style: TextStyle(
        backgroundColor: Colors.blueAccent.shade200,
        color: Colors.blueAccent.shade700,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    )
  );
}