// lib/providers/cart_provider.dart
// State management untuk keranjang belanja POS

import 'package:flutter/material.dart';
import '../models/product_model.dart';

// ── Model satu item di keranjang ──────────────────────
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.sellPrice * quantity;
}

class CartProvider extends ChangeNotifier {
  // Map productId → CartItem
  final Map<int, CartItem> _items = {};

  List<CartItem> get items     => _items.values.toList();
  bool           get isEmpty   => _items.isEmpty;
  int            get itemCount => _items.values.fold(0, (s, e) => s + e.quantity);

  // Total harga semua item
  double get total =>
      _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  int quantityOf(int productId) => _items[productId]?.quantity ?? 0;

  // ── Tambah produk ke keranjang ────────────────────────
  void addProduct(ProductModel product, {int quantity = 1}) {
    if (product.stock <= 0) return;
    if (_items.containsKey(product.id)) {
      final next = (_items[product.id]!.quantity + quantity)
          .clamp(1, product.stock);
      _items[product.id]!.quantity = next;
    } else {
      _items[product.id] = CartItem(
        product: product,
        quantity: quantity.clamp(1, product.stock),
      );
    }
    notifyListeners();
  }

  void setQuantity(int productId, int quantity) {
    if (!_items.containsKey(productId)) return;
    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      final stock = _items[productId]!.product.stock;
      _items[productId]!.quantity = quantity.clamp(1, stock);
    }
    notifyListeners();
  }

  // ── Kurangi qty satu item ─────────────────────────────
  void decreaseQuantity(int productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId]!.quantity--;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  // ── Naikkan qty satu item ─────────────────────────────
  void increaseQuantity(int productId) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      if (item.quantity < item.product.stock) {
        item.quantity++;
        notifyListeners();
      }
    }
  }

  // ── Hapus item dari keranjang ─────────────────────────
  void removeItem(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // ── Kosongkan seluruh keranjang ───────────────────────
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // ── Konversi ke format API untuk POST /api/sales ──────
  List<Map<String, dynamic>> toApiItems() => _items.values
      .map((e) => {
            'product_id' : e.product.id,
            'quantity'   : e.quantity,
            'price'      : e.product.sellPrice,
          })
      .toList();
}
