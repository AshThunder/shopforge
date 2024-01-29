import 'package:hooks_riverpod/hooks_riverpod.dart';

final recommendationsProvider = StateProvider<List>((ref) => []);
final newestsProvider = StateProvider<List>((ref) => []);
final ordersProvider = StateProvider<List>((ref) => []);
final wishlistsProvider = StateProvider<List>((ref) => []);
final categoryProvider = StateProvider<List>((ref) => []);
final cartProvider = StateProvider<List>((ref) => []);
final colorProvider = StateProvider<String>((ref) => 'light');
final accountProvider = StateProvider<Map>((ref) => {});
final userTokenProvider = StateProvider<String>((ref) => '');
final currencyProvider = StateProvider<String>((ref) => '\$');

final shippingMethodsProvider = StateProvider<List>((ref) => []);
final paymentMethodsProvider = StateProvider<List>((ref) => []);
final variationProvider = StateProvider<Map>((ref) => {});
final checkingOutProvider = StateProvider<bool>((ref) => false);
