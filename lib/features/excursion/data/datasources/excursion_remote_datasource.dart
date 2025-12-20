import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/excursion_model.dart';

/// Remote data source for excursion operations
abstract class ExcursionRemoteDataSource {
  Future<List<ExcursionModel>> getExcursions();
  Future<List<ExcursionModel>> getPopularExcursions({int limit = 10});
  Future<ExcursionModel> getExcursionById(String id);
  Future<List<ExcursionModel>> getUserExcursions(String userId);
  Future<ExcursionModel> createExcursion(ExcursionModel excursion);
  Future<ExcursionModel> updateExcursion(ExcursionModel excursion);
  Future<void> deleteExcursion(String id);
  Future<List<ExcursionModel>> searchExcursions(String query);
}

/// Implementation of ExcursionRemoteDataSource using Firestore
class ExcursionRemoteDataSourceImpl implements ExcursionRemoteDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'excursions';

  ExcursionRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ExcursionModel>> getExcursions() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExcursionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get excursions: $e');
    }
  }

  @override
  Future<List<ExcursionModel>> getPopularExcursions({int limit = 10}) async {
    try {
      // Simple query without composite index requirement
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      // Filter active status locally
      return snapshot.docs
          .map((doc) => ExcursionModel.fromFirestore(doc))
          .where((e) => e.status == 'active')
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get popular excursions: $e');
    }
  }

  @override
  Future<ExcursionModel> getExcursionById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        throw ServerException(message: 'Excursion not found');
      }

      return ExcursionModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to get excursion: $e');
    }
  }

  @override
  Future<List<ExcursionModel>> getUserExcursions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExcursionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get user excursions: $e');
    }
  }

  @override
  Future<ExcursionModel> createExcursion(ExcursionModel excursion) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(excursion.toFirestore());

      final doc = await docRef.get();
      return ExcursionModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to create excursion: $e');
    }
  }

  @override
  Future<ExcursionModel> updateExcursion(ExcursionModel excursion) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(excursion.id)
          .update(excursion.toFirestore());

      final doc =
          await _firestore.collection(_collection).doc(excursion.id).get();
      return ExcursionModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to update excursion: $e');
    }
  }

  @override
  Future<void> deleteExcursion(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete excursion: $e');
    }
  }

  @override
  Future<List<ExcursionModel>> searchExcursions(String query) async {
    try {
      // Search by name (case-insensitive using lowercase)
      final queryLower = query.toLowerCase();

      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'active')
          .get();

      // Filter locally for better search flexibility
      final results = snapshot.docs
          .map((doc) => ExcursionModel.fromFirestore(doc))
          .where((excursion) =>
              excursion.name.toLowerCase().contains(queryLower) ||
              excursion.destination.toLowerCase().contains(queryLower))
          .toList();

      return results;
    } catch (e) {
      throw ServerException(message: 'Failed to search excursions: $e');
    }
  }
}
