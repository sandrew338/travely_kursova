import 'package:cloud_firestore/cloud_firestore.dart';

/// Seed excursions data to Firebase
/// Call this function once to populate your Firestore with sample data
class SeedExcursions {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'excursions';

  /// Seed sample excursions to Firestore
  static Future<void> seedExcursions() async {
    final excursions = [
      {
        'name': 'Villa Kayu Lama',
        'description':
            'Experience the beautiful coastal views and historic architecture of this stunning seaside villa. Perfect for romantic getaways and photography enthusiasts.',
        'destination': 'Bali, Indonesia',
        'imageUrl':
            'https://images.unsplash.com/photo-1596484552834-6a58f850e0a1?w=800',
        'status': 'active',
        'startDate': Timestamp.fromDate(DateTime(2025, 12, 15)),
        'endDate': Timestamp.fromDate(DateTime(2025, 12, 22)),
        'price': 799.0,
        'rating': 3.5,
        'duration': '7 days',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'Beautiful mountains',
        'description':
            'Discover breathtaking mountain landscapes with guided hiking tours through pristine alpine trails. Witness stunning sunrises and connect with nature.',
        'destination': 'Swiss Alps',
        'imageUrl':
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        'status': 'active',
        'startDate': Timestamp.fromDate(DateTime(2025, 1, 5)),
        'endDate': Timestamp.fromDate(DateTime(2025, 1, 15)),
        'price': 1299.0,
        'rating': 4.5,
        'duration': '10 days',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'An incredible bay',
        'description':
            'Explore the crystal-clear waters and hidden coves of this spectacular bay. Perfect for snorkeling, kayaking, and beach relaxation.',
        'destination': 'Ha Long Bay, Vietnam',
        'imageUrl':
            'https://images.unsplash.com/photo-1528127269322-539801943592?w=800',
        'status': 'active',
        'startDate': Timestamp.fromDate(DateTime(2025, 2, 1)),
        'endDate': Timestamp.fromDate(DateTime(2025, 2, 10)),
        'price': 899.0,
        'rating': 4.5,
        'duration': '9 days',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'Ancient village',
        'description':
            'Step back in time exploring traditional villages with centuries-old architecture. Experience local culture, crafts, and authentic cuisine.',
        'destination': 'Shirakawa-go, Japan',
        'imageUrl':
            'https://images.unsplash.com/photo-1545569341-9eb8b30979d9?w=800',
        'status': 'active',
        'startDate': Timestamp.fromDate(DateTime(2025, 3, 10)),
        'endDate': Timestamp.fromDate(DateTime(2025, 3, 17)),
        'price': 1499.0,
        'rating': 4.5,
        'duration': '7 days',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'Lavender fields',
        'description':
            'Immerse yourself in endless purple fields during lavender season. Visit local distilleries and enjoy the aromatic beauty of Provence.',
        'destination': 'Provence, France',
        'imageUrl':
            'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800',
        'status': 'active',
        'startDate': Timestamp.fromDate(DateTime(2025, 6, 15)),
        'endDate': Timestamp.fromDate(DateTime(2025, 6, 22)),
        'price': 1099.0,
        'rating': 4.5,
        'duration': '7 days',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'Kamianets Podilskyi',
        'description':
            'Discover the medieval fortress city with its impressive castle overlooking the canyon. Rich history and stunning architecture await.',
        'destination': 'Ukraine',
        'imageUrl':
            'https://images.unsplash.com/photo-1552832230-c0197dd311b5?w=800',
        'status': 'active',
        'startDate': Timestamp.fromDate(DateTime(2025, 5, 1)),
        'endDate': Timestamp.fromDate(DateTime(2025, 5, 5)),
        'price': 299.0,
        'rating': 4.5,
        'duration': '4 days',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'Santorini Sunset',
        'description':
            'Experience the world-famous sunsets over the caldera. Explore white-washed villages, black sand beaches, and ancient ruins.',
        'destination': 'Santorini, Greece',
        'imageUrl':
            'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800',
        'status': 'active',
        'startDate': Timestamp.fromDate(DateTime(2025, 7, 1)),
        'endDate': Timestamp.fromDate(DateTime(2025, 7, 8)),
        'price': 1399.0,
        'rating': 4.9,
        'duration': '7 days',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
      {
        'name': 'Northern Lights',
        'description':
            'Chase the aurora borealis across the Arctic tundra. Stay in glass igloos and experience this natural wonder at its best.',
        'destination': 'Lapland, Finland',
        'imageUrl':
            'https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800',
        'status': 'active',
        'startDate': Timestamp.fromDate(DateTime(2025, 12, 1)),
        'endDate': Timestamp.fromDate(DateTime(2025, 12, 8)),
        'price': 2499.0,
        'rating': 4.8,
        'duration': '7 days',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
    ];

    // Add each excursion to Firestore
    final batch = _firestore.batch();
    for (final excursion in excursions) {
      final docRef = _firestore.collection(_collection).doc();
      batch.set(docRef, excursion);
    }

    await batch.commit();
  }

  /// Delete all excursions (for testing)
  static Future<void> clearExcursions() async {
    final snapshot = await _firestore.collection(_collection).get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}

