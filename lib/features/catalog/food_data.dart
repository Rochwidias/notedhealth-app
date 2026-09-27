/// Katalog konten statis — bukan pelacakan kalori.
/// Aset gambar dari design mockup (Pexels License).
class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.asset,
    required this.kcal,
    required this.desc,
    required this.ingredients,
    required this.tip,
    required this.isDrink,
  });

  final String id;
  final String name;
  final String asset;
  final int kcal;
  final String desc;
  final List<String> ingredients;
  final String tip;
  final bool isDrink;
}

const List<FoodItem> kFoods = [
  FoodItem(
    id: 'salad', name: 'Salad Sayur Segar', asset: 'assets/food/food-salad.jpg',
    kcal: 120, desc: 'Campuran sayur segar dengan dressing lemon ringan.',
    ingredients: ['Selada', 'Tomat', 'Timun', 'Dressing lemon'],
    tip: 'Tambah telur rebus biar lebih kenyang.',
    isDrink: false,
  ),
  FoodItem(
    id: 'poke', name: 'Poke Bowl', asset: 'assets/food/food-poke.jpg',
    kcal: 320, desc: 'Nasi, ikan segar, dan sayur dalam satu mangkuk.',
    ingredients: ['Nasi', 'Tuna', 'Alpukat', 'Edamame'],
    tip: 'Minta saus terpisah biar bisa atur sendiri.',
    isDrink: false,
  ),
  FoodItem(
    id: 'fruit', name: 'Buah Potong', asset: 'assets/food/food-fruit.jpg',
    kcal: 95, desc: 'Aneka buah segar potong, manis alami.',
    ingredients: ['Pepaya', 'Melon', 'Nanas', 'Semangka'],
    tip: 'Makan buah utuh, bukan jus — seratnya kept.',
    isDrink: false,
  ),
  FoodItem(
    id: 'granola', name: 'Granola Yogurt', asset: 'assets/food/food-granola.jpg',
    kcal: 210, desc: 'Yogurt dengan granola renyah dan buah.',
    ingredients: ['Yogurt plain', 'Granola', 'Madu', 'Berry'],
    tip: 'Pilih yogurt plain tanpa gula tambahan.',
    isDrink: false,
  ),
  FoodItem(
    id: 'salmon', name: 'Salmon Panggang', asset: 'assets/food/food-salmon.jpg',
    kcal: 350, desc: 'Salmon panggang dengan sayuran, kaya omega-3.',
    ingredients: ['Salmon', 'Brokoli', 'Lemon', 'Lada hitam'],
    tip: 'Panggang, jangan goreng — hemat kalori.',
    isDrink: false,
  ),
  FoodItem(
    id: 'chicken', name: 'Ayam Bakar & Sayur', asset: 'assets/food/food-chicken.jpg',
    kcal: 290, desc: 'Ayam bakar tanpa kulit plus sayuran panggang.',
    ingredients: ['Dada ayam', 'Wortel', 'Buncis', 'Bawang putih'],
    tip: 'Buang kulit ayam sebelum makan.',
    isDrink: false,
  ),
];

const List<FoodItem> kDrinks = [
  FoodItem(
    id: 'matcha', name: 'Matcha Latte', asset: 'assets/food/drink-matcha.jpg',
    kcal: 120, desc: 'Matcha dengan susu rendah lemak.',
    ingredients: ['Bubuk matcha', 'Susu low-fat', 'Madu sedikit'],
    tip: 'Tanpa gula tambahan sudah enak.',
    isDrink: true,
  ),
  FoodItem(
    id: 'smoothie', name: 'Smoothie Hijau', asset: 'assets/food/drink-smoothie.jpg',
    kcal: 150, desc: 'Bayam, pisang, dan apel diblender halus.',
    ingredients: ['Bayam', 'Pisang', 'Apel', 'Air kelapa'],
    tip: 'Jangan saring — seratnya penting.',
    isDrink: true,
  ),
  FoodItem(
    id: 'juice', name: 'Jus Jeruk Murni', asset: 'assets/food/drink-juice.jpg',
    kcal: 90, desc: 'Perasan jeruk asli tanpa gula.',
    ingredients: ['Jeruk peras'],
    tip: 'Minum segera biar vitamin C tidak hilang.',
    isDrink: true,
  ),
  FoodItem(
    id: 'water', name: 'Air Mineral', asset: 'assets/food/drink-water.jpg',
    kcal: 5, desc: 'Minuman terbaik: nol gula, nol kalori.',
    ingredients: ['Air'],
    tip: 'Target 8 gelas sehari.',
    isDrink: true,
  ),
  FoodItem(
    id: 'tea', name: 'Teh Tawar Hangat', asset: 'assets/food/drink-tea.jpg',
    kcal: 2, desc: 'Teh hangat tanpa gula, menenangkan.',
    ingredients: ['Teh', 'Air panas'],
    tip: 'Minum 30 menit setelah makan.',
    isDrink: true,
  ),
  FoodItem(
    id: 'juices', name: 'Jus Buah Campur', asset: 'assets/food/drink-juices.jpg',
    kcal: 110, desc: 'Campuran buah segar warna-warni.',
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
