import 'package:eazywallet/features/transactions/application/pin_store.dart';
import 'package:eazywallet/features/transactions/application/report_form_store.dart';
import 'package:eazywallet/features/transactions/data/wallet_repo_impl.dart';
import 'package:eazywallet/features/transactions/domain/report_transaction_model.dart';
import 'package:eazywallet/features/transactions/domain/wallet_repo.dart';
import 'package:eazywallet/features/transactions/presentation/widgets/pin_confirmation_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ReportTransactionPage extends StatefulWidget {
  const ReportTransactionPage({super.key, required this.transactionId});

  final String transactionId;

  @override
  State<ReportTransactionPage> createState() => _ReportTransactionPageState();
}

class _ReportTransactionPageState extends State<ReportTransactionPage> {
  final WalletRepository walletRepository = WalletRepositoryImpl();
  late final ReportFormStore formStore = ReportFormStore(
    walletRepository,
    widget.transactionId,
  );
  late final PinStore pinStore = PinStore(walletRepository);

  Future<void> handleSubmit() async {
    final confirmed = await showPinConfirmationSheet(context, pinStore);
    if (confirmed != true) return;

    final success = await formStore.submit();

    if (success && mounted) {
      Navigator.of(context).pop(true);
      return;
    }

    if (formStore.errorMessage.value != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(formStore.errorMessage.value!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Transaction')),
      body: Observer(
        builder: (context) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reason', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<ReportReason>(
                  value: formStore.reason.value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('Select a reason'),
                  items: ReportReason.values
                      .map(
                        (reason) => DropdownMenuItem(
                          value: reason,
                          child: Text(reason.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) formStore.setReason(value);
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  maxLines: 5,
                  maxLength: ReportFormStore.maxDescriptionLength,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText:
                        'Describe what went wrong (minimum 20 characters)',
                    errorText:
                        formStore.description.value.isNotEmpty &&
                            !formStore.isDescriptionValid.value
                        ? 'Description must be between ${ReportFormStore.minDescriptionLength} and ${ReportFormStore.maxDescriptionLength} characters'
                        : null,
                  ),
                  onChanged: formStore.setDescription,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        formStore.isValid.value && !formStore.isSubmitting.value
                        ? handleSubmit
                        : null,
                    child: formStore.isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Submit Report'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
