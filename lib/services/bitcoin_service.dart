import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bitcoin_transaction_model.dart';
import '../models/milestone_model.dart';

class BitcoinService {
  static const String _testnetApiUrl = 'https://testnet-api.smartbit.com.au/v1';
  static const bool _isTestMode = true; // Set to false for mainnet

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a simple Bitcoin testnet address (simplified for MVP)
  String generateTestnetAddress() {
    // For MVP, generate a simple testnet address format
    // In production, use proper Bitcoin libraries like bitcoin_flutter
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final addressSuffix = String.fromCharCodes(
      Iterable.generate(
        25,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );

    return 'tb1q$addressSuffix'; // Testnet bech32 format
  }

  // Get current Bitcoin price in USD (for conversion calculations)
  Future<double> getBitcoinPrice() async {
    try {
      // For MVP, use a mock price or simple API
      // In production, use CoinGecko or similar reliable API
      final response = await http.get(
        Uri.parse('https://api.coindesk.com/v1/bpi/currentprice.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final priceString = data['bpi']['USD']['rate_float'];
        return priceString.toDouble();
      }

      // Fallback price for MVP
      return 45000.0;
    } catch (e) {
      print('Error fetching Bitcoin price: $e');
      return 45000.0; // Fallback price
    }
  }

  // Convert USD amount to Bitcoin
  Future<double> usdToBitcoin(double usdAmount) async {
    final btcPrice = await getBitcoinPrice();
    return usdAmount / btcPrice;
  }

  // Process milestone reward (MVP implementation)
  Future<BitcoinTransactionModel> processMilestoneReward({
    required String userId,
    required MilestoneModel milestone,
    required String bitcoinAddress,
  }) async {
    try {
      // Convert USD amount to Bitcoin
      final bitcoinAmount = await usdToBitcoin(milestone.bitcoinAmount);

      // Create transaction record
      final transaction = BitcoinTransactionModel.createMilestoneTransaction(
        userId: userId,
        milestoneId: milestone.id,
        amount: milestone.bitcoinAmount,
        bitcoinAmount: bitcoinAmount,
        bitcoinAddress: bitcoinAddress,
      );

      // Save transaction to Firestore
      final docRef = await _firestore
          .collection('bitcoin_transactions')
          .add(transaction.toFirestore());

      final savedTransaction = transaction.copyWith(
        status: TransactionStatus.processing,
      );

      // For MVP testnet: simulate Bitcoin transaction
      if (_isTestMode) {
        await _simulateTestnetTransaction(docRef.id, savedTransaction);
      } else {
        // In production: integrate with actual Bitcoin payment processor
        await _processRealBitcoinTransaction(docRef.id, savedTransaction);
      }

      return savedTransaction.copyWith();
    } catch (e) {
      print('Error processing milestone reward: $e');
      rethrow;
    }
  }

  // Simulate testnet transaction for MVP
  Future<void> _simulateTestnetTransaction(
    String transactionId,
    BitcoinTransactionModel transaction,
  ) async {
    try {
      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Generate fake transaction hash for testnet
      final fakeHash = _generateFakeTransactionHash();

      // Update transaction as completed
      await _firestore
          .collection('bitcoin_transactions')
          .doc(transactionId)
          .update({
            'status': TransactionStatus.completed.name,
            'transactionHash': fakeHash,
            'completedAt': Timestamp.now(),
          });

      // Update user's total earned
      await _updateUserEarnings(
        transaction.userId,
        transaction.amount,
        transaction.bitcoinAmount,
      );

      print('Testnet transaction completed: $fakeHash');
    } catch (e) {
      // Mark transaction as failed
      await _firestore
          .collection('bitcoin_transactions')
          .doc(transactionId)
          .update({
            'status': TransactionStatus.failed.name,
            'errorMessage': e.toString(),
          });
      rethrow;
    }
  }

  // Process real Bitcoin transaction (placeholder for production)
  Future<void> _processRealBitcoinTransaction(
    String transactionId,
    BitcoinTransactionModel transaction,
  ) async {
    // TODO: Integrate with Bitcoin payment processor (BTCPay Server, etc.)
    // For now, throw an error since this is MVP testnet only
    throw UnimplementedError(
      'Real Bitcoin transactions not implemented in MVP',
    );
  }

  // Update user's total earnings
  Future<void> _updateUserEarnings(
    String userId,
    double usdAmount,
    double bitcoinAmount,
  ) async {
    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;

      final currentEarned = (userDoc.data()?['totalEarned'] ?? 0.0).toDouble();
      final currentBitcoinEarned =
          (userDoc.data()?['totalBitcoinEarned'] ?? 0.0).toDouble();

      transaction.update(userRef, {
        'totalEarned': currentEarned + usdAmount,
        'totalBitcoinEarned': currentBitcoinEarned + bitcoinAmount,
      });
    });
  }

  // Get user's transaction history
  Future<List<BitcoinTransactionModel>> getUserTransactions(
    String userId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('bitcoin_transactions')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => BitcoinTransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching user transactions: $e');
      return [];
    }
  }

  // Get pending transactions
  Future<List<BitcoinTransactionModel>> getPendingTransactions(
    String userId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('bitcoin_transactions')
              .where('userId', isEqualTo: userId)
              .where(
                'status',
                whereIn: [
                  TransactionStatus.pending.name,
                  TransactionStatus.processing.name,
                ],
              )
              .get();

      return snapshot.docs
          .map((doc) => BitcoinTransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching pending transactions: $e');
      return [];
    }
  }

  // Validate Bitcoin address format
  bool isValidBitcoinAddress(String address) {
    // Simple validation for MVP
    // In production, use proper Bitcoin address validation
    if (address.isEmpty) return false;

    // Testnet addresses typically start with 'tb1q' or 'm' or 'n' or '2'
    if (_isTestMode) {
      return address.startsWith('tb1q') ||
          address.startsWith('m') ||
          address.startsWith('n') ||
          address.startsWith('2');
    }

    // Mainnet addresses start with '1', '3', or 'bc1'
    return address.startsWith('1') ||
        address.startsWith('3') ||
        address.startsWith('bc1');
  }

  // Generate fake transaction hash for testing
  String _generateFakeTransactionHash() {
    const chars = 'abcdef0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        64,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Check if service is in test mode
  bool get isTestMode => _isTestMode;

  // Get network name for UI display
  String get networkName => _isTestMode ? 'Testnet' : 'Mainnet';

  // Process signup bonus
  Future<BitcoinTransactionModel> processSignupBonus({
    required String userId,
    required String bitcoinAddress,
  }) async {
    const signupBonusUSD = 1.0; // $1 signup bonus

    try {
      final bitcoinAmount = await usdToBitcoin(signupBonusUSD);

      final transaction = BitcoinTransactionModel.createSignupTransaction(
        userId: userId,
        amount: signupBonusUSD,
        bitcoinAmount: bitcoinAmount,
        bitcoinAddress: bitcoinAddress,
      );

      // Save and process transaction
      final docRef = await _firestore
          .collection('bitcoin_transactions')
          .add(transaction.toFirestore());

      if (_isTestMode) {
        await _simulateTestnetTransaction(docRef.id, transaction);
      }

      return transaction;
    } catch (e) {
      print('Error processing signup bonus: $e');
      rethrow;
    }
  }
}
