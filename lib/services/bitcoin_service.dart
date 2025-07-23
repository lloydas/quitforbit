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

  // Send Bitcoin to another wallet
  Future<BitcoinTransactionModel> sendBitcoin({
    required String userId,
    required String recipientAddress,
    required double bitcoinAmount,
    String? note,
  }) async {
    try {
      // Validate recipient address
      if (!isValidBitcoinAddress(recipientAddress)) {
        throw Exception('Invalid Bitcoin address: $recipientAddress');
      }

      // Check user balance
      final userBalance = await getUserBitcoinBalance(userId);
      final networkFee = await estimateNetworkFee(bitcoinAmount);
      final totalRequired = bitcoinAmount + networkFee;

      if (userBalance < totalRequired) {
        throw Exception(
          'Insufficient balance. Required: $totalRequired BTC, Available: $userBalance BTC',
        );
      }

      // Convert Bitcoin amount to USD for record keeping
      final usdAmount = await bitcoinToUsd(bitcoinAmount);

      // Create send transaction
      final transaction = BitcoinTransactionModel.createSendTransaction(
        userId: userId,
        amount: usdAmount,
        bitcoinAmount: bitcoinAmount,
        recipientAddress: recipientAddress,
        networkFee: networkFee,
      );

      // Save transaction to Firestore
      final docRef = await _firestore
          .collection('bitcoin_transactions')
          .add(transaction.toFirestore());

      // Process the transaction
      if (_isTestMode) {
        await _simulateTestnetSendTransaction(docRef.id, transaction);
      } else {
        await _processRealSendTransaction(docRef.id, transaction);
      }

      return transaction.copyWith(status: TransactionStatus.processing);
    } catch (e) {
      print('Error sending Bitcoin: $e');
      rethrow;
    }
  }

  // Get user's Bitcoin balance
  Future<double> getUserBitcoinBalance(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return 0.0;

      final userData = userDoc.data()!;
      return (userData['totalBitcoinEarned'] ?? 0.0).toDouble();
    } catch (e) {
      print('Error fetching user balance: $e');
      return 0.0;
    }
  }

  // Estimate network fee for transaction
  Future<double> estimateNetworkFee(double bitcoinAmount) async {
    try {
      if (_isTestMode) {
        // For testnet, use a minimal fee
        return 0.00001; // 0.00001 BTC fee for testnet
      } else {
        // In production, implement proper fee estimation
        // This could integrate with fee estimation APIs
        return 0.0001; // Placeholder mainnet fee
      }
    } catch (e) {
      print('Error estimating network fee: $e');
      return 0.0001; // Fallback fee
    }
  }

  // Convert Bitcoin amount to USD
  Future<double> bitcoinToUsd(double bitcoinAmount) async {
    final btcPrice = await getBitcoinPrice();
    return bitcoinAmount * btcPrice;
  }

  // Simulate testnet send transaction
  Future<void> _simulateTestnetSendTransaction(
    String transactionId,
    BitcoinTransactionModel transaction,
  ) async {
    try {
      // Simulate processing delay
      await Future.delayed(const Duration(seconds: 3));

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

      // Deduct from user's balance
      await _updateUserBalance(
        transaction.userId,
        -transaction.amount,
        -(transaction.bitcoinAmount +
            (transaction.metadata['networkFee'] ?? 0.0)),
      );

      print('Testnet send transaction completed: $fakeHash');
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

  // Process real send transaction (placeholder for production)
  Future<void> _processRealSendTransaction(
    String transactionId,
    BitcoinTransactionModel transaction,
  ) async {
    // TODO: Integrate with actual Bitcoin wallet/payment processor
    throw UnimplementedError(
      'Real Bitcoin send transactions not implemented in MVP',
    );
  }

  // Update user balance (can be positive or negative)
  Future<void> _updateUserBalance(
    String userId,
    double usdAmountDelta,
    double bitcoinAmountDelta,
  ) async {
    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) return;

      final currentEarned = (userDoc.data()?['totalEarned'] ?? 0.0).toDouble();
      final currentBitcoinEarned =
          (userDoc.data()?['totalBitcoinEarned'] ?? 0.0).toDouble();

      final newEarned = currentEarned + usdAmountDelta;
      final newBitcoinEarned = currentBitcoinEarned + bitcoinAmountDelta;

      transaction.update(userRef, {
        'totalEarned': newEarned > 0 ? newEarned : 0.0,
        'totalBitcoinEarned': newBitcoinEarned > 0 ? newBitcoinEarned : 0.0,
      });
    });
  }

  // Get maximum sendable amount (balance minus estimated fee)
  Future<double> getMaxSendableAmount(String userId) async {
    final balance = await getUserBitcoinBalance(userId);
    final minFee = await estimateNetworkFee(
      0.0001,
    ); // Estimate fee for small amount
    return (balance - minFee).clamp(0.0, balance);
  }

  // Validate if user can send specific amount
  Future<bool> canSendAmount(String userId, double bitcoinAmount) async {
    final balance = await getUserBitcoinBalance(userId);
    final fee = await estimateNetworkFee(bitcoinAmount);
    return balance >= (bitcoinAmount + fee);
  }
}
