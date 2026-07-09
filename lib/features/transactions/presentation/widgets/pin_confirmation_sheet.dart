import 'package:eazywallet/features/transactions/application/pin_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

Future<bool?> showPinConfirmationSheet(BuildContext context, PinStore store) {
  store.clear();
  final controller = TextEditingController();

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Observer(
          builder: (context) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Transaction PIN',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text('Enter your 4-digit PIN to confirm this report.'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: PinStore.pinLength,
                  enabled: !store.isLocked.value,
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    counterText: '',
                    border: const OutlineInputBorder(),
                    errorText: store.errorMessage.value,
                  ),
                  onChanged: store.setPin,
                ),
                if (store.isLocked.value)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Too many wrong attempts. PIN entry is locked for this session.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        store.isPinComplete.value &&
                            !store.isVerifying.value &&
                            !store.isLocked.value
                        ? () async {
                            FocusScope.of(context).unfocus();
                            final verified = await store.verify();
                            controller.clear();
                            if (verified && context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          }
                        : null,
                    child: store.isVerifying.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Confirm'),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  ).then((result)async {
    await Future.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    return result;
  });
}
