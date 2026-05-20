part of 'ui_util.dart';

const _circularLoader = Center(child: CircularProgressIndicator());

Widget _nullScreenMessage(String message) {
  return Builder(
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;

      return Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer,
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    },
  );
}
