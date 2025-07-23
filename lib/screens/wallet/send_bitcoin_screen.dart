import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/streak_provider.dart';
import '../../models/bitcoin_transaction_model.dart';
import '../../widgets/common/custom_button.dart';

class SendBitcoinScreen extends ConsumerStatefulWidget {
  const SendBitcoinScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SendBitcoinScreen> createState() => _SendBitcoinScreenState();
}

class _SendBitcoinScreenState extends ConsumerState<SendBitcoinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  bool _isLoading = false;
  double? _networkFee;
  double? _userBalance;

  @override
  void initState() {
    super.initState();
    _loadUserBalance();
    _amountController.addListener(_updateFeeEstimate);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadUserBalance() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    final bitcoinService = ref.read(bitcoinServiceProvider);
    final balance = await bitcoinService.getUserBitcoinBalance(user.id);

    if (mounted) {
      setState(() {
        _userBalance = balance;
      });
    }
  }

  Future<void> _updateFeeEstimate() async {
    final amountText = _amountController.text;
    if (amountText.isEmpty) {
      setState(() {
        _networkFee = null;
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() {
        _networkFee = null;
      });
      return;
    }

    final bitcoinService = ref.read(bitcoinServiceProvider);
    final fee = await bitcoinService.estimateNetworkFee(amount);

    if (mounted) {
      setState(() {
        _networkFee = fee;
      });
    }
  }

  void _scanQRCode() {
    // TODO: Implement QR scanner in a future update
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Scanner will be available in a future update'),
      ),
    );
  }

  bool _validateForm() {
    return _formKey.currentState?.validate() ?? false;
  }

  Future<void> _sendBitcoin() async {
    if (!_validateForm()) return;

    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      _showErrorDialog('User not found');
      return;
    }

    final recipientAddress = _addressController.text.trim();
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showErrorDialog('Please enter a valid amount');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bitcoinService = ref.read(bitcoinServiceProvider);

      // Check if user can send this amount
      final canSend = await bitcoinService.canSendAmount(user.id, amount);
      if (!canSend) {
        throw Exception('Insufficient balance for this transaction');
      }

      final transaction = await bitcoinService.sendBitcoin(
        userId: user.id,
        recipientAddress: recipientAddress,
        bitcoinAmount: amount,
        note:
            _noteController.text.trim().isNotEmpty
                ? _noteController.text.trim()
                : null,
      );

      if (mounted) {
        _showSuccessDialog(transaction);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(BitcoinTransactionModel transaction) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('✅ Transaction Sent'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount: ${transaction.bitcoinAmount} BTC'),
                Text('To: ${transaction.bitcoinAddress}'),
                const SizedBox(height: 8),
                const Text(
                  'Your transaction is being processed and will appear in your transaction history shortly.',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close send screen
                },
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  void _setMaxAmount() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bitcoinService = ref.read(bitcoinServiceProvider);
      final maxAmount = await bitcoinService.getMaxSendableAmount(user.id);

      if (mounted) {
        _amountController.text = maxAmount.toStringAsFixed(8);
        _updateFeeEstimate();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error calculating maximum amount: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Bitcoin'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildSendForm(),
    );
  }

  Widget _buildSendForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 24),
            _buildRecipientSection(),
            const SizedBox(height: 24),
            _buildAmountSection(),
            const SizedBox(height: 16),
            _buildNoteSection(),
            const SizedBox(height: 24),
            _buildFeeSection(),
            const SizedBox(height: 32),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Available Balance',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              _userBalance != null
                  ? '${_userBalance!.toStringAsFixed(8)} BTC'
                  : 'Loading...',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            if (_userBalance != null) ...[
              const SizedBox(height: 4),
              FutureBuilder<double>(
                future: ref
                    .read(bitcoinServiceProvider)
                    .bitcoinToUsd(_userBalance!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      '≈ \$${snapshot.data!.toStringAsFixed(2)} USD',
                      style: const TextStyle(color: Colors.grey),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipient Address',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          decoration: InputDecoration(
            hintText: 'Enter Bitcoin address',
            border: const OutlineInputBorder(),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanQRCode,
                  tooltip: 'Scan QR Code',
                ),
                IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      _addressController.text = data!.text!;
                    }
                  },
                  tooltip: 'Paste',
                ),
              ],
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a recipient address';
            }

            final bitcoinService = ref.read(bitcoinServiceProvider);
            if (!bitcoinService.isValidBitcoinAddress(value.trim())) {
              return 'Invalid Bitcoin address';
            }

            return null;
          },
          onChanged: (_) => _validateForm(),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Amount (BTC)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: _setMaxAmount, child: const Text('MAX')),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(
            hintText: '0.00000000',
            border: OutlineInputBorder(),
            suffixText: 'BTC',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an amount';
            }

            final amount = double.tryParse(value.trim());
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }

            if (_userBalance != null && amount > _userBalance!) {
              return 'Amount exceeds available balance';
            }

            return null;
          },
          onChanged: (_) {
            _validateForm();
            _updateFeeEstimate();
          },
        ),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note (Optional)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noteController,
          decoration: const InputDecoration(
            hintText: 'Add a note for your records',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildFeeSection() {
    if (_networkFee == null) return const SizedBox.shrink();

    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Network Fee:'),
                Text('${_networkFee!.toStringAsFixed(8)} BTC'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(_networkFee! + (double.tryParse(_amountController.text) ?? 0.0)).toStringAsFixed(8)} BTC',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return CustomButton(
      text: 'Send Bitcoin',
      onPressed: _isLoading ? null : _sendBitcoin,
      isLoading: _isLoading,
      icon: Icons.send,
    );
  }
}
