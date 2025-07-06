part of '../common.dart';

const _circularLoader = Center(child: CircularProgressIndicator());

Widget _nullScreenMessage(String message){
  return Center(
    child :DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.greenAccent.shade100 ,
        borderRadius: BorderRadius.circular(5)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(message,
          style: const TextStyle(
            color: Colors.black54 ,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    )
  );
}