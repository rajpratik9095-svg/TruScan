class Tip {
  final String id;
  final String title;
  final String content;
  final String category; // health, nutrition, product
  final String imageUrl;
  final DateTime createdAt;

  Tip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category,
    'imageUrl': imageUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Tip.fromJson(Map<String, dynamic> json) => Tip(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    category: json['category'],
    imageUrl: json['imageUrl'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class TipsDatabase {
  static final List<Tip> _tips = [
    Tip(
      id: '1',
      title: 'Stay Hydrated',
      content: 'Drinking adequate water is essential for your health. Aim for 8 glasses (2 liters) of water per day. Water helps maintain body temperature, transport nutrients, and remove waste.',
      category: 'health',
      imageUrl: 'https://via.placeholder.com/400x200.png?text=Stay+Hydrated',
    ),
    Tip(
      id: '2',
      title: 'Read Nutrition Labels',
      content: 'Always check the nutrition label before buying packaged foods. Look for low sodium, low sugar, and high fiber content. Avoid products with trans fats and artificial additives.',
      category: 'nutrition',
      imageUrl: 'https://via.placeholder.com/400x200.png?text=Nutrition+Labels',
    ),
    Tip(
      id: '3',
      title: 'Choose Whole Grains',
      content: 'Whole grains provide more nutrients and fiber than refined grains. Look for products with "whole grain" or "100% whole wheat" as the first ingredient.',
      category: 'nutrition',
      imageUrl: 'https://via.placeholder.com/400x200.png?text=Whole+Grains',
    ),
    Tip(
      id: '4',
      title: 'Check Expiry Dates',
      content: 'Always verify the manufacturing and expiry dates on product packaging. Consuming expired products can lead to foodborne illnesses. Store products properly to maintain freshness.',
      category: 'product',
      imageUrl: 'https://via.placeholder.com/400x200.png?text=Expiry+Dates',
    ),
    Tip(
      id: '5',
      title: 'Eat Colorful Vegetables',
      content: 'Different colored vegetables provide different nutrients. Aim to eat a rainbow of vegetables daily to get a wide variety of vitamins, minerals, and antioxidants.',
      category: 'health',
      imageUrl: 'https://via.placeholder.com/400x200.png?text=Colorful+Vegetables',
    ),
    Tip(
      id: '6',
      title: 'Understand Serving Sizes',
      content: 'Nutrition labels are based on serving sizes. Compare the serving size to the amount you actually eat. This helps you accurately track your nutrient intake.',
      category: 'nutrition',
      imageUrl: 'https://via.placeholder.com/400x200.png?text=Serving+Sizes',
    ),
    Tip(
      id: '7',
      title: 'Look for Certifications',
      content: 'Quality certifications like organic, non-GMO, and fair trade indicate higher standards. Check for recognized certification logos on product packaging.',
      category: 'product',
      imageUrl: 'https://via.placeholder.com/400x200.png?text=Certifications',
    ),
    Tip(
      id: '8',
      title: 'Limit Processed Foods',
      content: 'Highly processed foods often contain excessive sodium, sugar, and unhealthy fats. Choose fresh, whole foods whenever possible for better nutrition.',
      category: 'health',
      imageUrl: 'https://via.placeholder.com/400x200.png?text=Limit+Processed+Foods',
    ),
  ];

  static List<Tip> getAllTips() => _tips;

  static List<Tip> getTipsByCategory(String category) {
    return _tips.where((tip) => tip.category == category).toList();
  }

  static List<String> getCategories() {
    return _tips.map((tip) => tip.category).toSet().toList();
  }
}
