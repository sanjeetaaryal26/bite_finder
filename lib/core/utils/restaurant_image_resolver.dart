import 'package:birdle/features/restaurant/data/models/restaurant_model.dart';

class RestaurantImageResolver {
  static const featuredAssets = [
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/01_yala_layeku_kitchen.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/02_sanju_restaurant_pokhara.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/03_everest_steak_house.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/04_fujiyama_japanese_restaurant.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/05_pokhara_takali_kitchen.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/06_yin_yang_restaurant_exterior.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/07_fewa_view_lodge_restaurant.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/08_highway_restaurant_gunadi.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/09_bhojan_griha_dinner_42.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/10_bhojan_griha_dinner_26.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/11_pokhara_typical_restaurant.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/12_lake_fewa_pokhara_restaurant_view.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/13_pokhara_street_food.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/14_momo_nepal.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/15_plateful_of_momo.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/16_nepali_momo.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/17_dal_bhat_tarkari_nepal.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/18_newari_food.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/19_traditional_newari_thali.jpg',
    'assets/images/nepal_restaurant_images_20/nepal_restaurant_images/20_nepali_dal_bhat_tarkari.jpg',
  ];

  static String imageForRestaurantId(String id) {
    if (featuredAssets.isEmpty) return '';
    final normalizedHash = id.hashCode & 0x7fffffff;
    return featuredAssets[normalizedHash % featuredAssets.length];
  }

  static String imageForRestaurant(RestaurantModel restaurant) {
    return imageForRestaurantId(restaurant.id);
  }

  static List<String> detailGalleryFor(RestaurantModel restaurant) {
    final featured = imageForRestaurant(restaurant);
    final photos = restaurant.photos.where((p) => p.trim().isNotEmpty).toList();
    if (featured.isEmpty) return photos;
    if (photos.contains(featured)) return photos;
    return [featured, ...photos];
  }
}
