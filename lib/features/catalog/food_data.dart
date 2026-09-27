/// Katalog konten statis — bukan pelacakan kalori.
/// Aset gambar dari design mockup (Pexels License).
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.asset,
    required this.kcal,
    required this.portion,
    required this.desc,
    required this.ingredients,
    required this.tip,
    required this.isDrink,
    this.tags = const [],
    this.badge,
  });

  final String id;
  final String name;
  final String asset;
  final int kcal;

  /// Porsi per serving, contoh: '250 g' / '300 ml'.
  final String portion;
  final String desc;
  final List<String> ingredients;
  final String tip;
  final bool isDrink;

  /// Filter chips di katalog (frame 09/10).
  final List<String> tags;

  /// Chip tambahan di detail (frame 11), mis. 'Vegan'.
  final String? badge;
}

const List<FoodItem> kFoods = [
  FoodItem(
    id: 'salad', name: 'Salad Sayur Segar', asset: 'assets/food/food-salad.jpg',
    kcal: 120, portion: '250 g', tags: ['Sarapan'],
    desc: 'Campuran sayur segar dengan dressing lemon ringan.',
    ingredients: ['Selada', 'Tomat', 'Timun', 'Dressing lemon'],
    tip: 'Tambah telur rebus biar lebih kenyang.',
    isDrink: false, badge: 'Vegan',
  ),
  FoodItem(
    id: 'poke', name: 'Poke Bowl Tahu', asset: 'assets/food/food-poke.jpg',
    kcal: 320, portion: '350 g', tags: ['Makan malam'],
    desc: 'Mangkuk nasi merah dengan tahu panggang, alpukat, dan sayur rebus — kaya protein nabati, cocok jadi makan siang setelah jalan kaki.',
    ingredients: ['Tahu potong panggang — 100 g', 'Alpukat — ½ buah', 'Nasi merah — 100 g', 'Sayur rebus & wortel — secukupnya'],
    tip: 'Potong kecap asin jadi setengah porsi untuk menurunkan sodium tanpa mengurangi rasa.',
    isDrink: false, badge: 'Vegan',
  ),
  FoodItem(
    id: 'fruit', name: 'Buah Potong Segar', asset: 'assets/food/food-fruit.jpg',
    kcal: 95, portion: '200 g', tags: ['Cemilan'],
    desc: 'Aneka buah segar potong, manis alami.',
    ingredients: ['Pepaya', 'Melon', 'Nanas', 'Semangka'],
    tip: 'Makan buah utuh, bukan jus — seratnya kept.',
    isDrink: false, badge: 'Vegan',
  ),
  FoodItem(
    id: 'granola', name: 'Granola Yogurt', asset: 'assets/food/food-granola.jpg',
    kcal: 210, portion: '180 g', tags: ['Sarapan'],
    desc: 'Yogurt dengan granola renyah dan buah.',
    ingredients: ['Yogurt plain', 'Granola', 'Madu', 'Berry'],
    tip: 'Pilih yogurt plain tanpa gula tambahan.',
    isDrink: false,
  ),
  FoodItem(
    id: 'salmon', name: 'Salmon Panggang', asset: 'assets/food/food-salmon.jpg',
    kcal: 350, portion: '300 g', tags: ['Makan malam'],
    desc: 'Salmon panggang dengan sayuran, kaya omega-3.',
    ingredients: ['Salmon', 'Brokoli', 'Lemon', 'Lada hitam'],
    tip: 'Panggang, jangan goreng — hemat kalori.',
    isDrink: false,
  ),
  FoodItem(
    id: 'chicken', name: 'Ayam Bakar & Sayur', asset: 'assets/food/food-chicken.jpg',
    kcal: 290, portion: '320 g', tags: ['Makan malam'],
    desc: 'Ayam bakar tanpa kulit plus sayuran panggang.',
    ingredients: ['Dada ayam', 'Wortel', 'Buncis', 'Bawang putih'],
    tip: 'Buang kulit ayam sebelum makan.',
    isDrink: false,
  ),
];

const List<FoodItem> kDrinks = [
  FoodItem(
    id: 'matcha', name: 'Matcha Latte', asset: 'assets/food/drink-matcha.jpg',
    kcal: 120, portion: '250 ml', tags: ['Dingin'],
    desc: 'Matcha dengan susu rendah lemak.',
    ingredients: ['Bubuk matcha', 'Susu low-fat', 'Madu sedikit'],
    tip: 'Tanpa gula tambahan sudah enak.',
    isDrink: true,
  ),
  FoodItem(
    id: 'smoothie', name: 'Smoothie Hijau', asset: 'assets/food/drink-smoothie.jpg',
    kcal: 150, portion: '300 ml', tags: ['Dingin'],
    desc: 'Bayam, pisang, dan apel diblender halus.',
    ingredients: ['Bayam', 'Pisang', 'Apel', 'Air kelapa'],
    tip: 'Jangan saring — seratnya penting.',
    isDrink: true,
  ),
  FoodItem(
    id: 'juice', name: 'Jus Jeruk Segar', asset: 'assets/food/drink-juice.jpg',
    kcal: 90, portion: '250 ml', tags: ['Dingin'],
    desc: 'Perasan jeruk asli tanpa gula.',
    ingredients: ['Jeruk peras'],
    tip: 'Minum segera biar vitamin C tidak hilang.',
    isDrink: true,
  ),
  FoodItem(
    id: 'water', name: 'Air Detoks Lemon', asset: 'assets/food/drink-water.jpg',
    kcal: 5, portion: '500 ml', tags: ['Dingin', '< 50 kkal'],
    desc: 'Minuman terbaik: nol gula, nol kalori.',
    ingredients: ['Air', 'Irisan lemon'],
    tip: 'Target 8 gelas sehari.',
    isDrink: true,
  ),
  FoodItem(
    id: 'tea', name: 'Teh Herbal Hangat', asset: 'assets/food/drink-tea.jpg',
    kcal: 2, portion: '200 ml', tags: ['Hangat', '< 50 kkal'],
    desc: 'Teh hangat tanpa gula, menenangkan.',
    ingredients: ['Teh', 'Air panas'],
    tip: 'Minum 30 menit setelah makan.',
    isDrink: true,
  ),
  FoodItem(
    id: 'juices', name: 'Jus Campur Buah', asset: 'assets/food/drink-juices.jpg',
    kcal: 110, portion: '250 ml', tags: ['Dingin'],
    desc: 'Campuran buah segar warna-warni.',
    ingredients: ['Apel', 'Wortel', 'Jahe'],
    tip: 'Satu gelas sehari cukup.',
    isDrink: true,
  ),
];

FoodItem? findFood(String id) {
  for (final f in [...kFoods, ...kDrinks]) {
    if (f.id == id) return f;
  }
  return null;
}
