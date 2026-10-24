// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:simkeu/core/constants/api_constants.dart';
import 'package:simkeu/models/product_model.dart';

void main() {
  test('maps image path from product API to public Laravel URL', () {
    final product = ProductModel.fromJson({
      'id': 1,
      'name': 'Kopi Susu',
      'buy_price': '10000',
      'sell_price': '15000',
      'stock': 5,
      'unit': 'pcs',
      'image': 'products/kopi-susu.jpg',
    });

    expect(product.image, 'products/kopi-susu.jpg');
    expect(
      ApiConstants.productImageUrl(product.image),
      '${ApiConstants.serverUrl}/storage/products/kopi-susu.jpg',
    );
  });
}
